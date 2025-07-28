package hps.ma.web;

import hps.ma.dao.entities.Card;
import hps.ma.dao.repositories.CardRepository;
import hps.ma.dto.CardPackResponseDTO;
import hps.ma.dto.CardResponseDTO;
import hps.ma.dto.CardWithTravelPlanDTO;
import hps.ma.dto.TravelPlanCard;
import hps.ma.feign_client.CardholderService;
import hps.ma.feign_client.TravelPlanServiceClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/chatbot/data")
public class ChatbotCardController {

    @Autowired
    private CardRepository cardRepository;

    @Autowired
    private CardholderService cardholderService;

    @Autowired
    private TravelPlanServiceClient travelPlanServiceClient;

    @GetMapping("/full")
    public List<CardWithTravelPlanDTO> getAllCardsFull() {
        List<Card> cards = cardRepository.findAll();

        return cards.stream().map(card -> {
            // Get Cardholder
            Map<String, Object> userInfo = cardholderService.getCardholderById(card.getCardholderId());
            String cardholderName = (String) userInfo.getOrDefault("cardholderName", "Unknown");
            String cardholderEmail = (String) userInfo.getOrDefault("email", "Unknown");
            boolean locked = Boolean.TRUE.equals(userInfo.get("locked"));

            // Get Travel Plan
            TravelPlanCard travelPlan;
            try {
                travelPlan = travelPlanServiceClient.getTravelPlanByCardId(card.getId());
            } catch (Exception e) {
                // If no active travel plan, return null
                travelPlan = null;
            }

            return CardWithTravelPlanDTO.builder()
                    .card(mapCard(card, cardholderName))
                    .cardholderId(card.getCardholderId())
                    .cardholderName(cardholderName)
                    .cardholderEmail(cardholderEmail)
                    .locked(locked)
                    .travelPlan(travelPlan)
                    .build();
        }).toList();
    }

    // Helper to convert Card to CardResponseDTO
    private CardResponseDTO mapCard(Card card, String cardholderName) {
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
                .cvvRequested(Boolean.TRUE.equals(card.getCvvRequested()))
                .cardholderName(cardholderName)
                .cardPack(card.getCardPack() != null
                        ? CardPackResponseDTO.builder()
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
                                        : 0.0)
                        .build()
                        : null)
                .build();
    }
}
