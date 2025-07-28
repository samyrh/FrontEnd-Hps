package hps.ma.eventservice.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import hps.ma.eventservice.batch.AESUtil;
import hps.ma.eventservice.batch.EmailBuffer;
import hps.ma.eventservice.batch.EmailService;
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
    private final EmailService emailService;


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
    @KafkaListener(topics = "physical.card.replacement.request", groupId = "event-service")
    public void onPhysicalCardReplacementRequested(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // ✅ Save event in DB
            storeEvent(payload);

            // 🖨️ Log event details
            System.out.println("🔔 Physical card replacement requested:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            if (payload.getCategory() == EventCategory.REQUEST_REPLACEMENT_PHYSICAL_CARD) {
                System.out.println("📮 Event Category: REQUEST_REPLACEMENT_PHYSICAL_CARD");
                // No email logic — only storing
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process physical.card.replacement.request event: " + e.getMessage());
        }
    }


    @KafkaListener(topics = "card.physical.unblocked", groupId = "event-service")
    public void onPhysicalCardUnblocked(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Store in DB
            storeEvent(payload);

            // Log details
            System.out.println("🟢 Physical card unblocked:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            if (payload.getCategory() == EventCategory.PHYSICAL_CARD_UNBLOCKED) {
                System.out.println("📮 Event Category: PHYSICAL_CARD_UNBLOCKED");
                // No email—only store event
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.physical.unblocked event: " + e.getMessage());
        }
    }


    @KafkaListener(topics = "card.physical.canceled", groupId = "event-service")
    public void onPhysicalCardCanceled(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event to DB
            storeEvent(payload);

            // Log details
            System.out.println("🔴 Physical card canceled:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            if (payload.getCategory() == EventCategory.PHYSICAL_CARD_CANCELED) {
                System.out.println("📮 Event Category: PHYSICAL_CARD_CANCELED");
                // No email needed—only store the event
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.physical.canceled event: " + e.getMessage());
        }
    }


    @KafkaListener(topics = "transaction.created.pending", groupId = "event-service")
    public void onTransactionCreated(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // 1️⃣ Save event to DB
            storeEvent(payload);

            // 2️⃣ Log summary
            System.out.println("💸 New transaction event received:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            // 3️⃣ Queue email notification
            if (payload.getEmail() != null) {
                emailBuffer.add(payload);
                System.out.println("📬 Transaction email queued for: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process transaction.created event: " + e.getMessage());
        }
    }


    // 🔴 Account Suspended Events
    @KafkaListener(topics = "user.account.suspended", groupId = "event-service")
    public void onAccountSuspended(String json) {
        try {
            // Deserialize the payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // 🗂 Save the event in DB
            storeEvent(payload);

            // 🖨️ Log details
            System.out.println("🔴 Account suspended for user: " + payload.getUsername());
            System.out.println("    → Reason: " + payload.getMessage());

            // 📩 Send notification email
            if (payload.getEmail() != null) {
                emailService.sendAccountSuspendedEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ Suspension email sent to: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process account.suspended event: " + e.getMessage());
            e.printStackTrace();
        }
    }



    // 🟢 Account Unsuspended Events
    @KafkaListener(topics = "user.account.status", groupId = "event-service")
    public void onAccountUnsuspended(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event to DB
            storeEvent(payload);

            // Log details
            System.out.println("🟢 Account unsuspended for user: " + payload.getUsername());

            // Send email
            if (payload.getEmail() != null) {
                emailService.sendAccountUnsuspendedEmail(
                        payload.getEmail(),
                        payload.getUsername()
                );
                System.out.println("✅ Unsuspension email sent to: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process account.unsuspended event: " + e.getMessage());
            e.printStackTrace();
        }
    }


    // 🟢 Travel Plan Approved Events
    @KafkaListener(topics = "travel.plan.status", groupId = "event-service")
    public void onTravelPlanApproved(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Store event in DB
            storeEvent(payload);

            // Log details
            System.out.println("✅ Travel plan APPROVED event received:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

        } catch (Exception e) {
            System.err.println("❌ Failed to process travel.plan.approved event: " + e.getMessage());
        }
    }

    // 🔴 Travel Plan Rejected Events
    @KafkaListener(topics = "travel.plan.rejected", groupId = "event-service")
    public void onTravelPlanRejected(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Store event in DB
            storeEvent(payload);

            // Log details
            System.out.println("🔴 Travel plan REJECTED event received:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

        } catch (Exception e) {
            System.err.println("❌ Failed to process travel.plan.rejected event: " + e.getMessage());
        }
    }


    // 🟣 Travel Plan Details Updated Events - NO EMAIL SENT
    @KafkaListener(topics = "travel.plan.updated", groupId = "event-service")
    public void onTravelPlanDetailsUpdated(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event in DB
            storeEvent(payload);

            // Log details
            System.out.println("🟣 Travel Plan Details Updated Event received:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

        } catch (Exception e) {
            System.err.println("❌ Failed to process travel.plan.updated.details event: " + e.getMessage());
            e.printStackTrace();
        }
    }
    // 🟢 Agent-Created Card Events
    @KafkaListener(topics = "agent.card.created", groupId = "event-service")
    public void onAgentCardCreated(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event to DB
            storeEvent(payload);

            // Log details
            System.out.println("🟢 Agent-created card event for cardholder: " + payload.getUsername());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            // Send email
            if (payload.getEmail() != null) {
                emailService.sendAgentCardCreatedEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ Agent-created card email sent to: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process agent.card.created event: " + e.getMessage());
            e.printStackTrace();
        }
    }
    // 🟢 Agent-Approved Card Events
    @KafkaListener(topics = "agent.card.approved", groupId = "event-service")
    public void onAgentCardApproved(String json) {
        try {
            // Deserialize the payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event in DB
            storeEvent(payload);

            // Log details
            System.out.println("🟢 Agent-approved card event for cardholder: " + payload.getUsername());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            // Optionally, send an email to the cardholder
            if (payload.getEmail() != null) {
                emailService.sendAgentCardApprovedEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ Approval email sent to: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process agent.card.approved event: " + e.getMessage());
            e.printStackTrace();
        }
    }
    // 🔴 Agent-Rejected Card Events
    @KafkaListener(topics = "agent.card.rejected", groupId = "event-service")
    public void onAgentCardRejected(String json) {
        try {
            // Deserialize the payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event in DB
            storeEvent(payload);

            // Log details
            System.out.println("🔴 Agent-rejected card event for cardholder: " + payload.getUsername());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            // Optionally, send an email to the cardholder
            if (payload.getEmail() != null) {
                emailService.sendAgentCardRejectedEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ Rejection email sent to: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process agent.card.rejected event: " + e.getMessage());
            e.printStackTrace();
        }
    }
    // 🟥 Agent-Blocked Physical Card Events
    @KafkaListener(topics = "agent.physical.card.blocked", groupId = "event-service")
    public void onAgentPhysicalCardBlocked(String json) {
        try {
            // Deserialize the payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event in DB
            storeEvent(payload);

            // Log details
            System.out.println("🟥 Agent blocked a PHYSICAL card permanently for cardholder: " + payload.getUsername());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());


        if (payload.getEmail() != null) {
            emailService.sendAgentPhysicalCardBlockedEmail(
                payload.getEmail(),
                payload.getUsername(),
                payload.getMessage()
            );
            System.out.println("✅ Agent card blocked email sent to: " + payload.getEmail());
        }


        } catch (Exception e) {
            System.err.println("❌ Failed to process agent.physical.card.blocked event: " + e.getMessage());
            e.printStackTrace();
        }
    }
    // 🟢 Agent-Unblocked Physical Card Events
    @KafkaListener(topics = "card.physical.unblocked.agent", groupId = "event-service")
    public void onAgentPhysicalCardUnblocked(String json) {
        try {
            // Deserialize the payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event in DB
            storeEvent(payload);

            // Log details
            System.out.println("🟢 Agent unblocked a PHYSICAL card for cardholder: " + payload.getUsername());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            // Send notification email to the cardholder
            if (payload.getEmail() != null) {
                emailService.sendAgentPhysicalCardUnblockedEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ Agent card unblocked email sent to: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process agent.physical.card.unblocked event: " + e.getMessage());
            e.printStackTrace();
        }
    }
    // 🟥 Agent-Canceled Physical Card Events
    @KafkaListener(topics = "agent.physical.card.canceled", groupId = "event-service")
    public void onAgentPhysicalCardCanceled(String json) {
        try {
            // Deserialize the payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event in DB
            storeEvent(payload);

            // Log details
            System.out.println("🟥 Agent canceled a PHYSICAL card for cardholder: " + payload.getUsername());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            // Optionally send notification email
            if (payload.getEmail() != null) {
                emailService.sendAgentPhysicalCardCanceledEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ Agent card cancellation email sent to: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process agent.physical.card.canceled event: " + e.getMessage());
            e.printStackTrace();
        }
    }
    // 🟢 Agent-Uncanceled Physical Card Events
    @KafkaListener(topics = "agent.physical.card.uncanceled", groupId = "event-service")
    public void onAgentPhysicalCardUncanceled(String json) {
        try {
            // Deserialize the payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event to DB
            storeEvent(payload);

            // Log details
            System.out.println("🟢 Agent uncanceled a PHYSICAL card for cardholder: " + payload.getUsername());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            // Optionally send email to the cardholder
            if (payload.getEmail() != null) {
                emailService.sendAgentPhysicalCardUncanceledEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ Agent card uncanceled email sent to: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process agent.physical.card.uncanceled event: " + e.getMessage());
            e.printStackTrace();
        }
    }
    // 🟢 Physical Card PIN Generated Events
    @KafkaListener(topics = "agent.card.pin.generated", groupId = "event-service")
    public void onPhysicalCardPinGenerated(String json) {
        try {
            // Deserialize the payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event to DB
            storeEvent(payload);

            // Log event details
            System.out.println("🟢 Physical card PIN generated:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            // Optionally send email to the cardholder
            if (payload.getEmail() != null) {
                emailService.sendAgentPhysicalCardPinGeneratedEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ Agent card uncanceled email sent to: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.physical.card.pin.generated event: " + e.getMessage());
            e.printStackTrace();
        }
    }
    // 🟢 Agent-Generated CVV Events
    @KafkaListener(topics = "card.cvv.generated.by.agent", groupId = "event-service")
    public void onCvvGeneratedByAgent(String json) {
        try {
            // 1️⃣ Deserialize the payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // 2️⃣ Save event to DB
            storeEvent(payload);

            // 3️⃣ Log event details
            System.out.println("🟢 Agent generated a new CVV for cardholder: " + payload.getUsername());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            // 4️⃣ Optionally send email
            if (payload.getEmail() != null) {
                emailService.sendAgentCvvGeneratedEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ Agent CVV generation email sent to: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.cvv.generated.by.agent event: " + e.getMessage());
            e.printStackTrace();
        }
    }



    // 🟢 Physical Card Features Updated Events - NO EMAIL SENT
    @KafkaListener(topics = "card.physical.features.updated", groupId = "event-service")
    public void onPhysicalCardFeaturesUpdated(String json) {
        try {
            // 1️⃣ Deserialize the payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // 2️⃣ Save the event to the DB
            storeEvent(payload);

            // 3️⃣ Log event details
            System.out.println("🟢 Physical card FEATURES updated:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            if (payload.getCategory() == EventCategory.PHYSICAL_CARD_FEATURES_UPDATED) {
                System.out.println("📮 Event Category: PHYSICAL_CARD_FEATURES_UPDATED");
                // No email logic here—only store and log
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.physical.features.updated event: " + e.getMessage());
            e.printStackTrace();
        }
    }
    // 🟣 Limits Updated by Agent Events - NO EMAIL SENT
    @KafkaListener(topics = "card.limits.updated.agent", groupId = "event-service")
    public void onLimitsUpdatedByAgent(String json) {
        try {
            // 1️⃣ Deserialize payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // 2️⃣ Store the event in DB
            storeEvent(payload);

            // 3️⃣ Log details
            System.out.println("🟣 Limits updated by agent for cardholder: " + payload.getUsername());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            if (payload.getCategory() != null) {
                System.out.println("📮 Event Category: " + payload.getCategory());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.limits.updated.agent event: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // 🟢 Virtual Card Unblocked by Agent Events
    @KafkaListener(topics = "virtual.card.unblocked.agent", groupId = "event-service")
    public void onAgentVirtualCardUnblocked(String json) {
        try {
            // Deserialize payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Store event in DB
            storeEvent(payload);

            // Log event details
            System.out.println("🟢 Agent unblocked a VIRTUAL card for cardholder: " + payload.getUsername());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            // Optionally send email
            if (payload.getEmail() != null) {
                emailService.sendAgentVirtualCardUnblockedEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ Agent virtual card unblocked email sent to: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process virtual.card.unblocked.by.agent event: " + e.getMessage());
            e.printStackTrace();
        }
    }



    // 🟥 Agent-Blocked Virtual Card Events
    @KafkaListener(topics = "agent.virtual.card.blocked", groupId = "event-service")
    public void onAgentVirtualCardBlocked(String json) {
        try {
            // Deserialize the payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event to DB
            storeEvent(payload);

            // Log details
            System.out.println("🟥 Agent blocked a VIRTUAL card permanently for cardholder: " + payload.getUsername());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            // Optionally send notification email
            if (payload.getEmail() != null) {
                emailService.sendAgentVirtualCardBlockedEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ Agent virtual card blocked email sent to: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process agent.virtual.card.blocked event: " + e.getMessage());
            e.printStackTrace();
        }
    }
    // 🟥 Agent-Canceled Virtual Card Events
    @KafkaListener(topics = "agent.virtual.card.canceled", groupId = "event-service")
    public void onAgentVirtualCardCanceled(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event to DB
            storeEvent(payload);

            // Log details
            System.out.println("🟥 Agent canceled a VIRTUAL card for cardholder: " + payload.getUsername());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            // Optionally send email to the cardholder
            if (payload.getEmail() != null) {
                emailService.sendAgentVirtualCardCanceledEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ Agent virtual card canceled email sent to: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process agent.virtual.card.canceled event: " + e.getMessage());
            e.printStackTrace();
        }
    }


    // 🟢 Agent-Uncanceled Virtual Card Events
    @KafkaListener(topics = "agent.virtual.card.uncanceled", groupId = "event-service")
    public void onAgentVirtualCardUncanceled(String json) {
        try {
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // Save event to DB
            storeEvent(payload);

            // Log details
            System.out.println("🟢 Agent uncanceled a VIRTUAL card for cardholder: " + payload.getUsername());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            // Optionally send email to the cardholder
            if (payload.getEmail() != null) {
                emailService.sendAgentVirtualCardUncanceledEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ Agent virtual card uncanceled email sent to: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process agent.virtual.card.uncanceled event: " + e.getMessage());
            e.printStackTrace();
        }
    }
    // 🟢 Virtual Card Features Updated Events - EMAIL SENT
    @KafkaListener(topics = "card.virtual.features.updated", groupId = "event-service")
    public void onVirtualCardFeaturesUpdated(String json) {
        try {
            // 1️⃣ Deserialize payload
            EventPayload payload = objectMapper.readValue(json, EventPayload.class);

            // 2️⃣ Store event in DB
            storeEvent(payload);

            // 3️⃣ Log details
            System.out.println("🟢 Virtual card FEATURES updated:");
            System.out.println("    → Username: " + payload.getUsername());
            System.out.println("    → Email: " + payload.getEmail());
            System.out.println("    → Card ID: " + payload.getCardId());
            System.out.println("    → Message: " + payload.getMessage());

            if (payload.getCategory() == EventCategory.VIRTUAL_CARD_FEATURES_UPDATED) {
                System.out.println("📮 Event Category: VIRTUAL_CARD_FEATURES_UPDATED");
            }

            // 4️⃣ Send notification email
            if (payload.getEmail() != null) {
                emailService.sendAgentVirtualCardFeaturesUpdatedEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ Virtual card features update email sent to: " + payload.getEmail());
            }

        } catch (Exception e) {
            System.err.println("❌ Failed to process card.virtual.features.updated event: " + e.getMessage());
            e.printStackTrace();
        }
    }

}
