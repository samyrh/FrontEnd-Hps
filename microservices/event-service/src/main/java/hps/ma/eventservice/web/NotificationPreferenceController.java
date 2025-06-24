package hps.ma.eventservice.web;

import hps.ma.eventservice.dto.NotificationPreferencesDTO;
import hps.ma.eventservice.services.CardholderInfoService;
import hps.ma.eventservice.services.JwtUtil;
import hps.ma.eventservice.services.NotificationPreferenceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/notification-preferences")
@RequiredArgsConstructor
public class NotificationPreferenceController {

    private final NotificationPreferenceService preferenceService;
    private final JwtUtil jwtUtil;
    private final CardholderInfoService cardholderInfoService;

    @GetMapping
    public ResponseEntity<NotificationPreferencesDTO> getPreferences(
            @RequestHeader("Authorization") String token) {

        String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        return ResponseEntity.ok(preferenceService.getPreferences(cardholderId));
    }

    @PutMapping("/cardholder/update")
    public ResponseEntity<String> updatePreferences(
            @RequestHeader("Authorization") String token,
            @RequestBody NotificationPreferencesDTO dto) {

        String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        preferenceService.saveOrUpdatePreferences(cardholderId, dto);
        return ResponseEntity.ok("✅ Preferences updated.");
    }
}
