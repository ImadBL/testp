// Dans le contrôleur parent (vm)
vm.comments.forEach(function(comment, $index) {
  var isLastCustomer = comment.author === 'comment.author.clientsComment'
    && $index === vm.comments.length - 1;
  comment.showDocs = isLastCustomer; // ouvert par défaut sur le dernier msg client
});
vm.toggleDocs = function(comment) {
  comment.showDocs = !comment.showDocs;
};

<div ng-if="parsed.docs.length > 0">
  <!-- Liste des documents (visible si showDocs) -->
  <div ng-if="comment.showDocs">
    <div ng-repeat="doc in parsed.docs" class="docLinkRow">
      <md-icon md-svg-icon="attach_file" width="13" height="13"></md-icon>
      <a ng-href="{{doc.url}}" target="_blank"
         ng-attr-title="{{doc.name}}"
         class="docLink">
        {{doc.name | limitTo:20}}{{doc.name.length > 20 ? '...' : ''}}
      </a>
    </div>
  </div>
  <!-- Bouton toggle -->
  <a ng-click="vm.toggleDocs(comment)" class="docToggleLink">
    <span ng-if="!comment.showDocs"
          translate="messaging.dialog.displayDocs"
          translate-values="{count: parsed.docs.length}">
      Display the {{parsed.docs.length}} document(s)
    </span>
    <span ng-if="comment.showDocs"
          translate="messaging.dialog.hideDocs"
          translate-values="{count: parsed.docs.length}">
      Hide the {{parsed.docs.length}} document(s)
    </span>
  </a>
</div>

// parseDocCount doit désormais retourner parsed.docs (tableau)
function parseDocCount(message) {
  var parsed = { commentText: '', docCount: 0, docs: [] };
  // ... extraction existante du texte ...
  // Construire le tableau des documents avec nom + url
  if (message.attachments) {
    parsed.docs = message.attachments.map(function(att) {
      return { name: att.fileName, url: att.downloadUrl };
    });
    parsed.docCount = parsed.docs.length;
  }
  return parsed;
}


.docLinkRow { display: flex; align-items: center; gap: 4px; margin: 4px 0; }
.docLink    { color: var(--link-color, #1d9e75); text-decoration: none; }
.docLink:hover { text-decoration: underline; }
.docToggleLink { cursor: pointer; color: var(--link-color, #1d9e75);
                 font-size: 13px; display: inline-block; margin-top: 4px; }
