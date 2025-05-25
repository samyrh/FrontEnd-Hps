package hps.ma.eventservice.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import hps.ma.eventservice.batch.EmailBuffer;
import hps.ma.eventservice.dao.entity.Event;
import hps.ma.eventservice.dao.repository.EventRepository;
import hps.ma.eventservice.dto.EventPayload;
import lombok.RequiredArgsConstructor;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EventConsumer {

    private final ObjectMapper objectMapper;
    private final EventRepository eventRepository;
    private final EmailBuffer emailBuffer;

    // 🔵 Account Creation Event
    @KafkaListener(topics = "user.account.created", groupId = "event-service")
    public void onUserCreated(ConsumerRecord<String, String> record) {
        try {
            EventPayload payload = objectMapper.readValue(record.value(), EventPayload.class);
            storeEvent(payload);            // Save to DB
            handleAccountCreated(payload);  // Email logic
        } catch (Exception e) {
            System.err.println("❌ Failed to process account.created event: " + e.getMessage());
        }
    }

    // 🟡 Security Update Events (Password changed / reset)
    @KafkaListener(topics = "user.security.updated", groupId = "event-service")
    public void onSecurityEvent(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);
            storeEvent(payload);

            String message = payload.getMessage() != null ? payload.getMessage().toLowerCase() : "";

            if (message.contains("changed their password")) {
                handlePasswordChanged(payload);
            } else if (message.contains("reset their password")) {
                handlePasswordReset(payload);
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process security.updated event: " + e.getMessage());
        }
    }

    // 🏷️ Store any event in DB
    private void storeEvent(EventPayload payload) {
        Event event = Event.builder()
                .message(payload.getMessage())
                .sentAt(payload.getSentAt())
                .senderType(payload.getSenderType())
                .senderId(payload.getSenderId())
                .recipientId(payload.getRecipientId())
                .category(payload.getCategory())
                .cardId(payload.getCardId())
                .isRead(false)
                .build();

        eventRepository.save(event);
    }

    // 📩 Handle Account Creation
    private void handleAccountCreated(EventPayload payload) {
        if (payload.getEmail() != null && payload.getPassword() != null) {
            System.out.println("📬 Queued welcome email for: " + payload.getEmail());
            emailBuffer.add(payload);
        }
    }

    // 📬 Handle Password Change
    private void handlePasswordChanged(EventPayload payload) {
        if (payload.getEmail() != null && payload.getPassword() != null) {
            System.out.println("📬 Queued password change email for: " + payload.getEmail());
            emailBuffer.add(payload);
        }
    }

    // 📮 Handle Password Reset
    private void handlePasswordReset(EventPayload payload) {
        if (payload.getEmail() != null && payload.getPassword() != null) {
            System.out.println("📬 Queued password reset email for: " + payload.getEmail());
            emailBuffer.add(payload);
        }
    }
}
