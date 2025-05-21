package hps.ma.eventservice.dao.entity;



import hps.ma.eventservice.enums.EventCategory;
import hps.ma.eventservice.enums.SenderType;
import jakarta.persistence.*;
import lombok.*;

import java.util.Date;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Setter
@Getter
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String message;
    private Date sentAt;

    @Enumerated(EnumType.STRING)
    private SenderType senderType;

    @Enumerated(EnumType.STRING)
    private EventCategory category;

    private boolean isRead;


    // Only store IDs — not entity objects from other services
    private Long senderAgentId;
    private Long recipientCardholderId;
    private Long cardId;
}
