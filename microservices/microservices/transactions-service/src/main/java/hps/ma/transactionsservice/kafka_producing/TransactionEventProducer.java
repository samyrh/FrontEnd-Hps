package hps.ma.transactionsservice.kafka_producing;


import com.fasterxml.jackson.databind.ObjectMapper;
import hps.ma.transactionsservice.dao.enums.EventCategory;
import hps.ma.transactionsservice.dto.EventPayload;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class TransactionEventProducer {

    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    public void sendTransactionCreated(EventPayload payload) {
        payload.setCategory(EventCategory.NEW_TRANSACTION);
        sendToTopic("transaction.created.pending", payload);
    }

    private void sendToTopic(String topic, EventPayload payload) {
        try {
            String json = objectMapper.writeValueAsString(payload);
            kafkaTemplate.send(topic, json);
            System.out.println("✅ Event sent to Kafka: " + topic);
        } catch (Exception e) {
            System.err.println("❌ Kafka event send failed: " + e.getMessage());
        }
    }
}