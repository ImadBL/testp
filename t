import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import org.springframework.batch.core.BatchStatus;
import org.springframework.batch.core.ExitStatus;
import org.springframework.batch.core.StepExecution;
import org.springframework.batch.core.StepExecutionListener;

public class BccCleanupStepListener implements StepExecutionListener {

    @Override
    public ExitStatus afterStep(StepExecution stepExecution) {
        if (stepExecution.getStatus() != BatchStatus.FAILED) {
            return stepExecution.getExitStatus();
        }

        String file = stepExecution.getExecutionContext().getString("bcc_output_file", null);
        if (file == null) {
            return stepExecution.getExitStatus();
        }

        Path path = Path.of(file);

        // Retry (Windows lock)
        boolean deleted = false;
        for (int i = 0; i < 10; i++) {
            try {
                deleted = Files.deleteIfExists(path);
                if (deleted) break;
                // s'il n'existe déjà plus, on sort aussi
                if (!Files.exists(path)) break;
            } catch (IOException e) {
                try {
                    Thread.sleep(200);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
        }

        // Fallback si encore locké : suppression à la fin de la JVM
        if (Files.exists(path)) {
            path.toFile().deleteOnExit();
        }

        return stepExecution.getExitStatus();
    }
}
