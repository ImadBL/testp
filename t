vm.latestStepVersion = '1.9.10';

vm.shouldShowNewOptions = function(stepVersion) {
    return compareVersions(extractBaseVersion(stepVersion), vm.latestStepVersion) >= 0;
};

function extractBaseVersion(version) {
    if (!version) return '0.0.0';

    var parts = version.split('.');
    return parts.slice(0, 3).join('.'); // garde seulement major.minor.patch
}

function compareVersions(v1, v2) {
    var a = v1.split('.').map(Number);
    var b = v2.split('.').map(Number);

    var maxLength = Math.max(a.length, b.length);

    for (var i = 0; i < maxLength; i++) {
        var n1 = a[i] || 0;
        var n2 = b[i] || 0;

        if (n1 > n2) return 1;
        if (n1 < n2) return -1;
    }

    return 0;
}
