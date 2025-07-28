package hps.ma.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class VirtualCardBlockStatusDTO {
    private boolean blocked;
    private String blockReason; // Enum string value like "CVV_LEAK"
    private boolean cvvPending; // for CVV leak
    private int cvvCountdown; // optional (if you handle CVV timer server-side)
    private boolean requestSent; // for 'Someone Tried To Use My Card'
}
