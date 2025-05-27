package hps.ma.userservice.web;

import hps.ma.userservice.dao.entities.Cardholder;
import hps.ma.userservice.dao.repositories.CardholderReository;
import hps.ma.userservice.dto.user.CreateCardholderRequest;
import hps.ma.userservice.services.CardholderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/agents")
@RequiredArgsConstructor
public class AgentController {

    private final CardholderService cardholderService;
    private final CardholderReository cardholderReository;

    @PreAuthorize("hasRole('AGENT')")
    @PostMapping("/cardholders")
    public ResponseEntity<?> createCardholder(
            @RequestBody CreateCardholderRequest request,
            Principal principal // Agent authenticated via JWT
    ) {
        // Extract agent ID from token or DB
        Long agentId = extractAgentId(principal);
        cardholderService.createCardholder(request, agentId);
        return ResponseEntity.ok("Cardholder created.");
    }

    private Long extractAgentId(Principal principal) {
        // Implement based on your JWT logic (e.g., username → agentRepository.findByUsername)
        return 1L; // placeholder
    }


    @PreAuthorize("hasRole('AGENT')")
    @GetMapping("/cardholders/{username}/status")
    public ResponseEntity<?> getCardholderStatus(@PathVariable String username) {
        Optional<Cardholder> optional = cardholderReository.findByUsername(username);

        if (optional.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "User not found"));
        }

        Cardholder c = optional.get();
        Map<String, Object> status = Map.of(
                "isFirstLogin", c.isFirstLogin(),
                "isLocked", c.isLocked(),
                "loginAttempts", c.getLoginAttempts()
        );

        return ResponseEntity.ok(status);
    }


    @PreAuthorize("hasRole('AGENT')")
    @PatchMapping("/cardholders/{username}/unlock")
    public ResponseEntity<?> unlockCardholder(@PathVariable String username) {
        return cardholderReository.findByUsername(username)
                .map(cardholder -> {
                    cardholder.setLocked(false);
                    cardholder.setLoginAttempts(0);
                    cardholderReository.save(cardholder);
                    return ResponseEntity.ok("Cardholder unlocked.");
                })
                .orElseGet(() -> ResponseEntity.status(404).body("User not found"));
    }


}

