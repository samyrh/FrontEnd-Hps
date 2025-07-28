package hps.ma.travelplanservice.dto;

import hps.ma.travelplanservice.dao.enums.TravelPlanStatus;
import lombok.Builder;

import java.util.Date;
import java.util.List;

@Builder
public record TravelPlanCard(
        Long id,
        Date startDate,
        Date endDate,
        List<String> countries,
        TravelPlanStatus status,
        Double travelLimit,
        int maxDays,
        Long cardId,
        Long approverId
) {}
