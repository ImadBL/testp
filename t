---
@Entity
@Table(name = "BCP_PURGE_REPORT")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PurgeReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Column(name = "PURGE_START_TIME", nullable = false)
    private Instant purgeStartTime;

    @Column(name = "PURGE_END_TIME")
    private Instant purgeEndTime;

    @Column(name = "PAYOUT_PURGED")
    private Long payoutPurged;

    @Column(name = "CUSTOMER_SERVICE_PURGED")
    private Long customerServicePurged;

    @Column(name = "TO_BE_COMPLETED_PURGED")
    private Long toBeCompletedPurged;

    @Column(name = "PAYOUT_PURGE_ERROR")
    private Long payoutPurgeError;

    @Column(name = "CUSTOMER_SERVICE_PURGE_ERROR")
    private Long customerServicePurgeError;

    @Column(name = "TO_BE_COMPLETED_PURGE_ERROR")
    private Long toBeCompletedPurgeError;
}
