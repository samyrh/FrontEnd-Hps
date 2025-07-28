package hps.ma.transactionsservice.service;

import hps.ma.transactionsservice.dao.entities.Transaction;

import hps.ma.transactionsservice.dao.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.SimpleDateFormat;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TransactionProcessingService {

    private final TransactionRepository transactionRepository;
    private final TransactionClassifierClient classifierClient;

    @Transactional
    public void classifyAndUpdateTransactions() {
        List<Transaction> transactions = transactionRepository.findByCategoryIsNullOrCategory("");

        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");

        for (Transaction tx : transactions) {
            String dateStr = formatter.format(tx.getDate());
            String predictedCategory = classifierClient.classifyTransaction(
                    tx.getDescription(),
                    tx.getAmount(),
                    dateStr
            );

            if (predictedCategory != null) {
                tx.setCategory(predictedCategory);
                transactionRepository.save(tx);
            }
        }
    }

}
