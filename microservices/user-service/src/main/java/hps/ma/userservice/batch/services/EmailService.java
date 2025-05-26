package hps.ma.userservice.batch.services;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    public void sendOtpEmail(String to, String otp) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, "utf-8");

            String html = """
                <div style="font-family: 'Segoe UI', sans-serif; padding: 20px; background-color: #f6f8fb;">
                    <div style="max-width: 480px; margin: auto; background: white; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); padding: 30px;">
                        <h2 style="text-align: center; color: #333;">🔐 Vérification de sécurité</h2>
                        <p style="font-size: 15px; color: #555; text-align: center;">
                            Voici votre code de vérification à usage unique :
                        </p>
                        <div style="margin: 24px auto; width: fit-content; background: #f0f4ff; padding: 14px 32px; border-radius: 8px; font-size: 24px; font-weight: bold; letter-spacing: 2px; color: #2e4aad;">
                            %s
                        </div>
                        <p style="font-size: 14px; color: #777; text-align: center;">
                            Ce code est valable pendant 5 minutes. Ne le partagez avec personne.
                        </p>
                        <p style="margin-top: 32px; font-size: 13px; color: #aaa; text-align: center;">
                            © 2025 YourBank. Tous droits réservés.
                        </p>
                    </div>
                </div>
                """.formatted(otp);

            helper.setTo(to);
            helper.setSubject("🔐 Code de vérification (OTP)");
            helper.setText(html, true); // Enable HTML content
            helper.setFrom("noreply@yourbank.com"); // Optional branding

            mailSender.send(message);
            log.info("✅ OTP email sent to {}", to);
        } catch (MessagingException e) {
            log.error("❌ Failed to send OTP email to {}", to, e);
        }
    }
}
