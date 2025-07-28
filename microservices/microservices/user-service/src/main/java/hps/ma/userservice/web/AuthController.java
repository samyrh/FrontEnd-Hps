package hps.ma.userservice.web;

import hps.ma.userservice.dto.user.LoginResponse;
import hps.ma.userservice.dto.user.LoginUserDto;
import hps.ma.userservice.dto.user.RegisterUserDto;
import hps.ma.userservice.services.AuthenticationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@CrossOrigin("*")
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