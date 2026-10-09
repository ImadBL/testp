---
Bonjour,
Je vous fais un état des lieux : j’ai avancé sur les tests, mais il reste encore quelques points à corriger. J’espère qu’ils pourront être traités aujourd’hui.
Concernant la donnée que tu as ajoutée, CYCLE_NUMBER, elle n’est pas initialisée au moment de la sauvegarde des rapports.
Deux options sont possibles :
- soit la rendre nullable et l’initialiser ensuite ;
- soit la garder en NOT NULL, mais dans ce cas il faut obligatoirement l’initialiser au moment de la sauvegarde.
Il faut également que j’échange avec Philippe pour mettre à jour certains scripts afin que le démarrage soit automatique.
Pour le moment, je n’ai pas réussi à aller plus loin pour tester l’envoi de l’email, car nos environnements AMX d’intégration (EVO et SOCLE) sont KO. Pourrais-tu regarder, s’il te plaît, pourquoi ils ne fonctionnent pas ?
Néanmoins, j’ai réussi à faire fonctionner l’application en intégration hier, sans l’envoi de mail.
Pour les tests en recette, j’ai paramétré l’envoi de mail afin que la notification soit envoyée à la minute 10 de chaque heure, pour faciliter les tests.
En production et préproduction, le paramétrage sera différent :
- lancement du batch entre 19h00 et 23h45 ;
- envoi de la notification à 00h00.
Dites-moi si vous préférez un paramétrage spécifique en recette et en intégration.
