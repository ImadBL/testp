Je liste les sujets qui restent à traiter pour la purge. Voilà les principaux points:

1	Adapter fileImportJob au format réel: Adapter la lecture/parsing au format définitif du fichier reçu, mapping des données et contrôles nécessaires.	1,5
2	Faire évoluer le modèle de données: Séparer les demandes/cases d’archivage des cases de purge. Création de BCP_ARCHIVE_REQUEST, adaptation des entités, repositories et scripts Oracle.	2
3	Implémenter archiveRequestListener: Consommer les messages JMS, récupérer notamment le Case ID et le type de case, puis enregistrer la demande dans BCP_ARCHIVE_REQUEST.	2
4	Implémenter la génération du PDF: Créer un service dédié pour récupérer les informations nécessaires et générer le PDF correspondant à la case.	2
5	Implémenter l’archivage GED: Créer un service dédié pour sauvegarder le PDF dans la GED, renseigner les métadonnées, effectuer l’indexation et récupérer l’identifiant du document GED.	2,5
6	Implémenter archiveJob: Récupérer les demandes d’archivage en attente, appeler le service de génération PDF du ticket 4, puis le service GED du ticket 5 et mettre à jour le statut de la demande.	1,5
7	Tests: Tester le workflow complet
8	Configuration et finalisation: Ajouter/configurer les propriétés JMS, GED et archivage pour les différents environnements et finaliser les logs nécessaires.	1
	TOTAL
