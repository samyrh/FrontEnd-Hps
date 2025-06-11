
import com.fasterxml.jackson.databind.ObjectMapper;
import hps.ma.dao.enums.EventCategory;
import hps.ma.dto.EventPayload;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CardSecurityEventProducer {

    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    // Sends event when card security is updated (e.g., card options like contactless, TPE)
    public void send(EventPayload payload) {
        sendToTopic("card.security.updated", payload);
    }

    // Sends event when a card request is created
    public void sendCardRequestCreated(EventPayload payload) {
        sendToTopic("card.request.created", payload);
    }

    // Sends event when the CVV is viewed for a virtual card
    public void sendVirtualCardCvvViewed(EventPayload payload) {
        // Set the category to 'VIRTUAL_CARD_CVV_VIEWED' instead of 'SECURITY'
        payload.setCategory(EventCategory.VIRTUAL_CARD_CVV_VIEWED);  // Change category here
        sendToTopic("card.cvv.viewed", payload);  // Send to Kafka topic
    }

    // Sends event when the virtual card's annual limit is updated
    public void sendVirtualCardLimitUpdated(EventPayload payload) {
        payload.setCategory(EventCategory.VIRTUAL_CARD_LIMIT_UPDATED);  // Change category here
        sendToTopic("card.virtual.card.limit.updated", payload);  // New topic for virtual card limit updates
    }

    // Helper method to send events to Kafka topic
    private void sendToTopic(String topic, EventPayload payload) {
        try {
            // Convert the payload to JSON
            String json = objectMapper.writeValueAsString(payload);
            // Send the event to the specified Kafka topic
            kafkaTemplate.send(topic, json);
            System.out.println("✅ Event sent to Kafka: " + topic);
        } catch (Exception e) {
            // Handle any exception that occurs during the process
            System.err.println("❌ Kafka event send failed to " + topic + ": " + e.getMessage());
        }
    }
}
