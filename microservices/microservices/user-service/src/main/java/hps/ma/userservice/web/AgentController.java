package hps.ma.userservice.web;

import hps.ma.userservice.dao.entities.Agent;
import hps.ma.userservice.dao.entities.Cardholder;
import hps.ma.userservice.dao.repositories.AgentRepository;
import hps.ma.userservice.dao.repositories.CardholderReository;
import hps.ma.userservice.dto.user.AgentResponseDTO;
import hps.ma.userservice.dto.user.CardholderResponseDTO;
import hps.ma.userservice.dto.user.CreateCardholderRequest;
import hps.ma.userservice.services.CardholderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/agents")
@RequiredArgsConstructor
@CrossOrigin("*")
public class AgentController {

    private final CardholderService cardholderService;
    private final CardholderReository cardholderReository;
    private final AgentRepository agentRepository;

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

    @GetMapping
    public ResponseEntity<List<Agent>> getAllAgents() {
        List<Agent> agents = agentRepository.findAll();
        return ResponseEntity.ok(agents);
    }

    @PreAuthorize("hasRole('AGENT')")
    @GetMapping("/cardholders")
    public ResponseEntity<List<CardholderResponseDTO>> getAllCardholders() {
        List<Cardholder> cardholders = cardholderReository.findAll();

        List<CardholderResponseDTO> dtos = cardholders.stream()
                .map(c -> CardholderResponseDTO.builder()
                        .id(c.getId())
                        .username(c.getUsername())
                        .email(c.getEmail())
                        .locked(c.isLocked())
                        .firstLogin(c.isFirstLogin())
                        .loginAttempts(c.getLoginAttempts())
                        .biometricEnabled(c.isBiometricEnabled())
                        .build())
                .toList();

        return ResponseEntity.ok(dtos);
    }


    @PreAuthorize("hasRole('AGENT')")
    @PatchMapping("/cardholders/{cardholderId}/suspend")
    public ResponseEntity<?> suspendCardholderById(
            @PathVariable Long cardholderId,
            Principal principal
    ) {
        // Extract the authenticated agent ID from the JWT principal
        Long agentId = extractAgentId(principal);
        cardholderService.suspendCardholderById(agentId, cardholderId);
        return ResponseEntity.ok("✅ Cardholder account suspended and notification sent.");
    }


    @PreAuthorize("hasRole('AGENT')")
    @PatchMapping("/cardholders/{id}/unsuspend")
    public ResponseEntity<?> unSuspendCardholder(
            @PathVariable Long id,
            Principal principal
    ) {
        Long agentId = extractAgentId(principal);
        cardholderService.unSuspendCardholder(id, agentId);
        return ResponseEntity.ok("Cardholder account has been reactivated.");
    }
    @GetMapping("/internal/by-username/{username}")
    public ResponseEntity<?> getAgentDetailsByUsername(@PathVariable String username) {
        return agentRepository.findByUsername(username)
                .<ResponseEntity<?>>map(agent -> {
                    AgentResponseDTO dto = AgentResponseDTO.builder()
                            .id(agent.getId())
                            .username(agent.getUsername())
                            .email(agent.getEmail())
                            .isAdmin(agent.isAdmin())
                            .isActive(agent.isActive())
                            .build();
                    return ResponseEntity.ok(dto);
                })
                .orElse(ResponseEntity.status(404).body(Map.of("error", "Agent not found")));
    }

}

