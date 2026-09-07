--
En regardant directement les modifications dans Git, j’ai constaté que tu avais ajouté certaines entités qui ne sont pas nécessaires.

Par exemple, concernant l’entité `Process`, nous avions déjà convenu de ne pas créer de table dédiée. J’ai mis en place des enums, ce qui est suffisant pour cette partie. Je ne pense donc pas qu’il soit pertinent de revenir sur cette décision.

Le lien entre `RetentionCase` et `Report` via `purge_report_id` ne me paraît pas correct non plus. D’après la solution que tu m’as présentée et ce que tu as implémenté, l’entité `Report` est indépendante. Je ne vois donc pas encore clairement comment tu comptes établir ce lien.

Par ailleurs, l’entité `Country` existe déjà dans le package `domain`, avec les contraintes nécessaires.

Le point principal à étudier maintenant est la solution permettant de compter le nombre de rapports. Le schéma actuel sert uniquement à sauvegarder les données : il faut donc prévoir une étape intermédiaire. Prends le temps de réfléchir à une solution complète, puis nous en reparlerons.

Je ne serai pas présent au daily.
