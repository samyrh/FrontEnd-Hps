package hps.ma.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class VirtualCardSecurityOptionsDTO {
    private String label;
    private Boolean ecommerceEnabled;
    private String username;
    private String cardholderName;
}
