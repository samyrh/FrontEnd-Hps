package hps.ma.dto;

import lombok.Data;

@Data
public class UpdateCardFeaturesRequest {
    private Boolean contactlessEnabled;
    private Boolean ecommerceEnabled;
    private Boolean tpeEnabled;
    private Boolean internationalWithdraw;
}