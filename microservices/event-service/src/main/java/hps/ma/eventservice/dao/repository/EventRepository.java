package hps.ma.eventservice.dao.repository;

import hps.ma.eventservice.dao.entity.Event;
import org.springframework.data.jpa.repository.JpaRepository;


public interface EventRepository extends JpaRepository<Event, Long> {
}
