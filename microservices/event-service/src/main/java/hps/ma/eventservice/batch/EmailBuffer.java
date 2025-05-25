package hps.ma.eventservice.batch;

import hps.ma.eventservice.dto.EventPayload;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;


//Create EmailBuffer (In-Memory Batch Cache)

@Component
public class EmailBuffer {
    private final List<EventPayload> buffer = new CopyOnWriteArrayList<>();

    public void add(EventPayload payload) {
        buffer.add(payload);
    }

    public List<EventPayload> drain() {
        List<EventPayload> copy = new ArrayList<>(buffer);
        buffer.clear();
        return copy;
    }
}
