package hps.ma.userservice.services;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import hps.ma.userservice.dao.entities.Cardholder;
import hps.ma.userservice.dao.enums.EventCategory;
import hps.ma.userservice.dao.enums.SenderType;
import hps.ma.userservice.dao.repositories.CardholderReository;
import hps.ma.userservice.dto.event.EventPayload;
import hps.ma.userservice.dto.user.CreateCardholderRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
@RequiredArgsConstructor
public class CardholderService {

    @Autowired
    private  CardholderReository cardholderRepository;
    @Autowired
    private  KafkaTemplate<String, String> kafkaTemplate;
    @Autowired
    private  ObjectMapper objectMapper;
    @Autowired
    private PasswordEncoder passwordEncoder;

    public void createCardholder(CreateCardholderRequest request, Long agentId) {
        Cardholder cardholder = new Cardholder();
        cardholder.setUsername(request.getUsername());
        cardholder.setEmail(request.getEmail());
        cardholder.setPassword(passwordEncoder.encode(request.getPassword()));
        cardholder.setFirstLogin(true);
        cardholder.setLocked(false);
        cardholder.setLoginAttempts(0);
        cardholderRepository.save(cardholder);

        // Produce Kafka event
        EventPayload event = EventPayload.builder()
                .message("New cardholder account created")
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.INFO)
                .senderAgentId(agentId)
                .recipientCardholderId(cardholder.getId())
                .cardId(null)
                .build();

        try {
            String json = objectMapper.writeValueAsString(event);
            kafkaTemplate.send("user.account.created", json);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize Kafka event", e);
        }
    }
}
