package hps.ma.web.agent;

import hps.ma.dao.entities.Card;
import hps.ma.dao.entities.CardPack;
import hps.ma.dao.enums.CardType;
import hps.ma.dao.repositories.CardRepository;
import hps.ma.dto.*;
import hps.ma.feign_client.CardholderService;
import hps.ma.feign_client.TravelPlanServiceClient;
import hps.ma.services.CardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/agent")
@RequiredArgsConstructor
@CrossOrigin("*")
public class AgentController {

    private final CardRepository cardRepository;
    private final CardholderService cardholderService;
    private final TravelPlanServiceClient travelPlanServiceClient;
    private final CardService cardService;


    @GetMapping("/cards/{cardholderId}")
    public ResponseEntity<List<CardResponseDTO>> getCardsForCardholder(
            @RequestHeader("Authorization") String authorizationToken,
            @PathVariable Long cardholderId
    ) {
        // Example: log the token or use it to call downstream services
        System.out.println("Agent token received: " + authorizationToken);

        // Get cardholder details via Feign
        Map<String, Object> cardholderData = cardholderService.getCardholderById(cardholderId);
        String cardholderName = cardholderData.get("cardholderName") != null
                ? cardholderData.get("cardholderName").toString()
                : "Unknown";


        List<Card> cards = cardRepository.findByCardholderId(cardholderId);

        List<CardResponseDTO> response = cards.stream()
                .map(card -> {
                    CardPack pack = card.getCardPack();
                    return CardResponseDTO.builder()
                            .id(card.getId())
                            .cardNumber(card.getCardNumber())
                            .type(card.getType())
                            .status(card.getStatus())
                            .blockReason(card.getBlockReason())
                            .expirationDate(card.getExpirationDate())
                            .cvv(card.getCvv())
                            .pin(card.getPin())
                            .contactlessEnabled(Boolean.TRUE.equals(card.getContactlessEnabled()))
                            .ecommerceEnabled(Boolean.TRUE.equals(card.getEcommerceEnabled()))
                            .tpeEnabled(Boolean.TRUE.equals(card.getTpeEnabled()))
                            .dailyLimit(card.getDailyLimit() != null ? card.getDailyLimit() : 0.0)
                            .monthlyLimit(card.getMonthlyLimit() != null ? card.getMonthlyLimit() : 0.0)
                            .annualLimit(card.getAnnualLimit() != null ? card.getAnnualLimit() : 0.0)
                            .internationalWithdraw(Boolean.TRUE.equals(card.getInternationalWithdraw()))
                            .blockEndDate(card.getBlockEndDate())
                            .isCanceled(Boolean.TRUE.equals(card.getIsCanceled()))
                            .replacementRequested(card.getReplacementRequested())
                            .gradientStartColor(card.getGradientStartColor())
                            .gradientEndColor(card.getGradientEndColor())
                            .balance(card.getBalance() != null ? card.getBalance() : 0.0)
                            .hasActiveTravelPlan(Boolean.TRUE.equals(card.getHasActiveTravelPlan()))
                            .cardholderName(cardholderName)
                            .cardPack(pack != null
                                    ? CardPackResponseDTO.builder()
                                    .label(pack.getLabel())
                                    .audience(pack.getAudience())
                                    .fee(pack.getFee())
                                    .validityYears(pack.getValidityYears())
                                    .limitAnnual(pack.getLimitAnnual())
                                    .limitDaily(pack.getLimitDaily())
                                    .limitMonthly(pack.getLimitMonthly())
                                    .internationalWithdraw(Boolean.TRUE.equals(pack.getInternationalWithdraw()))
                                    .maxCountries(pack.getMaxCountries())
                                    .maxDays(pack.getMaxDays())
                                    .type(pack.getType())
                                    .build()
                                    : null
                            )
                            .build();
                })
                .collect(Collectors.toList());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/cards/physical/all")
    public ResponseEntity<List<CardWithTravelPlanDTO>> getAllPhysicalCardsWithCardholder(
            @RequestHeader("Authorization") String authorizationToken
    ) {
        System.out.println("Agent token received: " + authorizationToken);

        List<Card> cards = cardRepository.findAll().stream()
                .filter(card -> card.getType() == CardType.PHYSICAL)
                .toList();

        List<CardWithTravelPlanDTO> response = cards.stream()
                .map(card -> {
                    // Cardholder info
                    Map<String, Object> cardholderData = cardholderService.getCardholderById(card.getCardholderId());
                    String cardholderName = cardholderData.getOrDefault("cardholderName", "Unknown").toString();
                    String cardholderEmail = cardholderData.getOrDefault("email", "Unknown").toString();
                    boolean locked = Boolean.parseBoolean(cardholderData.getOrDefault("locked", "false").toString());

                    // CardPack
                    CardPack pack = card.getCardPack();

                    CardResponseDTO cardResponse = CardResponseDTO.builder()
                            .id(card.getId())
                            .cardNumber(card.getCardNumber())
                            .type(card.getType())
                            .status(card.getStatus())
                            .blockReason(card.getBlockReason())
                            .expirationDate(card.getExpirationDate())
                            .cvv(card.getCvv())
                            .pin(card.getPin())
                            .contactlessEnabled(Boolean.TRUE.equals(card.getContactlessEnabled()))
                            .ecommerceEnabled(Boolean.TRUE.equals(card.getEcommerceEnabled()))
                            .tpeEnabled(Boolean.TRUE.equals(card.getTpeEnabled()))
                            .dailyLimit(card.getDailyLimit() != null ? card.getDailyLimit() : 0.0)
                            .monthlyLimit(card.getMonthlyLimit() != null ? card.getMonthlyLimit() : 0.0)
                            .annualLimit(card.getAnnualLimit() != null ? card.getAnnualLimit() : 0.0)
                            .internationalWithdraw(Boolean.TRUE.equals(card.getInternationalWithdraw()))
                            .blockEndDate(card.getBlockEndDate())
                            .isCanceled(Boolean.TRUE.equals(card.getIsCanceled()))
                            .replacementRequested(card.getReplacementRequested())
                            .gradientStartColor(card.getGradientStartColor())
                            .gradientEndColor(card.getGradientEndColor())
                            .balance(card.getBalance() != null ? card.getBalance() : 0.0)
                            .hasActiveTravelPlan(Boolean.TRUE.equals(card.getHasActiveTravelPlan()))
                            .cardholderName(cardholderName)
                            .cardPack(pack != null
                                    ? CardPackResponseDTO.builder()
                                    .label(pack.getLabel())
                                    .audience(pack.getAudience())
                                    .fee(pack.getFee())
                                    .validityYears(pack.getValidityYears())
                                    .limitAnnual(pack.getLimitAnnual())
                                    .limitDaily(pack.getLimitDaily())
                                    .limitMonthly(pack.getLimitMonthly())
                                    .internationalWithdraw(Boolean.TRUE.equals(pack.getInternationalWithdraw()))
                                    .maxCountries(pack.getMaxCountries())
                                    .maxDays(pack.getMaxDays())
                                    .type(pack.getType())
                                    .internationalWithdrawLimitPerTravel(
                                            pack.getInternationalWithdrawLimitPerTravel() != null
                                                    ? pack.getInternationalWithdrawLimitPerTravel()
                                                    : 0.0
                                    )
                                    .build()
                                    : null
                            )
                            .build();

                    // Travel Plan
                    TravelPlanCard travelPlan = null;
                    try {
                        travelPlan = travelPlanServiceClient.getTravelPlanByCardId(card.getId());
                    } catch (Exception ex) {
                        System.out.println("No travel plan for card " + card.getId());
                    }

                    return CardWithTravelPlanDTO.builder()
                            .card(cardResponse)
                            .cardholderId(card.getCardholderId())
                            .cardholderName(cardholderName)
                            .cardholderEmail(cardholderEmail)
                            .locked(locked)
                            .travelPlan(travelPlan)
                            .build();
                })
                // ✅ filter out those without a travel plan
                .filter(dto -> {
                    boolean hasPlan = dto.travelPlan() != null;
                    if (!hasPlan) {
                        System.out.println("Skipping card with ID: " + dto.card().id() + " (no travel plan)");
                    }
                    return hasPlan;
                })
                .toList();

        return ResponseEntity.ok(response);
    }

    @GetMapping("/cards/all")
    public ResponseEntity<List<CardResponseDTO>> getAllCardsForAgent(
            @RequestHeader("Authorization") String token
    ) {
        List<CardResponseDTO> cards = cardService.getAllCardsForAgent(token);
        return ResponseEntity.ok(cards);
    }
    @PostMapping("/cards/create")
    public ResponseEntity<Map<String, Object>> createCardForCardholderByAgent(
            @RequestHeader("Authorization") String token,
            @RequestBody AddCardByAgentRequest request
    ) {
        // Log for debugging
        System.out.println("Agent requested to create a card for cardholder ID: " + request.getCardholderId());

        // Delegate to service
        Card card = cardService.addCardForCardholderByAgent(token, request);

        // Build JSON response
        Map<String, Object> response = Map.of(
                "message", "Card successfully created and activated.",
                "cardId", card.getId()
        );

        return ResponseEntity.ok(response);
    }


    @PostMapping("/cards/{cardId}/approve")
    public ResponseEntity<Map<String, Object>> approveCard(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId
    ) {
        // Log for visibility
        System.out.println("Agent approving card ID: " + cardId);

        // Delegate to service
        cardService.approveNewRequestedCard(token, cardId);

        // Return success response
        Map<String, Object> response = Map.of(
                "message", "Card approved successfully.",
                "cardId", cardId
        );

        return ResponseEntity.ok(response);
    }

    @PostMapping("/cards/{cardId}/approve-virtual")
    public ResponseEntity<Map<String, Object>> approveVirtualCard(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId
    ) {
        // Log for visibility
        System.out.println("Agent approving VIRTUAL card ID: " + cardId);

        // Delegate to service
        cardService.approveNewRequestedVirtualCard(token, cardId);

        // Return success response
        Map<String, Object> response = Map.of(
                "message", "Virtual card approved successfully.",
                "cardId", cardId
        );

        return ResponseEntity.ok(response);
    }
    @PostMapping("/cards/{cardId}/reject")
    public ResponseEntity<Map<String, Object>> rejectCard(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId
    ) {
        System.out.println("Agent rejecting card ID: " + cardId);
        cardService.rejectNewRequestedCard(token, cardId);
        Map<String, Object> response = Map.of(
                "message", "Card rejected and deleted successfully.",
                "cardId", cardId
        );
        return ResponseEntity.ok(response);
    }


    @PostMapping("/cards/{cardId}/block-physical")
    public ResponseEntity<Map<String, Object>> blockPhysicalCardByAgent(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId
    ) {
        System.out.println("Agent blocking PHYSICAL card permanently, cardId=" + cardId);

        // Delegate to service
        cardService.blockPhysicalCardByAgent(token, cardId);

        // Return success response
        Map<String, Object> response = Map.of(
                "message", "Physical card blocked permanently by agent.",
                "cardId", cardId
        );

        return ResponseEntity.ok(response);
    }


    @PostMapping("/cards/{cardId}/unblock-physical")
    public ResponseEntity<Map<String, Object>> unblockPhysicalCardByAgent(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId
    ) {
        System.out.println("Agent unblocking PHYSICAL card, cardId=" + cardId);

        // Delegate to service
        cardService.unblockPhysicalCardByAgent(token, cardId);

        // Return success response
        Map<String, Object> response = Map.of(
                "message", "Physical card unblocked successfully by agent.",
                "cardId", cardId
        );

        return ResponseEntity.ok(response);
    }
    @PostMapping("/cards/{cardId}/cancel-physical")
    public ResponseEntity<Map<String, Object>> cancelPhysicalCardByAgent(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId
    ) {
        System.out.println("Agent canceling PHYSICAL card, cardId=" + cardId);

        // Delegate to service
        cardService.cancelPhysicalCardByAgent(token, cardId);

        // Return success response
        Map<String, Object> response = Map.of(
                "message", "Physical card canceled successfully by agent.",
                "cardId", cardId
        );

        return ResponseEntity.ok(response);
    }
    @PostMapping("/cards/{cardId}/uncancel-physical")
    public ResponseEntity<Map<String, Object>> uncancelPhysicalCardByAgent(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId
    ) {
        System.out.println("Agent uncanceling PHYSICAL card, cardId=" + cardId);

        // Delegate to service
        cardService.uncancelPhysicalCardByAgent(token, cardId);

        // Return success response
        Map<String, Object> response = Map.of(
                "message", "Physical card uncanceled and reactivated successfully by agent.",
                "cardId", cardId
        );

        return ResponseEntity.ok(response);
    }
    @GetMapping("/cards/physical/{cardId}")
    public ResponseEntity<CardResponseDTO> getPhysicalCardById(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId
    ) {
        System.out.println("Agent fetching PHYSICAL card, cardId=" + cardId);

        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it is a PHYSICAL card
        if (card.getType() != CardType.PHYSICAL) {
            throw new RuntimeException("Card is not a PHYSICAL card.");
        }

        // 3️⃣ Get cardholder details
        Map<String, Object> cardholderData = cardholderService.getCardholderById(card.getCardholderId());
        String cardholderName = cardholderData.getOrDefault("cardholderName", "Unknown").toString();

        // 4️⃣ Map to DTO
        CardPack pack = card.getCardPack();
        CardResponseDTO response = CardResponseDTO.builder()
                .id(card.getId())
                .cardNumber(card.getCardNumber())
                .type(card.getType())
                .status(card.getStatus())
                .blockReason(card.getBlockReason())
                .expirationDate(card.getExpirationDate())
                .cvv(card.getCvv())
                .pin(card.getPin())
                .contactlessEnabled(Boolean.TRUE.equals(card.getContactlessEnabled()))
                .ecommerceEnabled(Boolean.TRUE.equals(card.getEcommerceEnabled()))
                .tpeEnabled(Boolean.TRUE.equals(card.getTpeEnabled()))
                .dailyLimit(card.getDailyLimit() != null ? card.getDailyLimit() : 0.0)
                .monthlyLimit(card.getMonthlyLimit() != null ? card.getMonthlyLimit() : 0.0)
                .annualLimit(card.getAnnualLimit() != null ? card.getAnnualLimit() : 0.0)
                .internationalWithdraw(Boolean.TRUE.equals(card.getInternationalWithdraw()))
                .blockEndDate(card.getBlockEndDate())
                .isCanceled(Boolean.TRUE.equals(card.getIsCanceled()))
                .replacementRequested(card.getReplacementRequested())
                .gradientStartColor(card.getGradientStartColor())
                .gradientEndColor(card.getGradientEndColor())
                .balance(card.getBalance() != null ? card.getBalance() : 0.0)
                .hasActiveTravelPlan(Boolean.TRUE.equals(card.getHasActiveTravelPlan()))
                .cardholderName(cardholderName)
                .cvvRequested(card.getCvvRequested())
                .cardPack(pack != null
                        ? CardPackResponseDTO.builder()
                        .label(pack.getLabel())
                        .audience(pack.getAudience())
                        .fee(pack.getFee())
                        .validityYears(pack.getValidityYears())
                        .limitAnnual(pack.getLimitAnnual())
                        .limitDaily(pack.getLimitDaily())
                        .limitMonthly(pack.getLimitMonthly())
                        .internationalWithdraw(Boolean.TRUE.equals(pack.getInternationalWithdraw()))
                        .maxCountries(pack.getMaxCountries())
                        .maxDays(pack.getMaxDays())
                        .type(pack.getType())
                        .internationalWithdrawLimitPerTravel(
                                pack.getInternationalWithdrawLimitPerTravel() != null
                                        ? pack.getInternationalWithdrawLimitPerTravel()
                                        : 0.0
                        )
                        .build()
                        : null
                )
                .build();

        return ResponseEntity.ok(response);
    }
    @PostMapping("/cards/{cardId}/generate-pin")
    public ResponseEntity<Map<String, Object>> generateNewPinForPhysicalCard(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId
    ) {
        System.out.println("Agent generating new PIN for PHYSICAL card " + cardId);

        String plainPin = cardService.regeneratePhysicalCardPin(token, cardId);

        Map<String, Object> response = Map.of(
                "message", "New PIN generated successfully.",
                "newPin", plainPin
        );

        return ResponseEntity.ok(response);
    }



    @PostMapping("/cards/{cardId}/generate-cvv")
    public ResponseEntity<Map<String, Object>> generateNewCvvForPhysicalCard(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId
    ) {
        System.out.println("Agent generating new CVV for PHYSICAL card " + cardId);

        // Delegate to service
        String plainCvv = cardService.regenerateCardCvvByAgent(token, cardId);

        // Build response
        Map<String, Object> response = Map.of(
                "message", "New CVV generated successfully.",
                "newCvv", plainCvv
        );

        return ResponseEntity.ok(response);
    }

    @PostMapping("/cards/physical/{cardId}/update-features")
    public ResponseEntity<Map<String, Object>> updatePhysicalCardFeatures(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId,
            @RequestBody UpdateCardFeaturesRequest request
    ) {
        System.out.println("Agent updating features for PHYSICAL card ID: " + cardId);

        // Delegate to service
        cardService.updatePhysicalCardFeatures(token, cardId, request);

        // Build response
        Map<String, Object> response = Map.of(
                "message", "Physical card features updated successfully.",
                "cardId", cardId
        );

        return ResponseEntity.ok(response);
    }


    @PostMapping("/cards/{cardId}/update-limits")
    public ResponseEntity<Map<String, Object>> updateCardLimitsByAgent(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId,
            @RequestBody UpdateCardLimitsRequest request
    ) {
        System.out.println("Agent updating limits for card ID: " + cardId);

        // Delegate to service
        cardService.updateCardLimitsByAgent(
                token,
                cardId,
                request.getDailyLimit(),
                request.getMonthlyLimit(),
                request.getAnnualOrEcommerceLimit()
        );

        Map<String, Object> response = Map.of(
                "message", "Card limits updated successfully.",
                "cardId", cardId
        );

        return ResponseEntity.ok(response);
    }
    @GetMapping("/cards/virtual/{cardId}")
    public ResponseEntity<CardResponseDTO> getVirtualCardById(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId
    ) {
        System.out.println("Agent fetching VIRTUAL card, cardId=" + cardId);

        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it is a VIRTUAL card
        if (card.getType() != CardType.VIRTUAL) {
            throw new RuntimeException("Card is not a VIRTUAL card.");
        }

        // 3️⃣ Get cardholder details
        Map<String, Object> cardholderData = cardholderService.getCardholderById(card.getCardholderId());
        String cardholderName = cardholderData.getOrDefault("cardholderName", "Unknown").toString();

        // 4️⃣ Map to DTO
        CardPack pack = card.getCardPack();
        CardResponseDTO response = CardResponseDTO.builder()
                .id(card.getId())
                .cardNumber(card.getCardNumber())
                .type(card.getType())
                .status(card.getStatus())
                .blockReason(card.getBlockReason())
                .expirationDate(card.getExpirationDate())
                .cvv(card.getCvv())
                .ecommerceEnabled(Boolean.TRUE.equals(card.getEcommerceEnabled()))
                .annualLimit(card.getAnnualLimit() != null ? card.getAnnualLimit() : 0.0)

                .isCanceled(Boolean.TRUE.equals(card.getIsCanceled()))
                .replacementRequested(card.getReplacementRequested())
                .gradientStartColor(card.getGradientStartColor())
                .gradientEndColor(card.getGradientEndColor())
                .balance(card.getBalance() != null ? card.getBalance() : 0.0)
                .cardholderName(cardholderName)
                .cvvRequested(card.getCvvRequested())
                .cardPack(pack != null
                        ? CardPackResponseDTO.builder()
                        .label(pack.getLabel())
                        .audience(pack.getAudience())
                        .fee(pack.getFee())
                        .validityYears(pack.getValidityYears())
                        .limitAnnual(pack.getLimitAnnual())
                        .limitDaily(pack.getLimitDaily())
                        .limitMonthly(pack.getLimitMonthly())
                        .internationalWithdraw(Boolean.TRUE.equals(pack.getInternationalWithdraw()))
                        .maxCountries(pack.getMaxCountries())
                        .maxDays(pack.getMaxDays())
                        .type(pack.getType())
                        .internationalWithdrawLimitPerTravel(
                                pack.getInternationalWithdrawLimitPerTravel() != null
                                        ? pack.getInternationalWithdrawLimitPerTravel()
                                        : 0.0
                        )
                        .build()
                        : null
                )
                .build();

        return ResponseEntity.ok(response);
    }


    @PostMapping("/cards/{cardId}/unblock-virtual")
    public ResponseEntity<Map<String, Object>> unblockVirtualCardByAgent(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId
    ) {
        System.out.println("Agent unblocking VIRTUAL card, cardId=" + cardId);

        // Delegate to service
        cardService.unblockVirtualCardByAgent(token, cardId);

        // Build success response
        Map<String, Object> response = Map.of(
                "message", "Virtual card unblocked successfully by agent.",
                "cardId", cardId
        );

        return ResponseEntity.ok(response);
    }



    @PostMapping("/cards/{cardId}/block-virtual")
    public ResponseEntity<Map<String, Object>> blockVirtualCardByAgent(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId
    ) {
        System.out.println("Agent blocking VIRTUAL card permanently, cardId=" + cardId);

        // Delegate to the service
        cardService.blockVirtualCardByAgent(token, cardId);

        // Build success response
        Map<String, Object> response = Map.of(
                "message", "Virtual card blocked permanently by agent.",
                "cardId", cardId
        );

        return ResponseEntity.ok(response);
    }


    @PostMapping("/cards/{cardId}/cancel-virtual")
    public ResponseEntity<Map<String, Object>> cancelVirtualCardByAgent(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId
    ) {
        System.out.println("Agent canceling VIRTUAL card, cardId=" + cardId);

        // Delegate to the service
        cardService.cancelVirtualCardByAgent(token, cardId);

        // Return success response
        Map<String, Object> response = Map.of(
                "message", "Virtual card canceled successfully by agent.",
                "cardId", cardId
        );

        return ResponseEntity.ok(response);
    }

    @PostMapping("/cards/{cardId}/uncancel-virtual")
    public ResponseEntity<Map<String, Object>> uncancelVirtualCardByAgent(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId
    ) {
        System.out.println("Agent uncanceling VIRTUAL card, cardId=" + cardId);

        // Delegate to the service
        cardService.uncancelVirtualCardByAgent(token, cardId);

        // Return success response
        Map<String, Object> response = Map.of(
                "message", "Virtual card uncanceled and reactivated successfully.",
                "cardId", cardId
        );

        return ResponseEntity.ok(response);
    }
    @PostMapping("/cards/{cardId}/update-virtual-ecommerce")
    public ResponseEntity<Map<String, Object>> updateVirtualCardEcommerce(
            @RequestHeader("Authorization") String token,
            @PathVariable Long cardId,
            @RequestBody Map<String, Boolean> request
    ) {
        System.out.println("Agent updating E-Commerce feature for VIRTUAL card ID: " + cardId);

        Boolean ecommerceEnabled = request.get("ecommerceEnabled");

        // Delegate to service
        cardService.updateVirtualCardEcommerceFeatureByAgent(token, cardId, ecommerceEnabled);

        // Build response
        Map<String, Object> response = Map.of(
                "message", "Virtual card E-Commerce feature updated successfully.",
                "cardId", cardId
        );

        return ResponseEntity.ok(response);
    }

}
