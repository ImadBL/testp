
import jakarta.jms.JMSException;
import jakarta.jms.Message;
import jakarta.jms.TextMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@ConditionalOnProperty(
        name = "jms.enabled",
        havingValue = "true"
)
public class ArchiveRequestListener {

    @JmsListener(
            destination = "${queue.name}",
            containerFactory = "jmsListenerContainerFactory"
    )
    public void onMessage(Message message) throws JMSException {

        String messageId = message.getJMSMessageID();

        log.info(
                "JMS message received - messageId={}",
                messageId
        );

        if (message instanceof TextMessage textMessage) {

            String payload = textMessage.getText();

            log.info(
                    "JMS payload received - messageId={}, payload={}",
                    messageId,
                    payload
            );

        } else {

            log.warn(
                    "Unsupported JMS message type: {}",
                    message.getClass().getName()
            );
        }
    }
}
