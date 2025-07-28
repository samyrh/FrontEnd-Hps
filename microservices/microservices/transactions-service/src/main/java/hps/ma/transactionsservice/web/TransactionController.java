package hps.ma.transactionsservice.web;

import hps.ma.transactionsservice.dto.TransactionCreateRequest;
import hps.ma.transactionsservice.dto.TransactionGroupedResponse;
import hps.ma.transactionsservice.dto.TransactionResponseDTO;
import hps.ma.transactionsservice.service.TransactionGraphClient;
import hps.ma.transactionsservice.service.TransactionProcessingService;
import hps.ma.transactionsservice.service.TransactionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
public class TransactionController {

    private final TransactionProcessingService processingService;
    private final TransactionService transactionService;
    private final TransactionGraphClient graphClient;


    @PostMapping("/classify-missing")
    public String classifyMissingCategories() {
        processingService.classifyAndUpdateTransactions();
        return "Classification process completed.";
    }

    @GetMapping("/cardholder/my-transactions")
    public TransactionGroupedResponse getMyTransactions(@RequestHeader("Authorization") String token) {
        return transactionService.getTransactionsForCardholder(token);
    }

    @PostMapping("/create")
    public TransactionResponseDTO createTransaction(@RequestBody TransactionCreateRequest request) {
        return transactionService.createTransaction(request);
    }
    // ✅ Graph Endpoints
    @GetMapping("/graph/category-counts")
    public ResponseEntity<byte[]> getCategoryCountsGraph() {
        byte[] img = graphClient.getCategoryCountsGraph();
        return buildImageResponse(img, "category-counts.png");
    }

    @GetMapping("/graph/category-pie")
    public ResponseEntity<byte[]> getCategoryPieGraph() {
        byte[] img = graphClient.getCategoryPieGraph();
        return buildImageResponse(img, "category-pie.png");
    }

    @GetMapping("/graph/income-per-year")
    public ResponseEntity<byte[]> getIncomePerYearGraph() {
        byte[] img = graphClient.getIncomePerYearGraph();
        return buildImageResponse(img, "income-per-year.png");
    }

    @GetMapping("/graph/income-per-month")
    public ResponseEntity<byte[]> getIncomePerMonthGraph() {
        byte[] img = graphClient.getIncomePerMonthGraph();
        return buildImageResponse(img, "income-per-month.png");
    }

    @GetMapping("/graph/income-per-day")
    public ResponseEntity<byte[]> getIncomePerDayGraph() {
        byte[] img = graphClient.getIncomePerDayGraph();
        return buildImageResponse(img, "income-per-day.png");
    }

    private ResponseEntity<byte[]> buildImageResponse(byte[] img, String filename) {
        return ResponseEntity.ok()
                .contentType(MediaType.IMAGE_PNG)
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + filename + "\"")
                .body(img);
    }

}
