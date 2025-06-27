package hps.ma.eventservice.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import hps.ma.eventservice.batch.AESUtil;
import hps.ma.eventservice.batch.EmailBuffer;
import hps.ma.eventservice.dao.entity.Event;
import hps.ma.eventservice.dao.repository.EventRepository;
import hps.ma.eventservice.dto.EventPayload;
import hps.ma.eventservice.enums.EventCategory;
import hps.ma.eventservice.enums.SenderType;
import lombok.RequiredArgsConstructor;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
@RequiredArgsConstructor
public class EventConsumer {

    private final ObjectMapper objectMapper;
    private final EventRepository eventRepository;
    private final EmailBuffer emailBuffer;
    private final NotificationPreferenceService notificationPreferenceService;


    // 🔵 Account Creation Event
    @KafkaListener(topics = "user.account.created", groupId = "event-service")
    public void onUserCreated(ConsumerRecord<String, String> record) {
        try {
            EventPayload payload = objectMapper.readValue(record.value(), EventPayload.class);

            // Step 1: Store the event in DB
            storeEvent(payload);

            // Step 2: Create default notification preferences
            if (payload.getRecipientId() != null) {
                notificationPreferenceService.createDefaultPreferences(payload.getRecipientId());
                System.out.println("✅ Notification preferences created for cardholder ID: " + payload.getRecipientId());
            } else {
                System.err.println("⚠️ Missing recipientId for preference creation.");
            }

            // Step 3: Email or other logic (optional)
            handleAccountCreated(payload);

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

    // 🟠 Card Security Updated Events
    @KafkaListener(topics = "card.security.updated", groupId = "event-service")
    public void onCardSecurityUpdated(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // 🔄 Save the event in DB
            storeEvent(payload);

            // 🖨️ Log details
            System.out.println("🔔 Card security updated by Cardholder:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.security.updated event: " + e.getMessage());
        }
    }

    // 🔴 Card CVV Viewed Events - NO EMAIL SENT
    @KafkaListener(topics = "card.cvv.viewed", groupId = "event-service")
    public void onCardCVVViewed(String json) {
        try {
            // Deserialize the event payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save the event in DB
            storeEvent(payload);

            // 🖨️ Log event details
            System.out.println("🔔 Cardholder " + payload.getUsername() + " viewed CVV for card: " + payload.getCardId());

            // Handle logic based on category VIRTUAL_CARD_CVV_VIEWED (no email sending)
            if (payload.getCategory() == EventCategory.VIRTUAL_CARD_CVV_VIEWED) {
                System.out.println("📮 Event Category: VIRTUAL_CARD_CVV_VIEWED");

                // You can add any specific logic for this event type if needed
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.cvv.viewed event: " + e.getMessage());
        }
    }

    // 🟢 Card Request Created Events
    @KafkaListener(topics = "card.request.created", groupId = "event-service")
    public void onCardRequestCreated(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // 1. 🗂️ Save event to database
            storeEvent(payload);

            // 3. 🖨️ Log summary
            System.out.println("📌 New Card Request Event:");
            System.out.println("    → From: " + payload.getUsername());
            System.out.println("    → Type: " + payload.getSenderType());
            System.out.println("    → Message: " + payload.getMessage());

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.request.created event: " + e.getMessage());
        }
    }

    // 🟡 Card Virtual Card Limit Update Events - NO EMAIL SENT
    @KafkaListener(topics = "card.virtual.card.limit.updated", groupId = "event-service")
    public void onVirtualCardLimitUpdated(String json) {
        try {
            // Deserialize the event payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save the event in DB
            storeEvent(payload);

            // 🖨️ Log event details
            System.out.println("🔔 Virtual card limit updated by Cardholder:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → New Annual Limit: " + payload.getMessage());

            // Handle logic based on category VIRTUAL_CARD_LIMIT_UPDATED (no email sending)
            if (payload.getCategory() == EventCategory.VIRTUAL_CARD_LIMIT_UPDATED) {
                System.out.println("📮 Event Category: VIRTUAL_CARD_LIMIT_UPDATED");

                // You can add any specific logic for this event type if needed
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.virtual.card.limit.updated event: " + e.getMessage());
        }
    }
    // 🔒 Virtual Card Blocked Events - NO EMAIL SENT
    @KafkaListener(topics = "card.virtual.card.blocked", groupId = "event-service")
    public void onVirtualCardBlocked(String json) {
        try {
            // Deserialize the event payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save the event in DB
            storeEvent(payload);

            // 🖨️ Log event details
            System.out.println("🔔 Virtual card blocked:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Reason: " + payload.getMessage());

            if (payload.getCategory() == EventCategory.VIRTUAL_CARD_BLOCKED) {
                System.out.println("📮 Event Category: VIRTUAL_CARD_BLOCKED");
                // No email logic — only stored
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.virtual.card.blocked event: " + e.getMessage());
        }
    }
    // 🟣 Virtual Card Replacement Requested Events - NO EMAIL SENT
    @KafkaListener(topics = "virtual.card.replacement.request", groupId = "event-service")
    public void onVirtualCardReplacementRequested(String json) {
        try {
            // Deserialize the payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event to DB
            storeEvent(payload);

            // 🖨️ Log event summary
            System.out.println("🔔 Virtual card replacement requested:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.virtual.replacement.requested event: " + e.getMessage());
        }
    }


    // 🟤 Virtual Card Unblocked Events - NO EMAIL SENT
    @KafkaListener(topics = "virtual.card.unblocked", groupId = "event-service")
    public void onVirtualCardUnblocked(String json) {
        try {
            // Deserialize payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event to database
            storeEvent(payload);

            // 🖨️ Log event details
            System.out.println("🔔 Virtual card unblocked:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            if (payload.getCategory() == EventCategory.VIRTUAL_CARD_UNBLOCKED) {
                System.out.println("📮 Event Category: VIRTUAL_CARD_UNBLOCKED");
                // No email — only saved in DB
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.virtual.card.unblocked event: " + e.getMessage());
        }
    }


    // 🟤 Virtual Card Canceled Events
    @KafkaListener(topics = "card.virtual.canceled", groupId = "event-service")
    public void onVirtualCardCanceled(String json) {
        try {
            // Deserialize the payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event to DB
            storeEvent(payload);

            // 🖨️ Log event summary
            System.out.println("🔔 Virtual card canceled:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

        } catch (Exception e) {
            System.err.println("❌ Failed to process virtual.card.canceled event: " + e.getMessage());
        }
    }


    // 🔵 Travel Plan Created Event - NO EMAIL SENT
    @KafkaListener(topics = "travel.plan.requested", groupId = "event-service")
    public void onTravelPlanCreated(String json) {
        try {
            // Deserialize payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event in database
            storeEvent(payload);

            // Log details
            System.out.println("🔔 Travel Plan Created Event Received:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

        } catch (Exception e) {
            System.err.println("❌ Failed to process travel.plan.created event: " + e.getMessage());
        }
    }

    @KafkaListener(topics = "card.physical.pin.updated", groupId = "event-service")
    public void onPhysicalPinUpdated(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // ✅ Save to DB
            storeEvent(payload);

            // ✅ Log and add to email buffer
            System.out.println("📥 [Kafka] Received PIN update event: " + payload.getMessage());
            emailBuffer.add(payload);

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.physical.pin.updated event: " + e.getMessage());
            e.printStackTrace(); // Optional: print full stack trace
        }
    }

    @KafkaListener(topics = "card.cvv.requested", groupId = "event-service")
    public void onCvvRequested(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save to DB
            storeEvent(payload);

            System.out.println("📥 [Kafka] Received CVV request event: " + payload.getMessage());

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.cvv.requested event: " + e.getMessage());
        }
    }


    @KafkaListener(topics = "card.physical.limits.updated", groupId = "event-service")
    public void onPhysicalCardLimitsUpdated(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // 🔄 Save the event to the DB
            storeEvent(payload);

            // 🖨️ Log the update info
            System.out.println("🔔 Physical card limits updated:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            if (payload.getCategory() == EventCategory.PHYSICAL_CARD_LIMITS_UPDATED) {
                System.out.println("📮 Event Category: PHYSICAL_CARD_LIMITS_UPDATED");
                // No email needed
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.physical.limits.updated event: " + e.getMessage());
        }
    }



    @KafkaListener(topics = "card.physical.card.blocked", groupId = "event-service")
    public void onPhysicalCardBlocked(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save to DB
            storeEvent(payload);

            // Log details
            System.out.println("🔴 Physical card blocked:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Reason: " + payload.getMessage());

            if (payload.getCategory() == EventCategory.PHYSICAL_CARD_BLOCKED) {
                System.out.println("📮 Event Category: PHYSICAL_CARD_BLOCKED");
                // No email needed for this case
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.physical.card.blocked event: " + e.getMessage());
        }
    }

}
