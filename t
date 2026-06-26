CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;

D'après ce que m'a expliqué Sarra, début juin il y avait un bug (erreur 500 sur les appels GED) lié à la montée de version vers Spring Boot 4. Finalement, la montée de version a été retirée via le ticket **X** afin de débloquer la livraison.

Par ailleurs, nous avons également identifié un oubli de notre part concernant la partie ECC. Cette correction sera intégrée dans le même correctif.

Peux-tu créer un defect et me l'affecter, s'il te plaît ? Le defect, la montée de version vers Spring Boot 4 ainsi que le correctif ECC seront embarqués dans une prochaine release.

De mon côté, je vais faire le nécessaire pour que l'ensemble des correctifs soit prêt. Ensuite, on regardera ensemble à quel moment il sera possible de livrer ce ticket.
