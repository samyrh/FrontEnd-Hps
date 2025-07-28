package hps.ma.dto;

import lombok.Data;

@Data
public class UpdatePinRequest {
    private String currentPin;
    private String newPin;
}