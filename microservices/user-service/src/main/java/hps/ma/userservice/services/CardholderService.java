package hps.ma.userservice.services;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import hps.ma.userservice.config.AESUtil;
import hps.ma.userservice.dao.entities.Cardholder;
import hps.ma.userservice.dao.enums.EventCategory;
import hps.ma.userservice.dao.enums.SenderType;
import hps.ma.userservice.dao.repositories.AgentRepository;
import hps.ma.userservice.dao.repositories.CardholderReository;
import hps.ma.userservice.dto.change_password.ChangePasswordRequest;
import hps.ma.userservice.dto.event.EventPayload;
import hps.ma.userservice.dto.user.CreateCardholderRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CardholderService {

    @Autowired
    private CardholderReository cardholderRepository;

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AgentRepository agentRepository;

    public void createCardholder(CreateCardholderRequest request, Long agentId) {
        Cardholder cardholder = new Cardholder();
        cardholder.setUsername(request.getUsername());
        cardholder.setEmail(request.getEmail());
        cardholder.setPassword(passwordEncoder.encode(request.getPassword())); // Store hashed
        cardholder.setFirstLogin(true);
        cardholder.setLocked(false);
        cardholder.setBiometricEnabled(true);
        cardholder.setLoginAttempts(0);
        cardholderRepository.save(cardholder);

        // 🛡 Encrypt the password for Kafka transmission (temporary use only)
        String encryptedPassword = AESUtil.encrypt(request.getPassword());

        EventPayload event = EventPayload.builder()
                .message("New cardholder account created")
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .senderId(agentId)
                .recipientId(cardholder.getId())
                .category(EventCategory.INFO)
                .cardId(null)
                .email(cardholder.getEmail())
                .username(cardholder.getUsername())
                .password(encryptedPassword)
                .build();

        try {
            String json = objectMapper.writeValueAsString(event);
            kafkaTemplate.send("user.account.created", json);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize Kafka event", e);
        }
    }
    public Long setSecurityCodeByUsername(String username, String rawCode) {
        Optional<Cardholder> optional = cardholderRepository.findByUsername(username);
        if (optional.isEmpty()) {
            System.out.println("❌ No cardholder found for username: " + username);
            throw new RuntimeException("Cardholder not found");
        }

        Cardholder cardholder = optional.get();
        cardholder.setSecurityCode(BCrypt.hashpw(rawCode, BCrypt.gensalt()));
        cardholder.setFirstLogin(false);
        cardholderRepository.save(cardholder);


        // ✅ Send Kafka event to all agents
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy 'at' HH:mm");

        agentRepository.findAll().forEach(agent -> {
            String formattedDate = dateFormat.format(new Date());

            EventPayload payload = EventPayload.builder()
                    .message("Cardholder *" + cardholder.getUsername() + "* successfully set up their security code on " + formattedDate + ".")
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.SECURITY)
                    .senderId(cardholder.getId())
                    .recipientId(agent.getId())
                    .build();

            try {
                kafkaTemplate.send("user.security.updated", objectMapper.writeValueAsString(payload));
            } catch (JsonProcessingException e) {
                throw new RuntimeException("❌ Failed to send Kafka event for agent ID " + agent.getId(), e);
            }
        });


        return cardholder.getId();
    }

    public void changePassword(String username, ChangePasswordRequest request) {
        Optional<Cardholder> optional = cardholderRepository.findByUsername(username);
        if (optional.isEmpty()) throw new RuntimeException("User not found");

        Cardholder cardholder = optional.get();

        // 🔐 Verify old password
        if (!passwordEncoder.matches(request.getOldPassword(), cardholder.getPassword())) {
            throw new RuntimeException("Current password is incorrect");
        }

        // ✅ Update password
        cardholder.setPassword(passwordEncoder.encode(request.getNewPassword()));
        cardholderRepository.save(cardholder);

        // 🔐 Encrypt new password
        String encryptedPassword = AESUtil.encrypt(request.getNewPassword());
        String formattedDate = new SimpleDateFormat("dd MMM yyyy 'at' HH:mm").format(new Date());

        // 🔁 Send event to Kafka (once, not per agent)
        EventPayload payload = EventPayload.builder()
                .message("Cardholder *" + cardholder.getUsername() + "* changed their password on " + formattedDate + ".")
                .sentAt(new Date())
                .senderType(SenderType.CARDHOLDER)
                .category(EventCategory.SECURITY)
                .senderId(cardholder.getId())
                .recipientId(cardholder.getId()) // Send to self (or keep as agent if needed)
                .username(cardholder.getUsername())
                .email(cardholder.getEmail())
                .password(encryptedPassword)
                .build();

        try {
            String json = objectMapper.writeValueAsString(payload);
            kafkaTemplate.send("user.security.updated", json);
            System.out.println("✅ Sent password change event for: " + cardholder.getEmail());
        } catch (JsonProcessingException e) {
            throw new RuntimeException("❌ Failed to send password change event", e);
        }
    }

    public void resetPasswordPublicly(String username, String newPassword) {
        Optional<Cardholder> optional = cardholderRepository.findByUsername(username);
        if (optional.isEmpty()) throw new RuntimeException("User not found");

        Cardholder cardholder = optional.get();

        // ✅ Update password
        cardholder.setPassword(passwordEncoder.encode(newPassword));
        cardholderRepository.save(cardholder);

        // 🔐 Encrypt password for Kafka
        String encryptedPassword = AESUtil.encrypt(newPassword);
        String formattedDate = new SimpleDateFormat("dd MMM yyyy 'at' HH:mm").format(new Date());

        // ✅ Send event once
        EventPayload payload = EventPayload.builder()
                .message("Cardholder *" + cardholder.getUsername() + "* reset their password on " + formattedDate + ".")
                .sentAt(new Date())
                .senderType(SenderType.CARDHOLDER)
                .category(EventCategory.SECURITY)
                .senderId(cardholder.getId())
                .recipientId(cardholder.getId()) // or use agentId if you want to notify agents only
                .username(cardholder.getUsername())
                .email(cardholder.getEmail())
                .password(encryptedPassword)
                .build();

        try {
            String json = objectMapper.writeValueAsString(payload);
            kafkaTemplate.send("user.security.updated", json);
            System.out.println("✅ Sent password reset event for: " + cardholder.getEmail());
        } catch (JsonProcessingException e) {
            throw new RuntimeException("❌ Failed to send password reset event", e);
        }
    }


}

