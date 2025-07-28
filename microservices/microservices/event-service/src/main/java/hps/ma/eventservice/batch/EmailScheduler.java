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

    @Scheduled(fixedRate = 30000) // 30 sec for testing; adjust in production
    public void sendBufferedEmails() {
        List<EventPayload> queue = emailBuffer.drain();
        System.out.println("📬 [Scheduler] Processing " + queue.size() + " buffered email(s)...");

        for (EventPayload payload : queue) {
            try {
                String message = payload.getMessage() != null ? payload.getMessage().toLowerCase() : "";

                if (message.contains("changed their password")) {
                    String decryptedPassword = AESUtil.decrypt(payload.getPassword());
                    emailService.sendPasswordChangedEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            decryptedPassword
                    );
                    System.out.println("✅ [Scheduler] Password change email sent to: " + payload.getEmail());

                } else if (message.contains("reset their password")) {
                    String decryptedPassword = AESUtil.decrypt(payload.getPassword());
                    emailService.sendPasswordResetEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            decryptedPassword
                    );
                    System.out.println("✅ [Scheduler] Password reset email sent to: " + payload.getEmail());

                }else if (message.contains("has been issued by agent")) {
                    emailService.sendAgentCardCreatedEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            payload.getMessage()
                    );
                    System.out.println("✅ [Scheduler] Agent-created card email sent to: " + payload.getEmail());
                }
                else if (message.contains("pin updated")) {
                    // PIN update requires no decryption
                    emailService.sendPinUpdateEmail(
                            payload.getEmail(),
                            payload.getUsername()
                    );
                    System.out.println("✅ [Scheduler] PIN update email sent to: " + payload.getEmail());

                } else if (message.contains("new transaction")) {
                    // Transaction email requires no decryption
                    emailService.sendTransactionEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            payload.getMessage()
                    );
                    System.out.println("✅ [Scheduler] Transaction email sent to: " + payload.getEmail());

                }else if (message.contains("has been permanently")) {
                    // Transaction email requires no decryption
                    emailService.sendAgentPhysicalCardBlockedEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            payload.getMessage()
                    );
                    System.out.println("✅ [Scheduler] Transaction email sent to: " + payload.getEmail());

                } else if (message.contains("has been unblocked")) {
                    // Transaction email requires no decryption
                    emailService.sendAgentPhysicalCardUnblockedEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            payload.getMessage()
                    );
                    System.out.println("✅ [Scheduler] Transaction email sent to: " + payload.getEmail());

                }else if (message.contains("has been generated for your physical card")) {
                    // Transaction email requires no decryption
                    emailService.sendAgentPhysicalCardUnblockedEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            payload.getMessage()
                    );
                    System.out.println("✅ [Scheduler] Transaction email sent to: " + payload.getEmail());

                }else if (message.contains("new cvv has been generated for your")) {
                    // Transaction email requires no decryption
                    emailService.sendAgentCvvGeneratedEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            payload.getMessage()
                    );
                    System.out.println("✅ [Scheduler] Transaction email sent to: " + payload.getEmail());

                } if (message.contains("virtual card") && message.contains("unblocked by agent")) {
                    emailService.sendAgentVirtualCardUnblockedEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            payload.getMessage()
                    );
                    System.out.println("✅ Virtual card unblocked email sent to: " + payload.getEmail());
                }else if (message.contains("(physical) has been reactivated")) {
                    // Transaction email requires no decryption
                    emailService.sendAgentPhysicalCardUncanceledEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            payload.getMessage()
                    );
                    System.out.println("✅ [Scheduler] Transaction email sent to: " + payload.getEmail());

                } else if (message.contains("(physical) has been canceled")) {
                    // Transaction email requires no decryption
                    emailService.sendAgentPhysicalCardBlockedEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            payload.getMessage()
                    );
                    System.out.println("✅ [Scheduler] Transaction email sent to: " + payload.getEmail());

                } else if (message.toLowerCase().contains("virtual card") && message.toLowerCase().contains("permanently blocked")) {
                emailService.sendAgentVirtualCardBlockedEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ [Scheduler] Virtual card blocked email sent to: " + payload.getEmail());
                }else if (message.toLowerCase().contains("virtual card") && message.toLowerCase().contains("canceled")) {
                    emailService.sendAgentVirtualCardCanceledEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            payload.getMessage()
                    );
                    System.out.println("✅ Agent virtual card cancellation email sent to: " + payload.getEmail());
                } else if (message.toLowerCase().contains("virtual card") && message.toLowerCase().contains("reactivated")) {
                    emailService.sendAgentVirtualCardUncanceledEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            payload.getMessage()
                    );
                    System.out.println("✅ Agent virtual card reactivation email sent to: " + payload.getEmail());
                }else if (message.toLowerCase().contains("virtual card") && message.toLowerCase().contains("e-commerce")) {
                    emailService.sendAgentVirtualCardFeaturesUpdatedEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            payload.getMessage()
                    );
                    System.out.println("✅ Agent virtual card E-Commerce feature update email sent to: " + payload.getEmail());
                } else if (message.contains("approved")) {
                emailService.sendAgentCardApprovedEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ [Scheduler] Card approval email sent to: " + payload.getEmail());
                }else if (message.contains("rejected")) {
                    emailService.sendAgentCardRejectedEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            payload.getMessage()
                    );
                } else if (message.contains("suspended")) {
                emailService.sendAccountSuspendedEmail(
                        payload.getEmail(),
                        payload.getUsername(),
                        payload.getMessage()
                );
                System.out.println("✅ [Scheduler] Account suspension email sent to: " + payload.getEmail());

                } else if (message.contains("reactivated") || message.contains("unsuspended")) {
                    // If your event says "reactivated" or "unsuspended"
                    emailService.sendAccountUnsuspendedEmail(
                            payload.getEmail(),
                            payload.getUsername()
                    );
                    System.out.println("✅ [Scheduler] Account reactivation email sent to: " + payload.getEmail());
                }
                else if (payload.getPassword() != null) {
                    // Default case: likely account creation
                    String decryptedPassword = AESUtil.decrypt(payload.getPassword());
                    emailService.sendCredentialsEmail(
                            payload.getEmail(),
                            payload.getUsername(),
                            decryptedPassword
                    );
                    System.out.println("✅ [Scheduler] Account creation email sent to: " + payload.getEmail());

                } else {
                    // No matching condition, skip safely
                    System.out.println("⚠️ [Scheduler] Skipped unknown event: " + message);
                }

            } catch (Exception e) {
                System.err.println("❌ [Scheduler] Failed to send email to: " + payload.getEmail());
                e.printStackTrace();
            }
        }
    }
}
