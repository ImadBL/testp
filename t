

import com.tibco.tibjms.TibjmsConnectionFactory;
import com.tibco.tibjms.TibjmsQueue;
import jakarta.jms.ConnectionFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.env.Environment;
import org.springframework.jms.annotation.EnableJms;
import org.springframework.jms.core.JmsTemplate;

import java.net.InetAddress;
import java.net.UnknownHostException;

@Configuration
@EnableJms
@RequiredArgsConstructor
public class JmsConfig {

    private final Environment env;

    @Bean
    public JmsTemplate jmsTemplate(ConnectionFactory factory) {

        JmsTemplate jmsTemplate = new JmsTemplate(factory);

        jmsTemplate.setDefaultDestination(
                new TibjmsQueue(
                        env.getProperty("queue.name")
                )
        );

        return jmsTemplate;
    }

    @Bean
    @Primary
    public ConnectionFactory connectionFactory() throws Exception {

        TibjmsConnectionFactory factory =
                new TibjmsConnectionFactory(
                        env.getProperty("jms.url")
                );

        factory.setClientID(
                "RETENTION_BATCH_" + getHostname()
        );

        factory.setUserName(
                env.getProperty("jms.username")
        );

        factory.setUserPassword(
                env.getProperty("jms.password")
        );

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
