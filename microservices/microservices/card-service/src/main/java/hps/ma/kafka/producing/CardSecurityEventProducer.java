package hps.ma.kafka.producing;

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
    public void sendVirtualCardCanceled(EventPayload payload) {
        payload.setCategory(EventCategory.VIRTUAL_CARD_CANCELED);
        sendToTopic("card.virtual.canceled", payload);
    }
    public void sendPhysicalCardPinGenerated(EventPayload payload) {
        sendToTopic("agent.card.pin.generated", payload);
        System.out.println("✅ Event sent to topic 'card.physical.card.pin.generated' for cardId=" + payload.getCardId());
    }
    public void sendVirtualCardUnblockedByAgent(EventPayload payload) {
        payload.setCategory(EventCategory.VIRTUAL_CARD_UNBLOCKED);
        sendToTopic("virtual.card.unblocked.agent", payload);
    }

    public void sendCvvGeneratedByAgent(EventPayload payload) {
        payload.setCategory(EventCategory.CVV_GENERATED);
        sendToTopic("card.cvv.generated.by.agent", payload);
    }
    public void sendLimitsUpdatedAgent(EventPayload payload) {
        sendToTopic("card.limits.updated.agent", payload);
    }

    public void sendPhysicalCardUnblocked(EventPayload payload) {
        payload.setCategory(EventCategory.PHYSICAL_CARD_UNBLOCKED);
        sendToTopic("card.physical.unblocked", payload);
    }
    public void sendPhysicalCardUncanceledByAgent(EventPayload payload) {
        payload.setCategory(EventCategory.PHYSICAL_CARD_UNBLOCKED); // You can define a new enum if you prefer
        sendToTopic("agent.physical.card.uncanceled", payload);
    }
    public void sendVirtualCardBlockedByAgent(EventPayload payload) {
        payload.setCategory(EventCategory.VIRTUAL_CARD_BLOCKED);
        sendToTopic("agent.virtual.card.blocked", payload);
    }

    // ✅ NEW: Sends event when a virtual card is reactivated (uncanceled)
    public void sendVirtualCardReactivated(EventPayload payload) {
        payload.setCategory(EventCategory.VIRTUAL_CARD_REACTIVATED);
        sendToTopic("card.virtual.reactivated", payload);
    }

    public void sendPhysicalCardCanceled(EventPayload payload) {
        payload.setCategory(EventCategory.PHYSICAL_CARD_CANCELED);
        sendToTopic("card.physical.canceled", payload);
    }
    public void sendVirtualCardCanceledByAgent(EventPayload payload) {
        payload.setCategory(EventCategory.VIRTUAL_CARD_CANCELED);
        sendToTopic("agent.virtual.card.canceled", payload);
    }

    public void sendVirtualCardUncanceledByAgent(EventPayload payload) {
        payload.setCategory(EventCategory.VIRTUAL_CARD_UNCANCELED);
        sendToTopic("agent.virtual.card.uncanceled", payload);
    }

    // Sends event when a card request is created
    public void sendCardRequestCreated(EventPayload payload) {
        sendToTopic("card.request.created", payload);
    }
    public void sendAgentCardCreated(EventPayload payload) {
        payload.setCategory(EventCategory.CREATE_CARD);
        sendToTopic("agent.card.created", payload);
    }
    public void sendAgentCardApproved(EventPayload payload) {
        payload.setCategory(EventCategory.CREATE_CARD); // Or you can define a new EventCategory if you prefer, e.g., APPROVE_CARD
        sendToTopic("agent.card.approved", payload);
    }
    public void sendAgentCardRejected(EventPayload payload) {
        payload.setCategory(EventCategory.REJECT_CARD);
        sendToTopic("agent.card.rejected", payload);
    }

    public void sendVirtualCardReplacementRequest(EventPayload payload) {
        sendToTopic("virtual.card.replacement.request", payload);
    }
    public void sendVirtualCardUnblocked(EventPayload payload) {
        payload.setCategory(EventCategory.VIRTUAL_CARD_UNBLOCKED);
        sendToTopic("virtual.card.unblocked", payload);
    }

    public void sendPhysicalCardReplacementRequest(EventPayload payload) {
        payload.setCategory(EventCategory.REQUEST_REPLACEMENT_PHYSICAL_CARD);
        sendToTopic("physical.card.replacement.request", payload);
    }

    // Sends event when the CVV is viewed for a virtual card
    public void sendViewedCvv(EventPayload payload) {
        payload.setCategory(EventCategory.VIRTUAL_CARD_CVV_VIEWED);
        sendToTopic("card.cvv.viewed", payload);
    }

    // Sends event when the virtual card's annual limit is updated
    public void sendVirtualCardLimitUpdated(EventPayload payload) {
        payload.setCategory(EventCategory.VIRTUAL_CARD_LIMIT_UPDATED);
        sendToTopic("card.virtual.card.limit.updated", payload);
    }

    // ✅ NEW: Sends event when a virtual card is blocked
    public void sendVirtualCardBlocked(EventPayload payload) {
        payload.setCategory(EventCategory.VIRTUAL_CARD_BLOCKED);
        sendToTopic("card.virtual.card.blocked", payload);
    }
    public void sendPhysicalCardFeaturesUpdated(EventPayload payload) {
        payload.setCategory(EventCategory.PHYSICAL_CARD_FEATURES_UPDATED);
        sendToTopic("card.physical.features.updated", payload);
    }
    public void sendVirtualCardFeaturesUpdated(EventPayload payload) {
        payload.setCategory(EventCategory.VIRTUAL_CARD_FEATURES_UPDATED);
        sendToTopic("card.virtual.features.updated", payload);
    }

    // Sends event when PIN is updated for a physical card
    public void sendPinUpdated(EventPayload payload) {
        payload.setCategory(EventCategory.PIN_UPDATED);
        sendToTopic("card.physical.pin.updated", payload);
    }

    // Sends event when CVV is requested for any card
    public void sendCvvRequested(EventPayload payload) {
        payload.setCategory(EventCategory.CVV_REQUESTED);
        sendToTopic("card.cvv.requested", payload);
    }
    public void sendPhysicalCardLimitsUpdated(EventPayload payload) {
        payload.setCategory(EventCategory.PHYSICAL_CARD_LIMITS_UPDATED);
        sendToTopic("card.physical.limits.updated", payload);
    }
    public void sendPhysicalCardBlocked(EventPayload payload) {
        payload.setCategory(EventCategory.PHYSICAL_CARD_BLOCKED);
        sendToTopic("card.physical.card.blocked", payload);
    }
    public void sendPhysicalCardBlockedByAgent(EventPayload payload) {
        payload.setCategory(EventCategory.PHYSICAL_CARD_BLOCKED); // Keep the same category if you prefer
        sendToTopic("agent.physical.card.blocked", payload);
    }
    public void sendPhysicalCardUnblockedByAgent(EventPayload payload) {
        payload.setCategory(EventCategory.PHYSICAL_CARD_UNBLOCKED);
        sendToTopic("card.physical.unblocked.agent", payload);
    }
    public void sendPhysicalCardCanceledByAgent(EventPayload payload) {
        payload.setCategory(EventCategory.PHYSICAL_CARD_CANCELED); // or define a specific EventCategory if you prefer
        sendToTopic("agent.physical.card.canceled", payload);
    }

    // Internal shared method for Kafka publishing
    private void sendToTopic(String topic, EventPayload payload) {
        try {
            String json = objectMapper.writeValueAsString(payload);
            kafkaTemplate.send(topic, json);
            System.out.println("✅ Event sent to Kafka: " + topic);
        } catch (Exception e) {
            System.err.println("❌ Kafka event send failed to " + topic + ": " + e.getMessage());
        }
    }
}
