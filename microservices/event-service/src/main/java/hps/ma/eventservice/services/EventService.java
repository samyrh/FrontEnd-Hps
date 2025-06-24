package hps.ma.eventservice.services;

import hps.ma.eventservice.dao.entity.Event;
import hps.ma.eventservice.dao.repository.EventRepository;
import hps.ma.eventservice.dto.EventResponseDTO;
import hps.ma.eventservice.dto.NotificationPreferencesDTO;
import hps.ma.eventservice.enums.EventCategory;
import hps.ma.eventservice.enums.SenderType;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;


@Service
@RequiredArgsConstructor
public class EventService {

    private final EventRepository eventRepository;
    private final JwtUtil jwtUtil;
    private final CardholderInfoService cardholderInfoService;
    // ✅ Add this line
    private final NotificationPreferenceService notificationPreferenceService;

    public List<EventResponseDTO> getEventsFromAgentForCardholder(String token) {
        String username = jwtUtil.extractUsername(token);
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);
        List<Event> events = eventRepository.findByRecipientIdAndSenderType(cardholderId, SenderType.AGENT);

        NotificationPreferencesDTO prefs = notificationPreferenceService.getPreferences(cardholderId); // ✅ correct

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
                        case TRANSACTION ->
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



}
