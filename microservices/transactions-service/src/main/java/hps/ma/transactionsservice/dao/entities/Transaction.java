package hps.ma.transactionsservice.dao.entities;


import hps.ma.transactionsservice.dao.enums.TransactionCategory;


import hps.ma.transactionsservice.dao.enums.TransactionStatus;
import jakarta.persistence.*;
import lombok.*;

import java.util.Date;

@Entity
@Getter
@Setter
@AllArgsConstructor@NoArgsConstructor
@Builder
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Temporal(TemporalType.TIMESTAMP)
    private Date date;

    private String merchant;

    private double amount;

    @Enumerated(EnumType.STRING)
    private TransactionCategory category;

    @Enumerated(EnumType.STRING)
    private TransactionStatus status;

    private String type;

    @Column(name = "card_id", nullable = false)
    private Long cardId;
}
