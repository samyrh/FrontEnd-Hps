package hps.ma.transactionsservice.dto;

import hps.ma.transactionsservice.dao.enums.TransactionStatus;
import lombok.Builder;
import lombok.Data;

import java.util.Date;

@Data
@Builder
public class TransactionResponseDTO {
    private Long id;
    private Date date;
    private String merchant;
    private double amount;
    private String category;
    private String description;
    private TransactionStatus status;
    private Long cardId;
}
