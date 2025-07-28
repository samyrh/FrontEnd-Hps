package hps.ma.eventservice.feign_client;


import hps.ma.eventservice.dto.AgentDto;
import hps.ma.eventservice.dto.AgentResponseDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

@FeignClient(name = "user-service", url = "http://localhost:9999/api/agents")
public interface AgentService {

    @GetMapping
    List<AgentDto> getAllAgents();
    @GetMapping("/internal/by-username/{username}")
    AgentResponseDTO getAgentDetailsByUsername(@PathVariable("username") String username);


}