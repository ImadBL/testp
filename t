package com.bnpp.leasing.batchcasepurge.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;

@Entity
@Table(
        name = "BCP_ARCHIVE_CASE",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "UK_BCP_ARCHIVE_CASE_REF",
                        columnNames = {"CASE_REFERENCE", "CASE_TYPE"}
                )
        }
)
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ArchiveCase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Column(name = "CASE_REFERENCE", nullable = false)
    private String caseReference;

    @Column(name = "CASE_TYPE")
    private String caseType;

    @Column(name = "SOURCE", nullable = false)
    private String source;

    @Column(name = "JMS_MESSAGE_ID")
    private String jmsMessageId;

    @Column(name = "ARCHIVE_CORRELATION_ID")
    private String archiveCorrelationId;

    @Enumerated(EnumType.STRING)
    @Column(name = "ARCHIVE_STATUS", nullable = false)
    private ArchiveStatus archiveStatus;

    @Builder.Default
    @Column(name = "ARCHIVE_ATTEMPT_COUNT", nullable = false)
    private int archiveAttemptCount = 0;

    @Column(name = "ARCHIVE_DATE")
    private Instant archiveDate;

    @Column(name = "CLAIMED_BY")
    private String claimedBy;

    @Column(name = "CLAIMED_AT")
    private Instant claimedAt;

    @Column(name = "LAST_ERROR")
    private String lastError;

    @Version
    @Column(name = "VERSION", nullable = false)
    private Long version;

    @Column(name = "CREATED_AT", nullable = false)
    private Instant createdAt;

    @Column(name = "UPDATED_AT", nullable = false)
    private Instant updatedAt;
}

public enum ArchiveSource {
    JMS,
    PURGE
}

@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "ARCHIVE_CASE_ID")
private ArchiveCase archiveCase;

@Column(name = "CASE_STATUS")
private String caseStatus;

@Column(name = "CONTRACT_ID")
private String contractId;

@Column(name = "PROPOSAL_ID")
private String proposalId;

@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "COUNTRY_ID")
private Country country;

package com.bnpp.leasing.batchcasepurge.domain;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "BCP_COUNTRY",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "UK_BCP_COUNTRY_CODE",
                        columnNames = "CODE"
                )
        }
)
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Country {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Column(
            name = "CODE",
            nullable = false,
            length = 10
    )
    private String code;

    @Column(
            name = "NAME",
            length = 100
    )
    private String name;
}


package com.bnpp.leasing.batchcasepurge.repository;

import com.bnpp.leasing.batchcasepurge.domain.Country;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CountryRepository
        extends JpaRepository<Country, Long> {

    Optional<Country> findByCodeIgnoreCase(
            String code
    );

    boolean existsByCodeIgnoreCase(
            String code
    );
}


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
                                "Pays non configuré : " + code
                        )
                );
    }
}



