
import com.tibco.tibjms.TibjmsConnectionFactory;
import jakarta.jms.ConnectionFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.env.Environment;
import org.springframework.jms.annotation.EnableJms;
import org.springframework.jms.config.DefaultJmsListenerContainerFactory;

import java.net.InetAddress;
import java.net.UnknownHostException;

@Configuration
@EnableJms
@RequiredArgsConstructor
@ConditionalOnProperty(
        name = "jms.enabled",
        havingValue = "true"
)
public class JmsConfig {

    private final Environment env;

    @Bean
    @Primary
    public ConnectionFactory connectionFactory() throws Exception {

        TibjmsConnectionFactory factory =
                new TibjmsConnectionFactory(
                        env.getProperty("jms.url")
                );

        factory.setClientID(
                "BATCH_CASE_PURGE_" + getHostname()
        );

        factory.setUserName(
                env.getProperty("jms.username")
        );

        factory.setUserPassword(
                env.getProperty("jms.password")
        );

        return factory;
    }

    @Bean
    public DefaultJmsListenerContainerFactory jmsListenerContainerFactory(
            ConnectionFactory connectionFactory
    ) {

        DefaultJmsListenerContainerFactory factory =
                new DefaultJmsListenerContainerFactory();

        factory.setConnectionFactory(connectionFactory);

        factory.setConcurrency("1");

        return factory;
    }

    private String getHostname() {
        try {
            return InetAddress
                    .getLocalHost()
                    .getHostName();
        } catch (UnknownHostException e) {
            return "";
        }
    }
}
