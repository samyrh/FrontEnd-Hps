package hps.ma.travelplanservice.dao.repository;

import hps.ma.travelplanservice.dao.entities.TravelPlan;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TravelPlanRepository extends JpaRepository<TravelPlan, Long> {
    void deleteByCardId(Long cardId);

    Optional<TravelPlan> findByCardId(Long cardId);
}
