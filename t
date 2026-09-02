package com.bnpp.leasing.batchcasepurge.service;

import com.bnpp.leasing.batchcasepurge.domain.Country;
import com.bnpp.leasing.batchcasepurge.repository.CountryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CountryService {

    private final CountryRepository repository;

    @Transactional(readOnly = true)
    public Country findByCode(String code) {

        if (code == null || code.isBlank()) {
            return null;
        }

        return repository
                .findByCodeIgnoreCase(code.trim())
                .orElseThrow(() ->
                        new IllegalStateException(
                                "Country not configured: " + code
                        )
                );
    }
}

package com.bnpp.leasing.batchcasepurge.repository;

import com.bnpp.leasing.batchcasepurge.domain.Country;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CountryRepository
        extends JpaRepository<Country, Long> {

    Optional<Country> findByCodeIgnoreCase(String code);

    boolean existsByCodeIgnoreCase(String code);
}


