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

    @Temporal(TemporalType.TIMESTAMP)
    private Date sentAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SenderType senderType; // AGENT or CARDHOLDER

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private EventCategory category;

    private boolean isRead;

    @Column(nullable = false)
    private Long senderId;


    @Column(nullable = false)
    private Long recipientId;  // Always a Cardholder ID

    private Long cardId;       // Optional: linked card
}
