package hps.ma.transactionsservice.dto;

import lombok.Data;

@Data
public class TransactionCreateRequest {
    private Long cardId;
    private String merchant;
    private double amount;
    private String description;
}