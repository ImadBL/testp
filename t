Objet : Passation / Backup – point d’avancement & actions à suivre

Bonjour,

Voici le point de passation (backup) :

Refresh data / création du step

Le refresh data prend ~30 secondes (appel AMX asynchrone, pas de retour direct).

La solution actuelle consiste à afficher un spinner pendant ~30s, le temps que le nouveau stepId soit généré.

À l’issue des 30s, le case passe en “alloué” à la personne connectée.
→ Ce comportement peut être ajusté si besoin (case “offert” par défaut ou non).

Requête

Pour mémoire, j’ai exécuté la requête sur tous les environnements.

Liquibase / Déploiements

Si les soucis Liquibase sont résolus : tester le job Liquibase sur tous les environnements et demander à OPS de relancer le déploiement Liquibase.
→ À voir avec Kamal / Abdelghani / Nasser en cas de blocage.

Tickets livrés en INT :

LS_TCBPM-934 : fix mergé sur develop, livré en intégration

LS_TCBPM-478 : fix mergé sur develop, livré en intégration

À faire / suivi :

Tester les pipelines de déploiement en INT et confirmer avec Abdelatif si tout est OK ou s’il y a un souci.

Vérifier avec Nasser l’état des sujets Liquibase et relancer le déploiement si nécessaire.

Les tickets en “Ready” : je ne les ai pas encore commencés.

Merci,
Imad BELMOUJAHID
