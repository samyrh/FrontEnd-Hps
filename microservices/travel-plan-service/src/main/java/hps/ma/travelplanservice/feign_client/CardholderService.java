package hps.ma.travelplanservice.feign_client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.Map;

@FeignClient(name = "user-service", url = "http://localhost:9999/api/cardholders")
public interface CardholderService {

    @GetMapping("/internal/by-id/{id}")
    Map<String, Object> getCardholderById(@PathVariable("id") Long id);

    @GetMapping("/internal/by-username/{username}")
    Map<String, Object> getCardholderIdByUsername(@PathVariable("username") String username);
}
