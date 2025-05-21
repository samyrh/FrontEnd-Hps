package hps.ma.userservice.dto.event;


import hps.ma.userservice.dao.enums.EventCategory;
import hps.ma.userservice.dao.enums.SenderType;
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
    private Long senderAgentId;
    private Long recipientCardholderId;
    private Long cardId; // Optional for card-related events
}
