package hps.ma.transactionsservice.service;

import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Service
public class TransactionGraphClient {

    private final RestTemplate restTemplate = new RestTemplate();
    private final String baseUrl = "http://localhost:8000";

    private byte[] fetchGraph(String endpoint) {
        String url = baseUrl + endpoint;

        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(List.of(MediaType.IMAGE_PNG));

        HttpEntity<Void> entity = new HttpEntity<>(headers);

        ResponseEntity<byte[]> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                entity,
                byte[].class
        );

        return response.getBody();
    }

    public byte[] getCategoryCountsGraph() {
        return fetchGraph("/graph/category-counts");
    }

    public byte[] getCategoryPieGraph() {
        return fetchGraph("/graph/category-pie");
    }

    public byte[] getIncomePerYearGraph() {
        return fetchGraph("/graph/income-per-year");
    }

    public byte[] getIncomePerMonthGraph() {
        return fetchGraph("/graph/income-per-month");
    }

    public byte[] getIncomePerDayGraph() {
        return fetchGraph("/graph/income-per-day");
    }
}
