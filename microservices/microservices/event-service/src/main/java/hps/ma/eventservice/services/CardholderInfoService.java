package hps.ma.eventservice.services;


import hps.ma.eventservice.feign_client.CardholderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class CardholderInfoService {

    @Autowired
    private CardholderService cardholderService;

    public Long getCardholderIdByUsername(String username) {
        Map<String, Object> response = cardholderService.getCardholderIdByUsername(username);

        if (response.containsKey("id")) {
            return ((Number) response.get("id")).longValue();
        } else {
            throw new RuntimeException("Cardholder not found or invalid response");
        }
    }

    public Map<String, Object> getCardholderById(Long id) {
        return cardholderService.getCardholderById(id);
    }

}