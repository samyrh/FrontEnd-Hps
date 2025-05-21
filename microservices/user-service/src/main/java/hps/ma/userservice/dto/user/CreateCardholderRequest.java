package hps.ma.userservice.dto.user;
import lombok.Data;

@Data
public class CreateCardholderRequest {
    private String username;
    private String email;
    private String password;
}
