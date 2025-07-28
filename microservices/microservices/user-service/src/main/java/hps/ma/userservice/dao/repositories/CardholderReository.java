package hps.ma.userservice.dao.repositories;

import hps.ma.userservice.dao.entities.Cardholder;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CardholderReository extends JpaRepository<Cardholder, Long> {

    Optional<Cardholder> findByEmail(String email);
    Optional<Cardholder> findByUsername(String username);


    boolean existsByUsername(String username);
}
