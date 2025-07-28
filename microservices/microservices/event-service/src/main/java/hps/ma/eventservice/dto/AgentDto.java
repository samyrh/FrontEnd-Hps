package hps.ma.eventservice.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AgentDto {
    private Long id;
    private String username;
    private String email;
    private boolean isAdmin;
    private boolean isActive;
}
