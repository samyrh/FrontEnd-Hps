package hps.ma.services;

import hps.ma.dao.entities.Card;
import hps.ma.dao.entities.CardPack;
import hps.ma.dao.enums.*;
import hps.ma.dao.repositories.CardPackRepository;
import hps.ma.dao.repositories.CardRepository;
import hps.ma.dto.*;
import hps.ma.feign_client.AgentService;
import hps.ma.feign_client.CardholderService;
import hps.ma.kafka.producing.CardSecurityEventProducer;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class CardService {

    @Autowired
    private CardRepository cardRepository;
    @Autowired
    private CardholderService cardholderService;
    @Autowired
    private CardSecurityEventProducer cardSecurityEventProducer;
    @Autowired
    private AgentService agentService;
    @Autowired
    private CardholderInfoService cardholderInfoService;
    @Autowired
    private JwtUtil jwtUtil;
    @Autowired
    private CardPackRepository cardPackRepository;
    @Autowired
    private  CardholderService cardholderServiceClient;

    public void updateSecurityOptions(Long cardId, Boolean contactless, Boolean ecommerce, Boolean tpe) {
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        Boolean oldContactless = card.getContactlessEnabled();
        Boolean oldEcommerce = card.getEcommerceEnabled();
        Boolean oldTpe = card.getTpeEnabled();

        // Retrieve cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String email = (String) user.get("email");
        String username = (String) user.get("cardholderName");
        String cardNumber = card.getCardNumber();

        StringBuilder changes = new StringBuilder();

        // Apply logic depending on card type
        if (card.getType() == CardType.PHYSICAL) {
            if (contactless != null && !contactless.equals(oldContactless)) {
                card.setContactlessEnabled(contactless);
                changes.append("contactless ").append(Boolean.TRUE.equals(contactless) ? "enabled" : "disabled").append(", ");
            }
            if (ecommerce != null && !ecommerce.equals(oldEcommerce)) {
                card.setEcommerceEnabled(ecommerce);
                changes.append("ecommerce ").append(Boolean.TRUE.equals(ecommerce) ? "enabled" : "disabled").append(", ");
            }
            if (tpe != null && !tpe.equals(oldTpe)) {
                card.setTpeEnabled(tpe);
                changes.append("TPE ").append(Boolean.TRUE.equals(tpe) ? "enabled" : "disabled").append(", ");
            }
        } else if (card.getType() == CardType.VIRTUAL) {
            // Only ecommerce is allowed for virtual cards
            if (ecommerce != null && !ecommerce.equals(oldEcommerce)) {
                card.setEcommerceEnabled(ecommerce);
                changes.append("ecommerce ").append(Boolean.TRUE.equals(ecommerce) ? "enabled" : "disabled").append(", ");
            }
        }

        // Save only if any change applied
        cardRepository.save(card);

        String changesText = changes.length() > 0
                ? changes.substring(0, changes.length() - 2)
                : "no options changed";

        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            EventPayload payload = EventPayload.builder()
                    .message("Cardholder " + username + " updated security options for card " + cardNumber + ": " + changesText)
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.SECURITY)
                    .senderId(cardholderId)
                    .recipientId(agent.getId())
                    .cardId(cardId)
                    .email(email)
                    .username(username)
                    .build();

            cardSecurityEventProducer.send(payload);
        }
    }
    public List<CardResponseDTO> getAllCardsForCardholder(String token) {
        try {
            String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));
            Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);
            Map<String, Object> userInfo = cardholderService.getCardholderById(cardholderId);
            String cardholderName = (String) userInfo.get("cardholderName");

            List<Card> cards = cardRepository.findByCardholderId(cardholderId);

            return cards.stream().map(card -> {
                if (card.getCardPack() == null) {
                    throw new RuntimeException("❌ Card " + card.getId() + " has no CardPack");
                }

                return CardResponseDTO.builder()
                        .id(card.getId())
                        .cardNumber(card.getCardNumber())
                        .type(card.getType())
                        .status(card.getStatus())
                        .blockReason(card.getBlockReason())
                        .expirationDate(card.getExpirationDate())
                        .contactlessEnabled(Boolean.TRUE.equals(card.getContactlessEnabled()))
                        .ecommerceEnabled(Boolean.TRUE.equals(card.getEcommerceEnabled()))
                        .tpeEnabled(Boolean.TRUE.equals(card.getTpeEnabled()))
                        .dailyLimit(card.getDailyLimit() != null ? card.getDailyLimit() : 0.0)
                        .monthlyLimit(card.getMonthlyLimit() != null ? card.getMonthlyLimit() : 0.0)
                        .annualLimit(card.getAnnualLimit() != null ? card.getAnnualLimit() : 0.0)
                        .internationalWithdraw(Boolean.TRUE.equals(card.getInternationalWithdraw()))
                        .blockEndDate(card.getBlockEndDate())
                        .isCanceled(Boolean.TRUE.equals(card.getIsCanceled()))
                        .gradientStartColor(card.getGradientStartColor())
                        .gradientEndColor(card.getGradientEndColor())
                        .hasActiveTravelPlan(Boolean.TRUE.equals(card.getHasActiveTravelPlan()))
                        .balance(card.getBalance() != null ? card.getBalance() : 0.0)
                        .cardholderName(cardholderName)
                        .cardPack(CardPackResponseDTO.builder()
                                .label(card.getCardPack().getLabel())
                                .audience(card.getCardPack().getAudience())
                                .fee(card.getCardPack().getFee() != null ? card.getCardPack().getFee() : 0.0)
                                .validityYears(card.getCardPack().getValidityYears() != null ? card.getCardPack().getValidityYears() : 0)
                                .limitAnnual(card.getCardPack().getLimitAnnual() != null ? card.getCardPack().getLimitAnnual() : 0.0)
                                .limitDaily(card.getCardPack().getLimitDaily() != null ? card.getCardPack().getLimitDaily() : 0.0)
                                .limitMonthly(card.getCardPack().getLimitMonthly() != null ? card.getCardPack().getLimitMonthly() : 0.0)
                                .internationalWithdraw(Boolean.TRUE.equals(card.getCardPack().getInternationalWithdraw()))
                                .maxCountries(card.getCardPack().getMaxCountries() != null ? card.getCardPack().getMaxCountries() : 0)
                                .maxDays(card.getCardPack().getMaxDays() != null ? card.getCardPack().getMaxDays() : 0)
                                .type(card.getCardPack().getType())
                                .internationalWithdrawLimitPerTravel(
                                        card.getCardPack().getInternationalWithdrawLimitPerTravel() != null
                                                ? card.getCardPack().getInternationalWithdrawLimitPerTravel()
                                                : 0.0
                                )
                                .build())
                        .build();
            }).toList();

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("❌ Failed to get cards: " + e.getMessage());
        }
    }
    public void addCardForCardholder(String token, AddCardRequest request) {
        String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);
        Map<String, Object> userInfo = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");

        // 🔍 Find the card pack
        CardPack pack = cardPackRepository.findByLabel(request.getCardPackLabel());
        if (pack == null) {
            throw new RuntimeException("Card pack not found: " + request.getCardPackLabel());
        }

        // 🔐 Convert type and generate secure credentials
        CardType type = CardType.valueOf(request.getType().toUpperCase());
        String cardNumber = generateCardNumber();

        // ✅ Generate plain CVV and PIN
        String plainCvv = generateRandomCVV();
        String plainPin = type == CardType.PHYSICAL ? generateRandomPIN() : null;

        // ✅ Encrypt using AESUtil
        String encryptedCvv = AESUtil.encrypt(plainCvv);
        String encryptedPin = plainPin != null ? AESUtil.encrypt(plainPin) : null;

        // 💳 Build and save the card
        Card card = Card.builder()
                .cardNumber(cardNumber)
                .cvv(encryptedCvv)
                .pin(encryptedPin)
                .type(type)
                .status(CardStatus.NEW_REQUEST)
                .expirationDate(calculateExpirationDate(pack.getValidityYears()))
                .contactlessEnabled(true)
                .ecommerceEnabled(true)
                .tpeEnabled(true)
                .dailyLimit(pack.getLimitDaily())
                .monthlyLimit(pack.getLimitMonthly())
                .annualLimit(pack.getLimitAnnual())
                .internationalWithdraw(Boolean.TRUE.equals(pack.getInternationalWithdraw()))
                .isCanceled(false)
                .cardholderId(cardholderId)
                .cardPack(pack)
                .gradientStartColor(
                        request.getGradientStartColor() != null ? request.getGradientStartColor().trim() : "#2E2E2E"
                )
                .gradientEndColor(
                        request.getGradientEndColor() != null ? request.getGradientEndColor().trim() : "#7E7E7E"
                )
                .balance(0.0)
                .build();

        cardRepository.save(card);

        // 📢 Notify all agents of the new card request
        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            EventPayload payload = EventPayload.builder()
                    .message("Cardholder " + cardholderName + " has requested a new card — Type: "
                            + type.name().toLowerCase() + ", Pack: \"" + pack.getLabel() + "\".")
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.REQUEST_NEW_CARD)
                    .senderId(cardholderId)
                    .recipientId(agent.getId())
                    .cardId(card.getId())
                    .email(email)
                    .username(cardholderName)
                    .build();

            cardSecurityEventProducer.sendCardRequestCreated(payload);
        }

        // ✅ Optionally: Log the plain values securely for support only (never expose in production logs!)
        System.out.println("✅ Generated CVV (for display): " + plainCvv);
        System.out.println("✅ Generated PIN (for display): " + plainPin);
    }

    private Date calculateExpirationDate(Integer years) {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.YEAR, years != null ? years : 3);
        return calendar.getTime();
    }
    private String generateCardNumber() {
        SecureRandom rand = new SecureRandom();
        StringBuilder cardNumber = new StringBuilder();
        for (int i = 0; i < 4; i++) {
            int block = rand.nextInt(9000) + 1000;
            cardNumber.append(block);
            if (i < 3) cardNumber.append("-");
        }
        return cardNumber.toString();
    }
    private String generateRandomCVV() {
        return String.format("%03d", new SecureRandom().nextInt(1000));
    }
    private String generateRandomPIN() {
        return String.format("%04d", new SecureRandom().nextInt(10000));
    }
    private String hash(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(input.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing value", e);
        }
    }
    public CardResponseDTO getCardById(Long cardId) {
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found with id: " + cardId));

        Map<String, Object> userInfo = cardholderService.getCardholderById(card.getCardholderId());
        String cardholderName = (String) userInfo.get("cardholderName");

        if (card.getCardPack() == null) {
            throw new RuntimeException("Card " + cardId + " has no CardPack");
        }

        return CardResponseDTO.builder()
                .id(card.getId())
                .cardNumber(card.getCardNumber())
                .type(card.getType())
                .status(card.getStatus())
                .blockReason(card.getBlockReason())
                .expirationDate(card.getExpirationDate())
                .contactlessEnabled(Boolean.TRUE.equals(card.getContactlessEnabled()))
                .ecommerceEnabled(Boolean.TRUE.equals(card.getEcommerceEnabled()))
                .tpeEnabled(Boolean.TRUE.equals(card.getTpeEnabled()))
                .dailyLimit(card.getDailyLimit() != null ? card.getDailyLimit() : 0.0)
                .monthlyLimit(card.getMonthlyLimit() != null ? card.getMonthlyLimit() : 0.0)
                .annualLimit(card.getAnnualLimit() != null ? card.getAnnualLimit() : 0.0)
                .internationalWithdraw(Boolean.TRUE.equals(card.getInternationalWithdraw()))
                .blockEndDate(card.getBlockEndDate())
                .isCanceled(Boolean.TRUE.equals(card.getIsCanceled()))
                .gradientStartColor(card.getGradientStartColor())
                .gradientEndColor(card.getGradientEndColor())
                .balance(card.getBalance() != null ? card.getBalance() : 0.0)
                .cvv(card.getCvv())
                .pin(card.getPin())
                .hasActiveTravelPlan(Boolean.TRUE.equals(card.getHasActiveTravelPlan()))
                .replacementRequested(Boolean.TRUE.equals(card.getReplacementRequested()))
                .cardholderName(cardholderName)
                .cardPack(CardPackResponseDTO.builder()
                        .label(card.getCardPack().getLabel())
                        .audience(card.getCardPack().getAudience())
                        .fee(card.getCardPack().getFee() != null ? card.getCardPack().getFee() : 0.0)
                        .validityYears(card.getCardPack().getValidityYears() != null ? card.getCardPack().getValidityYears() : 0)
                        .limitAnnual(card.getCardPack().getLimitAnnual() != null ? card.getCardPack().getLimitAnnual() : 0.0)
                        .limitDaily(card.getCardPack().getLimitDaily() != null ? card.getCardPack().getLimitDaily() : 0.0)
                        .limitMonthly(card.getCardPack().getLimitMonthly() != null ? card.getCardPack().getLimitMonthly() : 0.0)
                        .internationalWithdraw(Boolean.TRUE.equals(card.getCardPack().getInternationalWithdraw()))
                        .maxCountries(card.getCardPack().getMaxCountries() != null ? card.getCardPack().getMaxCountries() : 0)
                        .maxDays(card.getCardPack().getMaxDays() != null ? card.getCardPack().getMaxDays() : 0)
                        .type(card.getCardPack().getType())
                        .internationalWithdrawLimitPerTravel(
                                card.getCardPack().getInternationalWithdrawLimitPerTravel() != null
                                        ? card.getCardPack().getInternationalWithdrawLimitPerTravel()
                                        : 0.0
                        )
                        .build())
                .build();
    }
    public void viewVirtualCardCVV(Long cardId) {
        // Retrieve the card by ID
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // Check if the card is a virtual card
        if (card.getType() != CardType.VIRTUAL) {
            throw new RuntimeException("Card is not a virtual card.");
        }

        // Retrieve the cardholder details
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String username = (String) user.get("cardholderName");
        String email = (String) user.get("email");

        // Create event payload for CVV viewed
        EventPayload payload = EventPayload.builder()
                .message("Cardholder " + username + " viewed CVV for virtual card " + card.getCardNumber())
                .sentAt(new Date())
                .senderType(SenderType.CARDHOLDER)  // Sender is the cardholder
                .category(EventCategory.VIRTUAL_CARD_CVV_VIEWED)  // Event category: VIRTUAL_CARD_CVV_VIEWED
                .senderId(cardholderId)
                .recipientId(null)  // No specific recipient for the initial event
                .cardId(card.getId())
                .email(email)
                .username(username)
                .build();

        // Send the event to Kafka topic "card.cvv.viewed" for the cardholder
        cardSecurityEventProducer.sendViewedCvv(payload);

        // Notify all agents (admins)
        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            // Create the payload for each agent notification
            EventPayload agentPayload = EventPayload.builder()
                    .message("Cardholder " + username + " viewed CVV for virtual card " + card.getCardNumber())
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.VIRTUAL_CARD_CVV_VIEWED)  // Event category: VIRTUAL_CARD_CVV_VIEWED
                    .senderId(cardholderId)
                    .recipientId(agent.getId())  // Specific agent as recipient
                    .cardId(card.getId())
                    .email(email)
                    .username(username)
                    .build();

            // Send the event to Kafka topic "card.cvv.viewed" for each agent
            cardSecurityEventProducer.sendViewedCvv(agentPayload);
        }
    }
    public void updateVirtualCardLimit(Long cardId, Double newAnnualLimit) {
        // Fetch the card by its ID
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // Update the annual limit
        card.setAnnualLimit(newAnnualLimit);

        // Save the updated card in the database
        cardRepository.save(card);

        // Retrieve the cardholder details
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) user.get("cardholderName");
        String cardNumber = card.getCardNumber();
        String cardType = card.getType().name(); // Get card type (e.g., VIRTUAL, PHYSICAL)

        // Create an event payload to notify the event
        EventPayload eventPayload = EventPayload.builder()
                .message("The annual limit for virtual card " + cardNumber + " (" + cardType + ") belonging to cardholder " + cardholderName + " has been successfully updated to " + newAnnualLimit + ".")
                .sentAt(new Date())
                .senderType(SenderType.CARDHOLDER)  // Sender is the cardholder
                .category(EventCategory.VIRTUAL_CARD_LIMIT_UPDATED)  // Event category: VIRTUAL_CARD_LIMIT_UPDATED
                .senderId(cardholderId)  // Sender is the cardholder ID
                .recipientId(null)  // No specific recipient for the initial event
                .cardId(card.getId())  // The updated card ID
                .build();

        // Send the event to Kafka topic "card.virtual.card.limit.updated"
        cardSecurityEventProducer.sendVirtualCardLimitUpdated(eventPayload);

        // Notify all agents (this is where you notify all agents)
        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            // Create the payload for each agent notification
            EventPayload agentPayload = EventPayload.builder()
                    .message("The annual limit for virtual card " + cardNumber + " (" + cardType + ") belonging to cardholder " + cardholderName + " has been successfully updated to " + newAnnualLimit + ".")
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)  // Sender is the cardholder
                    .category(EventCategory.VIRTUAL_CARD_LIMIT_UPDATED)  // Event category: VIRTUAL_CARD_LIMIT_UPDATED
                    .senderId(cardholderId)
                    .recipientId(agent.getId())  // Specific agent as recipient
                    .cardId(card.getId())
                    .build();

            // Send the event to Kafka topic "card.virtual.card.limit.updated" for each agent
            cardSecurityEventProducer.sendVirtualCardLimitUpdated(agentPayload);
        }
    }
    public void blockVirtualCard(Long cardId, BlockReason blockReason) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Only virtual cards allowed
        if (card.getType() != CardType.VIRTUAL) {
            throw new RuntimeException("Card is not a virtual card.");
        }

        // 3️⃣ Always disable ecommerce when blocking
        card.setEcommerceEnabled(false);
        card.setBlockReason(blockReason);

        // 4️⃣ Handle block reasons
        String newCvvPlain = null;  // To store the plain CVV for later use (if generated)

        switch (blockReason) {
            case CVV_LEAK -> {
                // 1️⃣ Generate new CVV
                newCvvPlain = generateRandomCVV();
                String hashedCvv = hash(newCvvPlain);
                card.setCvv(hashedCvv);  // Store hashed CVV in DB

                // 2️⃣ Save card after CVV regeneration
                cardRepository.save(card);

                // 3️⃣ Immediately unblock after CVV regeneration
                unblockVirtualCard(cardId);

                // ✅ Debug log (for development only)
                System.out.println("✅ CVV regenerated & card unblocked for virtual card (cardId=" + cardId + ") — New CVV: " + newCvvPlain);
            }
            case JUST_BLOCK_TEMPORARY -> card.setStatus(CardStatus.TEMPORARILY_BLOCKED);
            case FRAUD_SUSPECTED -> card.setStatus(CardStatus.FRAUD_BLOCKED);
            case CLOSING_ACCOUNT -> card.setStatus(CardStatus.CLOSED_REQUEST);
            default -> throw new IllegalArgumentException("Unsupported block reason.");
        }

        // 5️⃣ Persist card updates
        cardRepository.save(card);

        // 6️⃣ Fetch cardholder info for notifications
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String username = (String) user.get("cardholderName");
        String email = (String) user.get("email");
        String cardNumber = card.getCardNumber();

        // 7️⃣ Build Kafka message depending on reason
        String reasonMessage = switch (blockReason) {
            case JUST_BLOCK_TEMPORARY -> "Temporary Block Requested";
            case CVV_LEAK -> "Security Block due to CVV Leak — New CVV will be generated and securely delivered.";
            case FRAUD_SUSPECTED -> "Fraud Suspected";
            case CLOSING_ACCOUNT -> "Account Closure Requested";
            default -> "Unknown Reason";  // ✅ added default case
        };


        String fullMessage = "Virtual card " + cardNumber + " belonging to cardholder " + username
                + " has been blocked. Reason: " + reasonMessage;

        // 8️⃣ Send Kafka event to cardholder
        EventPayload payload = EventPayload.builder()
                .message(fullMessage)
                .sentAt(new Date())
                .senderType(SenderType.CARDHOLDER)
                .category(EventCategory.VIRTUAL_CARD_BLOCKED)
                .senderId(cardholderId)
                .recipientId(null)
                .cardId(card.getId())
                .email(email)
                .username(username)
                .build();

        cardSecurityEventProducer.sendVirtualCardBlocked(payload);

        // 9️⃣ Notify all agents individually
        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            EventPayload agentPayload = EventPayload.builder()
                    .message(fullMessage)
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.VIRTUAL_CARD_BLOCKED)
                    .senderId(cardholderId)
                    .recipientId(agent.getId())
                    .cardId(card.getId())
                    .email(email)
                    .username(username)
                    .build();

            cardSecurityEventProducer.sendVirtualCardBlocked(agentPayload);
        }
    }
    public void unblockVirtualCard(Long cardId) {
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        if (card.getType() != CardType.VIRTUAL) {
            throw new RuntimeException("Card is not a virtual card.");
        }

        card.setStatus(CardStatus.ACTIVE);
        card.setBlockReason(null);
        card.setEcommerceEnabled(true);
        cardRepository.save(card);

        // 🔥 Send Kafka event
        Map<String, Object> userInfo = cardholderService.getCardholderById(card.getCardholderId());
        String cardholderName = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");

        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            String message = String.format(
                    "Virtual card unblocked for %s (Card: %s, Pack: %s)",
                    cardholderName,
                    card.getCardNumber(),
                    card.getCardPack() != null ? card.getCardPack().getLabel() : "Unknown Pack"
            );

            EventPayload payload = EventPayload.builder()
                    .message(message)
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.VIRTUAL_CARD_UNBLOCKED)
                    .senderId(card.getCardholderId())
                    .recipientId(agent.getId())
                    .cardId(card.getId())
                    .email(email)
                    .username(cardholderName)
                    .build();

            cardSecurityEventProducer.sendVirtualCardUnblocked(payload);
        }
    }
    public void blockVirtualCardByAgent(String token, Long cardId) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it is a VIRTUAL card
        if (card.getType() != CardType.VIRTUAL) {
            throw new RuntimeException("Card is not a virtual card.");
        }

        // 3️⃣ Update status and reason
        card.setStatus(CardStatus.PERMANENTLY_BLOCKED);
        card.setBlockReason(BlockReason.JUST_BLOCK_TEMPORARY );

        // 4️⃣ Disable relevant features
        card.setEcommerceEnabled(false);

        // 5️⃣ Save updates
        cardRepository.save(card);

        // 6️⃣ Retrieve cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String username = (String) user.get("cardholderName");
        String email = (String) user.get("email");
        String cardNumber = card.getCardNumber();

        // 7️⃣ Extract agent info
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long agentId = agent.getId();

        // 8️⃣ Build event payload
        String message = "Your virtual card " + cardNumber + " has been permanently blocked by agent " + agentUsername + ".";

        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.VIRTUAL_CARD_BLOCKED)
                .senderId(agentId)
                .recipientId(cardholderId)
                .cardId(card.getId())
                .email(email)
                .username(username)
                .build();

        // 9️⃣ Send the event to notify the cardholder
        cardSecurityEventProducer.sendVirtualCardBlockedByAgent(payload);
    }

    public VirtualCardSecurityOptionsDTO getVirtualCardSecurityOptionById(String token, Long cardId) {
        String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        Map<String, Object> userInfo = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) userInfo.get("cardholderName");

        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found with id: " + cardId));

        if (!Objects.equals(card.getCardholderId(), cardholderId)) {
            throw new RuntimeException("You do not have permission to access this card.");
        }

        if (card.getType() != CardType.VIRTUAL) {
            throw new RuntimeException("Card is not a virtual card.");
        }

        return VirtualCardSecurityOptionsDTO.builder()
                .label(card.getCardPack() != null ? card.getCardPack().getLabel() : "Unknown Pack")
                .ecommerceEnabled(Boolean.TRUE.equals(card.getEcommerceEnabled()))
                .username(username)
                .cardholderName(cardholderName)
                .build();
    }
    public void replaceVirtualCard(String token, Long blockedCardId) {

        String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        // 🔎 Load blocked card
        Card blockedCard = cardRepository.findById(blockedCardId)
                .orElseThrow(() -> new RuntimeException("Blocked card not found"));

        // ⚠ Ensure the card belongs to the requesting user
        if (!blockedCard.getCardholderId().equals(cardholderId)) {
            throw new RuntimeException("Unauthorized operation.");
        }

        // ✅ Only allow for virtual card type
        if (blockedCard.getType() != CardType.VIRTUAL) {
            throw new RuntimeException("Only virtual cards can be replaced.");
        }

        // 🔎 Get user info
        Map<String, Object> userInfo = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");

        // 🔐 Generate new credentials
        String newCardNumber = generateCardNumber();
        String newCvv = hash(generateRandomCVV());
        String newPin = null;  // No PIN for virtual

        // 🔨 Build replacement card with copied fields
        Card newCard = Card.builder()
                .cardNumber(newCardNumber)
                .cvv(newCvv)
                .pin(newPin)
                .type(CardType.VIRTUAL)
                .status(CardStatus.NEW_REQUEST)
                .expirationDate(blockedCard.getExpirationDate())
                .contactlessEnabled(blockedCard.getContactlessEnabled())
                .ecommerceEnabled(true)  // ✅ Always enable ecommerce for replacement card
                .tpeEnabled(blockedCard.getTpeEnabled())
                .dailyLimit(blockedCard.getDailyLimit())
                .monthlyLimit(blockedCard.getMonthlyLimit())
                .annualLimit(blockedCard.getAnnualLimit())
                .internationalWithdraw(blockedCard.getInternationalWithdraw())
                .isCanceled(false)
                .cardholderId(cardholderId)
                .cardPack(blockedCard.getCardPack())
                .gradientStartColor(blockedCard.getGradientStartColor())
                .gradientEndColor(blockedCard.getGradientEndColor())
                .balance(0.0)
                .build();

        // ✅ Save new card first
        cardRepository.save(newCard);

        // ✅ Mark original card as replacement requested
        blockedCard.setReplacementRequested(true);
        cardRepository.save(blockedCard);

        // 🔥 Notify agents via Kafka
        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            EventPayload payload = EventPayload.builder()
                    .message("Virtual card replacement requested by " + cardholderName + " (Card: " + newCard.getCardNumber() + ", Type: " + newCard.getType().name() + ").")
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.REQUEST_REPLACEMENT_VIRTUAL_CARD)
                    .senderId(cardholderId)
                    .recipientId(agent.getId())
                    .cardId(newCard.getId())
                    .email(email)
                    .username(cardholderName)
                    .build();

            cardSecurityEventProducer.sendVirtualCardReplacementRequest(payload);
        }
    }
    public void cancelVirtualCard(Long cardId) {
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        if (card.getType() != CardType.VIRTUAL) {
            throw new RuntimeException("Card is not a virtual card.");
        }

        // ✅ Apply cancellation logic
        card.setStatus(CardStatus.SUSPENDED);
        card.setIsCanceled(true);
        card.setBlockReason(null);
        card.setBlockEndDate(null);
        card.setEcommerceEnabled(false);

        cardRepository.save(card);

        // 🔥 Now produce Kafka event after cancellation
        Map<String, Object> userInfo = cardholderService.getCardholderById(card.getCardholderId());
        String cardholderName = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");

        // Send event to all admins
        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            EventPayload payload = EventPayload.builder()
                    .message("Virtual card canceled: " + cardholderName + " (" + card.getCardNumber() + " - " + card.getCardPack().getLabel() + ")")
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.VIRTUAL_CARD_CANCELED)
                    .senderId(card.getCardholderId())
                    .recipientId(agent.getId())
                    .cardId(card.getId())
                    .email(email)
                    .username(cardholderName)
                    .build();

            cardSecurityEventProducer.sendVirtualCardCanceled(payload);
        }
    }
    public void uncancelVirtualCard(Long cardId) {
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        if (card.getType() != CardType.VIRTUAL) {
            throw new RuntimeException("Card is not a virtual card.");
        }

        if (card.getIsCanceled() == null || !card.getIsCanceled()) {
            throw new RuntimeException("Card is not canceled.");
        }

        // ✅ Apply un-cancel logic
        card.setStatus(CardStatus.ACTIVE);
        card.setIsCanceled(false);
        card.setBlockReason(null);
        card.setBlockEndDate(null);
        card.setEcommerceEnabled(true); // optional

        cardRepository.save(card);

        /*
        // 🔥 Produce Kafka event after uncancellation
        Map<String, Object> userInfo = cardholderService.getCardholderById(card.getCardholderId());
        String cardholderName = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");


        String message = String.format(
                "Your virtual card (%s - %s) has been successfully reactivated by our support team.",
                card.getCardNumber(),
                card.getCardPack().getLabel()  // you can also put "VIRTUAL" directly if you prefer
        );

        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.VIRTUAL_CARD_REACTIVATED)
                .senderId(0L)
                .recipientId(card.getCardholderId())
                .cardId(card.getId())
                .email(email)
                .username(cardholderName)
                .build();

        cardSecurityEventProducer.sendVirtualCardReactivated(payload);

         */

    }
    public void updateHasActiveTravelPlan(Long cardId, boolean active) {
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        card.setHasActiveTravelPlan(active);
        cardRepository.save(card);
    }
    public void updatePin(String token, Long cardId, String currentPin, String newPin) {
        String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new IllegalArgumentException("Card not found with ID: " + cardId));

        if (!card.getCardholderId().equals(cardholderId)) {
            throw new SecurityException("You do not have permission to update this card's PIN.");
        }

        if (card.getType() != CardType.PHYSICAL) {
            throw new IllegalStateException("Only physical cards support PIN update.");
        }

        // ✅ Compare raw PIN directly
        if (!card.getPin().equals(currentPin)) {
            throw new SecurityException("The current PIN is incorrect.");
        }

        // ✅ Ensure new PIN is different
        if (currentPin.equals(newPin)) {
            throw new IllegalArgumentException("The new PIN must be different from the current PIN.");
        }

        // ✅ Save new PIN as-is (no hashing)
        card.setPin(newPin);
        cardRepository.save(card);

        Map<String, Object> userInfo = cardholderService.getCardholderById(cardholderId);
        String name = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");

        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            EventPayload payload = EventPayload.builder()
                    .message("PIN updated for " + name + " (" + card.getType().name() + " - " + card.getCardNumber() + ")")
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.PIN_UPDATED)
                    .senderId(cardholderId)
                    .recipientId(agent.getId())
                    .cardId(card.getId())
                    .email(email) // 🔐 Optional: encrypt if required
                    .username(name)
                    .build();

            cardSecurityEventProducer.sendPinUpdated(payload);
        }
    }

    public void requestCvv(String token, Long cardId) {
        String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new IllegalArgumentException("Card not found with ID: " + cardId));

        if (!card.getCardholderId().equals(cardholderId)) {
            throw new SecurityException("You do not have permission to request CVV for this card.");
        }

        if (Boolean.TRUE.equals(card.getCvvRequested())) {
            throw new IllegalStateException("CVV already requested for this card.");
        }

        card.setCvvRequested(true);
        cardRepository.save(card);

        Map<String, Object> userInfo = cardholderService.getCardholderById(cardholderId);
        String name = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");

        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            EventPayload payload = EventPayload.builder()
                    .message("CVV requested by " + name + " (" + card.getType().name() + " - " + card.getCardNumber() + ")")
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.CVV_REQUESTED)
                    .senderId(cardholderId)
                    .recipientId(agent.getId())
                    .cardId(card.getId())
                    .email(email)
                    .username(name)
                    .build();

            cardSecurityEventProducer.sendCvvRequested(payload);
        }
    }
    public void updatePhysicalCardLimits(Long cardId, UpdatePhysicalLimitsRequest request) {
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // Update limits
        card.setDailyLimit(request.getNewDailyLimit());
        card.setMonthlyLimit(request.getNewMonthlyLimit());
        card.setAnnualLimit(request.getNewAnnualLimit());

        cardRepository.save(card);

        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) user.get("cardholderName");

        String message = "Limits updated for physical card " + card.getCardNumber() + " → " +
                "Daily: " + request.getNewDailyLimit() + ", " +
                "Monthly: " + request.getNewMonthlyLimit() + ", " +
                "Annual: " + request.getNewAnnualLimit();

        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.CARDHOLDER)
                .category(EventCategory.PHYSICAL_CARD_LIMITS_UPDATED)
                .senderId(cardholderId)
                .cardId(cardId)
                .build();

        // Notify all agents
        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            payload.setRecipientId(agent.getId());
            cardSecurityEventProducer.sendPhysicalCardLimitsUpdated(payload);
        }
    }
    public void blockPhysicalCard(Long cardId, BlockReason blockReason) {
        // 1️⃣ Retrieve card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure physical card
        if (card.getType() != CardType.PHYSICAL) {
            throw new RuntimeException("Card is not a physical card.");
        }

        // 3️⃣ Update status based on block reason
        card.setBlockReason(blockReason);
        switch (blockReason) {
            case PERMANENT_BLOCK -> card.setStatus(CardStatus.PERMANENTLY_BLOCKED);
            case LOST -> card.setStatus(CardStatus.LOST);
            case STOLEN -> card.setStatus(CardStatus.STOLEN);
            case DAMAGED -> card.setStatus(CardStatus.DAMAGED);
            default -> throw new IllegalArgumentException("Unsupported block reason for physical card.");
        }

        // 4️⃣ Disable features for security
        card.setContactlessEnabled(false);
        card.setEcommerceEnabled(false);
        card.setTpeEnabled(false);
        card.setInternationalWithdraw(false);

        // 5️⃣ Save card
        cardRepository.save(card);

        // 6️⃣ Gather info for notification
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String username = (String) user.get("cardholderName");
        String email = (String) user.get("email");
        String cardNumber = card.getCardNumber();

        String reasonMessage = switch (blockReason) {
            case PERMANENT_BLOCK -> "Permanent Block Requested";
            case LOST -> "Card Reported Lost";
            case STOLEN -> "Card Reported Stolen";
            case DAMAGED -> "Card Reported Damaged";
            default -> "Unknown Reason";
        };

        String fullMessage = "Physical card " + cardNumber + " belonging to cardholder " + username
                + " has been blocked. Reason: " + reasonMessage;

        // 7️⃣ Notify each agent with a separate payload
        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            EventPayload agentPayload = EventPayload.builder()
                    .message(fullMessage)
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.PHYSICAL_CARD_BLOCKED)
                    .senderId(cardholderId)
                    .recipientId(agent.getId())
                    .cardId(card.getId())
                    .email(email)
                    .username(username)
                    .build();

            cardSecurityEventProducer.sendPhysicalCardBlocked(agentPayload);
        }
    }
    public void requestPhysicalCardReplacementDueToLoss(String token, Long cardId) {
        // 1️⃣ Extract username from token
        String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        // 2️⃣ Retrieve the card
        Card existingCard = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 3️⃣ Ensure the card belongs to this user
        if (!existingCard.getCardholderId().equals(cardholderId)) {
            throw new RuntimeException("Unauthorized operation.");
        }

        // 4️⃣ Ensure it's a physical card
        if (existingCard.getType() != CardType.PHYSICAL) {
            throw new RuntimeException("Only physical cards can be replaced via this operation.");
        }

        // 5️⃣ Retrieve cardholder info
        Map<String, Object> userInfo = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");

        // 6️⃣ Reset security features and mark as replacement requested
        existingCard.setStatus(CardStatus.NEW_REQUEST);
        existingCard.setContactlessEnabled(false);
        existingCard.setEcommerceEnabled(false);
        existingCard.setTpeEnabled(false);
        existingCard.setInternationalWithdraw(false);
        existingCard.setReplacementRequested(true);
        existingCard.setBlockReason(null);
        // 7️⃣ Save the updated card
        cardRepository.save(existingCard);

        // 8️⃣ Notify all agents
        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            EventPayload payload = EventPayload.builder()
                    .message("Physical card reissue requested because the card was reported LOST (Type: PHYSICAL) by "
                            + cardholderName + " (Card: " + existingCard.getCardNumber() + ").")
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.REQUEST_REPLACEMENT_PHYSICAL_CARD)
                    .senderId(cardholderId)
                    .recipientId(agent.getId())
                    .cardId(existingCard.getId())
                    .email(email)
                    .username(cardholderName)
                    .build();

            cardSecurityEventProducer.sendPhysicalCardReplacementRequest(payload);
        }
    }
    public void requestPhysicalCardReplacementDueToStolen(String token, Long cardId) {
        String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        Card existingCard = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        if (!existingCard.getCardholderId().equals(cardholderId)) {
            throw new RuntimeException("Unauthorized operation.");
        }
        if (existingCard.getType() != CardType.PHYSICAL) {
            throw new RuntimeException("Only physical cards can be replaced via this operation.");
        }

        // ✅ DO NOT change status or blockReason — keep them as is
        // ✅ Only mark replacementRequested
        existingCard.setReplacementRequested(true);

        // 🔐 Generate new credentials
        String newCardNumber = generateCardNumber();
        String plainCvv = generateRandomCVV();
        String plainPin = generateRandomPIN();
        String encryptedCvv = AESUtil.encrypt(plainCvv);
        String encryptedPin = AESUtil.encrypt(plainPin);

        // Build replacement card
        Card newCard = Card.builder()
                .cardNumber(newCardNumber)
                .cvv(encryptedCvv)
                .pin(encryptedPin)
                .type(CardType.PHYSICAL)
                .status(CardStatus.NEW_REQUEST)
                .expirationDate(existingCard.getExpirationDate())
                .contactlessEnabled(false)
                .ecommerceEnabled(false)
                .tpeEnabled(false)
                .dailyLimit(existingCard.getDailyLimit())
                .monthlyLimit(existingCard.getMonthlyLimit())
                .annualLimit(existingCard.getAnnualLimit())
                .internationalWithdraw(false)
                .isCanceled(false)
                .cardholderId(cardholderId)
                .cardPack(existingCard.getCardPack())
                .gradientStartColor(existingCard.getGradientStartColor())
                .gradientEndColor(existingCard.getGradientEndColor())
                .balance(0.0)
                .build();

        // Save both
        cardRepository.save(existingCard);
        cardRepository.save(newCard);

        Map<String, Object> userInfo = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");

        // Notify agents
        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            EventPayload payload = EventPayload.builder()
                    .message("Physical card reissue requested because the card was reported STOLEN by "
                            + cardholderName + " (Old Card: " + existingCard.getCardNumber() + ").")
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.REQUEST_REPLACEMENT_PHYSICAL_CARD)
                    .senderId(cardholderId)
                    .recipientId(agent.getId())
                    .cardId(newCard.getId())
                    .email(email)
                    .username(cardholderName)
                    .build();

            cardSecurityEventProducer.sendPhysicalCardReplacementRequest(payload);
        }

        System.out.println("✅ New card created: " + newCardNumber + ", CVV: " + plainCvv + ", PIN: " + plainPin);
    }
    public void requestPhysicalCardReplacementDueToDamaged(String token, Long cardId) {
        // 1️⃣ Extract username from token
        String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        // 2️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 3️⃣ Ensure ownership
        if (!card.getCardholderId().equals(cardholderId)) {
            throw new RuntimeException("Unauthorized operation.");
        }

        // 4️⃣ Ensure it's a PHYSICAL card
        if (card.getType() != CardType.PHYSICAL) {
            throw new RuntimeException("Only physical cards can be replaced via this operation.");
        }

        // 5️⃣ Update status and flags
        card.setStatus(CardStatus.NEW_REQUEST);
        card.setBlockReason(null);
        card.setReplacementRequested(true);
        card.setContactlessEnabled(false);
        card.setEcommerceEnabled(false);
        card.setTpeEnabled(false);
        card.setInternationalWithdraw(false);

        // 6️⃣ Save the updated card
        cardRepository.save(card);

        // 7️⃣ Retrieve cardholder info for notifications
        Map<String, Object> userInfo = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");

        // 8️⃣ Notify all agents
        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            EventPayload payload = EventPayload.builder()
                    .message("Physical card replacement requested because the card was reported DAMAGED by "
                            + cardholderName + " (Card: " + card.getCardNumber() + ").")
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.REQUEST_REPLACEMENT_PHYSICAL_CARD)
                    .senderId(cardholderId)
                    .recipientId(agent.getId())
                    .cardId(card.getId())
                    .email(email)
                    .username(cardholderName)
                    .build();

            cardSecurityEventProducer.sendPhysicalCardReplacementRequest(payload);
        }
    }
    public void updatePhysicalCardSecurityOptions(
            Long cardId,
            Boolean contactless,
            Boolean ecommerce,
            Boolean tpe,
            Boolean internationalWithdraw
    ) {
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        if (card.getType() != CardType.PHYSICAL) {
            throw new RuntimeException("This method is only for physical cards.");
        }

        // Store old values for comparison
        boolean changed = false;
        StringBuilder changes = new StringBuilder();

        if (contactless != null && !contactless.equals(card.getContactlessEnabled())) {
            card.setContactlessEnabled(contactless);
            changes.append("contactless ").append(contactless ? "enabled" : "disabled").append(", ");
            changed = true;
        }
        if (ecommerce != null && !ecommerce.equals(card.getEcommerceEnabled())) {
            card.setEcommerceEnabled(ecommerce);
            changes.append("ecommerce ").append(ecommerce ? "enabled" : "disabled").append(", ");
            changed = true;
        }
        if (tpe != null && !tpe.equals(card.getTpeEnabled())) {
            card.setTpeEnabled(tpe);
            changes.append("TPE ").append(tpe ? "enabled" : "disabled").append(", ");
            changed = true;
        }
        if (internationalWithdraw != null && !internationalWithdraw.equals(card.getInternationalWithdraw())) {
            card.setInternationalWithdraw(internationalWithdraw);
            changes.append("international withdraw ").append(internationalWithdraw ? "enabled" : "disabled").append(", ");
            changed = true;
        }

        // Only save and notify if any change was made
        if (changed) {
            cardRepository.save(card);

            Long cardholderId = card.getCardholderId();
            Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
            String email = (String) user.get("email");
            String username = (String) user.get("cardholderName");
            String cardNumber = card.getCardNumber();

            String changesText = changes.substring(0, changes.length() - 2); // remove last comma

            List<AgentDto> agents = agentService.getAllAgents();
            for (AgentDto agent : agents) {
                EventPayload payload = EventPayload.builder()
                        .message("Cardholder " + username + " updated physical card security options for card " + cardNumber + ": " + changesText)
                        .sentAt(new Date())
                        .senderType(SenderType.CARDHOLDER)
                        .category(EventCategory.SECURITY)
                        .senderId(cardholderId)
                        .recipientId(agent.getId())
                        .cardId(cardId)
                        .email(email)
                        .username(username)
                        .build();

                cardSecurityEventProducer.send(payload);
            }
        } else {
            // Optional: log or handle "no changes" situation
            System.out.println("⚠️ No changes detected in security options for card " + cardId);
        }
    }

    public CardSecurityOptionsWithIdDTO getPhysicalCardSecurityOptionById(String token, Long cardId) {
        String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        Long cardholderId = cardholderInfoService.getCardholderIdByUsername(username);

        Map<String, Object> userInfo = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) userInfo.get("cardholderName");

        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found with id: " + cardId));

        if (!Objects.equals(card.getCardholderId(), cardholderId)) {
            throw new RuntimeException("You do not have permission to access this card.");
        }

        if (card.getType() != CardType.PHYSICAL) {
            throw new RuntimeException("Card is not a physical card.");
        }

        return CardSecurityOptionsWithIdDTO.builder()
                .cardId(card.getId())
                .label(card.getCardPack() != null ? card.getCardPack().getLabel() : "Unknown Pack")
                .contactlessEnabled(Boolean.TRUE.equals(card.getContactlessEnabled()))
                .ecommerceEnabled(Boolean.TRUE.equals(card.getEcommerceEnabled()))
                .tpeEnabled(Boolean.TRUE.equals(card.getTpeEnabled()))
                .internationalWithdrawEnabled(Boolean.TRUE.equals(card.getInternationalWithdraw()))
                .username(username)
                .cardholderName(cardholderName)
                .build();
    }
    public void unblockPhysicalCard(Long cardId) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it's a PHYSICAL card
        if (card.getType() != CardType.PHYSICAL) {
            throw new RuntimeException("Card is not a physical card.");
        }

        // 3️⃣ Check if the card is actually blocked
        if (card.getStatus() != CardStatus.PERMANENTLY_BLOCKED &&
                card.getStatus() != CardStatus.LOST &&
                card.getStatus() != CardStatus.STOLEN &&
                card.getStatus() != CardStatus.DAMAGED) {
            throw new RuntimeException("Card is not in a blocked state.");
        }

        // 4️⃣ Reactivate card and re-enable features
        card.setStatus(CardStatus.ACTIVE);
        card.setBlockReason(null);
        card.setContactlessEnabled(true);
        card.setEcommerceEnabled(true);
        card.setTpeEnabled(true);
        card.setInternationalWithdraw(true);
        cardRepository.save(card);

        // 5️⃣ Gather info for notification
        Map<String, Object> userInfo = cardholderService.getCardholderById(card.getCardholderId());
        String cardholderName = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");

        // 6️⃣ Notify all agents
        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            String message = String.format(
                    "Physical card unblocked for %s (Card: %s, Pack: %s)",
                    cardholderName,
                    card.getCardNumber(),
                    card.getCardPack() != null ? card.getCardPack().getLabel() : "Unknown Pack"
            );

            EventPayload payload = EventPayload.builder()
                    .message(message)
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.PHYSICAL_CARD_UNBLOCKED)
                    .senderId(card.getCardholderId())
                    .recipientId(agent.getId())
                    .cardId(card.getId())
                    .email(email)
                    .username(cardholderName)
                    .build();

            // You can create a method similar to sendVirtualCardUnblocked if you prefer, or reuse a generic send
            cardSecurityEventProducer.sendPhysicalCardUnblocked(payload);
        }
    }
    public void cancelPhysicalCard(Long cardId) {
        // Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // Validate card type
        if (card.getType() != CardType.PHYSICAL) {
            throw new RuntimeException("Card is not a physical card.");
        }

        // Optional: check current status
        if (Boolean.TRUE.equals(card.getIsCanceled())) {
            throw new RuntimeException("Card is already canceled.");
        }

        // Update status
        card.setStatus(CardStatus.SUSPENDED);
        card.setIsCanceled(true);
        card.setBlockReason(null);
        card.setBlockEndDate(null);
        card.setContactlessEnabled(false);
        card.setEcommerceEnabled(false);
        card.setTpeEnabled(false);
        card.setInternationalWithdraw(false);

        // Save the update
        cardRepository.save(card);

        // Notify all agents
        Long cardholderId = card.getCardholderId();
        Map<String, Object> userInfo = cardholderService.getCardholderById(cardholderId);
        String username = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");

        List<AgentDto> agents = agentService.getAllAgents();
        for (AgentDto agent : agents) {
            EventPayload payload = EventPayload.builder()
                    .message("Physical card canceled: " + username + " (" + card.getCardNumber() + ")")
                    .sentAt(new Date())
                    .senderType(SenderType.CARDHOLDER)
                    .category(EventCategory.PHYSICAL_CARD_CANCELED)
                    .senderId(cardholderId)
                    .recipientId(agent.getId())
                    .cardId(cardId)
                    .email(email)
                    .username(username)
                    .build();

            cardSecurityEventProducer.sendPhysicalCardCanceled(payload);
        }
    }


    public List<CardResponseDTO> getAllCardsForAgent(String token) {
        // 1️⃣ Extract username of the agent
        String username = jwtUtil.extractUsername(token.replace("Bearer ", ""));



        // 3️⃣ Fetch all cards
        List<Card> cards = cardRepository.findAll();

        // 4️⃣ Map to DTOs
        return cards.stream().map(card -> {
            Map<String, Object> userInfo = cardholderService.getCardholderById(card.getCardholderId());
            String cardholderName = (String) userInfo.getOrDefault("cardholderName", "Unknown");

            return CardResponseDTO.builder()
                    .id(card.getId())
                    .cardNumber(card.getCardNumber())
                    .type(card.getType())
                    .status(card.getStatus())
                    .blockReason(card.getBlockReason())
                    .expirationDate(card.getExpirationDate())
                    .cvv(card.getCvv())
                    .pin(card.getPin())
                    .contactlessEnabled(Boolean.TRUE.equals(card.getContactlessEnabled()))
                    .ecommerceEnabled(Boolean.TRUE.equals(card.getEcommerceEnabled()))
                    .tpeEnabled(Boolean.TRUE.equals(card.getTpeEnabled()))
                    .dailyLimit(card.getDailyLimit() != null ? card.getDailyLimit() : 0.0)
                    .monthlyLimit(card.getMonthlyLimit() != null ? card.getMonthlyLimit() : 0.0)
                    .annualLimit(card.getAnnualLimit() != null ? card.getAnnualLimit() : 0.0)
                    .internationalWithdraw(Boolean.TRUE.equals(card.getInternationalWithdraw()))
                    .blockEndDate(card.getBlockEndDate())
                    .isCanceled(Boolean.TRUE.equals(card.getIsCanceled()))
                    .replacementRequested(card.getReplacementRequested())
                    .gradientStartColor(card.getGradientStartColor())
                    .gradientEndColor(card.getGradientEndColor())
                    .balance(card.getBalance() != null ? card.getBalance() : 0.0)
                    .hasActiveTravelPlan(Boolean.TRUE.equals(card.getHasActiveTravelPlan()))
                    .cardholderName(cardholderName)
                    .cardPack(card.getCardPack() != null
                            ? CardPackResponseDTO.builder()
                            .label(card.getCardPack().getLabel())
                            .audience(card.getCardPack().getAudience())
                            .fee(card.getCardPack().getFee() != null ? card.getCardPack().getFee() : 0.0)
                            .validityYears(card.getCardPack().getValidityYears() != null ? card.getCardPack().getValidityYears() : 0)
                            .limitAnnual(card.getCardPack().getLimitAnnual() != null ? card.getCardPack().getLimitAnnual() : 0.0)
                            .limitDaily(card.getCardPack().getLimitDaily() != null ? card.getCardPack().getLimitDaily() : 0.0)
                            .limitMonthly(card.getCardPack().getLimitMonthly() != null ? card.getCardPack().getLimitMonthly() : 0.0)
                            .internationalWithdraw(Boolean.TRUE.equals(card.getCardPack().getInternationalWithdraw()))
                            .maxCountries(card.getCardPack().getMaxCountries() != null ? card.getCardPack().getMaxCountries() : 0)
                            .maxDays(card.getCardPack().getMaxDays() != null ? card.getCardPack().getMaxDays() : 0)
                            .type(card.getCardPack().getType())
                            .internationalWithdrawLimitPerTravel(
                                    card.getCardPack().getInternationalWithdrawLimitPerTravel() != null
                                            ? card.getCardPack().getInternationalWithdrawLimitPerTravel()
                                            : 0.0
                            )
                            .build()
                            : null
                    )
                    .build();
        }).toList();
    }




    public Card addCardForCardholderByAgent(String token, AddCardByAgentRequest request) {
        // 1️⃣ Extract agent username
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));

        // 2️⃣ Get agent info WITHOUT Authorization header
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        String agentName = agent.getUsername(); // or getFullName()

        // 3️⃣ Get cardholder info
        Map<String, Object> userInfo = cardholderService.getCardholderById(request.getCardholderId());
        String cardholderName = (String) userInfo.get("cardholderName");
        String cardholderEmail = (String) userInfo.get("email");

        // 4️⃣ Validate CardPack
        CardPack pack = cardPackRepository.findByLabel(request.getCardPackLabel());
        if (pack == null) {
            throw new RuntimeException("Card pack not found: " + request.getCardPackLabel());
        }

        // 5️⃣ Convert card type
        CardType type = CardType.valueOf(request.getType().toUpperCase());

        // 6️⃣ Generate credentials
        String cardNumber = generateCardNumber();
        String plainCvv = generateRandomCVV();
        String plainPin = type == CardType.PHYSICAL ? generateRandomPIN() : null;

        // 7️⃣ Encrypt credentials
        String encryptedCvv = AESUtil.encrypt(plainCvv);
        String encryptedPin = plainPin != null ? AESUtil.encrypt(plainPin) : null;

        // 8️⃣ Build card entity
        Card card = Card.builder()
                .cardNumber(cardNumber)
                .cvv(encryptedCvv)
                .pin(encryptedPin)
                .type(type)
                .status(CardStatus.ACTIVE)
                .expirationDate(calculateExpirationDate(pack.getValidityYears()))
                .contactlessEnabled(true)
                .ecommerceEnabled(true)
                .tpeEnabled(true)
                .dailyLimit(pack.getLimitDaily())
                .monthlyLimit(pack.getLimitMonthly())
                .annualLimit(pack.getLimitAnnual())
                .internationalWithdraw(Boolean.TRUE.equals(pack.getInternationalWithdraw()))
                .isCanceled(false)
                .cardholderId(request.getCardholderId())
                .cardPack(pack)
                .gradientStartColor(request.getGradientStartColor() != null ? request.getGradientStartColor().trim() : "#2E2E2E")
                .gradientEndColor(request.getGradientEndColor() != null ? request.getGradientEndColor().trim() : "#7E7E7E")
                .balance(0.0)
                .build();

        // 9️⃣ Save card
        cardRepository.save(card);

        // 🔟 Produce event
        EventPayload payload = EventPayload.builder()
                .message("A new " + type.name().toLowerCase() + " card (\"" + pack.getLabel() + "\") has been issued by Agent " + agentName + " for cardholder " + cardholderName + ".")
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.CREATE_CARD)
                .senderId(agent.getId())
                .recipientId(request.getCardholderId())
                .cardId(card.getId())
                .email(cardholderEmail)
                .username(cardholderName)
                .build();

        cardSecurityEventProducer.sendAgentCardCreated(payload);

        // ✅ Log credentials (support)
        System.out.println("✅ Generated CVV (for display): " + plainCvv);
        System.out.println("✅ Generated PIN (for display): " + plainPin);

        // ✅ Return the card
        return card;
    }



    public void approveNewRequestedCard(String token, Long cardId) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it's pending approval
        if (card.getStatus() != CardStatus.NEW_REQUEST) {
            throw new IllegalStateException("Only cards in NEW_REQUEST status can be approved.");
        }

        // 3️⃣ Set all the required fields
        card.setStatus(CardStatus.ACTIVE);
        card.setCvvRequested(false);
        card.setEcommerceEnabled(true);
        card.setIsCanceled(false);
        card.setBlockReason(null);
        card.setContactlessEnabled(true);
        card.setHasActiveTravelPlan(false);
        card.setInternationalWithdraw(true);
        card.setReplacementRequested(false);
        card.setTpeEnabled(true);

        // 4️⃣ Save the card
        cardRepository.save(card);

        // 5️⃣ Gather cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) user.get("cardholderName");
        String email = (String) user.get("email");
        String cardNumber = card.getCardNumber();

        // 6️⃣ Extract agent info from token
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long approverAgentId = agent.getId();

        // 7️⃣ Prepare message
        String message = "The new card " + cardNumber + " for cardholder " + cardholderName
                + " has been approved and activated by Agent " + agentUsername + ".";

        // 8️⃣ Send single event
        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.CREATE_CARD)
                .senderId(approverAgentId)         // ✅ The approving agent
                .recipientId(cardholderId)         // ✅ The cardholder
                .cardId(card.getId())
                .email(email)
                .username(cardholderName)
                .build();

        cardSecurityEventProducer.sendAgentCardApproved(payload);
    }
    public void approveNewRequestedVirtualCard(String token, Long cardId) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it's a virtual card and pending approval
        if (card.getType() != CardType.VIRTUAL) {
            throw new IllegalStateException("Card is not a virtual card.");
        }
        if (card.getStatus() != CardStatus.NEW_REQUEST) {
            throw new IllegalStateException("Only cards in NEW_REQUEST status can be approved.");
        }

        // 3️⃣ Set all required fields
        card.setStatus(CardStatus.ACTIVE);
        card.setCvvRequested(false);
        card.setEcommerceEnabled(true);
        card.setIsCanceled(false);
        card.setBlockReason(null);
        card.setReplacementRequested(false);

        // 4️⃣ Save the card
        cardRepository.save(card);

        // 5️⃣ Gather cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) user.get("cardholderName");
        String email = (String) user.get("email");
        String cardNumber = card.getCardNumber();

        // 6️⃣ Extract agent info from token
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long approverAgentId = agent.getId();

        // 7️⃣ Prepare message
        String message = "The new virtual card " + cardNumber + " for cardholder " + cardholderName
                + " has been approved and activated by Agent " + agentUsername + ".";

        // 8️⃣ Send single event
        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.CREATE_CARD)
                .senderId(approverAgentId)       // ✅ The approving agent
                .recipientId(cardholderId)       // ✅ The cardholder
                .cardId(card.getId())
                .email(email)
                .username(cardholderName)
                .build();

        cardSecurityEventProducer.sendAgentCardApproved(payload);
    }
    public void rejectNewRequestedCard(String token, Long cardId) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it's pending approval
        if (card.getStatus() != CardStatus.NEW_REQUEST) {
            throw new IllegalStateException("Only cards in NEW_REQUEST status can be rejected.");
        }

        // 3️⃣ Get cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) user.get("cardholderName");
        String email = (String) user.get("email");
        String cardNumber = card.getCardNumber();

        // 4️⃣ Extract agent info
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long rejectingAgentId = agent.getId();

        // 5️⃣ Prepare event payload
        String message = "The new card " + cardNumber + " for cardholder " + cardholderName
                + " has been rejected and removed by Agent " + agentUsername + ".";

        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.REJECT_CARD)
                .senderId(rejectingAgentId)
                .recipientId(cardholderId)
                .cardId(card.getId())
                .email(email)
                .username(cardholderName)
                .build();

        // 6️⃣ Send event
        cardSecurityEventProducer.sendAgentCardRejected(payload);

        // 7️⃣ Delete the card
        cardRepository.delete(card);
    }
    public void blockPhysicalCardByAgent(String token, Long cardId) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it is a PHYSICAL card
        if (card.getType() != CardType.PHYSICAL) {
            throw new RuntimeException("Card is not a physical card.");
        }

        // 3️⃣ Update status
        card.setStatus(CardStatus.PERMANENTLY_BLOCKED);
        card.setBlockReason(BlockReason.PERMANENT_BLOCK);

        // 4️⃣ Disable all features for security
        card.setContactlessEnabled(false);
        card.setEcommerceEnabled(false);
        card.setTpeEnabled(false);
        card.setInternationalWithdraw(false);

        // 5️⃣ Save updates
        cardRepository.save(card);

        // 6️⃣ Retrieve cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String username = (String) user.get("cardholderName");
        String email = (String) user.get("email");
        String cardNumber = card.getCardNumber();

        // 7️⃣ Extract agent info
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long agentId = agent.getId();

        // 8️⃣ Build event payload to notify the cardholder
        String message = "Your physical card " + cardNumber + " has been permanently blocked by agent " + agentUsername + ".";

        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.PHYSICAL_CARD_BLOCKED)
                .senderId(agentId)
                .recipientId(cardholderId)
                .cardId(card.getId())
                .email(email)
                .username(username)
                .build();

        // 9️⃣ Send the event to notify the cardholder
        cardSecurityEventProducer.sendPhysicalCardBlockedByAgent(payload);
    }
    @Transactional
    public void unblockVirtualCardByAgent(String token, Long cardId) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it is a VIRTUAL card
        if (card.getType() != CardType.VIRTUAL) {
            throw new RuntimeException("Card is not a virtual card.");
        }

        // 3️⃣ Update fields
        card.setStatus(CardStatus.ACTIVE);
        card.setBlockReason(null);
        card.setCvvRequested(false);
        card.setEcommerceEnabled(true);
        card.setIsCanceled(false);
        card.setReplacementRequested(false);

        // 4️⃣ Save updates
        cardRepository.save(card);

        // 5️⃣ Retrieve cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String username = (String) user.get("cardholderName");
        String email = (String) user.get("email");
        String cardNumber = card.getCardNumber();

        // 6️⃣ Extract agent info
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long agentId = agent.getId();

        String cardPackLabel = card.getCardPack() != null
                ? card.getCardPack().getLabel()
                : "No associated pack";

        // 7️⃣ Compose notification message
        String message = "Your virtual card " + cardNumber + " (Pack: " + cardPackLabel + ") has been unblocked by Agent " + agentUsername + ".";

        // 8️⃣ Build event payload
        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.VIRTUAL_CARD_UNBLOCKED)
                .senderId(agentId)
                .recipientId(cardholderId)
                .cardId(cardId)
                .email(email)
                .username(username)
                .build();

        // 9️⃣ Send event to Kafka
        cardSecurityEventProducer.sendVirtualCardUnblockedByAgent(payload);
    }

    public void unblockPhysicalCardByAgent(String token, Long cardId) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it is a PHYSICAL card
        if (card.getType() != CardType.PHYSICAL) {
            throw new RuntimeException("Card is not a physical card.");
        }

        // 3️⃣ Update status and reset fields
        card.setStatus(CardStatus.ACTIVE);
        card.setBlockReason(null);
        card.setCvvRequested(false);
        card.setEcommerceEnabled(true);
        card.setIsCanceled(false);
        card.setContactlessEnabled(true);
        card.setHasActiveTravelPlan(false);
        card.setInternationalWithdraw(true);
        card.setReplacementRequested(false);
        card.setTpeEnabled(true);

        // 4️⃣ Save updates
        cardRepository.save(card);

        // 5️⃣ Retrieve cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String username = (String) user.get("cardholderName");
        String email = (String) user.get("email");
        String cardNumber = card.getCardNumber();

        // 6️⃣ Extract agent info
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long agentId = agent.getId();


        String cardPackLabel = card.getCardPack() != null
                ? card.getCardPack().getLabel()
                : "No associated pack";

        String message = "Your physical card " + cardNumber + " (Pack: " + cardPackLabel + ") has been unblocked by Agent " + agentUsername + ".";

        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.PHYSICAL_CARD_BLOCKED)
                .senderId(agentId)
                .recipientId(cardholderId)
                .cardId(card.getId())
                .email(email)
                .username(username)
                .build();

        // 8️⃣ Send the event to notify the cardholder
        cardSecurityEventProducer.sendPhysicalCardUnblockedByAgent(payload);
    }
    public void cancelPhysicalCardByAgent(String token, Long cardId) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it is a PHYSICAL card
        if (card.getType() != CardType.PHYSICAL) {
            throw new RuntimeException("Card is not a physical card.");
        }

        // 3️⃣ Update status and flags
        card.setStatus(CardStatus.SUSPENDED);
        card.setIsCanceled(true);
        card.setBlockReason(null);
        card.setBlockEndDate(null);
        card.setContactlessEnabled(false);
        card.setEcommerceEnabled(false);
        card.setTpeEnabled(false);
        card.setInternationalWithdraw(false);

        // 4️⃣ Save the update
        cardRepository.save(card);

        // 5️⃣ Retrieve cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String username = (String) user.get("cardholderName");
        String email = (String) user.get("email");
        String cardNumber = card.getCardNumber();

        // 6️⃣ Extract agent info
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long agentId = agent.getId();

        // 7️⃣ Build event payload to notify the cardholder
        String message = "Your card " + cardNumber + " (physical) has been canceled by Agent " + agentUsername + ".";

        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.PHYSICAL_CARD_CANCELED)
                .senderId(agentId)
                .recipientId(cardholderId)
                .cardId(card.getId())
                .email(email)
                .username(username)
                .build();

        // 8️⃣ Send the event to notify the cardholder
        cardSecurityEventProducer.sendPhysicalCardCanceledByAgent(payload);
    }
    public void uncancelPhysicalCardByAgent(String token, Long cardId) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it is a PHYSICAL card
        if (card.getType() != CardType.PHYSICAL) {
            throw new RuntimeException("Card is not a physical card.");
        }

        // 3️⃣ Check if it was canceled
        if (!Boolean.TRUE.equals(card.getIsCanceled())) {
            throw new RuntimeException("Card is not canceled.");
        }

        // 4️⃣ Reactivate the card
        card.setStatus(CardStatus.ACTIVE);
        card.setIsCanceled(false);

        // Re-enable features (or adjust as needed)
        card.setContactlessEnabled(true);
        card.setEcommerceEnabled(true);
        card.setTpeEnabled(true);
        card.setInternationalWithdraw(true);

        // Clear any block reasons or end dates
        card.setBlockReason(null);
        card.setBlockEndDate(null);

        // 5️⃣ Save changes
        cardRepository.save(card);

        // 6️⃣ Get cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String username = (String) user.get("cardholderName");
        String email = (String) user.get("email");
        String cardNumber = card.getCardNumber();

        // 7️⃣ Extract agent info
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long agentId = agent.getId();

        // 8️⃣ Create event payload
        String message = "Your  card " + cardNumber + " (physical) has been reactivated by Agent " + agentUsername + ".";

        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.PHYSICAL_CARD_UNCANCELED)
                .senderId(agentId)
                .recipientId(cardholderId)
                .cardId(card.getId())
                .email(email)
                .username(username)
                .build();

        // 9️⃣ Publish event
        cardSecurityEventProducer.sendPhysicalCardUncanceledByAgent(payload);
    }
    @Transactional
    public String regeneratePhysicalCardPin(String token, Long cardId) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it's a PHYSICAL card
        if (card.getType() != CardType.PHYSICAL) {
            throw new RuntimeException("Card is not a physical card.");
        }

        // 3️⃣ Generate new PIN
        String newPlainPin = generateRandomPIN();

        // 4️⃣ Save new PIN without encryption
        card.setPin(newPlainPin);
        cardRepository.save(card);

        // 5️⃣ Fetch cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) user.get("cardholderName");
        String email = (String) user.get("email");
        String cardNumber = card.getCardNumber();

        // 6️⃣ Extract agent info
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long agentId = agent.getId();

        // 7️⃣ Build notification message
        String message = "A new PIN has been generated for your physical card " + cardNumber + " by Agent " + agentUsername + ".";

        // 8️⃣ Send Kafka event
        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.PIN_GENERATED)
                .senderId(agentId)
                .recipientId(cardholderId)
                .cardId(card.getId())
                .email(email)
                .username(cardholderName)
                .build();

        cardSecurityEventProducer.sendPhysicalCardPinGenerated(payload);

        // ✅ Return plain PIN (for display)
        return newPlainPin;
    }
    @Transactional
    public String regenerateCardCvvByAgent(String token, Long cardId) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Generate new CVV
        String newPlainCvv = generateRandomCVV();
        String encryptedCvv = AESUtil.encrypt(newPlainCvv);

        // 3️⃣ Save the new CVV
        card.setCvv(encryptedCvv);
        card.setCvvRequested(false); // ✅ mark CVV as no longer requested
        cardRepository.save(card);

        // 4️⃣ Fetch cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> userInfo = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");
        String cardNumber = card.getCardNumber();
        String cardType = card.getType().name();

        // 5️⃣ Extract agent info
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long agentId = agent.getId();

        // 6️⃣ Build notification message
        String message = "A new CVV has been generated for your " + cardType.toLowerCase()
                + " card " + cardNumber + " by Agent " + agentUsername + ".";

        // 7️⃣ Build Kafka event
        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.CVV_GENERATED)
                .senderId(agentId)
                .recipientId(cardholderId)
                .cardId(card.getId())
                .email(email)
                .username(cardholderName)
                .build();

        // 8️⃣ Send event
        cardSecurityEventProducer.sendCvvGeneratedByAgent(payload);

        // ✅ Return the plain CVV for display or secure delivery
        return newPlainCvv;
    }



    @Transactional
    public void updatePhysicalCardFeatures(String token, Long cardId, UpdateCardFeaturesRequest request) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it is PHYSICAL
        if (card.getType() != CardType.PHYSICAL) {
            throw new RuntimeException("This operation is only allowed for PHYSICAL cards.");
        }

        // 3️⃣ Update fields (only if not null)
        boolean anyUpdated = false;
        StringBuilder changes = new StringBuilder();

        if (request.getContactlessEnabled() != null) {
            card.setContactlessEnabled(request.getContactlessEnabled());
            changes.append("Contactless = ").append(request.getContactlessEnabled() ? "Enabled" : "Disabled").append(", ");
            anyUpdated = true;
        }
        if (request.getEcommerceEnabled() != null) {
            card.setEcommerceEnabled(request.getEcommerceEnabled());
            changes.append("E-Commerce = ").append(request.getEcommerceEnabled() ? "Enabled" : "Disabled").append(", ");
            anyUpdated = true;
        }
        if (request.getTpeEnabled() != null) {
            card.setTpeEnabled(request.getTpeEnabled());
            changes.append("TPE = ").append(request.getTpeEnabled() ? "Enabled" : "Disabled").append(", ");
            anyUpdated = true;
        }
        if (request.getInternationalWithdraw() != null) {
            card.setInternationalWithdraw(request.getInternationalWithdraw());
            changes.append("International Withdraw = ").append(request.getInternationalWithdraw() ? "Enabled" : "Disabled").append(", ");
            anyUpdated = true;
        }

        if (!anyUpdated) {
            throw new RuntimeException("No features specified to update.");
        }

        // 4️⃣ Save updated card
        cardRepository.save(card);

        // 5️⃣ Fetch cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> userInfo = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");

        // 6️⃣ Extract agent info
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long agentId = agent.getId();

        // 7️⃣ Build notification message
        String message = "The following features have been updated for your PHYSICAL card "
                + card.getCardNumber()
                + " by Agent " + agentUsername + ": "
                + changes.toString().replaceAll(", $", ".");

        // 8️⃣ Build Kafka Event
        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.PHYSICAL_CARD_FEATURES_UPDATED)
                .senderId(agentId)
                .recipientId(cardholderId)
                .cardId(card.getId())
                .email(email)
                .username(cardholderName)
                .build();

        // 9️⃣ Publish the event
        cardSecurityEventProducer.sendPhysicalCardFeaturesUpdated(payload);
    }




    @Transactional
    public void updateCardLimitsByAgent(String token, Long cardId, Double dailyLimit, Double monthlyLimit, Double annualOrEcommerceLimit) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Extract agent info
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long agentId = agent.getId();

        // 3️⃣ Retrieve cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> userInfo = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");

        // 4️⃣ Track changes
        StringBuilder changes = new StringBuilder();
        boolean anyChange = false;

        if (card.getType() == CardType.PHYSICAL) {
            if (dailyLimit != null) {
                card.setDailyLimit(dailyLimit);
                changes.append("Daily limit: ").append(dailyLimit).append(", ");
                anyChange = true;
            }
            if (monthlyLimit != null) {
                card.setMonthlyLimit(monthlyLimit);
                changes.append("Monthly limit: ").append(monthlyLimit).append(", ");
                anyChange = true;
            }
            if (annualOrEcommerceLimit != null) {
                card.setAnnualLimit(annualOrEcommerceLimit);
                changes.append("Annual limit: ").append(annualOrEcommerceLimit).append(", ");
                anyChange = true;
            }
        } else if (card.getType() == CardType.VIRTUAL) {
            if (annualOrEcommerceLimit != null) {
                card.setAnnualLimit(annualOrEcommerceLimit);
                changes.append("E-commerce limit: ").append(annualOrEcommerceLimit).append(", ");
                anyChange = true;
            }
        } else {
            throw new RuntimeException("Unsupported card type.");
        }

        if (!anyChange) {
            throw new RuntimeException("No limits were provided to update.");
        }

        // 5️⃣ Save changes
        cardRepository.save(card);

        // 6️⃣ Prepare professional message
        String message = "Agent " + agentUsername + " has updated the limits of the "
                + card.getType().name().toLowerCase() + " card (" + card.getCardNumber() + ") belonging to "
                + cardholderName + ". Updated values: " + changes.substring(0, changes.length() - 2) + ".";

        // 7️⃣ Build event payload
        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.LIMITS_UPDATED_AGENT)
                .senderId(agentId)
                .recipientId(cardholderId)
                .cardId(cardId)
                .email(email)
                .username(cardholderName)
                .build();

        // 8️⃣ Send event
        cardSecurityEventProducer.sendLimitsUpdatedAgent(payload);
    }
    public void cancelVirtualCardByAgent(String token, Long cardId) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it is a VIRTUAL card
        if (card.getType() != CardType.VIRTUAL) {
            throw new RuntimeException("Card is not a virtual card.");
        }

        // 3️⃣ Update status and flags
        card.setStatus(CardStatus.SUSPENDED);
        card.setIsCanceled(true);
        card.setBlockReason(null);
        card.setReplacementRequested(false);
        card.setEcommerceEnabled(false);

        // 4️⃣ Save the update
        cardRepository.save(card);

        // 5️⃣ Retrieve cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String username = (String) user.get("cardholderName");
        String email = (String) user.get("email");
        String cardNumber = card.getCardNumber();

        // 6️⃣ Extract agent info
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long agentId = agent.getId();

        // 7️⃣ Build event payload
        String message = "Your virtual card " + cardNumber + " has been canceled by Agent " + agentUsername + ".";

        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.VIRTUAL_CARD_CANCELED)
                .senderId(agentId)
                .recipientId(cardholderId)
                .cardId(card.getId())
                .email(email)
                .username(username)
                .build();

        // 8️⃣ Publish event
        cardSecurityEventProducer.sendVirtualCardCanceledByAgent(payload);
    }
    public void uncancelVirtualCardByAgent(String token, Long cardId) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it is a VIRTUAL card
        if (card.getType() != CardType.VIRTUAL) {
            throw new RuntimeException("Card is not a virtual card.");
        }

        // 3️⃣ Validate it is canceled
        if (!Boolean.TRUE.equals(card.getIsCanceled())) {
            throw new RuntimeException("Card is not canceled.");
        }

        // 4️⃣ Reactivate the card
        card.setStatus(CardStatus.ACTIVE);
        card.setIsCanceled(false);

        // Enable relevant features (only ecommerce for virtual)
        card.setEcommerceEnabled(true);

        // Clear block metadata
        card.setBlockReason(null);
        card.setBlockEndDate(null);

        // 5️⃣ Save changes
        cardRepository.save(card);

        // 6️⃣ Retrieve cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> user = cardholderService.getCardholderById(cardholderId);
        String username = (String) user.get("cardholderName");
        String email = (String) user.get("email");
        String cardNumber = card.getCardNumber();

        // 7️⃣ Extract agent info
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long agentId = agent.getId();

        // 8️⃣ Build event payload
        String message = "Your virtual card " + cardNumber + " has been reactivated by Agent " + agentUsername + ".";

        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.VIRTUAL_CARD_UNCANCELED)
                .senderId(agentId)
                .recipientId(cardholderId)
                .cardId(card.getId())
                .email(email)
                .username(username)
                .build();

        // 9️⃣ Publish event
        cardSecurityEventProducer.sendVirtualCardUncanceledByAgent(payload);
    }
    @Transactional
    public void updateVirtualCardEcommerceFeatureByAgent(String token, Long cardId, Boolean ecommerceEnabled) {
        // 1️⃣ Retrieve the card
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        // 2️⃣ Ensure it is VIRTUAL
        if (card.getType() != CardType.VIRTUAL) {
            throw new RuntimeException("This operation is only allowed for VIRTUAL cards.");
        }

        // 3️⃣ Validate input
        if (ecommerceEnabled == null) {
            throw new RuntimeException("You must provide the new E-Commerce value.");
        }

        // 4️⃣ Update field
        card.setEcommerceEnabled(ecommerceEnabled);
        cardRepository.save(card);

        // 5️⃣ Fetch cardholder info
        Long cardholderId = card.getCardholderId();
        Map<String, Object> userInfo = cardholderService.getCardholderById(cardholderId);
        String cardholderName = (String) userInfo.get("cardholderName");
        String email = (String) userInfo.get("email");

        // 6️⃣ Extract agent info
        String agentUsername = jwtUtil.extractUsername(token.replace("Bearer ", ""));
        AgentResponseDTO agent = agentService.getAgentDetailsByUsername(agentUsername);
        Long agentId = agent.getId();

        // 7️⃣ Build notification message
        String message = "E-Commerce feature has been "
                + (ecommerceEnabled ? "enabled" : "disabled")
                + " for your VIRTUAL card "
                + card.getCardNumber()
                + " by Agent " + agentUsername + ".";

        // 8️⃣ Build Kafka Event
        EventPayload payload = EventPayload.builder()
                .message(message)
                .sentAt(new Date())
                .senderType(SenderType.AGENT)
                .category(EventCategory.VIRTUAL_CARD_FEATURES_UPDATED)
                .senderId(agentId)
                .recipientId(cardholderId)
                .cardId(card.getId())
                .email(email)
                .username(cardholderName)
                .build();

        // 9️⃣ Publish the event
        cardSecurityEventProducer.sendVirtualCardFeaturesUpdated(payload);
    }

}
