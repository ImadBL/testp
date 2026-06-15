CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;

Vendredi après-midi, je n’ai pas pu aller plus loin, car je manquais de temps et les problèmes HVD étaient assez pénalisants.

Je laisse mon analyse à Sarra afin qu’elle puisse suivre le sujet en attendant mon retour mercredi.

D’après mes analyses, côté backend, les requêtes sont envoyées de la même manière dans les scénarios OK et KO. En revanche, côté front, j’ai identifié plusieurs comportements suspects qui nécessitent une nouvelle analyse et des correctifs :

* Le service `generateMsgId` ne devrait pas être appelé tant que le message n’a pas été envoyé.
* Plusieurs messages inhabituels apparaissent dans la console.
* Tester également la version sans les évolutions `generateMsgId` et `generatePortalClientId`.
* Vérifier si les données qui ne passent pas lors des mises à jour des dossiers (« update cases ») sont écrasées ou non.
