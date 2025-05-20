package hps.ma.dto;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Agent {
    private Long id;
    private String username;
    private String email;
    private boolean isAdmin;
    private boolean isActive;
}
