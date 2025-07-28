package hps.ma.dto;

import hps.ma.dao.enums.BlockReason;
import hps.ma.dao.enums.CardStatus;
import hps.ma.dao.enums.CardType;
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
        String cvv,                // ← newly added
        String pin,                // ← newly added
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
        boolean hasActiveTravelPlan,
        String cardholderName,
        boolean cvvRequested,
        CardPackResponseDTO cardPack
) {}
