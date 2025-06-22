package hps.ma.eventservice.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotificationPreferencesDTO {
    @JsonProperty("cardStatusNotification")
    private boolean cardStatusChanges;

    @JsonProperty("cardCancelNotification")
    private boolean cardCancelReactivate;

    @JsonProperty("newCardRequestNotification")
    private boolean newCardRequest;

    @JsonProperty("cardReplacementNotification")
    private boolean cardReplacementRequest;

    @JsonProperty("travelPlanNotification")
    private boolean travelPlanStatus;

    @JsonProperty("transactionNotification")
    private boolean transactionAlert;
}
