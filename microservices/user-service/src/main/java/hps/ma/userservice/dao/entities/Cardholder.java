package hps.ma.userservice.dao.entities;

import jakarta.persistence.*;
import lombok.*;


@Entity
@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Cardholder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 50, nullable = false, unique = true)
    private String username;

    @Column(length = 100, nullable = false, unique = true)
    private String email;

    @Column(length = 150, nullable = false)
    private String password;

    @Column(name = "is_locked", nullable = false)
    private boolean locked;

    @Column(name = "login_attempts", nullable = false)
    private int loginAttempts = 0;

    @Column(name = "biometric_enabled", nullable = false)
    private boolean biometricEnabled;

    @Column(length = 6)
    private String securityCode;

    @Column(name = "is_first_login", nullable = false)
    private boolean isFirstLogin = true;


}
