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

import static org.apache.kafka.streams.kstream.EmitStrategy.log;

@Service
@RequiredArgsConstructor
public class EventConsumer {

    private final ObjectMapper objectMapper;
    private final EventRepository eventRepository;
    private final EmailBuffer emailBuffer;

    @KafkaListener(topics = "user.account.created", groupId = "event-service")
    public void onUserCreated(ConsumerRecord<String, String> record) {
        try {
            EventPayload payload = objectMapper.readValue(record.value(), EventPayload.class);

            // Store metadata only
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

            // Store credentials in memory (not DB)
            if (payload.getEmail() != null && payload.getPassword() != null) {
                emailBuffer.add(payload);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    @KafkaListener(topics = "user.security.updated",   groupId = "event-service")
    public void handleSecurityCodeSet(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            Event event = Event.builder()
                    .message(payload.getMessage())
                    .sentAt(payload.getSentAt())
                    .senderType(payload.getSenderType())
                    .category(payload.getCategory())
                    .senderId(payload.getSenderId())
                    .recipientId(payload.getRecipientId())  // one per agent
                    .cardId(payload.getCardId())           // optional
                    .isRead(false)
                    .build();

            eventRepository.save(event);
        } catch (Exception e) {
            log.error("❌ Failed to consume user.security.updated event", e);
        }
    }


    @KafkaListener(topics = "user.security.updated", groupId = "event-service")
    public void handleSecurityEvents(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Store event normally
            Event event = Event.builder()
                    .message(payload.getMessage())
                    .sentAt(payload.getSentAt())
                    .senderType(payload.getSenderType())
                    .category(payload.getCategory())
                    .senderId(payload.getSenderId())
                    .recipientId(payload.getRecipientId())
                    .cardId(payload.getCardId())
                    .isRead(false)
                    .build();

            eventRepository.save(event);

            // ✅ Custom handling: If it's a password change
            if (payload.getMessage() != null && payload.getMessage().toLowerCase().contains("changed their password")) {
                log.info("🔐 Password change event received for cardholder ID: " + payload.getSenderId());
                // You can also notify security team, audit log, etc. here
            }

        } catch (Exception e) {
            log.error("❌ Failed to consume user.security.updated event", e);
        }
    }

}
