package hps.ma.userservice.dao.repositories;

import hps.ma.userservice.dao.entities.Agent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface AgentRepository extends JpaRepository<Agent, Long> {

    Optional<Agent> findByEmail(String email);
    Optional<Agent> findByUsername(String username);
    @Query("SELECT a.id FROM Agent a")
    List<Long> findAllAgentIds();
}
