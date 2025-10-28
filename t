Hello,
Pour info, je serai absent demain toute la matinée.
J’ai préparé une version, mais je ne l’ai pas encore livrée car j’attends que la partie de Sarra soit prête.
J’ai corrigé la première partie pour améliorer l’enchaînement des méthodes.
Il reste un problème à résoudre côté backend concernant l’update du case : il ne faut pas faire deux mises à jour séparées.
Il faudrait faire une seule requête qui modifie le flag et ajoute l’audit, afin d’éviter d’envoyer deux requêtes distinctes pour ces deux actions.
Essaie d’optimiser au maximum cette partie.
