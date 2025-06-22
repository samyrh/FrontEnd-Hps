package hps.ma.travelplanservice.web;


import hps.ma.travelplanservice.dao.entities.TravelPlan;
import hps.ma.travelplanservice.dto.TravelPlanRequest;
import hps.ma.travelplanservice.dto.TravelPlanResponse;
import hps.ma.travelplanservice.service.TravelPlanService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;


@RestController
@RequestMapping("/api/travel-plans")
@RequiredArgsConstructor
public class TravelPlanController {

    private final TravelPlanService travelPlanService;

    @PostMapping("/cardholder/create/{cardId}")
    public ResponseEntity<?> createTravelPlanBYCardholder(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId,
            @RequestBody TravelPlanRequest request) {

        try {
            travelPlanService.createTravelPlanByCardholder(token, cardId, request);
            return ResponseEntity.ok("✅ Travel plan successfully created.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("❌ " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("❌ Server error: " + e.getMessage());
        }
    }


    // ✅ Reset Travel Plan & Card Link (Admin or Agent)
    @DeleteMapping("/reset/{cardId}")
    public ResponseEntity<?> resetTravelPlanAndCard(@PathVariable Long cardId) {
        try {
            travelPlanService.resetTravelPlanAndCard(cardId);
            return ResponseEntity.ok("✅ Travel plan reset successfully for card ID: " + cardId);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("❌ Failed to reset travel plan: " + e.getMessage());
        }
    }


    @GetMapping("/card/{cardId}")
    public ResponseEntity<?> getTravelPlanByCardId(@PathVariable Long cardId) {
        try {
            Optional<TravelPlan> response = travelPlanService.getTravelPlanByCardId(cardId);
            return ResponseEntity.ok(response);
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("❌ No travel plan for this card.");
        }
    }

}