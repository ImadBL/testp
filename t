<dependency>
  <groupId>org.springframework.ldap</groupId>
  <artifactId>spring-ldap-core</artifactId>
  <version>3.2.7</version>
  <scope>test</scope>
</dependency>
<dependency>
  <groupId>org.mockito</groupId>
  <artifactId>mockito-junit-jupiter</artifactId>
  <version>5.12.0</version>
  <scope>test</scope>
</dependency>
<dependency>
  <groupId>org.junit.jupiter</groupId>
  <artifactId>junit-jupiter</artifactId>
  <version>5.10.2</version>
  <scope>test</scope>
</dependency>

@Slf4j
@Service
@RequiredArgsConstructor
public class AmxLdapServiceImpl implements AmxLdapService {

  private final LdapContextSource contextSource;
  private final LdapTemplate ldapTemplate;

  @Override
  public boolean userExists(String uid) {
    try {
      var res = ldapTemplate.search(
          query().where("uid").is(uid),
          (AttributesMapper<String>) attrs -> (String) attrs.get("uid").get()
      );
      return !res.isEmpty();
    } catch (Exception e) {
      log.warn("Error on verification LDAP for {}: {}", uid, e.getMessage());
      return false;
    }
  }

  @Override
  public void addUser(String uid) throws ServiceException {
    if (userExists(uid)) {
      throw new ServiceException("User already exists: " + uid);
    }
    Name dn = LdapNameBuilder.newInstance().add("uid", uid).build();
    var ctx = new DirContextAdapter(dn);
    ctx.setAttributeValues("objectClass",
        new String[]{"top", "person", "organizationalPerson", "inetOrgPerson"});
    ctx.setAttributeValue("uid", uid);
    ctx.setAttributeValue("sn", "DOE");
    ctx.setAttributeValue("cn", "John Doe");
    ctx.setAttributeValue("mail", "john.doe@example.com");
    ctx.setAttributeValue("userPassword", uid);

    try {
      ldapTemplate.bind(ctx);
    } catch (Exception e) {
      throw new ServiceException("Error of creation on LDAP for " + uid + ": " + e.getMessage(), e);
    }
  }
}
Tests unitaires
java
Copier le code
@ExtendWith(MockitoExtension.class)
class AmxLdapServiceImplTest {

  @Mock LdapContextSource contextSource; // pas utilisé directement mais présent au ctor
  @Mock LdapTemplate ldapTemplate;

  AmxLdapServiceImpl service;

  @BeforeEach
  void setUp() {
    service = new AmxLdapServiceImpl(contextSource, ldapTemplate);
  }

  // ---------- userExists ----------

  @Test
  void userExists_returnsTrue_whenSearchReturnsResult() {
    when(ldapTemplate.search(any(), any(AttributesMapper.class)))
        .thenReturn(List.of("titi"));

    boolean exists = service.userExists("titi");

    assertTrue(exists);
    verify(ldapTemplate).search(any(), any(AttributesMapper.class));
  }

  @Test
  void userExists_returnsFalse_whenSearchReturnsEmpty() {
    when(ldapTemplate.search(any(), any(AttributesMapper.class)))
        .thenReturn(Collections.emptyList());

    boolean exists = service.userExists("toto");

    assertFalse(exists);
  }

  @Test
  void userExists_returnsFalse_whenLdapThrows() {
    when(ldapTemplate.search(any(), any(AttributesMapper.class)))
        .thenThrow(new RuntimeException("boom"));

    boolean exists = service.userExists("err");

    assertFalse(exists);
  }

  // ---------- addUser ----------

  @Test
  void addUser_bindsEntry_whenUserAbsent() throws Exception {
    // userExists -> false
    when(ldapTemplate.search(any(), any(AttributesMapper.class)))
        .thenReturn(Collections.emptyList());

    // capture du DirContext envoyé à bind
    ArgumentCaptor<DirContextAdapter> captor = ArgumentCaptor.forClass(DirContextAdapter.class);

    service.addUser("titi");

    verify(ldapTemplate).bind(captor.capture());
    DirContextAdapter sent = captor.getValue();

    // DN attendu (base gérée par contextSource -> ici DN relatif)
    assertEquals("uid=titi", sent.getDn().toString().toLowerCase());
    assertEquals("titi", sent.getStringAttribute("uid"));
    assertEquals("DOE", sent.getStringAttribute("sn"));
    assertEquals("John Doe", sent.getStringAttribute("cn"));
    assertEquals("john.doe@example.com", sent.getStringAttribute("mail"));
  }

  @Test
  void addUser_throws_whenUserAlreadyExists() {
    when(ldapTemplate.search(any(), any(AttributesMapper.class)))
        .thenReturn(List.of("titi")); // exists = true

    ServiceException ex = assertThrows(ServiceException.class,
        () -> service.addUser("titi"));

    assertTrue(ex.getMessage().contains("already exists"));
    verify(ldapTemplate, never()).bind(any()); // pas de bind
  }

  @Test
  void addUser_wrapsException_whenBindFails() {
    when(ldapTemplate.search(any(), any(AttributesMapper.class)))
        .thenReturn(Collections.emptyList()); // exists=false

    doThrow(new RuntimeException("bind failed")).when(ldapTemplate).bind(any());

    ServiceException ex = assertThrows(ServiceException.class,
        () -> service.addUser("titi"));

    assertTrue(ex.getMessage().contains("Error of creation"));
    verify(ldapTemplate).bind(any());
  }
}
