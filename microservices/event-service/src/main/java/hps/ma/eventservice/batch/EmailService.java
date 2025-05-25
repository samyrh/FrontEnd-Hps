package hps.ma.eventservice.batch;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    public void sendCredentialsEmail(String to, String username, String password) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, "utf-8");

        String html = """
        <html>
        <body style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; color: #333;">
            <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.05); padding: 30px;">
                <h2 style="color: #004085;">🎉 Welcome to <strong>HPS</strong> – Your Account Is Ready</h2>
                <p>Dear <strong>%s</strong>,</p>

                <p>We are pleased to inform you that your cardholder account has been successfully created in our secure system.</p>

                <p><strong>Below are your temporary login credentials:</strong></p>
                <div style="padding: 15px; background-color: #e9ecef; border-left: 4px solid #007bff; margin-bottom: 20px;">
                    <p><strong>Username:</strong> %s</p>
                    <p><strong>Password:</strong> %s</p>
                </div>

                <p><strong>What happens next?</strong></p>
                <ol>
                    <li>Log in to your HPS portal using the above credentials.</li>
                    <li>For your security, you will be prompted to change your password on first login.</li>
                    <li>Enable biometric login or two-factor authentication (optional but recommended).</li>
                </ol>

                <p>If you have any questions or encounter issues during your first login, feel free to reach out to our support team.</p>

                <p style="margin-top: 30px; font-size: 15px;">
                    🔒 <strong>Your security matters to us.</strong><br>
                    Never share your login information. HPS will never ask for your password via email or phone.
                </p>

                <hr style="margin: 30px 0;">

                <p style="font-size: 13px; color: #666;">
                    📩 This is an automated message. Please do not reply directly to this email.<br>
                    If you need help, contact our support team at <a href="mailto:support@hps.com">support@hps.com</a> or visit our help center.
                </p>

                <p style="font-size: 12px; color: #aaa; margin-top: 40px;">
                    © %s HPS Technologies. All rights reserved.
                </p>
            </div>
        </body>
        </html>
        """.formatted(username, username, password, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("🎉 Welcome to HPS – Secure Account Setup");
        helper.setText(html, true); // true = send as HTML
        helper.setFrom("no-reply@hps.com");

        mailSender.send(message);
    }
    public void sendPasswordChangedEmail(String to, String username, String newPassword) throws MessagingException {

        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 30px;">
  <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">
    
    <h2 style="color: #1a1a1a; font-size: 22px;">🔐 Password Changed Successfully</h2>
    <p>Hi <strong>%s</strong>,</p>
    <p>Your password was successfully updated. Here are your updated credentials:</p>
    
    <div style="background-color: #e9f7ef; padding: 16px; border-left: 5px solid #28a745; border-radius: 6px; margin: 20px 0;">
      <p style="margin: 0;"><strong>Username:</strong> %s</p>
      <p style="margin: 0;"><strong>New Password:</strong> %s</p>
    </div>

    <p>If this was not you, please reset your password immediately or contact support.</p>

    <h4 style="color: #1a1a1a; margin-top: 32px;">🛡️ Security Tips</h4>
    <ul style="color: #333; padding-left: 20px;">
      <li>Use a unique password for each account.</li>
      <li>Never share your password via email or phone.</li>
      <li>Enable two-factor authentication (if available).</li>
    </ul>

    <p style="margin-top: 30px; font-size: 14px;">
      If you have questions, contact us at <a href="mailto:support@hps.com">support@hps.com</a>.
    </p>

    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ccc;">
    <p style="font-size: 12px; color: #888; text-align: center;">© %s HPS Technologies. All rights reserved.</p>
  </div>
</body>
</html>
""".formatted(username, username, newPassword, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("🔐 Your Password Has Been Successfully Changed");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(message);
    }
    public void sendPasswordResetEmail(String to, String username, String newPassword) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, "utf-8");

        String html = """
    <html>
    <body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 30px;">
      <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">

        <h2 style="color: #1a1a1a; font-size: 22px;">🔁 Password Reset Confirmation</h2>
        <p>Hi <strong>%s</strong>,</p>
        <p>Your password was reset by request. Below are your updated credentials:</p>

        <div style="background-color: #fff3cd; padding: 16px; border-left: 5px solid #ffc107; border-radius: 6px; margin: 20px 0;">
          <p style="margin: 0;"><strong>Username:</strong> %s</p>
          <p style="margin: 0;"><strong>New Password:</strong> %s</p>
        </div>

        <p>Please log in and change this password immediately if you did not request this reset.</p>

        <h4 style="color: #1a1a1a; margin-top: 32px;">🛡️ Security Tips</h4>
        <ul style="color: #333; padding-left: 20px;">
          <li>Use a unique password for each account.</li>
          <li>Never share your password via email or phone.</li>
          <li>Enable two-factor authentication if available.</li>
        </ul>

        <p style="margin-top: 30px; font-size: 14px;">
          Need help? Contact us at <a href="mailto:support@hps.com">support@hps.com</a>.
        </p>

        <hr style="margin: 40px 0; border: none; border-top: 1px solid #ccc;">
        <p style="font-size: 12px; color: #888; text-align: center;">© %s HPS Technologies. All rights reserved.</p>
      </div>
    </body>
    </html>
    """.formatted(username, username, newPassword, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("🔁 Your HPS Password Was Reset");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(message);
    }

}
