package hps.ma.userservice.services;

import hps.ma.userservice.dao.entities.Agent;
import hps.ma.userservice.dao.entities.AgentAuth;
import hps.ma.userservice.dao.entities.Cardholder;
import hps.ma.userservice.dao.entities.CardholderAuth;
import hps.ma.userservice.dao.repositories.AgentRepository;
import hps.ma.userservice.dao.repositories.CardholderReository;
import hps.ma.userservice.dto.user.LoginResponse;
import hps.ma.userservice.dto.user.LoginUserDto;
import hps.ma.userservice.dto.user.RegisterUserDto;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthenticationService {

    private final AgentRepository agentRepo;
    private final CardholderReository cardholderRepo;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;

    public LoginResponse authenticate(LoginUserDto dto) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(dto.getUsername(), dto.getPassword()));

        Optional<? extends UserDetails> optionalUser =
                agentRepo.findByUsername(dto.getUsername())
                        .map(AgentAuth::new)
                        .map(user -> (UserDetails) user)
                        .or(() -> cardholderRepo.findByUsername(dto.getUsername())
                                .map(CardholderAuth::new)
                                .map(user -> (UserDetails) user));

        UserDetails user = optionalUser.orElseThrow();

        String role = user.getAuthorities().stream()
                .findFirst()
                .map(GrantedAuthority::getAuthority)
                .orElse("UNKNOWN");

        String token = jwtService.generateToken(user);

        return LoginResponse.builder()
                .token(token)
                .expiresIn(jwtService.getExpirationTime())
                .role(role)
                .build();
    }

    public String registerCardholder(RegisterUserDto dto) {
        Cardholder user = Cardholder.builder()
                .username(dto.getUsername()) // ✅ now using username
                .email(dto.getEmail())
                .password(passwordEncoder.encode(dto.getPassword()))
                .locked(false)
                .isFirstLogin(true)
                .loginAttempts(0)
                .biometricEnabled(false)
                .build();
        cardholderRepo.save(user);
        return "Cardholder registered.";
    }

    public String registerAgent(RegisterUserDto dto) {
        Agent agent = Agent.builder()
                .username(dto.getUsername()) // ✅ now using username
                .email(dto.getEmail())
                .password(passwordEncoder.encode(dto.getPassword()))
                .isAdmin(false)
                .isActive(true)
                .build();
        agentRepo.save(agent);
        return "Agent registered.";
    }
}
