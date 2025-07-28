package hps.ma.dto;

import hps.ma.dao.enums.BlockReason;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PhysicalCardBlockRequest {
    private BlockReason blockReason;

}
