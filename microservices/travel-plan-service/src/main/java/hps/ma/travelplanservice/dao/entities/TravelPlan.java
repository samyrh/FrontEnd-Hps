package hps.ma.travelplanservice.dao.entities;


import hps.ma.travelplanservice.dao.enums.TravelPlanStatus;
import jakarta.persistence.*;
import lombok.*;

import java.util.Date;
import java.util.List;

@Entity
@Setter
@Getter
@Builder
@NoArgsConstructor@AllArgsConstructor
public class TravelPlan {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Date startDate;
    private Date endDate;

    @ElementCollection
    private List<String> countries;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TravelPlanStatus status;

    private double travelLimit;
    private int maxDays;

    @ManyToOne
    private Card card;

    @ManyToOne
    private Agent approver;
}
