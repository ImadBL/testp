CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;

.constant('DOCUMENT_CHANNELS', [
            { value: '', display: '' },
            { value: 'BCI', display: 'BCI' },
            { value: 'CSV', display: 'CSV' },
            { value: 'DUP', display: 'DUP' },
            { value: 'ECC', display: 'ECC' },
            { value: 'ELO', display: 'ELO' },
            { value: 'FMD', display: 'FMD' },
            { value: 'FMP', display: 'FMP' },
            { value: 'IDP', display: 'IDP' },
            { value: 'IML', display: 'IML' },
            { value: 'IPF', display: 'IPF' },
            { value: 'LAS', display: 'LAS' },
            { value: 'MAN', display: 'MAN' },
            { value: 'PAP', display: 'PAP' },
            { value: 'SDS', display: 'SDS' }
        ]);

vm.channels = DOCUMENT_CHANNELS;

<md-input-container class="search-input">
    <label>Input channel</label>

    <md-select ng-model="vm.selectedChannel">
        <md-option ng-repeat="channel in vm.channels"
                   ng-value="channel.value">
            {{channel.display}}
        </md-option>
    </md-select>
</md-input-container>


vm.channelsMap = {};

angular.forEach(DOCUMENT_CHANNELS, function (channel) {
    vm.channelsMap[channel.value] = channel.display;
});
