package hps.ma.feign_client;

import hps.ma.dto.TravelPlanCard;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(
        name = "travel-plan-service",
        url = "http://localhost:8084/api/travel-plans"  // <-- adapt port if needed
)
public interface TravelPlanServiceClient {

    @GetMapping("/internal/card/{cardId}")
    TravelPlanCard getTravelPlanByCardId(@PathVariable("cardId") Long cardId);
}