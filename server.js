// server.js
const express = require('express');
const { spawn } = require('child_process');
const path = require('path');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

app.use(bodyParser.json());
// On sert les fichiers statiques (notre page AngularJS) depuis le dossier "public"
app.use(express.static('public'));

/**
 * Endpoint pour lancer le test runner "Update"
 * Le client envoie une liste de Case IDs dans le body JSON sous la clé "caseIds"
 */
app.post('/api/update-cases', (req, res) => {
  const caseIds = req.body.caseIds; // attend un tableau de chaînes
  console.log("Reçu pour update:", caseIds);

  // Chemin vers le script testrunner de SoapUI et le projet SoapUI
  const testRunnerPath = path.join('/path/to/SoapUI/bin', 'testrunner.sh'); // ou testrunner.bat sous Windows
  const soapuiProjectPath = path.join('/path/to/projects', 'MySoapUIProject.xml');

  // On passe la liste des Case IDs sous forme de chaîne séparée par des virgules
  const caseIdsProp = caseIds.join(',');

  const args = [
    '-s', 'UpdateTestSuite',    // Nom de la TestSuite pour l'update
    '-c', 'UpdateTestCase',     // Nom du TestCase pour l'update
    '-PCaseIDs=' + caseIdsProp, // Passage d'une propriété SoapUI
    '-r',                       // Option pour générer un rapport
    soapuiProjectPath
  ];

  const testProcess = spawn(testRunnerPath, args);
  let output = '';
  let errorOutput = '';

  testProcess.stdout.on('data', (data) => {
    output += data.toString();
  });
  testProcess.stderr.on('data', (data) => {
    errorOutput += data.toString();
  });
  testProcess.on('close', (code) => {
    console.log(`Update test terminé avec le code ${code}`);
    res.json({
      exitCode: code,
      stdout: output,
      stderr: errorOutput,
      caseIds: caseIds
    });
  });
});

/**
 * Endpoint pour lancer le test runner "ReadCase"
 * Il renvoie le statut de chaque case
 */
app.get('/api/read-cases', (req, res) => {
  // Chemin vers le script testrunner et le projet SoapUI
  const testRunnerPath = path.join('/path/to/SoapUI/bin', 'testrunner.sh'); // ou testrunner.bat
  const soapuiProjectPath = path.join('/path/to/projects', 'MySoapUIProject.xml');

  const args = [
    '-s', 'ReadCaseTestSuite',  // Nom de la TestSuite pour la lecture des cas
    '-c', 'ReadCaseTestCase',   // Nom du TestCase pour la lecture des cas
    '-r',                       // Génération d'un rapport
    soapuiProjectPath
  ];

  const testProcess = spawn(testRunnerPath, args);
  let output = '';
  let errorOutput = '';

  testProcess.stdout.on('data', (data) => {
    output += data.toString();
  });
  testProcess.stderr.on('data', (data) => {
    errorOutput += data.toString();
  });
  testProcess.on('close', (code) => {
    console.log(`ReadCase test terminé avec le code ${code}`);

    // Pour cet exemple, nous supposons que la sortie est au format "case1:SUCCESS,case2:FAIL"
    let caseStatus = [];
    output.trim().split(',').forEach(pair => {
      let [id, status] = pair.split(':');
      if(id && status) {
        caseStatus.push({ id: id.trim(), status: status.trim() });
      }
    });
    res.json({
      exitCode: code,
      stdout: output,
      stderr: errorOutput,
      cases: caseStatus
    });
  });
});

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/index.html');
});

app.listen(PORT, () => {
  console.log(`Serveur démarré sur le port ${PORT}`);
});
