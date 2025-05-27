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
        boolean contactlessEnabled,
        boolean ecommerceEnabled,
        boolean tpeEnabled,
        double spendingLimit,
        String limitType,
        Date blockEndDate,
        boolean isCanceled,
        CardPackResponseDTO cardPack
) {}
