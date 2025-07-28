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
    @Column(length = 20)
    private CardType type;

    @Enumerated(EnumType.STRING)
    @Column(length = 30) // ensure enough room for enum string values
    private CardStatus status;

    @Enumerated(EnumType.STRING)
    @Column(length = 30)
    private BlockReason blockReason;

    @Temporal(TemporalType.DATE)
    private Date expirationDate;

    private String cvv;

    private String pin;

    private Boolean contactlessEnabled;
    private Boolean ecommerceEnabled;
    private Boolean tpeEnabled;

    @Column(name = "daily_limit")
    private Double dailyLimit;

    @Column(name = "monthly_limit")
    private Double monthlyLimit;

    @Column(name = "replacement_requested")
    private Boolean replacementRequested = false;

    @Column(name = "annual_limit")
    private Double annualLimit;

    @Column(name = "international_withdraw")
    private Boolean internationalWithdraw;

    @Temporal(TemporalType.TIMESTAMP)
    private Date blockEndDate;

    private Boolean isCanceled;

    @Column(name = "cardholder_id", nullable = false)
    private Long cardholderId;

    @Column(name = "manager_id")
    private Long managerId;

    @Column(name = "gradient_start_color")
    private String gradientStartColor;

    @Column(name = "gradient_end_color")
    private String gradientEndColor;

    @Column(name = "balance") // or "solde" if you prefer
    private Double balance;

    @Column(name = "has_active_travel_plan")
    private Boolean hasActiveTravelPlan = false;

    @Column(name = "cvv_requested")
    private Boolean cvvRequested = false;

    @ManyToOne
    private CardPack cardPack;
}
