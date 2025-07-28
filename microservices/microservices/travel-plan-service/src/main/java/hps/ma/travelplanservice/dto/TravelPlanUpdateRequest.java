package hps.ma.travelplanservice.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.time.Instant;
import java.util.List;
@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class TravelPlanUpdateRequest {
    private String startDate;
    private String endDate;
    private List<String> countries;
}
