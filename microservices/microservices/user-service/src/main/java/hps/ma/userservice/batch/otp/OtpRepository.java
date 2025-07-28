package hps.ma.userservice.batch.otp;

import org.springframework.stereotype.Repository;

import java.util.concurrent.ConcurrentHashMap;

@Repository
public class OtpRepository {

    private final ConcurrentHashMap<String, String> otpStore = new ConcurrentHashMap<>();

    public void save(String email, String otp) {
        otpStore.put(email, otp);
    }

    public String findByEmail(String email) {
        return otpStore.get(email);
    }

    public void delete(String email) {
        otpStore.remove(email);
    }
}
