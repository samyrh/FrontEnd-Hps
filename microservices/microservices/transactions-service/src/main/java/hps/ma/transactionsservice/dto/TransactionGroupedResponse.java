package hps.ma.transactionsservice.dto;

import java.util.List;
import java.util.Map;

public record TransactionGroupedResponse(
        Map<Long, List<TransactionResponseDTO>> transactionsByCardId
) {}
