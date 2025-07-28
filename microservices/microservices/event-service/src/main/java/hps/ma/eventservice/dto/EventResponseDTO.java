package hps.ma.eventservice.dto;

import hps.ma.eventservice.enums.EventCategory;
import hps.ma.eventservice.enums.SenderType;
import lombok.*;

import java.util.Date;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class EventResponseDTO {
    private Long id;
    private String message;
    private Date sentAt;
    private boolean isRead;
    private EventCategory category;
    private SenderType senderType;
    private Long senderId;
    private Long recipientId;
    private Long cardId;
}
