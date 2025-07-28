package hps.ma.dto;

import lombok.Builder;

@Builder
public record CardWithTravelPlanDTO(
        CardResponseDTO card,
        Long cardholderId,
        String cardholderName,
        String cardholderEmail,
        boolean locked,
        TravelPlanCard travelPlan
) {}
