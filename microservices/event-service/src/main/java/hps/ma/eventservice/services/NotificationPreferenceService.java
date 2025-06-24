package hps.ma.eventservice.services;

import hps.ma.eventservice.dao.entity.NotificationPreference;
import hps.ma.eventservice.dao.repository.NotificationPreferenceRepository;
import hps.ma.eventservice.dto.NotificationPreferencesDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NotificationPreferenceService {

    private final NotificationPreferenceRepository repository;

    public NotificationPreferencesDTO getPreferences(Long cardholderId) {
        return repository.findById(cardholderId)
                .map(pref -> NotificationPreferencesDTO.builder()
                        .cardStatusChanges(pref.isCardStatusChanges())
                        .cardCancelReactivate(pref.isCardCancelReactivate())
                        .newCardRequest(pref.isNewCardRequest())
                        .cardReplacementRequest(pref.isCardReplacementRequest())
                        .travelPlanStatus(pref.isTravelPlanStatus())
                        .transactionAlert(pref.isTransactionAlert())
                        .build())
                .orElseGet(() -> NotificationPreferencesDTO.builder()
                        .cardStatusChanges(true)
                        .cardCancelReactivate(true)
                        .newCardRequest(true)
                        .cardReplacementRequest(true)
                        .travelPlanStatus(true)
                        .transactionAlert(true)
                        .build());
    }

    public void saveOrUpdatePreferences(Long cardholderId, NotificationPreferencesDTO dto) {
        NotificationPreference pref = repository.findById(cardholderId)
                .orElse(new NotificationPreference());
        pref.setCardholderId(cardholderId);
        pref.setCardStatusChanges(dto.isCardStatusChanges());
        pref.setCardCancelReactivate(dto.isCardCancelReactivate());
        pref.setNewCardRequest(dto.isNewCardRequest());
        pref.setCardReplacementRequest(dto.isCardReplacementRequest());
        pref.setTravelPlanStatus(dto.isTravelPlanStatus());
        pref.setTransactionAlert(dto.isTransactionAlert());

        repository.save(pref);
    }

    public void createDefaultPreferences(Long cardholderId) {
        // Check if preferences already exist to avoid duplicates
        if (repository.existsById(cardholderId)) {
            return;
        }

        NotificationPreference pref = NotificationPreference.builder()
                .cardholderId(cardholderId)
                .cardStatusChanges(true)
                .cardCancelReactivate(true)
                .newCardRequest(true)
                .cardReplacementRequest(true)
                .travelPlanStatus(true)
                .transactionAlert(true)
                .build();

        repository.save(pref);
    }

}
