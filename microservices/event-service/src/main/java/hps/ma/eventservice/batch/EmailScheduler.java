package hps.ma.eventservice.batch;

import hps.ma.eventservice.dto.EventPayload;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class EmailScheduler {

    private final EmailBuffer emailBuffer;
    private final EmailService emailService;

    @Scheduled(fixedRate = 30000) // 30 seconds for testing; change to 300000 (5 mins) in production
    public void sendBufferedEmails() {
        List<EventPayload> queue = emailBuffer.drain();
        System.out.println("📬 [Scheduler] Processing " + queue.size() + " buffered email(s)...");

        for (EventPayload payload : queue) {
            try {
                String message = payload.getMessage() != null ? payload.getMessage().toLowerCase() : "";

                if (message.contains("changed their password")) {
                    String decryptedPassword = AESUtil.decrypt(payload.getPassword());
                    emailService.sendPasswordChangedEmail(payload.getEmail(), payload.getUsername(), decryptedPassword);
                    System.out.println("✅ [Scheduler] Password change email sent to: " + payload.getEmail());

                } else if (message.contains("reset their password")) {
                    String decryptedPassword = AESUtil.decrypt(payload.getPassword());
                    emailService.sendPasswordResetEmail(payload.getEmail(), payload.getUsername(), decryptedPassword);
                    System.out.println("✅ [Scheduler] Password reset email sent to: " + payload.getEmail());

                } else if (message.contains("pin updated")) {
                    // ✅ No decryption needed for PIN update
                    emailService.sendPinUpdateEmail(payload.getEmail(), payload.getUsername());
                    System.out.println("✅ [Scheduler] PIN update email sent to: " + payload.getEmail());

                } else {
                    // Default: likely credentials (account creation)
                    String decryptedPassword = AESUtil.decrypt(payload.getPassword());
                    emailService.sendCredentialsEmail(payload.getEmail(), payload.getUsername(), decryptedPassword);
                    System.out.println("✅ [Scheduler] Account creation email sent to: " + payload.getEmail());
                }

            } catch (Exception e) {
                System.err.println("❌ [Scheduler] Failed to send email to: " + payload.getEmail());
                e.printStackTrace();
            }
        }
    }
}
