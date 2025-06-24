package hps.ma.travelplanservice.kafka_producing;

import com.fasterxml.jackson.databind.ObjectMapper;

import hps.ma.travelplanservice.dto.EventPayload;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class TravelPlanEventProducer {

    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    public void sendTravelPlanCreated(EventPayload payload) {
        sendToTopic("travel.plan.requested", payload);
    }

    private void sendToTopic(String topic, EventPayload payload) {
        try {
            String json = objectMapper.writeValueAsString(payload);
            kafkaTemplate.send(topic, json);
            System.out.println("✅ Travel plan event sent to Kafka: " + topic);
        } catch (Exception e) {
            System.err.println("❌ Failed to send travel plan event to Kafka: " + e.getMessage());
        }
    }
}