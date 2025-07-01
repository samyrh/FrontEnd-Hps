package hps.ma.userservice.web;

import hps.ma.userservice.batch.otp.OtpBatchJob;
import hps.ma.userservice.batch.otp.OtpJobResult;
import hps.ma.userservice.dao.entities.Cardholder;
import hps.ma.userservice.dao.repositories.CardholderReository;
import hps.ma.userservice.dto.change_password.ChangePasswordRequest;
import hps.ma.userservice.dto.security_code.SecurityCodeRequest;
import hps.ma.userservice.services.CardholderService;
import hps.ma.userservice.services.VirtualCardOtpService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/cardholders")
@RequiredArgsConstructor
public class CardholderController {

    private final CardholderService cardholderService;
    private final CardholderReository cardholderReository;
    private final PasswordEncoder passwordEncoder;
    private final OtpBatchJob otpBatchJob;
    private final VirtualCardOtpService virtualCardOtpService;


    @PreAuthorize("hasRole('CARDHOLDER')")
    @PostMapping("/security-code")
    public ResponseEntity<String> submitSecurityCode(@RequestBody SecurityCodeRequest request,
                                                     Authentication authentication) {
        String username = authentication.getName();
        System.out.println("🔐 Extracted username from token: " + username);

        Long cardholderId = cardholderService.setSecurityCodeByUsername(username, request.getSecurityCode());

        System.out.println("✅ Security code set for cardholder ID: " + cardholderId);

        return ResponseEntity.ok("Security code set successfully.");
    }

    @PostMapping("/password/verify")
    @PreAuthorize("hasRole('CARDHOLDER')")
    public ResponseEntity<?> verifyPassword(@RequestBody Map<String, String> payload,
                                            Authentication authentication) {
        String username = authentication.getName();
        String oldPassword = payload.get("oldPassword");

        Optional<Cardholder> optional = cardholderReository.findByUsername(username);
        if (optional.isPresent() &&
                passwordEncoder.matches(oldPassword, optional.get().getPassword())) {
            return ResponseEntity.ok().build(); // ✅ 200 = valid
        } else {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Invalid current password");
        }
    }


    @PreAuthorize("hasRole('CARDHOLDER')")
    @PatchMapping("/password")
    public ResponseEntity<String> changePassword(@RequestBody ChangePasswordRequest request,
                                                 Authentication authentication) {
        String username = authentication.getName();
        cardholderService.changePassword(username, request);
        return ResponseEntity.ok("Password changed successfully.");
    }
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> payload) {
        String username = payload.get("username");
        String newPassword = payload.get("newPassword");

        try {
            cardholderService.resetPasswordPublicly(username, newPassword);
            return ResponseEntity.ok("Password reset successfully");
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @PostMapping("/verify-username")
    public ResponseEntity<?> verifyUsername(@RequestBody Map<String, String> request) {
        String username = request.get("username");

        Optional<Cardholder> cardholderOpt = cardholderReository.findByUsername(username);
        if (cardholderOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
        }

        String email = cardholderOpt.get().getEmail();

        // ✅ Send OTP via batch job
        OtpJobResult result = otpBatchJob.execute(email);

        return ResponseEntity.ok(result);
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String otp = request.get("otp");

        Optional<Cardholder> cardholderOpt = cardholderReository.findByUsername(username);
        if (cardholderOpt.isEmpty()) {
            return ResponseEntity.status(404).body("User not found");
        }

        String email = cardholderOpt.get().getEmail();

        // 🔍 Add debug logs
        System.out.println("📨 Verifying OTP: " + otp + " for email: " + email);

        OtpJobResult result = otpBatchJob.verify(email, otp);

        System.out.println("🔍 Result: " + result);
        System.out.println("✅ Success: " + result.isSuccess());

        return result.isSuccess()
                ? ResponseEntity.ok(result)
                : ResponseEntity.status(401).body(result);
    }

    @GetMapping("/internal/by-username/{username}")
    public ResponseEntity<Map<String, Object>> getCardholderIdByUsername(@PathVariable String username) {
        return cardholderReository.findByUsername(username)
                .<ResponseEntity<Map<String, Object>>>map(cardholder ->
                        ResponseEntity.ok(Map.of("id", cardholder.getId())))
                .orElse(ResponseEntity.status(404).body(Map.of("error", "User not found")));
    }




    @GetMapping("/internal/by-id/{id}")
    public ResponseEntity<Map<String, Object>> getCardholderById(@PathVariable Long id) {
        return cardholderReository.findById(id)
                .<ResponseEntity<Map<String, Object>>>map(cardholder ->
                        ResponseEntity.ok(Map.of(
                                "id", cardholder.getId(),
                                "cardholderName", cardholder.getUsername(),
                                "email", cardholder.getEmail()
                        )))
                .orElse(ResponseEntity.status(404).body(Map.of("error", "Cardholder not found")));
    }


    @PreAuthorize("hasRole('CARDHOLDER')")
    @GetMapping("/me")
    public ResponseEntity<Map<String, Object>> getMyInfo(Authentication authentication) {
        String username = authentication.getName();
        Optional<Cardholder> optional = cardholderReository.findByUsername(username);

        if (optional.isPresent()) {
            Cardholder cardholder = optional.get();
            return ResponseEntity.ok(Map.of(
                    "id", cardholder.getId(),
                    "username", cardholder.getUsername(),
                    "email", cardholder.getEmail()
            ));
        } else {
            return ResponseEntity.status(404).body(Map.of("error", "User not found"));
        }
    }

    
    // ✅ Generate OTP for Virtual Card
    @PostMapping("/virtual-card/generate-otp")
    public ResponseEntity<?> generateVirtualCardOtp(@RequestBody Map<String, String> request) {
        String username = request.get("username");

        Optional<Cardholder> cardholderOpt = cardholderReository.findByUsername(username);
        if (cardholderOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
        }

        String email = cardholderOpt.get().getEmail();

        // 📨 Send OTP via batch job (reusing existing job)
        OtpJobResult result = otpBatchJob.execute(email);

        return ResponseEntity.ok(result);
    }

    // ✅ Verify OTP for Virtual Card
    @PostMapping("/virtual-card/verify-otp")
    public ResponseEntity<?> verifyVirtualCardOtp(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String otp = request.get("otp");

        Optional<Cardholder> cardholderOpt = cardholderReository.findByUsername(username);
        if (cardholderOpt.isEmpty()) {
            return ResponseEntity.status(404).body("User not found");
        }

        String email = cardholderOpt.get().getEmail();

        System.out.println("📨 Verifying Virtual Card OTP: " + otp + " for email: " + email);

        OtpJobResult result = otpBatchJob.verify(email, otp);

        return result.isSuccess()
                ? ResponseEntity.ok(result)
                : ResponseEntity.status(401).body(result);
    }


    @PreAuthorize("hasRole('CARDHOLDER')")
    @PatchMapping("/biometric")
    public ResponseEntity<?> updateBiometric(@RequestBody Map<String, Boolean> payload,
                                             Authentication authentication) {
        String username = authentication.getName();
        boolean enabled = payload.getOrDefault("enabled", false);

        boolean result = cardholderService.updateBiometricStatus(username, enabled);
        return ResponseEntity.ok(Map.of("enabled", result));
    }



    
    @PreAuthorize("hasRole('CARDHOLDER')")
    @GetMapping("/biometric")
    public ResponseEntity<?> getBiometric(Authentication authentication) {
        String username = authentication.getName();
        boolean status = cardholderService.getBiometricStatus(username);
        return ResponseEntity.ok(Map.of("enabled", status));
    }


    @PostMapping("/physical-card/generate-otp")
    public ResponseEntity<?> generatePhysicalCardOtp(@RequestBody Map<String, String> request) {
        String username = request.get("username");

        Optional<Cardholder> cardholderOpt = cardholderReository.findByUsername(username);
        if (cardholderOpt.isEmpty()) {
            return ResponseEntity.status(404).body("User not found");
        }

        String email = cardholderOpt.get().getEmail();

        // 📨 Send OTP via batch job (reusing the same mechanism)
        OtpJobResult result = otpBatchJob.execute(email);

        return ResponseEntity.ok(result);
    }


    @PostMapping("/physical-card/verify-otp")
    public ResponseEntity<?> verifyPhysicalCardOtp(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String otp = request.get("otp");

        Optional<Cardholder> cardholderOpt = cardholderReository.findByUsername(username);
        if (cardholderOpt.isEmpty()) {
            return ResponseEntity.status(404).body("User not found");
        }

        String email = cardholderOpt.get().getEmail();

        System.out.println("📨 Verifying Physical Card OTP: " + otp + " for email: " + email);

        OtpJobResult result = otpBatchJob.verify(email, otp);

        return result.isSuccess()
                ? ResponseEntity.ok(result)
                : ResponseEntity.status(401).body(result);
    }

}
