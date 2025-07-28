package hps.ma.travelplanservice.dto;


import hps.ma.travelplanservice.dao.enums.BlockReason;
import hps.ma.travelplanservice.dao.enums.CardStatus;
import hps.ma.travelplanservice.dao.enums.CardType;
import lombok.Builder;

import java.util.Date;

@Builder
public record CardResponseDTO(
        Long id,
        String cardNumber,
        CardType type,
        CardStatus status,
        BlockReason blockReason,
        Date expirationDate,
        String cvv,
        String pin,
        boolean contactlessEnabled,
        boolean ecommerceEnabled,
        boolean tpeEnabled,
        double dailyLimit,
        double monthlyLimit,
        double annualLimit,
        boolean internationalWithdraw,
        Date blockEndDate,
        boolean isCanceled,
        Boolean replacementRequested,
        String gradientStartColor,
        String gradientEndColor,
        double balance,
        String cardholderName,
        boolean hasActiveTravelPlan,
        CardPackResponseDTO cardPack
) {}
