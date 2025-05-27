package hps.ma.dao.repositories;


import hps.ma.dao.entities.Card;
import hps.ma.dao.enums.CardType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CardRepository extends JpaRepository<Card, Long> {

    List<Card> findByCardholderId(Long cardholderId);

    List<Card> findByManagerId(Long managerId);


    List<Card> findByCardPackId(Long cardPackId);

    List<Card> findByStatus(String status);

    List<Card> findByCardholderIdAndType(Long cardholderId, CardType type);


}
