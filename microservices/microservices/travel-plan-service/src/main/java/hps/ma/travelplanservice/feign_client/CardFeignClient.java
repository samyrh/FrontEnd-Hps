package hps.ma.travelplanservice.feign_client;

import hps.ma.travelplanservice.dto.CardResponseDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@FeignClient(name = "card-service", url = "http://localhost:7777/api/cards")
public interface CardFeignClient {
    @GetMapping("/{id}")
    CardResponseDTO getCardById(@PathVariable("id") Long id);

    @PutMapping("/{id}/update-active-travel-plan")
    void updateHasActiveTravelPlan(
            @PathVariable("id") Long id,
            @RequestParam("active") boolean active
    );

    @PutMapping("/{cardId}/reset-travel-plan")
    void resetHasActiveTravelPlan(@PathVariable("cardId") Long cardId);

    @GetMapping("/cardholder/{cardholderId}/ids")
    List<Long> getCardIdsByCardholderId(@PathVariable("cardholderId") Long cardholderId);

}
