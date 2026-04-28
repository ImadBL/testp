<div ng-if="comment.docs.length > 0 && comment.messageId" class="classDocCount">
    <div ng-if="comment.showDocs">
        <div ng-repeat="doc in comment.docs" class="docLinkRow" style="border-bottom: 1px solid currentColor;">

            <div ng-class="{'bpm-document-visited': doc.visited, 'bpm-document-ged-error': doc.metadata == null || doc.metadata == ''}"
                 style="display: flex; align-items: center; gap: 8px;"
                 class="bpm-document"
                 ng-click="vm.open(doc, $event)">

                <md-icon class="bpm-document-icon" md-svg-icon="icon_attachment" style="margin: 7px; flex-shrink: 0;"></md-icon>
                <md-icon class="bpm-document-visited-icon" md-svg-icon="icon_done" style="flex-shrink: 0;"></md-icon>
                <a title="{{doc.fileName}}" class="docLink">{{doc.metadata.externalDocumentName | truncate:30}}</a>

            </div>
        </div>
    </div>
</div>
