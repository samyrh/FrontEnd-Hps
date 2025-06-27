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
    public void updatePin(String token, Long cardId, String newPin) {
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

        card.setPin(hash(newPin));
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
                    .email(email) // 🔐 encrypt email before sending
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

}
