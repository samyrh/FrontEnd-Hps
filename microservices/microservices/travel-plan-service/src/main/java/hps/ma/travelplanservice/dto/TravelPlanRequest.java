package hps.ma.travelplanservice.dto;

import lombok.Data;
import java.util.Date;
import java.util.List;

@Data
public class TravelPlanRequest {
    private Date startDate;
    private Date endDate;
    private List<String> countries;
}