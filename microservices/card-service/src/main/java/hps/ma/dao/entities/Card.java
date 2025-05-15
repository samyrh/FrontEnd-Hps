package hps.ma.dao.entities;


import hps.ma.dao.enums.BlockReason;
import hps.ma.dao.enums.CardStatus;
import hps.ma.dao.enums.CardType;
import jakarta.persistence.*;
import lombok.*;

import java.util.Date;

@Entity
@Getter
@Setter
@AllArgsConstructor@NoArgsConstructor
@Builder
public class Card {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String cardNumber;

    @Enumerated(EnumType.STRING)
    private CardType type;

    @Enumerated(EnumType.STRING)
    private CardStatus status;

    @Enumerated(EnumType.STRING)
    private BlockReason blockReason;

    @Temporal(TemporalType.DATE)
    private Date expirationDate;

    private String cvv;

    private String pin;

    private boolean contactlessEnabled;

    private boolean ecommerceEnabled;

    private boolean tpeEnabled;

    private double spendingLimit;

    private String limitType;

    @Temporal(TemporalType.TIMESTAMP)
    private Date blockEndDate;

    private boolean isCanceled;

    @ManyToOne
    private Cardholder cardholder;

    @ManyToOne
    private Agent manager;

    @ManyToOne
    private CardPack cardPack;

    @OneToMany(mappedBy = "card", cascade = CascadeType.ALL)
    private List<Transaction> transactions;

    @OneToMany(mappedBy = "card", cascade = CascadeType.ALL)
    private List<Event> events;
}
