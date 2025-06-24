package hps.ma.travelplanservice;


import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.kafka.annotation.EnableKafka;

@SpringBootApplication
@EnableFeignClients
@EnableKafka
@EnableDiscoveryClient
public class TravelPlanServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(TravelPlanServiceApplication.class, args);
    }

}
