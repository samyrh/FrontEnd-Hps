package hps.ma.dao.repositories;

import hps.ma.dao.entities.CardPack;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CardPackRepository extends JpaRepository<CardPack, Long> {

    CardPack findByLabel(String label);

    List<CardPack> findByAudience(String audience);

    List<CardPack> findByType(String type);
}