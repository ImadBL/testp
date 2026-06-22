CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;

J'ai un point d'interrogation concernant le comportement lors du `completeWorkItem` pour passer une case en `waiting`, avec un payload vide contenant uniquement la raison d'attente.

Ce qui est étrange, c'est qu'AMX semble effectuer des traitements inattendus : les données `portalId` et `comment.external` sont écrasées.

J'ai corrigé le problème en ajoutant deux opérations supplémentaires : `closeItem` puis `openAndLocateWorkItem`.

Le problème est résolu avec ce contournement, mais j'aimerais comprendre la cause racine. Si vous avez une explication, je suis preneur.

Pour information, le problème est reproductible sur une nouvelle case.
