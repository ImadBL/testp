---
Suite à notre point d’hier, j’ai déposé le jar du batch sur le serveur xxxxx, ainsi que le fichier application.yml dans le répertoire xxxxx.

Le batch est compilé et doit être exécuté avec Java 21. Il faut donc vérifier que Java 21 est bien installé et disponible sur le serveur avant de pouvoir démarrer le jar.

La commande de lancement sera de ce type :

$JAVA_HOME/bin/java -Dspring.profiles.active=<profil> -jar <nom-du-jar>.jar

Il faudra également vérifier/configurer le JAVA_HOME utilisé par le script de démarrage afin qu’il pointe bien vers l’installation Java 21.

Vous trouverez également sur le même serveur un exemple existant pour le batch BCC, qui peut servir de référence pour le script de démarrage et la configuration d’exécution.

Une fois Java 21 disponible et la configuration finalisée, on pourra démarrer le batch et vérifier les logs de lancement.
