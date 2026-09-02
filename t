--
package com.bnpp.leasing.batchcasepurge.service;

import com.bnpp.leasing.batchcasepurge.client.AmxClient;
import com.bnpp.leasing.batchcasepurge.domain.CaseType;
import com.bnpp.leasing.batchcasepurge.domain.Country;
import com.bnpp.leasing.batchcasepurge.domain.PurgeStatus;
import com.bnpp.leasing.batchcasepurge.domain.RetentionCase;
import com.bnpp.leasing.batchcasepurge.repository.RetentionCaseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Service
@RequiredArgsConstructor
public class TbcDiscoveryService {

    private final AmxClient amx;
    private final RetentionCaseRepository repository;
    private final CountryService countryService;

    @Transactional
    public int discover(int limit) {

        int count = 0;

        for (var info : amx.findEligibleTbcCases(limit)) {

            if (repository.existsByCaseTypeAndCaseReference(
                    CaseType.TBC,
                    info.caseReference()
            )) {
                continue;
            }

            Country country =
                    countryService.findByCode(
                            info.country()
                    );

            Instant now = Instant.now();

            RetentionCase retentionCase =
                    RetentionCase.builder()
                            .caseType(CaseType.TBC)
                            .caseReference(info.caseReference())
                            .country(country)
                            .processType(info.processType())
                            .eligible(true)

                            // TBC ne nécessite pas d'archivage
                            .archiveCase(null)

                            // directement disponible pour purge
                            .purgeStatus(PurgeStatus.READY)
                            .purgeAttemptCount(0)

                            .createdAt(now)
                            .updatedAt(now)
                            .build();

            repository.save(retentionCase);

            count++;
        }

        return count;
    }
}
