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
    private String email;
    private String username;
    private String password; // encrypted
    private Long senderId;     // Now works for both Agent or Cardholder
    private Long recipientId;  // Always a Cardholder
    private Long cardId;       // Optional for card-related events
}
