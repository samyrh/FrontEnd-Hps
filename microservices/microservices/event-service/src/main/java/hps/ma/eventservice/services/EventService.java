package hps.ma.eventservice.services;

import hps.ma.eventservice.dao.entity.Event;
import hps.ma.eventservice.dao.repository.EventRepository;
import hps.ma.eventservice.dto.AgentDto;
import hps.ma.eventservice.dto.AgentResponseDTO;
import hps.ma.eventservice.dto.EventResponseDTO;
import hps.ma.eventservice.dto.NotificationPreferencesDTO;
import hps.ma.eventservice.enums.EventCategory;
import hps.ma.eventservice.enums.SenderType;
import hps.ma.eventservice.feign_client.AgentService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;


@Slf4j
@Service
@RequiredArgsConstructor
public class EventService {

    private final EventRepository eventRepository;
    private final JwtUtil jwtUtil;
    private final CardholderInfoService cardholderInfoService;
    private final NotificationPreferenceService notificationPreferenceService;
    private final AgentService agentService;


    public List<EventResponseDTO> getEventsFromAgentForCardholder(String token) {
        String username = jwtUtil.extractUsername(token);
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        List<Event> agentEvents = eventRepository.findByRecipientIdAndSenderType(cardholderId, SenderType.AGENT);
        List<Event> systemEvents = eventRepository.findByRecipientIdAndSenderType(cardholderId, SenderType.SYSTEM);

        List<Event> events = new ArrayList<>();
        events.addAll(agentEvents);
        events.addAll(systemEvents);

        NotificationPreferencesDTO prefs = notificationPreferenceService.getPreferences(cardholderId);

        return events.stream()
                .filter(event -> {
                    EventCategory cat = event.getCategory();
                    return switch (cat) {
                        case VIRTUAL_CARD_BLOCKED, PHYSICAL_CARD_BLOCKED,
                             VIRTUAL_CARD_UNBLOCKED, PHYSICAL_CARD_UNBLOCKED ->
                                prefs.isCardStatusChanges();
                        case VIRTUAL_CARD_CANCELED, PHYSICAL_CARD_CANCELED,
                             VIRTUAL_CARD_REACTIVATED, PHYSICAL_CARD_REACTIVATED ->
                                prefs.isCardCancelReactivate();
                        case REQUEST_NEW_CARD_APPROVED, REQUEST_NEW_CARD_REJECTED ->
                                prefs.isNewCardRequest();
                        case REQUEST_REPLACEMENT_VIRTUAL_CARD,
                             REQUEST_REPLACEMENT_VIRTUAL_CARD_APPROVED,
                             REQUEST_REPLACEMENT_VIRTUAL_CARD_REJECTED,
                             REQUEST_REPLACEMENT_PHYSICAL_CARD,
                             REQUEST_REPLACEMENT_PHYSICAL_CARD_APPROVED,
                             REQUEST_REPLACEMENT_PHYSICAL_CARD_REJECTED ->
                                prefs.isCardReplacementRequest();
                        case TRAVEL_PLAN_APPROVED, TRAVEL_PLAN_REJECTED, TRAVEL_PLAN_EXPIRED ->
                                prefs.isTravelPlanStatus();
                        case TRANSACTION, NEW_TRANSACTION ->
                                prefs.isTransactionAlert();
                        default -> true;
                    };
                })
                .map(event -> EventResponseDTO.builder()
                        .id(event.getId())
                        .message(event.getMessage())
                        .sentAt(event.getSentAt())
                        .isRead(event.isRead())
                        .category(event.getCategory())
                        .senderType(event.getSenderType())
                        .senderId(event.getSenderId())
                        .recipientId(event.getRecipientId())
                        .cardId(event.getCardId())
                        .build())
                .toList();
    }

    public void markAllEventsAsReadForCardholder (Long cardholderId) {
        List<Event> unreadEvents = eventRepository.findByRecipientIdAndIsReadFalse(cardholderId);
        unreadEvents.forEach(event -> event.setRead(true));
        eventRepository.saveAll(unreadEvents);
    }
    public List<EventResponseDTO> getUnreadEventsForCardholder(Long cardholderId) {
        List<Event> unreadEvents = eventRepository.findByRecipientIdAndIsReadFalse(cardholderId);

        return unreadEvents.stream().map(event -> EventResponseDTO.builder()
                .id(event.getId())
                .message(event.getMessage())
                .sentAt(event.getSentAt())              // returns Date
                .senderType(event.getSenderType())
                .category(event.getCategory())
                .isRead(event.isRead())
                .senderId(event.getSenderId())
                .recipientId(event.getRecipientId())
                .cardId(event.getCardId())
                .build()
        ).toList();
    }
    public Long countUnreadEventsForCardholder(Long cardholderId) {
        return eventRepository.countByRecipientIdAndIsReadFalse(cardholderId);
    }
    @Transactional
    public void deleteEventForCardholder(String token, Long eventId) {
        // Extract username from token
        String username = jwtUtil.extractUsername(token);

        // Get the cardholder's ID
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        // Fetch event to ensure it exists and belongs to the cardholder
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new IllegalArgumentException("Event not found"));

        if (!event.getRecipientId().equals(cardholderId)) {
            throw new SecurityException("You are not authorized to delete this event");
        }

        eventRepository.delete(event);
    }

    public List<EventResponseDTO> getEventsFromCardholdersForAgent(String token) {
        log.info("Extracting username from token...");
        String username = jwtUtil.extractUsername(token);
        log.info("Username extracted: {}", username);

        AgentResponseDTO agent;
        try {
            log.info("Calling user-service to get agent details by username (no Authorization header)...");
            // Only pass username (no token header)
            agent = agentService.getAgentDetailsByUsername(username);
            log.info("Agent found: {}", agent);
        } catch (Exception e) {
            log.error("Failed to fetch agent by username: {}", e.getMessage(), e);
            throw new IllegalStateException("Unable to verify agent: " + e.getMessage());
        }

        if (agent == null || !agent.isActive()) {
            throw new IllegalStateException("Agent not found or inactive");
        }

        log.info("Fetching events with senderType=CARDHOLDER...");
        List<Event> events = eventRepository.findBySenderType(SenderType.CARDHOLDER);
        log.info("Found {} events", events.size());

        return events.stream()
                .map(event -> EventResponseDTO.builder()
                        .id(event.getId())
                        .message(event.getMessage())
                        .sentAt(event.getSentAt())
                        .isRead(event.isRead())
                        .category(event.getCategory())
                        .senderType(event.getSenderType())
                        .senderId(event.getSenderId())
                        .recipientId(event.getRecipientId())
                        .cardId(event.getCardId())
                        .build())
                .toList();
    }

}
