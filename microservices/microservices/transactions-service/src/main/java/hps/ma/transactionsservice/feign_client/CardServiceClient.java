package hps.ma.transactionsservice.feign_client;

import hps.ma.transactionsservice.dto.CardIdsResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;

import java.util.List;
import java.util.Map;

@FeignClient(name = "card-service", url = "http://localhost:7777/api/cards")
public interface CardServiceClient {

    @GetMapping("/my-card-ids")
    CardIdsResponse getMyCardIds(@RequestHeader("Authorization") String token);
    @GetMapping("/cardholder-details/{cardId}")
    Map<String, Object> getCardholderDetailsByCardId(@PathVariable("cardId") Long cardId);

}
