package hps.ma.dao.entities;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CardPack {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String label;
    private String audience;
    private Double fee;
    private Integer validityYears;
    private Double limitAnnual;
    private Double limitDaily;
    private Double limitMonthly;
    private Boolean internationalWithdraw;
    private Integer maxCountries;
    private Integer maxDays;
    private String type;
    @Column(name = "international_withdraw_limit_per_travel")
    private Double internationalWithdrawLimitPerTravel;

    @OneToMany(mappedBy = "cardPack")
    private List<Card> cards;
}
