package hps.ma.travelplanservice.service;


import hps.ma.travelplanservice.feign_client.CardholderService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class CardholderInfoService {

    private final CardholderService cardholderFeignClient;

    public Long getCardholderIdByUsername(String username) {
        Map<String, Object> response = cardholderFeignClient.getCardholderIdByUsername(username);

        if (response.containsKey("id")) {
            return ((Number) response.get("id")).longValue();
        } else {
            throw new RuntimeException("Cardholder not found or invalid response");
        }
    }
}