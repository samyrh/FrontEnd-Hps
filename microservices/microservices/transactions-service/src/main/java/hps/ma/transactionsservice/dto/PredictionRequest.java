package hps.ma.transactionsservice.dto;

import lombok.Data;

@Data
public class PredictionRequest {
    private String description;
    private double amount;
    private String date; // Format: YYYY-MM-DD
}
