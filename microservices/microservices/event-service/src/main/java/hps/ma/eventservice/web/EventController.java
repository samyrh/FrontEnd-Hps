package hps.ma.eventservice.web;

import hps.ma.eventservice.dto.EventResponseDTO;
import hps.ma.eventservice.feign_client.CardholderService;
import hps.ma.eventservice.services.CardholderInfoService;
import hps.ma.eventservice.services.EventService;
import hps.ma.eventservice.services.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/events")
@RequiredArgsConstructor
@CrossOrigin("*")
public class EventController {

    private final EventService eventService;
    private final JwtUtil jwtUtil;
    private final CardholderInfoService cardholderInfoService;

    @GetMapping("/cardholder")
    public ResponseEntity<List<EventResponseDTO>> getEventsForCardholderFromAgent(
            @RequestHeader("Authorization") String token) {

        // ✅ Delegate full logic to service (including token parsing)
        List<EventResponseDTO> events = eventService.getEventsFromAgentForCardholder(token);

        return ResponseEntity.ok(events);
    }


    @PutMapping("/cardholder/mark-all-read")
    public ResponseEntity<String> markAllAsRead(@RequestHeader("Authorization") String authHeader) {
        try {
            // Extract the token
            String token = authHeader.replace("Bearer ", "");

            // Extract username from JWT
            String username = jwtUtil.extractUsername(token);

            // Get cardholder ID using Feign client
            Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

            // Mark all unread events as read
            eventService.markAllEventsAsReadForCardholder(cardholderId);

            return ResponseEntity.ok("✅ All notifications marked as read.");
        } catch (Exception e) {
            return ResponseEntity
                    .status(500)
                    .body("❌ Failed to mark notifications as read: " + e.getMessage());
        }
    }

    @GetMapping("/cardholder/unread")
    public ResponseEntity<List<EventResponseDTO>> getUnreadEventsForCardholder(@RequestHeader("Authorization") String authHeader) {
        try {
            String token = authHeader.replace("Bearer ", "");
            String username = jwtUtil.extractUsername(token);
            Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

            List<EventResponseDTO> unreadEvents = eventService.getUnreadEventsForCardholder(cardholderId);
            return ResponseEntity.ok(unreadEvents);
        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }

    @GetMapping("/cardholder/unread/count")
    public ResponseEntity<Long> countUnreadEvents(@RequestHeader("Authorization") String authHeader) {
        try {
            String token = authHeader.replace("Bearer ", "");
            String username = jwtUtil.extractUsername(token);
            Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);
            Long unreadCount = eventService.countUnreadEventsForCardholder(cardholderId);
            return ResponseEntity.ok(unreadCount);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(0L);
        }
    }

    @DeleteMapping("/cardholder/delete/{eventId}")
    public ResponseEntity<String> deleteEventForCardholder(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable Long eventId) {

        try {
            String token = authHeader.replace("Bearer ", "");
            eventService.deleteEventForCardholder(token, eventId);
            return ResponseEntity.ok("✅ Event deleted successfully.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(404).body("❌ Event not found.");
        } catch (SecurityException e) {
            return ResponseEntity.status(403).body("❌ Unauthorized to delete this event.");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("❌ Failed to delete event: " + e.getMessage());
        }
    }

    @GetMapping("/agent/sent-by-cardholders")
    public ResponseEntity<List<EventResponseDTO>> getEventsSentByCardholders(
            @RequestHeader("Authorization") String authHeader) {
        try {
            // Extract token (remove "Bearer " prefix if needed)
            String token = authHeader.replace("Bearer ", "");

            // Delegate to service
            List<EventResponseDTO> events = eventService.getEventsFromCardholdersForAgent(token);

            return ResponseEntity.ok(events);
        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }

}