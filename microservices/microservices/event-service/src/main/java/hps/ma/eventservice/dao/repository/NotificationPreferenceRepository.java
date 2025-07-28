package hps.ma.eventservice.dao.repository;

import hps.ma.eventservice.dao.entity.NotificationPreference;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NotificationPreferenceRepository extends JpaRepository<NotificationPreference, Long> {
}
