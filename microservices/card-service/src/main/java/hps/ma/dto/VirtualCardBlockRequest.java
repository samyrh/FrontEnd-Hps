package hps.ma.dto;

import hps.ma.dao.enums.BlockReason;
import lombok.Data;

@Data
public class VirtualCardBlockRequest {
    private Long cardId;
    private BlockReason blockReason;
}
