package hps.ma.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Cardholder {
    private Long id;
    private String username;
    private String email;
    private boolean isLocked;
    private int loginAttempts;
    private boolean biometricEnabled;
    private String securityCode;
}


