package hps.ma.userservice.dto.user;

import lombok.*;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class LoginResponse {
    private String token;
    private long expiresIn;
    private String role;
}
