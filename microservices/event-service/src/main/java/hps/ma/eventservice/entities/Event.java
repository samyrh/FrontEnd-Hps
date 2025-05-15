package hps.ma.eventservice.entities;


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
    @GeneratedValue
    private Long id;

    private String message;
    private Date sentAt;

    @Enumerated(EnumType.STRING)
    private SenderType senderType;

    @Enumerated(EnumType.STRING)
    private EventCategory category;

    private boolean isRead;

    @ManyToOne
    @JoinColumn(name = "sender_agent_id")
    private Agent senderAgent;

    @ManyToOne
    @JoinColumn(name = "recipient_cardholder_id")
    private Cardholder recipient;

    @ManyToOne
    private Card card;
}
