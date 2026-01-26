pour une même table (X), évite de disperser la définition/paramétrage sur plusieurs fichiers (SQL/CSV/changelogs). L’idée, c’est d’avoir un “single source of truth” pour tout ce qui concerne X, sinon tu payes vite en bugs + temps perdu.

Pourquoi c’est préférable de tout regrouper (par table)

1) Lisibilité & compréhension

Quand tu dois comprendre “comment la table X est construite et alimentée”, tu ouvres un seul fichier.

Tu évites le ping-pong entre X_schema.sql, X_constraints.sql, X_seed_1.csv, X_seed_2.csv, X_patch.sql…

2) Ordre d’exécution maîtrisé
Liquibase exécute les changeSets dans l’ordre du changelog (ou par include).
Quand tu éclates sur plusieurs fichiers, tu peux te retrouver avec :

contraintes appliquées avant que les colonnes existent

inserts avant que les index/contraintes soient posés

modifications concurrentes sur les mêmes objets (surtout si plusieurs devs touchent X)

3) Conflits Git et “merge hell” réduits

Paradoxalement, regrouper par table évite que 5 PR touchent 5 fichiers liés à la même table.

Ça rend les reviews plus simples : “tout ce qui change sur X est là”.

4) Traçabilité / audit plus simple
En prod, quand ça casse, tu veux remonter vite :

“Quels changeSets concernent X ?”

“Quel est l’état attendu de X ?”
Quand tout est “éparpillé”, tu rates des morceaux.

5) Moins de risques de divergence entre environnements
Souvent les erreurs de Liquibase viennent de :

un fichier inclus dans un env mais pas l’autre

une data CSV mise à jour mais pas la SQL qui va avec (ou inversement)
Un fichier “par table” limite ce genre de drift.

Ce que je recommande comme organisation “propre”
Option A — 1 fichier par table (et c’est tout)

Exemple (au choix SQL ou YAML/XML/JSON Liquibase) :

tables/X.sql
Contenu typique :

create table X ...

alter table X add constraint ...

create index ...

éventuellement seed (inserts) si c’est cohérent

✅ Simple, efficace, robuste.

Option B — 1 dossier par table (si vraiment tu as beaucoup)

Si X est énorme, tu peux rester “mono-source” via un dossier, mais avec un seul point d’entrée :

X/changelog.xml (ou .yaml) qui inclut dans l’ordre :

X/01_schema.sql

X/02_constraints.sql

X/03_data.sql (ou data.csv)

✅ Tu gardes la granularité sans perdre la cohérence.

Le point délicat : SQL vs CSV (seed data)

CSV est bien pour des référentiels (liste de pays, statuts, codes…) et des données stables.

SQL est mieux quand :

tu as des INSERT ... SELECT

des conditions (upsert, gestion de doublons)

de la logique dépendante de l’existant

Dans tous les cas, l’important : ne pas mettre la seed data de X dans 3 CSV différents.
Tu fais un seul X.csv (ou un seul X_data.sql) et tu assumes.

Exceptions où séparer peut être acceptable

Séparer “structure” vs “données” si les données changent souvent (mais toujours un seul fichier data pour X).

Hotfix prod : tu ajoutes un changeSet correctif ailleurs (ex: hotfix/2026-01-xx.sql) puis tu refactors plus tard.

Très grosse volumétrie de seed data : tu peux chunker, mais alors tu documentes strictement l’ordre et tu gardes le point d’entrée unique.
