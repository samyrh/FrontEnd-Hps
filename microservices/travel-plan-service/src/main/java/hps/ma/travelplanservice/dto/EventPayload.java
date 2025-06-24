package hps.ma.travelplanservice.dto;



import hps.ma.travelplanservice.dao.enums.EventCategory;
import hps.ma.travelplanservice.dao.enums.SenderType;
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
