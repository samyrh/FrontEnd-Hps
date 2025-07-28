package hps.ma.travelplanservice.web;


import hps.ma.travelplanservice.dao.entities.TravelPlan;
import hps.ma.travelplanservice.dao.enums.TravelPlanStatus;
import hps.ma.travelplanservice.dto.TravelPlanCard;
import hps.ma.travelplanservice.dto.TravelPlanRequest;
import hps.ma.travelplanservice.dto.TravelPlanResponse;
import hps.ma.travelplanservice.dto.TravelPlanUpdateRequest;
import hps.ma.travelplanservice.service.TravelPlanService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;


@RestController
@RequestMapping("/api/travel-plans")
@RequiredArgsConstructor
@CrossOrigin("*")
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

    @GetMapping("/cardholder/{cardholderId}/count")
    public ResponseEntity<?> countTravelPlansByCardholder(@PathVariable Long cardholderId) {
        try {
            long count = travelPlanService.countTravelPlansByCardholder(cardholderId);
            return ResponseEntity.ok(Map.of(
                    "cardholderId", cardholderId,
                    "travelPlanCount", count
            ));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("❌ Error: " + e.getMessage());
        }
    }
    @GetMapping("/internal/card/{cardId}")
    public ResponseEntity<?> getTravelPlanDetailsByCardId(@PathVariable Long cardId) {
        Optional<TravelPlan> optional = travelPlanService.getTravelPlanByCardId(cardId);
        if (optional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("❌ No travel plan for this card.");
        }

        TravelPlan t = optional.get();
        TravelPlanCard dto = TravelPlanCard.builder()
                .id(t.getId())
                .startDate(t.getStartDate())
                .endDate(t.getEndDate())
                .countries(t.getCountries())
                .status(t.getStatus())
                .travelLimit(t.getTravelLimit())
                .maxDays(t.getMaxDays())
                .cardId(t.getCardId())
                .approverId(t.getApproverId())
                .build();

        return ResponseEntity.ok(dto);
    }
    @PutMapping("/agent/update-details/{cardId}")
    public ResponseEntity<?> updateTravelPlanDetails(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId,
            @RequestBody TravelPlanUpdateRequest request
    ) {
        try {
            travelPlanService.updateTravelPlanDetails(token, cardId, request);
            return ResponseEntity.ok(Map.of("message", "Travel plan details updated successfully."));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }


    @PutMapping("/agent/update-status/{cardId}")
    public ResponseEntity<?> updateTravelPlanStatus(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId,
            @RequestParam("status") String statusParam
    ) {
        try {
            TravelPlanStatus newStatus;
            try {
                newStatus = TravelPlanStatus.valueOf(statusParam.toUpperCase());
            } catch (IllegalArgumentException e) {
                return ResponseEntity.badRequest().body("❌ Invalid status: must be APPROVED or REJECTED");
            }

            if (newStatus != TravelPlanStatus.APPROVED && newStatus != TravelPlanStatus.REJECTED) {
                return ResponseEntity.badRequest().body("❌ Only APPROVED or REJECTED are allowed.");
            }

            travelPlanService.updateTravelPlanStatus(token, cardId, newStatus);
            return ResponseEntity.ok("✅ Travel plan status updated to " + newStatus);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("❌ " + e.getMessage());
        }
    }
}