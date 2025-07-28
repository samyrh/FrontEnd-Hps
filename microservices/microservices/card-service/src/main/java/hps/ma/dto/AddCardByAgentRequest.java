package hps.ma.dto;

import lombok.Data;

@Data
public class AddCardByAgentRequest {
    private Long cardholderId;
    private String type;
    private String cardPackLabel;
    private String gradientStartColor;
    private String gradientEndColor;
}
