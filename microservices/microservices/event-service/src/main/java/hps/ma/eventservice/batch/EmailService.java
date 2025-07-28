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
    public void sendPinUpdateEmail(String to, String username) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 30px;">
  <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">
    
    <h2 style="color: #1a1a1a; font-size: 22px;">🔢 PIN Code Successfully Updated</h2>
    <p>Hi <strong>%s</strong>,</p>
    <p>This is to inform you that your PIN code was successfully updated for your card.</p>

    <div style="background-color: #e2e3e5; padding: 16px; border-left: 5px solid #17a2b8; border-radius: 6px; margin: 20px 0;">
      <p style="margin: 0;"><strong>Cardholder:</strong> %s</p>
      <p style="margin: 0;"><strong>Action:</strong> PIN Update</p>
      <p style="margin: 0;"><strong>Date:</strong> %s</p>
    </div>

    <p>If you did not request this change, please contact our support team immediately to secure your account.</p>

    <h4 style="color: #1a1a1a; margin-top: 32px;">🛡️ Security Tips</h4>
    <ul style="color: #333; padding-left: 20px;">
      <li>Never share your PIN or password with anyone.</li>
      <li>Update your credentials regularly for better security.</li>
      <li>Enable two-factor authentication whenever possible.</li>
    </ul>

    <p style="margin-top: 30px; font-size: 14px;">
      If you have any concerns, contact our support team at <a href="mailto:support@hps.com">support@hps.com</a>.
    </p>

    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ccc;">
    <p style="font-size: 12px; color: #888; text-align: center;">© %s HPS Technologies. All rights reserved.</p>
  </div>
</body>
</html>
""".formatted(username, username, new java.text.SimpleDateFormat("dd MMM yyyy, HH:mm").format(new Date()), java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("🔢 Your Card PIN Has Been Updated");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(message);
    }
    public void sendTransactionEmail(String to, String username, String details) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 30px;">
 
    
    <h2 style="color: #004085; text-align: center; margin-bottom: 24px; font-weight: 600; font-size: 22px;">
      💳 HPS eBanking – Transaction Alert
    </h2>
    
    <p style="font-size: 16px; color: #333;">Dear <strong>%s</strong>,</p>
    <p style="font-size: 15px; color: #333;">A new transaction has been recorded on your <strong>HPS eBanking</strong> account. Please review the details below:</p>

    <div style="margin: 25px 0; padding: 18px; border: 1px solid #007bff; border-radius: 8px; background-color: #f0f4ff; font-size: 15px; color: #333; text-align: justify;">
      %s
    </div>


    <p style="font-size: 15px; color: #333;">If you did not authorize this transaction, please contact our support team immediately.</p>

    <h4 style="color: #333; margin-top: 28px; font-size: 16px;">🔒 Security Tips</h4>
    <ul style="font-size: 14px; color: #333; padding-left: 20px; margin-top: 10px;">
      <li>Never share your login credentials.</li>
      <li>Enable two-factor authentication in your profile settings.</li>
      <li>Regularly monitor your transactions for unusual activity.</li>
    </ul>

    <p style="margin-top: 28px; font-size: 14px;">
      For assistance, contact us at <a href="mailto:support@hps.com">support@hps.com</a>.
    </p>

    <hr style="margin: 38px 0; border: none; border-top: 1px solid #ccc;">

    <p style="font-size: 12px; color: #888; text-align: center;">
      © %s HPS eBanking. All rights reserved.
    </p>

</body>
</html>
""".formatted(username, details, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("💳 HPS eBanking – Transaction Alert");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(message);
    }
    public void sendAccountSuspendedEmail(String to, String username, String reason) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 30px;">
  <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">

    <h2 style="color: #c82333; font-size: 22px;">🚫 Account Suspension Notice</h2>
    <p>Hi <strong>%s</strong>,</p>
    <p>We regret to inform you that your account has been <strong>suspended</strong> as part of our HPS eBanking security policy.</p>

    <div style="background-color: #f8d7da; padding: 16px; border-left: 5px solid #dc3545; border-radius: 6px; margin: 20px 0;">
      <p style="margin: 0;"><strong>Reason:</strong></p>
      <p style="margin: 0;">%s</p>
    </div>

    <p>If you believe this suspension was in error or wish to appeal, please contact our support team immediately.</p>

    <h4 style="color: #1a1a1a; margin-top: 32px;">🔒 HPS eBanking Policy</h4>
    <ul style="color: #333; padding-left: 20px;">
      <li>Account suspensions help protect you from unauthorized activity.</li>
      <li>Never share your login credentials with anyone.</li>
      <li>Always enable two-factor authentication for increased security.</li>
      <li>Regularly review your account for any suspicious activity.</li>
    </ul>

    <h4 style="color: #1a1a1a; margin-top: 32px;">📞 Contact Support</h4>
    <p style="margin-bottom: 0;">Email: <a href="mailto:support@hps.com">support@hps.com</a></p>
    <p style="margin-top: 0;">Phone: +1-800-HPS-HELP</p>

    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ccc;">
    <p style="font-size: 12px; color: #888; text-align: center;">© %s HPS eBanking. All rights reserved.</p>
  </div>
</body>
</html>
""".formatted(username, reason, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("🚫 Your HPS eBanking Account Has Been Suspended");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(message);
    }
    public void sendAccountUnsuspendedEmail(String to, String username) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 30px;">
  <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">

    <h2 style="color: #28a745; font-size: 22px;">✅ Account Reactivated</h2>
    <p>Hi <strong>%s</strong>,</p>
    <p>We’re pleased to inform you that your HPS eBanking account has been <strong>re-activated</strong>.</p>

    <p>You can now log in and resume using your services as usual.</p>

    <h4 style="color: #1a1a1a; margin-top: 32px;">🔒 HPS eBanking Policy Reminder</h4>
    <ul style="color: #333; padding-left: 20px;">
      <li>Never share your login credentials.</li>
      <li>Enable two-factor authentication for extra security.</li>
      <li>Contact us immediately if you notice any unusual activity.</li>
    </ul>

    <h4 style="color: #1a1a1a; margin-top: 32px;">📞 Contact Support</h4>
    <p>Email: <a href="mailto:support@hps.com">support@hps.com</a></p>
    <p>Phone: +1-800-HPS-HELP</p>

    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ccc;">
    <p style="font-size: 12px; color: #888; text-align: center;">© %s HPS eBanking. All rights reserved.</p>
  </div>
</body>
</html>
""".formatted(username, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("✅ Your Account Has Been Reactivated");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(message);
    }
    public void sendAgentCardCreatedEmail(String to, String cardholderName, String message) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 40px;">
  <div style="max-width: 800px; margin: auto; background-color: #ffffff; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.05); padding: 40px;">

    <h2 style="color: #003366; font-size: 24px; margin-bottom: 20px;">New Card Issued Notification</h2>

    <p style="font-size: 15px; color: #333;">Dear <strong>%s</strong>,</p>

    <p style="font-size: 15px; color: #333;">
      This message confirms that a new card has been issued and securely associated with your HPS eBanking account.
      This action was completed by an authorized HPS agent as part of our account services.
    </p>

    <div style="background: #f5f5f5; padding: 18px; border-left: 4px solid #007bff; color: #333; margin: 28px 0;">
      <p style="margin: 0; font-size: 14px;"><strong>Card Details:</strong></p>
      <p style="margin: 0; font-size: 14px;">%s</p>
    </div>

    <h3 style="color: #1a1a1a; font-size: 16px; margin-top: 32px;">Important Next Steps</h3>
    <p style="font-size: 14px; color: #333;">
      Please review the card details above carefully. If you did not request or authorize this card, contact our support team immediately. 
      You can also review your account activity through the HPS eBanking portal at any time.
    </p>

    <h3 style="color: #1a1a1a; font-size: 16px; margin-top: 32px;">HPS eBanking Policy and Security Guidelines</h3>
    <ul style="font-size: 14px; color: #333; padding-left: 20px;">
      <li>Do not share your card number, PIN, or CVV with any person or third party.</li>
      <li>Enable two-factor authentication for additional security.</li>
      <li>Regularly monitor your account for any unusual transactions.</li>
      <li>HPS will never request your login credentials or sensitive information by email or phone.</li>
      <li>Keep this email as a record of your card issuance for your personal files.</li>
    </ul>

    <p style="font-size: 14px; color: #333; margin-top: 20px;">
      Your trust and security are important to us. Thank you for using HPS eBanking.
    </p>

    <h3 style="color: #1a1a1a; font-size: 16px; margin-top: 32px;">Contact HPS eBanking Support</h3>
    <p style="font-size: 14px;">
      If you have any questions or require assistance, please contact us:
    </p>
    <p style="font-size: 14px; margin: 4px 0;">
      Email: <a href="mailto:support@hps.com">support@hps.com</a>
    </p>
    <p style="font-size: 14px; margin: 0;">
      Phone: +1-800-HPS-HELP
    </p>

    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ccc;">

    <p style="font-size: 12px; color: #888; text-align: center;">
      © %s HPS eBanking. All rights reserved.
    </p>
  </div>
</body>
</html>
""".formatted(cardholderName, message, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("New Card Issued Notification");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(mimeMessage);
    }
    public void sendAgentCardApprovedEmail(String to, String username, String message) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 30px;">
  <div style="max-width: 700px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 10px rgba(0,0,0,0.05); padding: 32px;">

    <h2 style="color: #004085; font-size: 22px;">✅ Your New Card Has Been Approved</h2>

    <p style="font-size: 15px; color: #333;">
      Dear <strong>%s</strong>,
    </p>

    <p style="font-size: 15px; color: #333;">
      We're pleased to inform you that your new card request has been <strong>approved and activated</strong>.
      You can now start using your card for secure transactions and purchases.
    </p>

    <div style="background-color: #e9f7ef; padding: 16px; border-left: 5px solid #28a745; border-radius: 6px; margin: 24px 0; color: #333;">
      <p style="margin: 0; font-size: 14px;"><strong>Details:</strong></p>
      <p style="margin: 0; font-size: 14px;">%s</p>
    </div>

    <p style="font-size: 14px; color: #333;">
      If you have any pending card block requests, they will be automatically canceled to ensure uninterrupted use of your new card.
    </p>

    <p style="font-size: 14px; color: #333;">
      If you did not request this card or believe this approval was made in error, please contact our support team <strong>immediately</strong>.
    </p>

    <h4 style="color: #1a1a1a; margin-top: 32px;">🔒 HPS eBanking Security Policy</h4>
    <ul style="font-size: 14px; color: #333; padding-left: 20px;">
      <li>Never share your card number, PIN, or CVV with anyone.</li>
      <li>Enable two-factor authentication for added security.</li>
      <li>Regularly review your account activity and report suspicious transactions.</li>
      <li>HPS will never ask for your login credentials or personal data via email or phone.</li>
    </ul>

    <h4 style="color: #1a1a1a; margin-top: 32px;">📞 Need Assistance?</h4>
    <p style="font-size: 14px;">
      Our support team is available to help you 24/7:
    </p>
    <p style="font-size: 14px; margin: 4px 0;">
      Email: <a href="mailto:support@hps.com">support@hps.com</a>
    </p>
    <p style="font-size: 14px; margin: 0;">
      Phone: +1-800-HPS-HELP
    </p>

    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ccc;">

    <p style="font-size: 12px; color: #888; text-align: center;">
      © %s HPS eBanking. All rights reserved.
    </p>
  </div>
</body>
</html>
""".formatted(username, message, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("✅ Your New Card Has Been Approved – HPS eBanking");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(mimeMessage);
    }
    public void sendAgentCardRejectedEmail(String to, String username, String reason) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

        String html = """
    <html>
    <body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 40px;">
      <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">
        
        <h2 style="color: #d93025; font-size: 24px; margin-bottom: 16px;">🚫 Card Request Rejected</h2>
        
        <p style="font-size: 16px; color: #333;">
          Hello <strong>%s</strong>,
        </p>
        
        <p style="font-size: 15px; color: #333; line-height: 1.6;">
          We regret to inform you that your recent card request has been <strong style="color: #d93025;">rejected</strong>.
        </p>
        
        <div style="background-color: #fce8e6; padding: 18px; border-left: 5px solid #d93025; border-radius: 6px; margin: 24px 0;">
          <p style="margin:0; font-size: 15px; color:#333;">
            <strong>Reason for Rejection:</strong><br>
            %s
          </p>
        </div>
        
        <p style="font-size: 15px; color: #333; line-height: 1.6;">
          If you believe this decision was made in error or you would like to discuss this further, please contact our support team. We are here to help you.
        </p>
        
        <a href="mailto:support@hps.com" style="display: inline-block; margin-top: 24px; padding: 12px 20px; background-color: #007bff; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 500;">
          Contact Support
        </a>
        
        <hr style="margin: 40px 0; border: none; border-top: 1px solid #ddd;">
        
        <p style="font-size: 13px; color: #777;">
          🔒 For your security, never share your account credentials or personal information via email.
        </p>
        
        <p style="font-size: 12px; color: #aaa; text-align: center; margin-top: 30px;">
          © %s HPS eBanking. All rights reserved.
        </p>
      </div>
    </body>
    </html>
    """.formatted(username, reason, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("🚫 Your Card Request Has Been Rejected");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(mimeMessage);
    }
    public void sendAgentPhysicalCardBlockedEmail(String to, String username, String reason) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 40px;">
  <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">
    
    <h2 style="color: #d93025; font-size: 24px; margin-bottom: 16px;">🔒 Card Blocked Permanently</h2>
    
    <p style="font-size: 16px; color: #333;">
      Hello <strong>%s</strong>,
    </p>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      We are writing to inform you that your physical card has been <strong style="color: #d93025;">permanently blocked</strong> by our support team for security reasons.
    </p>
    
    <div style="background-color: #fce8e6; padding: 18px; border-left: 5px solid #d93025; border-radius: 6px; margin: 24px 0;">
      <p style="margin:0; font-size: 15px; color:#333;">
        <strong>Reason for Blocking:</strong><br>
        %s
      </p>
    </div>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      If you have any questions or need assistance with replacing your card, please contact our support team. We are here to help you.
    </p>
    
    <a href="mailto:support@hps.com" style="display: inline-block; margin-top: 24px; padding: 12px 20px; background-color: #007bff; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 500;">
      Contact Support
    </a>
    
    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ddd;">
    
    <p style="font-size: 13px; color: #777;">
      🔒 For your security, never share your account credentials or personal information via email.
    </p>
    
    <p style="font-size: 12px; color: #aaa; text-align: center; margin-top: 30px;">
      © %s HPS eBanking. All rights reserved.
    </p>
  </div>
</body>
</html>
""".formatted(username, reason, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("🔒 Your Physical Card Has Been Blocked");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(mimeMessage);
    }
    public void sendAgentPhysicalCardUnblockedEmail(String to, String username, String message) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

        String html = """
    <html>
    <body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 40px;">
      <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">
        
        <h2 style="color: #34a853; font-size: 24px; margin-bottom: 16px;">✅ Card Unblocked</h2>
        
        <p style="font-size: 16px; color: #333;">
          Hello <strong>%s</strong>,
        </p>
        
        <p style="font-size: 15px; color: #333; line-height: 1.6;">
          We’re pleased to inform you that your physical card has been <strong style="color: #34a853;">unblocked</strong> by our team.
        </p>
        
        <div style="background-color: #e6f4ea; padding: 18px; border-left: 5px solid #34a853; border-radius: 6px; margin: 24px 0;">
          <p style="margin:0; font-size: 15px; color:#333;">
            <strong>Details:</strong><br>
            %s
          </p>
        </div>
        
        <p style="font-size: 15px; color: #333; line-height: 1.6;">
          You can now resume using your card as usual. If you have any questions or require assistance, please don’t hesitate to contact our support team.
        </p>
        
        <a href="mailto:support@hps.com" style="display: inline-block; margin-top: 24px; padding: 12px 20px; background-color: #007bff; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 500;">
          Contact Support
        </a>
        
        <hr style="margin: 40px 0; border: none; border-top: 1px solid #ddd;">
        
        <p style="font-size: 13px; color: #777;">
          🔒 For your security, never share your account credentials or personal information via email.
        </p>
        
        <p style="font-size: 12px; color: #aaa; text-align: center; margin-top: 30px;">
          © %s HPS eBanking. All rights reserved.
        </p>
      </div>
    </body>
    </html>
    """.formatted(username, message, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("✅ Your Card Has Been Unblocked");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(mimeMessage);
    }
    public void sendAgentPhysicalCardCanceledEmail(String to, String username, String message) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 40px;">
  <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">
    
    <h2 style="color: #d93025; font-size: 24px; margin-bottom: 16px;">🔴 Card Canceled</h2>
    
    <p style="font-size: 16px; color: #333;">
      Hello <strong>%s</strong>,
    </p>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      We’re writing to inform you that your physical card has been <strong style="color: #d93025;">canceled</strong> by our support team.
    </p>
    
    <div style="background-color: #fce8e6; padding: 18px; border-left: 5px solid #d93025; border-radius: 6px; margin: 24px 0;">
      <p style="margin:0; font-size: 15px; color:#333;">
        <strong>Details:</strong><br>
        %s
      </p>
    </div>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      If you believe this action was taken in error or have any questions, please contact our support team immediately.
    </p>
    
    <a href="mailto:support@hps.com" style="display: inline-block; margin-top: 24px; padding: 12px 20px; background-color: #007bff; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 500;">
      Contact Support
    </a>
    
    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ddd;">
    
    <p style="font-size: 13px; color: #777;">
      🔒 For your security, never share your account credentials or personal information via email.
    </p>
    
    <p style="font-size: 12px; color: #aaa; text-align: center; margin-top: 30px;">
      © %s HPS eBanking. All rights reserved.
    </p>
  </div>
</body>
</html>
""".formatted(username, message, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("🔴 Your Card Has Been Canceled");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(mimeMessage);
    }
    public void sendAgentPhysicalCardUncanceledEmail(String to, String username, String message) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 40px;">
  <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">
    
    <h2 style="color: #34a853; font-size: 24px; margin-bottom: 16px;">✅ Card Uncanceled</h2>
    
    <p style="font-size: 16px; color: #333;">
      Hello <strong>%s</strong>,
    </p>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      Good news! Your physical card has been <strong style="color: #34a853;">reactivated</strong by our support team and is now active again.
    </p>
    
    <div style="background-color: #e6f4ea; padding: 18px; border-left: 5px solid #34a853; border-radius: 6px; margin: 24px 0;">
      <p style="margin:0; font-size: 15px; color:#333;">
        <strong>Details:</strong><br>
        %s
      </p>
    </div>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      You can now resume using your card as usual. If you need any assistance, please feel free to reach out to our support team.
    </p>
    
    <a href="mailto:support@hps.com" style="display: inline-block; margin-top: 24px; padding: 12px 20px; background-color: #007bff; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 500;">
      Contact Support
    </a>
    
    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ddd;">
    
    <p style="font-size: 13px; color: #777;">
      🔒 For your security, never share your account credentials or personal information via email.
    </p>
    
    <p style="font-size: 12px; color: #aaa; text-align: center; margin-top: 30px;">
      © %s HPS eBanking. All rights reserved.
    </p>
  </div>
</body>
</html>
""".formatted(username, message, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("✅ Your Card Has Been Reactivated");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(mimeMessage);
    }
    public void sendAgentPhysicalCardPinGeneratedEmail(String to, String username, String detailsMessage) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 40px;">
  <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">
    
    <h2 style="color: #4285f4; font-size: 24px; margin-bottom: 16px;">🔑 New PIN Generated</h2>
    
    <p style="font-size: 16px; color: #333;">
      Hello <strong>%s</strong>,
    </p>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      We’re letting you know that a new PIN code has been <strong style="color: #4285f4;">generated</strong for your physical card by our support team.
    </p>
    
    <div style="background-color: #e8f0fe; padding: 18px; border-left: 5px solid #4285f4; border-radius: 6px; margin: 24px 0;">
      <p style="margin:0; font-size: 15px; color:#333;">
        <strong>Details:</strong><br>
        %s
      </p>
    </div>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      If you did not request this change, please contact our support team immediately to help secure your account.
    </p>
    
    <a href="mailto:support@hps.com" style="display: inline-block; margin-top: 24px; padding: 12px 20px; background-color: #007bff; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 500;">
      Contact Support
    </a>
    
    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ddd;">
    
    <p style="font-size: 13px; color: #777;">
      🔒 For your security, never share your PIN or personal credentials via email.
    </p>
    
    <p style="font-size: 12px; color: #aaa; text-align: center; margin-top: 30px;">
      © %s HPS eBanking. All rights reserved.
    </p>
  </div>
</body>
</html>
""".formatted(
                username,
                detailsMessage != null ? detailsMessage : "N/A",
                java.time.Year.now()
        );

        helper.setTo(to);
        helper.setSubject("🔑 A New PIN Has Been Generated for Your Card");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(mimeMessage);
    }
    public void sendAgentCvvGeneratedEmail(String to, String username, String message) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 40px;">
  <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">
    
    <h2 style="color: #4285f4; font-size: 24px; margin-bottom: 16px;">🔑 New CVV Generated</h2>
    
    <p style="font-size: 16px; color: #333;">
      Hello <strong>%s</strong>,
    </p>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      A new CVV has been <strong style="color: #4285f4;">generated</strong for your card by our support team.
    </p>
    
    <div style="background-color: #e8f0fe; padding: 18px; border-left: 5px solid #4285f4; border-radius: 6px; margin: 24px 0;">
      <p style="margin:0; font-size: 15px; color:#333;">
        <strong>Details:</strong><br>
        %s
      </p>
    </div>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      For security reasons, please do not share this CVV with anyone. You can now use your updated CVV for your transactions.
    </p>
    
    <a href="mailto:support@hps.com" style="display: inline-block; margin-top: 24px; padding: 12px 20px; background-color: #007bff; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 500;">
      Contact Support
    </a>
    
    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ddd;">
    
    <p style="font-size: 13px; color: #777;">
      🔒 For your security, never share your account credentials or personal information via email.
    </p>
    
    <p style="font-size: 12px; color: #aaa; text-align: center; margin-top: 30px;">
      © %s HPS eBanking. All rights reserved.
    </p>
  </div>
</body>
</html>
""".formatted(username, message, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("🔑 Your New CVV Has Been Generated");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(mimeMessage);
    }
    public void sendAgentVirtualCardUnblockedEmail(String to, String username, String message) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 40px;">
  <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">
    
    <h2 style="color: #34a853; font-size: 24px; margin-bottom: 16px;">✅ Virtual Card Reactivated</h2>
    
    <p style="font-size: 16px; color: #333;">
      Hello <strong>%s</strong>,
    </p>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      We’re pleased to inform you that your virtual card has been <strong style="color: #34a853;">unblocked</strong> and is now active.
    </p>
    
    <div style="background-color: #e6f4ea; padding: 18px; border-left: 5px solid #34a853; border-radius: 6px; margin: 24px 0;">
      <p style="margin:0; font-size: 15px; color:#333;">
        <strong>Details:</strong><br>
        %s
      </p>
    </div>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      You can now resume online purchases and transactions with your virtual card. If you have any questions or require assistance, please contact our support team.
    </p>
    
    <a href="mailto:support@hps.com" style="display: inline-block; margin-top: 24px; padding: 12px 20px; background-color: #007bff; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 500;">
      Contact Support
    </a>
    
    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ddd;">
    
    <p style="font-size: 13px; color: #777;">
      🔒 For your security, never share your account credentials or personal information via email.
    </p>
    
    <p style="font-size: 12px; color: #aaa; text-align: center; margin-top: 30px;">
      © %s HPS eBanking. All rights reserved.
    </p>
  </div>
</body>
</html>
""".formatted(username, message, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("✅ Your Virtual Card Has Been Reactivated");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(mimeMessage);
    }
    public void sendAgentVirtualCardBlockedEmail(String to, String username, String message) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 40px;">
  <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">
    
    <h2 style="color: #d93025; font-size: 24px; margin-bottom: 16px;">❌ Virtual Card Blocked</h2>
    
    <p style="font-size: 16px; color: #333;">
      Hello <strong>%s</strong>,
    </p>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      We’d like to inform you that your virtual card has been <strong style="color: #d93025;">permanently blocked</strong> by our support team.
    </p>
    
    <div style="background-color: #fbe9e7; padding: 18px; border-left: 5px solid #d93025; border-radius: 6px; margin: 24px 0;">
      <p style="margin:0; font-size: 15px; color:#333;">
        <strong>Details:</strong><br>
        %s
      </p>
    </div>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      If you have any questions or believe this was a mistake, please contact our support team.
    </p>
    
    <a href="mailto:support@hps.com" style="display: inline-block; margin-top: 24px; padding: 12px 20px; background-color: #007bff; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 500;">
      Contact Support
    </a>
    
    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ddd;">
    
    <p style="font-size: 13px; color: #777;">
      🔒 For your security, never share your account credentials or personal information via email.
    </p>
    
    <p style="font-size: 12px; color: #aaa; text-align: center; margin-top: 30px;">
      © %s HPS eBanking. All rights reserved.
    </p>
  </div>
</body>
</html>
""".formatted(username, message, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("❌ Your Virtual Card Has Been Blocked");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(mimeMessage);
    }
    public void sendAgentVirtualCardCanceledEmail(String to, String username, String message) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 40px;">
  <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">
    
    <h2 style="color: #d93025; font-size: 24px; margin-bottom: 16px;">🔴 Virtual Card Canceled</h2>
    
    <p style="font-size: 16px; color: #333;">
      Hello <strong>%s</strong>,
    </p>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      We’re writing to inform you that your virtual card has been <strong style="color: #d93025;">canceled</strong> by our support team.
    </p>
    
    <div style="background-color: #fce8e6; padding: 18px; border-left: 5px solid #d93025; border-radius: 6px; margin: 24px 0;">
      <p style="margin:0; font-size: 15px; color:#333;">
        <strong>Details:</strong><br>
        %s
      </p>
    </div>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      If you believe this action was taken in error or have any questions, please contact our support team immediately.
    </p>
    
    <a href="mailto:support@hps.com" style="display: inline-block; margin-top: 24px; padding: 12px 20px; background-color: #007bff; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 500;">
      Contact Support
    </a>
    
    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ddd;">
    
    <p style="font-size: 13px; color: #777;">
      🔒 For your security, never share your account credentials or personal information via email.
    </p>
    
    <p style="font-size: 12px; color: #aaa; text-align: center; margin-top: 30px;">
      © %s HPS eBanking. All rights reserved.
    </p>
  </div>
</body>
</html>
""".formatted(username, message, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("🔴 Your Virtual Card Has Been Canceled");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(mimeMessage);
    }
    public void sendAgentVirtualCardUncanceledEmail(String to, String username, String message) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 40px;">
  <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">
    
    <h2 style="color: #188038; font-size: 24px; margin-bottom: 16px;">🟢 Virtual Card Reactivated</h2>
    
    <p style="font-size: 16px; color: #333;">
      Hello <strong>%s</strong>,
    </p>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      Good news—your virtual card has been <strong style="color: #188038;">reactivated</strong> by our support team and is now available for use.
    </p>
    
    <div style="background-color: #e6f4ea; padding: 18px; border-left: 5px solid #188038; border-radius: 6px; margin: 24px 0;">
      <p style="margin:0; font-size: 15px; color:#333;">
        <strong>Details:</strong><br>
        %s
      </p>
    </div>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      If you have any questions or need assistance, feel free to reach out to our support team.
    </p>
    
    <a href="mailto:support@hps.com" style="display: inline-block; margin-top: 24px; padding: 12px 20px; background-color: #007bff; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 500;">
      Contact Support
    </a>
    
    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ddd;">
    
    <p style="font-size: 13px; color: #777;">
      🔒 For your security, never share your account credentials or personal information via email.
    </p>
    
    <p style="font-size: 12px; color: #aaa; text-align: center; margin-top: 30px;">
      © %s HPS eBanking. All rights reserved.
    </p>
  </div>
</body>
</html>
""".formatted(username, message, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("🟢 Your Virtual Card Has Been Reactivated");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(mimeMessage);
    }
    public void sendAgentVirtualCardFeaturesUpdatedEmail(String to, String username, String message) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

        String html = """
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: #f4f4f7; padding: 40px;">
  <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.05); padding: 32px;">
    
    <h2 style="color: #007bff; font-size: 24px; margin-bottom: 16px;">🔵 Virtual Card Features Updated</h2>
    
    <p style="font-size: 16px; color: #333;">
      Hello <strong>%s</strong>,
    </p>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      This is to inform you that one or more features of your virtual card have been updated by our support team.
    </p>
    
    <div style="background-color: #e8f0fe; padding: 18px; border-left: 5px solid #007bff; border-radius: 6px; margin: 24px 0;">
      <p style="margin:0; font-size: 15px; color:#333;">
        <strong>Details:</strong><br>
        %s
      </p>
    </div>
    
    <p style="font-size: 15px; color: #333; line-height: 1.6;">
      If you have any questions about these changes, please contact our support team.
    </p>
    
    <a href="mailto:support@hps.com" style="display: inline-block; margin-top: 24px; padding: 12px 20px; background-color: #007bff; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 500;">
      Contact Support
    </a>
    
    <hr style="margin: 40px 0; border: none; border-top: 1px solid #ddd;">
    
    <p style="font-size: 13px; color: #777;">
      🔒 For your security, never share your account credentials or personal information via email.
    </p>
    
    <p style="font-size: 12px; color: #aaa; text-align: center; margin-top: 30px;">
      © %s HPS eBanking. All rights reserved.
    </p>
  </div>
</body>
</html>
""".formatted(username, message, java.time.Year.now());

        helper.setTo(to);
        helper.setSubject("🔵 Virtual Card Features Updated");
        helper.setText(html, true);
        helper.setFrom("no-reply@hps.com");

        mailSender.send(mimeMessage);
    }

}
