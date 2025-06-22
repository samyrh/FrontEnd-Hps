package hps.ma.userservice.services;


import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@Service
public class VirtualCardOtpService {

    private final Map<String, String> otpStore = new HashMap<>();
    private final Random random = new Random();

    public String generateOtp(String username) {
        String otp = String.format("%06d", random.nextInt(1000000));
        otpStore.put(username, otp);
        System.out.println("🔐 Virtual Card OTP generated for " + username + ": " + otp);
        return otp;
    }

    public boolean verifyOtp(String username, String otp) {
        String stored = otpStore.get(username);
        if (stored != null && stored.equals(otp)) {
            otpStore.remove(username);
            return true;
        }
        return false;
    }
}
