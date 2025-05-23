package hps.ma.dao.entities;


import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Getter
@Setter
@AllArgsConstructor@NoArgsConstructor
@Builder
public class CardPack {


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String label;
    private String audience;
    private double fee;
    private int validityYears;
    private double limitAnnual;
    private double limitDaily;
    private double limitMonthly;
    private boolean internationalWithdraw;
    private int maxCountries;
    private int maxDays;
    private String type;

    @OneToMany(mappedBy = "cardPack")
    private List<Card> cards;

}
