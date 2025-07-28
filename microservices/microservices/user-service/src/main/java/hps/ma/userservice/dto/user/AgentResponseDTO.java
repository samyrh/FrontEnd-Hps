package hps.ma.userservice.dto.user;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AgentResponseDTO {
    private Long id;
    private String username;
    private String email;
    private boolean isAdmin;
    private boolean isActive;
}