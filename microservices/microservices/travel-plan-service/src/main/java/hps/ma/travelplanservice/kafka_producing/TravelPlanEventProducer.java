package hps.ma.travelplanservice.kafka_producing;

import com.fasterxml.jackson.databind.ObjectMapper;

import hps.ma.travelplanservice.dao.entities.TravelPlan;
import hps.ma.travelplanservice.dao.enums.EventCategory;
import hps.ma.travelplanservice.dao.enums.SenderType;
import hps.ma.travelplanservice.dao.enums.TravelPlanStatus;
import hps.ma.travelplanservice.dto.CardResponseDTO;
import hps.ma.travelplanservice.dto.EventPayload;
import hps.ma.travelplanservice.feign_client.CardFeignClient;
import hps.ma.travelplanservice.feign_client.CardholderService;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class TravelPlanEventProducer {

    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;
    private final CardFeignClient cardFeignClient;
    private final CardholderService cardholderService;

    public void sendTravelPlanCreated(EventPayload payload) {
        sendToTopic("travel.plan.requested", payload);
    }

    public void sendTravelPlanUpdatedStatus(EventPayload payload) {
        sendToTopic("travel.plan.status", payload);
    }

    public void sendTravelPlanDetailsUpdated(EventPayload payload) {
        sendToTopic("travel.plan.updated", payload);
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