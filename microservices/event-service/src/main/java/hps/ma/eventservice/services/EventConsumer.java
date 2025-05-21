package hps.ma.eventservice.services;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import hps.ma.eventservice.dao.entity.Event;
import hps.ma.eventservice.dao.repository.EventRepository;
import hps.ma.eventservice.dto.EventPayload;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EventConsumer {

    private final ObjectMapper objectMapper;
    private final EventRepository eventRepository;

    @KafkaListener(topics = "user.account.created", groupId = "event-service")
    public void onCardholderCreated(String message) {
        System.out.println("📥 Received Kafka message: " + message);
        try {
            EventPayload payload = objectMapper.readValue(message, EventPayload.class);
            System.out.println("✅ Parsed payload: " + payload);

            Event event = Event.builder()
                    .message(payload.getMessage())
                    .sentAt(payload.getSentAt())
                    .senderType(payload.getSenderType())
                    .category(payload.getCategory())
                    .senderAgentId(payload.getSenderAgentId())
                    .recipientCardholderId(payload.getRecipientCardholderId())
                    .cardId(payload.getCardId())
                    .isRead(false)
                    .build();

            eventRepository.save(event);
            System.out.println("💾 Event saved to DB: " + event.getMessage());

        } catch (Exception e) {
            System.err.println("❌ Failed to process Kafka event: " + e.getMessage());
        }
    }

}
