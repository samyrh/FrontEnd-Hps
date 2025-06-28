package hps.ma.web;

import hps.ma.dao.entities.Card;
import hps.ma.dao.enums.CardType;
import hps.ma.dao.repositories.CardRepository;
import hps.ma.dto.*;
import hps.ma.feign_client.CardholderService;
import hps.ma.services.CardService;
import hps.ma.services.CardholderInfoService;
import hps.ma.services.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/cards")
@RequiredArgsConstructor
public class CardController {

    private final JwtUtil jwtUtil;
    private final CardholderService cardholderServiceClient;
    private final CardRepository cardRepository;
    private final CardholderInfoService cardholderInfoService;
    private final CardService cardService;

    @GetMapping("/my-physical-cards")
    public ResponseEntity<?> getMyPhysicalCards(@RequestHeader("Authorization") String token) {
        String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        List<Card> cards = cardRepository.findByCardholderIdAndType(cardholderId, CardType.PHYSICAL);

        Map<String, Object> userInfo = cardholderServiceClient.getCardholderById(cardholderId);
        String cardholderName = (String) userInfo.get("cardholderName");

        List<CardResponseDTO> response = cards.stream().map(card -> {
            if (card.getCardPack() == null) {
                throw new RuntimeException("Card " + card.getId() + " has no CardPack");
            }

            return CardResponseDTO.builder()
                    .id(card.getId())
                    .cardNumber(card.getCardNumber())
                    .type(card.getType())
                    .status(card.getStatus())
                    .blockReason(card.getBlockReason())
                    .expirationDate(card.getExpirationDate())
                    .contactlessEnabled(Boolean.TRUE.equals(card.getContactlessEnabled()))
                    .ecommerceEnabled(Boolean.TRUE.equals(card.getEcommerceEnabled()))
                    .tpeEnabled(Boolean.TRUE.equals(card.getTpeEnabled()))
                    .dailyLimit(card.getDailyLimit() != null ? card.getDailyLimit() : 0.0)
                    .monthlyLimit(card.getMonthlyLimit() != null ? card.getMonthlyLimit() : 0.0)
                    .annualLimit(card.getAnnualLimit() != null ? card.getAnnualLimit() : 0.0)
                    .internationalWithdraw(Boolean.TRUE.equals(card.getInternationalWithdraw()))
                    .blockEndDate(card.getBlockEndDate())
                    .isCanceled(Boolean.TRUE.equals(card.getIsCanceled()))
                    .gradientStartColor(card.getGradientStartColor())
                    .gradientEndColor(card.getGradientEndColor())
                    .balance(card.getBalance() != null ? card.getBalance() : 0.0)
                    .cvv(card.getCvv())
                    .pin(card.getPin())
                    .hasActiveTravelPlan(Boolean.TRUE.equals(card.getHasActiveTravelPlan()))
                    .cardholderName(cardholderName)
                    .replacementRequested(Boolean.TRUE.equals(card.getReplacementRequested()))
                    .cardPack(CardPackResponseDTO.builder()
                            .label(card.getCardPack().getLabel())
                            .audience(card.getCardPack().getAudience())
                            .fee(card.getCardPack().getFee() != null ? card.getCardPack().getFee() : 0.0)
                            .validityYears(card.getCardPack().getValidityYears() != null ? card.getCardPack().getValidityYears() : 0)
                            .limitAnnual(card.getCardPack().getLimitAnnual() != null ? card.getCardPack().getLimitAnnual() : 0.0)
                            .limitDaily(card.getCardPack().getLimitDaily() != null ? card.getCardPack().getLimitDaily() : 0.0)
                            .limitMonthly(card.getCardPack().getLimitMonthly() != null ? card.getCardPack().getLimitMonthly() : 0.0)
                            .internationalWithdraw(Boolean.TRUE.equals(card.getCardPack().getInternationalWithdraw()))
                            .maxCountries(card.getCardPack().getMaxCountries() != null ? card.getCardPack().getMaxCountries() : 0)
                            .maxDays(card.getCardPack().getMaxDays() != null ? card.getCardPack().getMaxDays() : 0)
                            .type(card.getCardPack().getType())
                            .internationalWithdrawLimitPerTravel(
                                    card.getCardPack().getInternationalWithdrawLimitPerTravel() != null
                                            ? card.getCardPack().getInternationalWithdrawLimitPerTravel()
                                            : 0.0
                            )
                            .build())
                    .build();
        }).toList();

        return ResponseEntity.ok(response);
    }

    @GetMapping("/security-options")
    public ResponseEntity<?> getCardSecurityOptions(@RequestHeader("Authorization") String token) {
        String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        Map<String, Object> userInfo = cardholderServiceClient.getCardholderById(cardholderId);
        String cardholderName = (String) userInfo.get("cardholderName");

        List<Card> cards = cardRepository.findByCardholderIdAndType(cardholderId, CardType.PHYSICAL);

        List<CardSecurityOptionsDTO> options = cards.stream().map(card -> CardSecurityOptionsDTO.builder()
                .label(card.getCardPack() != null ? card.getCardPack().getLabel() : "Unknown Pack")
                .contactlessEnabled(Boolean.TRUE.equals(card.getContactlessEnabled()))
                .ecommerceEnabled(Boolean.TRUE.equals(card.getEcommerceEnabled()))
                .tpeEnabled(Boolean.TRUE.equals(card.getTpeEnabled()))
                .username(username)
                .cardholderName(cardholderName)
                .build()
        ).toList();

        return ResponseEntity.ok(options);
    }

    @GetMapping("/virtual-security-options")
    public ResponseEntity<?> getVirtualCardSecurityOptions(@RequestHeader("Authorization") String token) {
        String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        Map<String, Object> userInfo = cardholderServiceClient.getCardholderById(cardholderId);
        String cardholderName = (String) userInfo.get("cardholderName");

        List<Card> cards = cardRepository.findByCardholderIdAndType(cardholderId, CardType.VIRTUAL);

        List<VirtualCardSecurityOptionsDTO> options = cards.stream().map(card -> VirtualCardSecurityOptionsDTO.builder()
                .label(card.getCardPack() != null ? card.getCardPack().getLabel() : "Unknown Pack")
                .ecommerceEnabled(Boolean.TRUE.equals(card.getEcommerceEnabled()))
                .username(username)
                .cardholderName(cardholderName)
                .build()
        ).toList();

        return ResponseEntity.ok(options);
    }


    @PutMapping("/security-options/update")
    public ResponseEntity<?> updateSecurityOptions(@RequestBody UpdateSecurityOptionRequest request) {
        cardService.updateSecurityOptions(
                request.getCardId(),
                request.getContactlessEnabled(),
                request.getEcommerceEnabled(),
                request.getTpeEnabled()
        );
        return ResponseEntity.ok("Card security options updated");
    }

    @GetMapping("/my-cards")
    public ResponseEntity<?> getAllMyCards(@RequestHeader("Authorization") String token)   {
        List<CardResponseDTO> allCards = cardService.getAllCardsForCardholder(token);
        return ResponseEntity.ok(allCards);
    }

    @PostMapping("/add")
    public ResponseEntity<?> addCard(@RequestHeader("Authorization") String token,
                                     @RequestBody AddCardRequest request) {
        cardService.addCardForCardholder(token, request);
        return ResponseEntity.ok("✅ Card created successfully.");
    }

    @GetMapping("/{id}")
    public ResponseEntity<CardResponseDTO> getCardById(@PathVariable("id") Long id) {
        CardResponseDTO card = cardService.getCardById(id);
        return ResponseEntity.ok(card);
    }

    // Endpoint to view the CVV for a virtual card
    @PutMapping("/virtual-card/{cardId}/view-cvv")
    public ResponseEntity<?> viewVirtualCardCVV(@PathVariable Long cardId) {
        try {
            // Call the service method to handle the CVV view and event publishing
            cardService.viewVirtualCardCVV(cardId);
            return ResponseEntity.ok("✅ CVV viewed and event sent successfully.");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("❌ Error: " + e.getMessage());
        }
    }

    // Endpoint to update the annual limit for a virtual card
    @PutMapping("/virtual-card/{cardId}/update-limit")
    public ResponseEntity<?> updateVirtualCardLimit(@PathVariable Long cardId, @RequestBody UpdateAnnualLimitRequest request) {
        try {
            // Call the service to update the annual limit
            cardService.updateVirtualCardLimit(cardId, request.getNewAnnualLimit());
            return ResponseEntity.ok("✅ Virtual card limit updated successfully.");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("❌ Error: " + e.getMessage());
        }
    }

    @PutMapping("/physical-card/{cardId}/update-limits")
    public ResponseEntity<?> updatePhysicalCardLimits(@PathVariable Long cardId,
                                                      @RequestBody UpdatePhysicalLimitsRequest request) {
        try {
            cardService.updatePhysicalCardLimits(cardId, request);
            return ResponseEntity.ok("✅ Physical card limits updated successfully.");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("❌ Error: " + e.getMessage());
        }
    }

    @PutMapping("/virtual-card/{cardId}/block")
    public ResponseEntity<String> blockVirtualCard(@PathVariable Long cardId,
                                                   @RequestBody VirtualCardBlockRequest request) {
        cardService.blockVirtualCard(cardId, request.getBlockReason());
        return ResponseEntity.ok("✅ Virtual card blocked successfully.");
    }


    @PutMapping("/virtual-card/{cardId}/unblock")
    public ResponseEntity<?> unblockVirtualCard(@PathVariable Long cardId) {
        try {
            cardService.unblockVirtualCard(cardId);
            return ResponseEntity.ok("✅ Virtual card unblocked successfully.");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("❌ Error: " + e.getMessage());
        }
    }

    @GetMapping("/virtual-cards/{cardId}/security-option")
    public ResponseEntity<?> getVirtualCardSecurityOptionById(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId) {
        try {
            VirtualCardSecurityOptionsDTO option = cardService.getVirtualCardSecurityOptionById(token, cardId);
            return ResponseEntity.ok(option);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("❌ Error: " + e.getMessage());
        }
    }

    @PostMapping("/virtual-card/replace")
    public ResponseEntity<?> replaceVirtualCard(@RequestHeader("Authorization") String token,
                                                @RequestBody ReplaceVirtualCardRequest request) {
        try {
            cardService.replaceVirtualCard(token, request.getBlockedCardId());
            return ResponseEntity.ok("✅ Virtual card replacement requested successfully.");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("❌ Error: " + e.getMessage());
        }
    }


    @PutMapping("/virtual-card/{cardId}/cancel")
    public ResponseEntity<?> cancelVirtualCard(@PathVariable Long cardId) {
        try {
            cardService.cancelVirtualCard(cardId);
            return ResponseEntity.ok("✅ Virtual card canceled successfully.");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("❌ Error: " + e.getMessage());
        }
    }

    @PutMapping("/virtual-card/{cardId}/uncancel")
    public ResponseEntity<?> uncancelVirtualCard(@PathVariable Long cardId) {
        try {
            cardService.uncancelVirtualCard(cardId);
            return ResponseEntity.ok("✅ Virtual card reactivated successfully.");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("❌ Error: " + e.getMessage());
        }
    }

    @PutMapping("/{cardId}/update-active-travel-plan")
    public ResponseEntity<?> updateActiveTravelPlan(@PathVariable Long cardId, @RequestParam boolean active) {
        cardService.updateHasActiveTravelPlan(cardId, active);
        return ResponseEntity.ok("✅ Card travel plan status updated.");
    }
    @PutMapping("/cardholder/{cardId}/request-cvv")
    public ResponseEntity<?> requestCvv(@RequestHeader("Authorization") String token,
                                        @PathVariable Long cardId) {
        cardService.requestCvv(token, cardId);
        return ResponseEntity.ok("✅ CVV request submitted for approval.");
    }

    @PutMapping("/cardholder/{cardId}/update-pin")
    public ResponseEntity<?> updatePin(@RequestHeader("Authorization") String token,
                                       @PathVariable Long cardId,
                                       @RequestBody UpdatePinRequest request) {
        cardService.updatePin(token, cardId, request.getNewPin());
        return ResponseEntity.ok("PIN updated successfully.");
    }



    @PutMapping("/physical-card/{cardId}/block")
    public ResponseEntity<String> blockPhysicalCard(@PathVariable Long cardId,
                                                    @RequestBody PhysicalCardBlockRequest request) {
        try {
            cardService.blockPhysicalCard(cardId, request.getBlockReason());
            return ResponseEntity.ok("✅ Physical card blocked successfully.");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("❌ Error: " + e.getMessage());
        }
    }

    @PutMapping("/physical-card/{cardId}/request-replacement-due-to-loss")
    public ResponseEntity<String> requestPhysicalCardReplacementDueToLoss(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId) {
        try {
            cardService.requestPhysicalCardReplacementDueToLoss(token, cardId);
            return ResponseEntity.ok("✅ Physical card replacement requested successfully.");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("❌ Error: " + e.getMessage());
        }
    }
    @PutMapping("/physical-card/{cardId}/request-replacement-due-to-stolen")
    public ResponseEntity<String> requestPhysicalCardReplacementDueToStolen(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId) {
        try {
            cardService.requestPhysicalCardReplacementDueToStolen(token, cardId);
            return ResponseEntity.ok("✅ Replacement requested successfully.");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("❌ Error: " + e.getMessage());
        }
    }

}
