package hps.ma.travelplanservice.service;

import hps.ma.travelplanservice.dao.entities.TravelPlan;
import hps.ma.travelplanservice.dao.enums.EventCategory;
import hps.ma.travelplanservice.dao.enums.SenderType;
import hps.ma.travelplanservice.dao.enums.TravelPlanStatus;
import hps.ma.travelplanservice.dao.repository.TravelPlanRepository;
import hps.ma.travelplanservice.dto.*;
import hps.ma.travelplanservice.feign_client.AgentService;
import hps.ma.travelplanservice.feign_client.CardFeignClient;
import hps.ma.travelplanservice.feign_client.CardholderService;
import hps.ma.travelplanservice.kafka_producing.TravelPlanEventProducer;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Service
@RequiredArgsConstructor
public class TravelPlanService {


    private final TravelPlanRepository travelPlanRepository;
    private final CardFeignClient cardFeignClient;
    private final CardholderInfoService cardholderInfoService;
    private final JwtUtil jwtUtil;
    private final AgentService agentService;
    private final TravelPlanEventProducer travelPlanEventProducer;
    private final CardholderService cardholderService;

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


    public long countTravelPlansByCardholder(Long cardholderId) {
        List<Long> cardIds = cardFeignClient.getCardIdsByCardholderId(cardholderId);
        if (cardIds.isEmpty()) {
            return 0;
        }
        return travelPlanRepository.countByCardIdIn(cardIds);
    }

    @Transactional
    public void updateTravelPlanStatus(String token, Long cardId, TravelPlanStatus newStatus) {
        TravelPlan travelPlan = travelPlanRepository.findByCardId(cardId)
                .orElseThrow(() -> new RuntimeException("Travel plan not found for card ID: " + cardId));

        if (travelPlan.getStatus() != TravelPlanStatus.IN_REVIEW) {
            throw new IllegalStateException("Cannot update travel plan that is not in review.");
        }

        // ✅ Extract agent info
        String agentUsername = jwtUtil.extractUsername(token);
        List<AgentDto> agents = agentService.getAllAgents();
        AgentDto approver = agents.stream()
                .filter(a -> a.getUsername().equals(agentUsername))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Approver not found: " + agentUsername));

        // ✅ Update status and approver
        travelPlan.setStatus(newStatus);
        travelPlan.setApproverId(approver.getId());

        // ✅ If rejected, mark card as having no active travel plan
        if (newStatus == TravelPlanStatus.REJECTED) {
            cardFeignClient.updateHasActiveTravelPlan(cardId, false);
        }

        // ✅ Prepare event payload
        CardResponseDTO card = cardFeignClient.getCardById(cardId);

        // Get cardholder info
        Map<String, Object> idMap = cardholderService.getCardholderIdByUsername(card.cardholderName());
        Long cardholderId = Long.parseLong(idMap.get("id").toString());

        Map<String, Object> cardholderInfo = cardholderService.getCardholderById(cardholderId);
        String cardholderUsername = (String) cardholderInfo.getOrDefault("cardholderName", "Unknown");
        String cardholderEmail = (String) cardholderInfo.getOrDefault("email", "-");

        EventCategory eventCategory = (newStatus == TravelPlanStatus.APPROVED)
                ? EventCategory.TRAVEL_PLAN_APPROVED
                : EventCategory.TRAVEL_PLAN_REJECTED;

        String action = (newStatus == TravelPlanStatus.APPROVED) ? "approved" : "rejected";

        SimpleDateFormat formatter = new SimpleDateFormat("yyyy/MM/dd HH:mm");
        String formattedDate = formatter.format(new Date());

        String message = String.format(
                "Your travel plan for card %s has been %s by agent %s on %s.",
                card.cardNumber(),
                action,
                approver.getUsername(),
                formattedDate
        );

        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(eventCategory)
                .senderId(approver.getId())
                .recipientId(cardholderId)
                .cardId(cardId)
                .username(cardholderUsername)
                .email(cardholderEmail)
                .build();

        // ✅ Produce event to Kafka
        travelPlanEventProducer.sendTravelPlanUpdatedStatus(payload);
    }


    @Transactional
    public void updateTravelPlanDetails(String token, Long cardId, TravelPlanUpdateRequest request) {
        TravelPlan travelPlan = travelPlanRepository.findByCardId(cardId)
                .orElseThrow(() -> new RuntimeException("Travel plan not found for card ID: " + cardId));

        if (travelPlan.getStatus() != TravelPlanStatus.IN_REVIEW) {
            throw new IllegalStateException("Cannot update a travel plan that is not in review.");
        }

        // Extract agent info
        String agentUsername = jwtUtil.extractUsername(token);
        List<AgentDto> agents = agentService.getAllAgents();
        AgentDto approver = agents.stream()
                .filter(a -> a.getUsername().equals(agentUsername))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Approver not found: " + agentUsername));

        // Retrieve card pack for validation
        CardResponseDTO card = cardFeignClient.getCardById(cardId);
        int maxCountries = card.cardPack().maxCountries();

        // Prepare date formatter
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy/MM/dd HH:mm");
        formatter.setLenient(false);

        Date parsedStartDate = null;
        Date parsedEndDate = null;
        Instant now = Instant.now();

        // Parse and validate start date if provided
        if (request.getStartDate() != null) {
            if (!request.getStartDate().trim().isEmpty()) {
                try {
                    parsedStartDate = formatter.parse(request.getStartDate());
                    if (parsedStartDate.toInstant().isBefore(now)) {
                        throw new IllegalArgumentException("Start date cannot be in the past.");
                    }
                } catch (ParseException e) {
                    throw new IllegalArgumentException("Invalid start date format. Use yyyy/MM/dd HH:mm.");
                }
            }
        }

        // Parse and validate end date if provided
        if (request.getEndDate() != null) {
            if (!request.getEndDate().trim().isEmpty()) {
                try {
                    parsedEndDate = formatter.parse(request.getEndDate());
                } catch (ParseException e) {
                    throw new IllegalArgumentException("Invalid end date format. Use yyyy/MM/dd HH:mm.");
                }
            }
        }

        // Validate duration if both dates are provided
        if (parsedStartDate != null && parsedEndDate != null) {
            long diffMillis = parsedEndDate.getTime() - parsedStartDate.getTime();
            long diffDays = diffMillis / (1000 * 60 * 60 * 24);
            if (diffDays <= 0) {
                throw new IllegalArgumentException("End date must be after start date.");
            }
            if (diffDays > 90) {
                throw new IllegalArgumentException("Travel duration cannot exceed 90 days.");
            }
        }

        // Validate countries if provided
        if (request.getCountries() != null && !request.getCountries().isEmpty()) {
            if (request.getCountries().size() > maxCountries) {
                throw new IllegalArgumentException(
                        "Number of countries exceeds allowed limit (" + maxCountries + ")."
                );
            }
        }

        // Update fields if provided
        StringBuilder changes = new StringBuilder();

        if (parsedStartDate != null) {
            travelPlan.setStartDate(parsedStartDate);
            changes.append(" Start Date: ").append(request.getStartDate()).append(";");
        }
        if (parsedEndDate != null) {
            travelPlan.setEndDate(parsedEndDate);
            changes.append(" End Date: ").append(request.getEndDate()).append(";");
        }
        if (request.getCountries() != null && !request.getCountries().isEmpty()) {
            travelPlan.setCountries(request.getCountries());
            changes.append(" Countries: ").append(String.join(", ", request.getCountries())).append(";");
        }

        // Prepare Kafka event
        Map<String, Object> idMap = cardholderService.getCardholderIdByUsername(card.cardholderName());
        Long cardholderId = Long.parseLong(idMap.get("id").toString());

        Map<String, Object> cardholderInfo = cardholderService.getCardholderById(cardholderId);
        String cardholderUsername = (String) cardholderInfo.getOrDefault("cardholderName", "Unknown");
        String cardholderEmail = (String) cardholderInfo.getOrDefault("email", "-");

        String message;
        if (!changes.isEmpty()) {
            message = String.format(
                    "Your travel plan for card %s has been updated by agent %s.%s",
                    card.cardNumber(),
                    approver.getUsername(),
                    changes.toString()
            );
        } else {
            message = String.format(
                    "Your travel plan for card %s has been updated by agent %s. No fields were changed.",
                    card.cardNumber(),
                    approver.getUsername()
            );
        }

        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.TRAVEL_PLAN_UPDATED)
                .senderId(approver.getId())
                .recipientId(cardholderId)
                .cardId(cardId)
                .username(cardholderUsername)
                .email(cardholderEmail)
                .build();

        travelPlanEventProducer.sendTravelPlanDetailsUpdated(payload);
    }

}
