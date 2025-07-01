package hps.ma.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CardSecurityOptionsWithIdDTO {
    private Long cardId;
    private String label;
    private Boolean contactlessEnabled;
    private Boolean ecommerceEnabled;
    private Boolean tpeEnabled;
    private Boolean internationalWithdrawEnabled;
    private String username;
    private String cardholderName;
}