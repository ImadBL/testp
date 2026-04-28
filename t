<div ng-repeat="doc in comment.docs" class="docLinkRow" style="border-bottom: 1px solid currentColor;">

    <div ng-class="{'bpm-document-visited': doc.visited, 'bpm-document-ged-error': doc.metadata == null || doc.metadata == ''}"
         style="display: flex; align-items: center; gap: 8px; position: relative;"
         class="bpm-document"
         ng-click="vm.open(doc, $event)">

        <!-- Icône trombone -->
        <md-icon class="bpm-document-icon" 
                 md-svg-icon="icon_attachment" 
                 style="flex-shrink: 0; width: 20px; height: 20px;">
        </md-icon>

        <!-- Icône ✓ uniquement si doc visité -->
        <md-icon ng-if="doc.visited"
                 class="bpm-document-visited-icon" 
                 md-svg-icon="icon_done" 
                 style="position: absolute; top: -5px; left: 12px; width: 12px; height: 12px;">
        </md-icon>

        <!-- Nom du fichier -->
        <a title="{{doc.fileName}}" class="docLink">
            {{doc.metadata.externalDocumentName | truncate:30}}
        </a>

    </div>
</div>
