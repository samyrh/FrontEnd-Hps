package hps.ma.eventservice.dto;

import hps.ma.eventservice.enums.EventCategory;
import hps.ma.eventservice.enums.SenderType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EventPayload {
    private String message;
    private Date sentAt;
    private SenderType senderType;
    private EventCategory category;
    private String email;
    private String username;
    private String password; // encrypted
    private Long senderId;
    private Long recipientId;
    private Long cardId;
}
