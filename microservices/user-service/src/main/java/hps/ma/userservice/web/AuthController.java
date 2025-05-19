package hps.ma.userservice.web;

import hps.ma.userservice.dto.LoginResponse;
import hps.ma.userservice.dto.LoginUserDto;
import hps.ma.userservice.dto.RegisterUserDto;
import hps.ma.userservice.services.AuthenticationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationService authService;

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginUserDto dto) {
        return ResponseEntity.ok(authService.authenticate(dto));
    }

    @PostMapping("/register-cardholder")
    public ResponseEntity<String> registerCardholder(@RequestBody RegisterUserDto dto) {
        return ResponseEntity.ok(authService.registerCardholder(dto));
    }

    @PostMapping("/register-agent")
    public ResponseEntity<String> registerAgent(@RequestBody RegisterUserDto dto) {
        return ResponseEntity.ok(authService.registerAgent(dto));
    }
}