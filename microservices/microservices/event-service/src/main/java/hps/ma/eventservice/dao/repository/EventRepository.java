package hps.ma.eventservice.dao.repository;

import hps.ma.eventservice.dao.entity.Event;
import hps.ma.eventservice.enums.SenderType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;


public interface EventRepository extends JpaRepository<Event, Long> {
    List<Event> findByRecipientIdAndSenderType(Long recipientId, SenderType attr0);

    List<Event> findByRecipientIdAndIsReadFalse(Long recipientId);

    Long countByRecipientIdAndIsReadFalse(Long cardholderId);

    List<Event> findBySenderType(SenderType senderType);
}
