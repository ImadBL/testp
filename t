public interface TeamMemberRepository extends JpaRepository<TeamMember, Long> {

  @Modifying(clearAutomatically = true, flushAutomatically = true)
  @Query("update TeamMember tm set tm.user = :newUser where tm.user.id = :oldUserId")
  int reassignUser(@Param("oldUserId") Long oldUserId, @Param("newUser") User newUser);
}

public interface UserOrganismLinkRepository {

  void moveLinks(Long oldUserId, Long newUserId);
  void deleteLinks(Long oldUserId);
}

@Repository
@RequiredArgsConstructor
public class UserOrganismLinkRepositoryImpl implements UserOrganismLinkRepository {

  private final EntityManager em;

  @Override
  @Transactional
  public void moveLinks(Long oldUserId, Long newUserId) {
    // Ajoute chez user(1) tous les organismes de userX, sans doublons
    em.createNativeQuery("""
      insert into REF_USER_ORGANISM (USER_ID, ORGANISM_ID)
      select :newId, uo.ORGANISM_ID
      from REF_USER_ORGANISM uo
      where uo.USER_ID = :oldId
        and not exists (
          select 1 from REF_USER_ORGANISM uo2
          where uo2.USER_ID = :newId and uo2.ORGANISM_ID = uo.ORGANISM_ID
        )
      """)
      .setParameter("oldId", oldUserId)
      .setParameter("newId", newUserId)
      .executeUpdate();
  }

  @Override
  @Transactional
  public void deleteLinks(Long oldUserId) {
    em.createNativeQuery("delete from REF_USER_ORGANISM where USER_ID = :oldId")
      .setParameter("oldId", oldUserId)
      .executeUpdate();
  }
}

@Service
@RequiredArgsConstructor
public class UserCleanupService {

  private final UserRepository userRepository;
  private final TeamMemberRepository teamMemberRepository;
  private final UserOrganismLinkRepository userOrganismLinkRepository;

  @Transactional
  public void replaceUserByUser1ThenDelete(Long userXId) {

    if (userXId == null) throw new IllegalArgumentException("userXId is null");
    if (userXId == 1L) throw new IllegalArgumentException("Impossible de supprimer l'utilisateur 1");

    User user1 = userRepository.findById(1L)
      .orElseThrow(() -> new IllegalStateException("User id=1 introuvable"));

    User userX = userRepository.findById(userXId)
      .orElseThrow(() -> new IllegalArgumentException("User id=" + userXId + " introuvable"));

    // 1) Migrer la table de jointure REF_USER_ORGANISM
    userOrganismLinkRepository.moveLinks(userXId, 1L);

    // 2) Réaffecter les FK (ex: TeamMember.user)
    teamMemberRepository.reassignUser(userXId, user1);

    // 3) Supprimer les liens restants de userX (join table)
    userOrganismLinkRepository.deleteLinks(userXId);

    // 4) Supprimer userX
    userRepository.delete(userX);
  }
}



