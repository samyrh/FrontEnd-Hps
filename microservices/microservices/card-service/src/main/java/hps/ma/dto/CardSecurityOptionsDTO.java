package hps.ma.dto;

import lombok.Builder;

@Builder
public record CardSecurityOptionsDTO(
        String label,
        boolean contactlessEnabled,
        boolean ecommerceEnabled,
        boolean tpeEnabled,
        String username,
        String cardholderName
) {}
