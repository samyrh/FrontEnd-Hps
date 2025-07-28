package hps.ma.userservice.services;

import hps.ma.userservice.dao.entities.AgentAuth;
import hps.ma.userservice.dao.entities.CardholderAuth;
import hps.ma.userservice.dao.repositories.AgentRepository;
import hps.ma.userservice.dao.repositories.CardholderReository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthUserDetailsService implements UserDetailsService {

    private final AgentRepository agentRepository;
    private final CardholderReository cardholderRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return agentRepository.findByUsername(username)
                .<UserDetails>map(AgentAuth::new)
                .or(() -> cardholderRepository.findByUsername(username).map(CardholderAuth::new))
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
    }
}

