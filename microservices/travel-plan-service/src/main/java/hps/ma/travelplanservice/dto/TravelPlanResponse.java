package hps.ma.travelplanservice.dto;

import hps.ma.travelplanservice.dao.enums.TravelPlanStatus;
import lombok.*;

import java.util.Date;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TravelPlanResponse {
    private Long id;
    private Date startDate;
    private Date endDate;
    private List<String> countries;
    private TravelPlanStatus status;
    private Double travelLimit;
    private int maxDays;
    private Long cardId;
}