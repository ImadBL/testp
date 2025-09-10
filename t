// Angular global + modules
import angular from 'angular';
window.angular = angular;
import '@uirouter/angularjs';
import 'angular-animate';
import 'angular-aria';
import 'angular-messages';
import 'angular-sanitize';
import 'angular-resource';
import 'angular-cookies';
import 'angular-translate';
import 'angular-translate-loader-static-files';
import 'angular-material';
import 'angular-material/angular-material.css';

// Toastr + CSS -> global
import toastr from 'toastr';
import 'toastr/build/toastr.css';
window.toastr = toastr;
