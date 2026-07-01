CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;

<md-input-container class="search-input">
    <label>Subtype</label>

    <md-select ng-model="vm.selectedSubType">
        <md-option value=""></md-option>

        <md-option
            ng-repeat="subType in vm.docSubTypes"
            ng-value="subType.value">
            {{subType.display}}
        </md-option>

    </md-select>
</md-input-container>
