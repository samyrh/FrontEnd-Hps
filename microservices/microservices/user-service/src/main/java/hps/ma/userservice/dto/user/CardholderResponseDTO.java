package hps.ma.userservice.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CardholderResponseDTO {
    private Long id;
    private String username;
    private String email;
    private boolean locked;
    private boolean firstLogin;
    private int loginAttempts;
    private boolean biometricEnabled;
}
