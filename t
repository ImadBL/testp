CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;

Bonjour,

Les tickets **1262** et **1264** ont été corrigés et mergés sur la branche **develop**. Ils sont prêts à être testés avant livraison en **INT** et **EVO**.

Je te transfère également le ticket **987**.

**Ticket 1202 :**
D'après mes analyses, le problème semble être lié au mécanisme de migration automatique des cases que nous avons livré précédemment. Il faudrait remettre la version antérieure afin de retester le comportement et réfléchir à une autre solution si nécessaire. Si tu as un peu de temps, pourrais-tu regarder ce point ?

**Ticket 1275 :**
Le problème est assez étrange et je n'ai pas encore d'explication claire. En base, je constate la présence de la même pièce documentaire avec le même **messageId**, dupliquée trois fois. Le sujet est à réanalyser avec Samia et il faudrait essayer de reproduire le problème sur les environnements hors production.

Concernant l'**US 27**, elle est toujours en cours. Il me reste les tests à finaliser et je les terminerai dès mon retour la semaine prochaine.

Je reste joignable sur WhatsApp en cas d'urgence : **06 23 76 96 96**.

Merci et bonne journée.

Cordialement,

Imad
