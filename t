Bonjour,

Voici l’avancement sur l’EVOL :

Le nombre de documents échangés est corrigé, aussi bien pour l’agent que pour les anciens commentaires.
L’upload de plus de 5 fichiers fonctionne correctement : l’affichage montre “5 fichiers” et les autres sont masqués via le bouton “hide”.
Par défaut, sur le dernier message client, les documents sont maintenant affichés.
Le message client est identifié via :
comment.author === 'comment.author.clientsComment'
Si besoin, vous pouvez ajuster la condition (l’image ci-dessous est uniquement un exemple et ne concerne pas un message client réel).
Le bug signalé est corrigé.
Quand les documents ne sont pas disponibles, le message s’affiche actuellement sans le filename. À voir si on préfère masquer complètement le message dans ce cas.
L’ouverture des documents fonctionne correctement.
L’icône “visited” est OK.
Le rafraîchissement automatique est OK.
L’attachement des documents est OK.

Point restant :

Lorsqu’on attache des documents déjà attachés auparavant, il faut actuellement rafraîchir la page pour que les documents disparaissent du message 2 et apparaissent dans le message 1.
