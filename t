Finalisation de la configuration du batch de purge


Bonjour l’équipe DevOps,
Je vous partage les éléments nécessaires pour finaliser la configuration du batch de purge.
Les variables actuellement récupérées depuis le fichier .batch_profile sont les suivantes :

# Database
BCP_DB_URL
BCP_DB_USERNAME
BCP_DB_PASSWORD

# JMS - non utilisé pour le moment
BCP_JMS_URL
BCP_JMS_USERNAME
BCP_JMS_PASSWORD

Les fichiers de configuration application.yml et logback-spring.xml sont directement inclus dans le JAR. Il n’est donc pas nécessaire de livrer un fichier de configuration séparé. Au démarrage de l’application, il faudra simplement passer le bon profil correspondant à l’environnement.

Pour les tests, la branche à utiliser est :
feat/purgeNotification

Pourriez-vous finaliser la configuration des scripts, de la pipeline et du déploiement sur les différents serveurs ?
De mon côté, j’ai commencé à effectuer des tests de déploiement manuellement en recette afin que nous puissions avancer sur les tests fonctionnels.
Pouvez-vous également nous communiquer l’état d’avancement de votre côté ainsi que les éventuels points bloquants restants ?
Merci d’avance.
Cordialement,
Imad
