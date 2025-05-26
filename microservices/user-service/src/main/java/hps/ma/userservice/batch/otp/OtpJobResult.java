package hps.ma.userservice.batch.otp;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class OtpJobResult {
    private boolean success;
    private String message;
}