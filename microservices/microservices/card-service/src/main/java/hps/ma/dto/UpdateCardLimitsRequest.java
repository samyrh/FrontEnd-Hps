package hps.ma.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateCardLimitsRequest {
    private Double dailyLimit;
    private Double monthlyLimit;
    private Double annualOrEcommerceLimit;
}