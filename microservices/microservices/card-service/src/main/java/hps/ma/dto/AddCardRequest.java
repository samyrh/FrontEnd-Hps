package hps.ma.dto;


import hps.ma.dao.enums.CardType;
import lombok.Data;

@Data
public class AddCardRequest {
    private String cardPackLabel;
    private String type;
    private String gradientStartColor;
    private String gradientEndColor;
}