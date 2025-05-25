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

    @Scheduled(fixedRate = 300000) // every 5 minutes
    public void sendBufferedEmails() {
        List<EventPayload> queue = emailBuffer.drain();

        for (EventPayload payload : queue) {
            try {
                String decrypted = AESUtil.decrypt(payload.getPassword());
                emailService.sendCredentialsEmail(payload.getEmail(), payload.getUsername(), decrypted);
            } catch (Exception e) {
                System.err.println("❌ Failed to email: " + payload.getEmail());
                e.printStackTrace();
            }
        }
    }
}

