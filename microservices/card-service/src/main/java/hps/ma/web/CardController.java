package hps.ma.web;

import hps.ma.dao.entities.Card;
import hps.ma.dao.enums.CardType;
import hps.ma.dao.repositories.CardRepository;
import hps.ma.dto.CardPackResponseDTO;
import hps.ma.dto.CardResponseDTO;
import hps.ma.feign_client.UserService;
import hps.ma.services.CardholderInfoService;
import hps.ma.services.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;


@RestController
@RequestMapping("/api/cards")
@RequiredArgsConstructor
public class CardController {

    private final JwtUtil jwtUtil;
    private final UserService userServiceClient;
    private final CardRepository cardRepository;
    private final CardholderInfoService cardholderInfoService;

    @GetMapping("/my-physical-cards")
    public ResponseEntity<?> getMyPhysicalCards(@RequestHeader("Authorization") String token) {
        String username = jwtUtil.extractUsername(token);
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        List<Card> cards = cardRepository.findByCardholderIdAndType(cardholderId, CardType.PHYSICAL);

        List<CardResponseDTO> response = cards.stream().map(card -> CardResponseDTO.builder()
                .id(card.getId())
                .cardNumber(card.getCardNumber())
                .type(card.getType())
                .status(card.getStatus())
                .blockReason(card.getBlockReason())
                .expirationDate(card.getExpirationDate())
                .contactlessEnabled(card.isContactlessEnabled())
                .ecommerceEnabled(card.isEcommerceEnabled())
                .tpeEnabled(card.isTpeEnabled())
                .spendingLimit(card.getSpendingLimit())
                .limitType(card.getLimitType())
                .blockEndDate(card.getBlockEndDate())
                .isCanceled(card.isCanceled())
                .cardPack(CardPackResponseDTO.builder()
                        .label(card.getCardPack().getLabel())
                        .audience(card.getCardPack().getAudience())
                        .fee(card.getCardPack().getFee())
                        .validityYears(card.getCardPack().getValidityYears())
                        .limitAnnual(card.getCardPack().getLimitAnnual())
                        .limitDaily(card.getCardPack().getLimitDaily())
                        .limitMonthly(card.getCardPack().getLimitMonthly())
                        .internationalWithdraw(card.getCardPack().isInternationalWithdraw())
                        .maxCountries(card.getCardPack().getMaxCountries())
                        .maxDays(card.getCardPack().getMaxDays())
                        .type(card.getCardPack().getType())
                        .build())
                .build()
        ).toList();

        return ResponseEntity.ok(response);
    }



}

