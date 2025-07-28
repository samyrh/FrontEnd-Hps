package hps.ma.transactionsservice.service;


import hps.ma.transactionsservice.dao.entities.Transaction;
import hps.ma.transactionsservice.dao.enums.EventCategory;
import hps.ma.transactionsservice.dao.enums.SenderType;
import hps.ma.transactionsservice.dao.repository.TransactionRepository;
import hps.ma.transactionsservice.dto.*;
import hps.ma.transactionsservice.feign_client.CardServiceClient;
import hps.ma.transactionsservice.kafka_producing.TransactionEventProducer;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TransactionService {

    private final CardServiceClient cardServiceClient;
    private final TransactionRepository transactionRepository;
    private final TransactionClassifierClient classifierClient;
    private final TransactionEventProducer transactionEventProducer;
    /**
     * Fetch all transactions for the current cardholder,
     * and classify missing categories if needed.
     */
    public TransactionGroupedResponse getTransactionsForCardholder(String token) {
        CardIdsResponse response = cardServiceClient.getMyCardIds(token);
        List<Long> cardIds = response.cardIds();

        if (cardIds == null || cardIds.isEmpty()) {
            throw new RuntimeException("No cards found for this user.");
        }

        List<Transaction> transactions = transactionRepository.findByCardIdIn(cardIds);

        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
        for (Transaction tx : transactions) {
            if (tx.getCategory() == null || tx.getCategory().isEmpty()) {
                String dateStr = formatter.format(tx.getDate());
                String predicted = classifierClient.classifyTransaction(
                        tx.getDescription(),
                        tx.getAmount(),
                        dateStr
                );
                if (predicted != null) {
                    tx.setCategory(predicted);
                    transactionRepository.save(tx);
                }
            }
        }

        // Map and group by card ID
        Map<Long, List<TransactionResponseDTO>> grouped = transactions.stream()
                .map(tx -> TransactionResponseDTO.builder()
                        .id(tx.getId())
                        .date(tx.getDate())
                        .merchant(tx.getMerchant())
                        .amount(tx.getAmount())
                        .category(tx.getCategory())
                        .description(tx.getDescription())
                        .status(tx.getStatus())
                        .cardId(tx.getCardId())
                        .build()
                )
                .collect(Collectors.groupingBy(TransactionResponseDTO::getCardId));

        return new TransactionGroupedResponse(grouped);
    }
    public TransactionResponseDTO createTransaction(TransactionCreateRequest request) {
        // ✅ Predict category
        String dateStr = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
        String predictedCategory = classifierClient.classifyTransaction(
                request.getDescription(),
                request.getAmount(),
                dateStr
        );

        // ✅ Create Transaction entity
        Transaction tx = Transaction.builder()
                .cardId(request.getCardId())
                .merchant(request.getMerchant())
                .amount(request.getAmount())
                .description(request.getDescription())
                .date(new Date())
                .status(hps.ma.transactionsservice.dao.enums.TransactionStatus.PENDING)
                .category(predictedCategory != null ? predictedCategory : "Uncategorized")
                .build();

        Transaction saved = transactionRepository.save(tx);

        // ✅ Fetch cardholder info by cardId
        Map<String, Object> cardholderInfo = cardServiceClient.getCardholderDetailsByCardId(request.getCardId());
        System.out.println("📢 cardholderInfo map = " + cardholderInfo);

        String cardholderName = (String) cardholderInfo.get("username");
        String email = (String) cardholderInfo.get("email");
        String cardNumber = (String) cardholderInfo.get("cardNumber");
        Long cardholderId = cardholderInfo.get("cardholderId") instanceof Integer
                ? ((Integer) cardholderInfo.get("cardholderId")).longValue()
                : (Long) cardholderInfo.get("cardholderId");

        // ✅ Build event message
        String eventMessage = String.format(
                "HPS eBanking - A new transaction of %.2f MAD at %s was initiated on card %s (Status: %s, Date: %s, Description: %s). If you did not authorize this, please contact support immediately.",
                saved.getAmount(),
                saved.getMerchant(),
                cardNumber,
                saved.getStatus(),
                new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(saved.getDate()),
                saved.getDescription()
        );


        // ✅ Build EventPayload
        EventPayload payload = EventPayload.builder()
                .message(eventMessage)
                .sentAt(new Date())
                .senderType(SenderType.SYSTEM)
                .senderId(1L) // ✅ SYSTEM events do NOT have senderId
                .category(EventCategory.NEW_TRANSACTION)
                .recipientId(cardholderId)
                .cardId(saved.getCardId())
                .username(cardholderName)
                .email(email)
                .build();

        // ✅ Send event
        transactionEventProducer.sendTransactionCreated(payload);

        // ✅ Return DTO
        return TransactionResponseDTO.builder()
                .id(saved.getId())
                .date(saved.getDate())
                .merchant(saved.getMerchant())
                .amount(saved.getAmount())
                .category(saved.getCategory())
                .description(saved.getDescription())
                .status(saved.getStatus())
                .cardId(saved.getCardId())
                .build();
    }
    public List<TransactionWithCardholderDTO> getAllTransactionsWithCardholderDetails() {
        List<Transaction> transactions = transactionRepository.findAll();

        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");

        return transactions.stream().map(tx -> {
            // ✅ Classify if category is missing
            if (tx.getCategory() == null || tx.getCategory().isEmpty()) {
                String dateStr = formatter.format(tx.getDate());
                String predictedCategory = classifierClient.classifyTransaction(
                        tx.getDescription(),
                        tx.getAmount(),
                        dateStr
                );
                if (predictedCategory != null) {
                    tx.setCategory(predictedCategory);
                    transactionRepository.save(tx);
                }
            }

            // ✅ Fetch cardholder info
            Map<String, Object> cardholderDetails = cardServiceClient.getCardholderDetailsByCardId(tx.getCardId());
            String cardNumber = (String) cardholderDetails.get("cardNumber");
            String username = (String) cardholderDetails.get("username");
            String email = (String) cardholderDetails.get("email");

            return TransactionWithCardholderDTO.builder()
                    .id(tx.getId())
                    .date(tx.getDate())
                    .merchant(tx.getMerchant())
                    .amount(tx.getAmount())
                    .category(tx.getCategory())
                    .description(tx.getDescription())
                    .status(tx.getStatus())
                    .cardId(tx.getCardId())
                    .cardNumber(cardNumber)
                    .cardholderUsername(username)
                    .build();
        }).toList();
    }

}
