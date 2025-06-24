package hps.ma.travelplanservice.service;

import hps.ma.travelplanservice.dao.entities.TravelPlan;
import hps.ma.travelplanservice.dao.enums.EventCategory;
import hps.ma.travelplanservice.dao.enums.SenderType;
import hps.ma.travelplanservice.dao.enums.TravelPlanStatus;
import hps.ma.travelplanservice.dao.repository.TravelPlanRepository;
import hps.ma.travelplanservice.dto.AgentDto;
import hps.ma.travelplanservice.dto.CardResponseDTO;
import hps.ma.travelplanservice.dto.EventPayload;
import hps.ma.travelplanservice.dto.TravelPlanRequest;
import hps.ma.travelplanservice.feign_client.AgentService;
import hps.ma.travelplanservice.feign_client.CardFeignClient;
import hps.ma.travelplanservice.kafka_producing.TravelPlanEventProducer;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class TravelPlanService {


    private final TravelPlanRepository travelPlanRepository;
    private final CardFeignClient cardFeignClient;
    private final CardholderInfoService cardholderInfoService;
    private final JwtUtil jwtUtil;
    private final AgentService agentService;
    private final TravelPlanEventProducer travelPlanEventProducer;

    public void createTravelPlanByCardholder(String token, Long cardId, TravelPlanRequest request) {

        // ✅ Extract username from token
        String username = jwtUtil.extractUsername(token);
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);
        CardResponseDTO card = cardFeignClient.getCardById(cardId);

        // ✅ Validate card ownership
        if (!Objects.equals(card.cardholderName(), username)) {
            throw new RuntimeException("Card does not belong to current user");
        }

        // ✅ Check existing travel plan
        if (Boolean.TRUE.equals(card.hasActiveTravelPlan())) {
            throw new RuntimeException("You already have an active travel plan for this card.");
        }

        var pack = card.cardPack();

        // ✅ Validate countries
        if (request.getCountries().size() > pack.maxCountries()) {
            throw new RuntimeException("Max countries exceeded: allowed " + pack.maxCountries());
        }

        // ✅ Validate duration
        long duration = ChronoUnit.DAYS.between(request.getStartDate().toInstant(), request.getEndDate().toInstant());
        if (duration <= 0 || duration > pack.maxDays()) {
            throw new RuntimeException("Invalid duration: allowed max " + pack.maxDays());
        }

        // ✅ Create & Save travel plan
        TravelPlan plan = TravelPlan.builder()
                .cardId(cardId)
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .countries(request.getCountries())
                .travelLimit(pack.internationalWithdrawLimitPerTravel())
                .maxDays(pack.maxDays())
                .status(TravelPlanStatus.IN_REVIEW)
                .build();

        travelPlanRepository.save(plan);
        cardFeignClient.updateHasActiveTravelPlan(cardId, true);

        // ✅ Notify all agents via Kafka
        sendTravelPlanCreatedEvent(cardholderId, username, cardId, plan);
    }

    private void sendTravelPlanCreatedEvent(Long cardholderId, String cardholderName, Long cardId, TravelPlan plan) {
        List<AgentDto> agents = agentService.getAllAgents();

        String message = String.format(
                "New travel plan requested by %s (Card: %d, Countries: %d, Period: %s to %s)",
                cardholderName,
                cardId,
                plan.getCountries().size(),
                plan.getStartDate(),
                plan.getEndDate()
        );

        for (AgentDto agent : agents) {
            EventPayload payload = EventPayload.builder()
                    .message(message)
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.TRAVEL_PLAN_REQUESTED)
                    .senderId(cardholderId)
                    .recipientId(agent.getId())
                    .cardId(cardId)
                    .username(cardholderName)
                    .email(agent.getEmail())  // If agent has email (adjust if you don't store email in agent)
                    .build();

            travelPlanEventProducer.sendTravelPlanCreated(payload);
        }
    }
    @Transactional
    public void resetTravelPlanAndCard(Long cardId) {
        // Transactional: delete in DB
        travelPlanRepository.deleteByCardId(cardId);

        try {
            // External call: not inside transaction scope
            cardFeignClient.updateHasActiveTravelPlan(cardId, false);
        } catch (Exception e) {
            // Log the error, trigger alert, retry mechanism etc.
            throw new RuntimeException("Failed to update card-service: " + e.getMessage());
        }
    }

    public Optional<TravelPlan> getTravelPlanByCardId(Long cardId) {
        return travelPlanRepository.findByCardId(cardId);
    }

}
