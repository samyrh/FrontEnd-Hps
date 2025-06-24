package hps.ma.travelplanservice.feign_client;


import hps.ma.travelplanservice.dto.AgentDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@FeignClient(name = "user-service", url = "http://localhost:9999/api/agents")
public interface AgentService {

    @GetMapping
    List<AgentDto> getAllAgents();
}