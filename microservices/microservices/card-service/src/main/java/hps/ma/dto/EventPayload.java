package hps.ma.dto;


import hps.ma.dao.enums.EventCategory;
import hps.ma.dao.enums.SenderType;
import lombok.*;

import java.util.Date;

@Getter
@Setter
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
    private Long senderId;
    private Long recipientId;
    private Long cardId;
}
