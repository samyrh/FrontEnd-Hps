package hps.ma.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdatePhysicalSecurityOptionRequest {
    private Long cardId;
    private Boolean contactlessEnabled;
    private Boolean ecommerceEnabled;
    private Boolean tpeEnabled;
    private Boolean internationalWithdrawEnabled;
}
