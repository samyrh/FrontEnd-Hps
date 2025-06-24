package hps.ma.eventservice.dao.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.Date;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotificationPreference {

    @Id
    private Long cardholderId; // 1 row per cardholder

    private boolean cardStatusChanges;
    private boolean cardCancelReactivate;
    private boolean newCardRequest;
    private boolean cardReplacementRequest;
    private boolean travelPlanStatus;
    private boolean transactionAlert;

    @Temporal(TemporalType.TIMESTAMP)
    private Date updatedAt;

    @PreUpdate
    @PrePersist
    protected void updateTimestamp() {
        this.updatedAt = new Date();
    }
}
