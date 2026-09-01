
import jakarta.jms.JMSException;
import jakarta.jms.Message;
import jakarta.jms.TextMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class ArchiveRequestListener {

    @JmsListener(
            destination = "${queue.name}"
    )
    public void onMessage(Message message)
            throws JMSException {

        String messageId =
                message.getJMSMessageID();

        if (message instanceof TextMessage textMessage) {

            String payload = textMessage.getText();

            log.info(
                    "Archive JMS event received: messageId={}, payload={}",
                    messageId,
                    payload
            );

            // TODO :
            // XML -> EventPublication
            // récupérer Case ID / Case Type
            // enregistrer BCP_ARCHIVE_REQUEST
        } else {

            log.warn(
                    "Unsupported JMS message type: {}",
                    message.getClass().getName()
            );
        }
    }
}
