package hps.ma.userservice.web;

import hps.ma.userservice.dto.user.CreateCardholderRequest;
import hps.ma.userservice.services.CardholderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;

@RestController
@RequestMapping("/api/agents")
@RequiredArgsConstructor
public class AgentController {

    private final CardholderService cardholderService;

    @PreAuthorize("hasRole('ROLE_AGENT')")
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
}

