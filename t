Bonjour,

D’après les modifications que j’ai identifiées, deux sujets sont concernés : Microsoft Graph et la conversion en PDF.

Pour Microsoft Graph, il faut vérifier que le fonctionnement reste identique à celui d’avant. Ce test ne pouvant pas être réalisé en local, il faudra déployer l’application sur un serveur pour le valider.

Concernant la conversion en PDF, j’ai effectué un premier test simple, sans analyser en détail tous les cas ni identifier l’ensemble des écarts ou erreurs possibles. À ce stade, je constate plusieurs différences entre les deux bibliothèques :

La police de caractères et les marges des pages ne sont pas identiques.
La numérotation des pages est absente.
Les images ne sont pas redimensionnées : les plus grandes peuvent occuper toute une page, ce qui pourrait bloquer le traitement de certains mails.

Des tests plus approfondis sont donc nécessaires pour évaluer les corrections à prévoir. Je ne peux pas encore donner d’estimation fiable : cela pourrait prendre deux jours comme une semaine, selon les problèmes rencontrés entre l’ancienne bibliothèque et la nouvelle.

Dès que j’aurai un créneau la semaine prochaine, je pourrai approfondir les tests et affiner l’estimation.

Bonne journée,
Imad
