package hps.ma.transactionsservice.service;

import hps.ma.transactionsservice.dto.PredictionRequest;
import hps.ma.transactionsservice.dto.PredictionResponse;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class TransactionClassifierClient {

    private final RestTemplate restTemplate = new RestTemplate();
    private final String apiUrl = "http://localhost:8000/predict";

    public String classifyTransaction(String description, double amount, String date) {
        PredictionRequest request = new PredictionRequest();
        request.setDescription(description);
        request.setAmount(amount);
        request.setDate(date);

        PredictionResponse response = restTemplate.postForObject(
                apiUrl,
                request,
                PredictionResponse.class
        );

        return response != null ? response.getPredicted_category() : null;
    }
}

