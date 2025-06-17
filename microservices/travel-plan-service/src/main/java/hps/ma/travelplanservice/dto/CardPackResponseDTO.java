package hps.ma.dto;

import lombok.Builder;

@Builder
public record CardPackResponseDTO(
        String label,
        String audience,
        double fee,
        int validityYears,
        double limitAnnual,
        double limitDaily,
        double limitMonthly,
        boolean internationalWithdraw,
        int maxCountries,
        int maxDays,
        String type,
        double internationalWithdrawLimitPerTravel
) {}
