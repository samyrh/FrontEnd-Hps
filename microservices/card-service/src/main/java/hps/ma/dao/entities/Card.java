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
@AllArgsConstructor
@NoArgsConstructor
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

    @Column(name = "daily_limit")
    private double dailyLimit;

    @Column(name = "monthly_limit")
    private double monthlyLimit;

    @Column(name = "annual_limit")
    private double annualLimit;

    @Column(name = "international_withdraw")
    private boolean internationalWithdraw;

    @Temporal(TemporalType.TIMESTAMP)
    private Date blockEndDate;

    private boolean isCanceled;

    @Column(name = "cardholder_id", nullable = false)
    private Long cardholderId;

    @Column(name = "manager_id")
    private Long managerId;

    @Column(name = "gradient_start_color")
    private String gradientStartColor;

    @Column(name = "gradient_end_color")
    private String gradientEndColor;

    @Column(name = "balance") // or "solde" if you prefer
    private double balance;

    @ManyToOne
    private CardPack cardPack;
}
