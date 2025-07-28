package hps.ma.transactionsservice.dao.entities;

import hps.ma.transactionsservice.dao.enums.TransactionStatus;
import jakarta.persistence.*;
import lombok.*;

import java.util.Date;

@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Temporal(TemporalType.TIMESTAMP)
    private Date date;

    private String merchant;

    private double amount;

    @Column(nullable = false)
    private String category;

    @Column(length = 500)
    private String description;

    @Enumerated(EnumType.STRING)
    private TransactionStatus status;


    @Column(name = "card_id", nullable = false)
    private Long cardId;

}
