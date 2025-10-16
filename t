/* global require */
const fs = require('fs');
const path = require('path');
const xlsx = require('xlsx');

const jsonFiles = [
  { lang: 'fr', path: path.join(__dirname, 'locale-fr.json') },
  { lang: 'en', path: path.join(__dirname, 'locale-en.json') },
  { lang: 'it', path: path.join(__dirname, 'locale-it.json') },
  { lang: 'de', path: path.join(__dirname, 'locale-de.json') }
];

const excelFilePath = path.join(__dirname, 'data-from-json.xlsx');

/**
 * Aplatit un objet JSON en clés pointées.
 * Exemple : { a: { b: { c: "val" } } } => { "a.b.c": "val" }
 */
function flattenJson(obj, prefix = '') {
  let result = {};
  for (const key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      const newKey = prefix ? `${prefix}.${key}` : key;
      if (typeof obj[key] === 'object' && obj[key] !== null) {
        Object.assign(result, flattenJson(obj[key], newKey));
      } else {
        result[newKey] = obj[key];
      }
    }
  }
  return result;
}

/**
 * Lecture et conversion de tous les JSON
 */
function readAllJson() {
  const allLangData = {};

  jsonFiles.forEach(({ lang, path: filePath }) => {
    const content = fs.readFileSync(filePath, 'utf-8').replace(/^\uFEFF/, '');
    const jsonData = JSON.parse(content);
    allLangData[lang] = flattenJson(jsonData);
  });

  // Fusion de toutes les clés
  const allKeys = new Set();
  for (const lang in allLangData) {
    Object.keys(allLangData[lang]).forEach(k => allKeys.add(k));
  }

  // Construction du tableau pour Excel
  const rows = [];
  allKeys.forEach(key => {
    const row = { key };
    jsonFiles.forEach(({ lang }) => {
      row[lang] = allLangData[lang][key] || '';
    });
    rows.push(row);
  });

  return rows;
}

/**
 * Écriture du tableau dans un fichier Excel
 */
function writeExcel(data) {
  const worksheet = xlsx.utils.json_to_sheet(data);
  const workbook = xlsx.utils.book_new();
  xlsx.utils.book_append_sheet(workbook, worksheet, 'Traductions');
  xlsx.writeFile(workbook, excelFilePath);
  console.log(`✅ Fichier Excel généré: ${excelFilePath}`);
}

// Exécution
try {
  const data = readAllJson();
  writeExcel(data);
} catch (err) {
  console.error('Erreur:', err);
}
