package hps.ma.transactionsservice.web;


import hps.ma.transactionsservice.dto.TransactionWithCardholderDTO;
import hps.ma.transactionsservice.service.TransactionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/agent/transactions")
@RequiredArgsConstructor
@CrossOrigin("*")
public class AgentTransactionController {

    private final TransactionService transactionService;

    /**
     * Fetch all transactions with cardholder and card number info,
     * and classify missing categories before returning.
     */
    @GetMapping("/all")
    public List<TransactionWithCardholderDTO> getAllTransactionsWithCardholderDetails() {
        return transactionService.getAllTransactionsWithCardholderDetails();
    }
}
