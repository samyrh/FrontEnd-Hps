package hps.ma.userservice.batch.otp;


import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Random;

@Slf4j
@Component
public class OtpProcessor {

    public String generateOtp() {
        return String.valueOf(100000 + new Random().nextInt(900000));
    }

    public boolean validateOtp(String expected, String provided) {
        return expected != null && expected.equals(provided);
    }
}
