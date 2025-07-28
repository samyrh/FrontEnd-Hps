package hps.ma.transactionsservice.dao.repository;

import hps.ma.transactionsservice.dao.entities.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    List<Transaction> findByCategoryIsNullOrCategory(String category);

    List<Transaction> findByCardIdIn(List<Long> cardIds);
}
