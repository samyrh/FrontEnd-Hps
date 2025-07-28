package hps.ma.userservice.batch.otp;



import hps.ma.userservice.batch.services.EmailService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class OtpBatchJob {

    private final OtpProcessor otpProcessor;
    private final OtpRepository otpRepository;
    private final EmailService emailService;

    public OtpJobResult execute(String email) {
        String otp = otpProcessor.generateOtp();
        otpRepository.save(email, otp);
        emailService.sendOtpEmail(email, otp);
        return new OtpJobResult(true, "OTP sent to " + email);
    }

    public OtpJobResult verify(String email, String userOtp) {
        String stored = otpRepository.findByEmail(email);
        boolean valid = otpProcessor.validateOtp(stored, userOtp);
        if (valid) {
            otpRepository.delete(email);
            return new OtpJobResult(true, "OTP verified");
        } else {
            return new OtpJobResult(false, "Invalid OTP");
        }
    }
}
