package hps.ma.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdatePhysicalLimitsRequest {
    private Double newDailyLimit;
    private Double newMonthlyLimit;
    private Double newAnnualLimit;
}
