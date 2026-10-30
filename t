----

D’après Sami, le mécanisme de tolérance aux pannes permet de basculer automatiquement vers le serveur EMS secondaire en cas d’incident. Or, le batch est actuellement configuré pour se connecter uniquement au serveur principal. Selon lui, le retour sur le serveur principal devrait avoir lieu au prochain redémarrage, lundi.

Deux solutions sont donc possibles :

Conserver la configuration actuelle et attendre lundi : le batch devrait alors reprendre son fonctionnement normal.

Ajouter l’URL du serveur EMS secondaire dans la configuration du batch pour gérer cette bascule. Cette modification nécessite un redéploiement du batch.
