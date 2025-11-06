
<span ng-if="vm.Math.ceil($chip.file.size / 1024) > 7168" class="error-text">
            (Taille max: 7 Mo)
        </span>



var maxFileSize = 7 * 1024 * 1024; // 7 MB
var isValid = true;

_.forEach(vm.files, function(file) {
    if (file.size > maxFileSize) {
        isValid = false;
    }
});

vm.form.files.$setValidity('file-size', isValid);



