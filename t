// src/vendor.js

// 1) jQuery d’abord
import 'jquery';

// 2) Angular ensuite + exposé global si besoin legacy
import angular from 'angular';
window.angular = angular;

// 3) Modules Angular avant ton code
import '@uirouter/angularjs';
import 'angular-animate';
import 'angular-aria';
import 'angular-messages';
import 'angular-sanitize';
import 'angular-cookies';
import 'angular-resource';
import 'angular-translate';
import 'angular-translate-loader-static-files';
import 'angular-material';
import 'angular-material/angular-material.css';

// 4) Toastr + CSS + global (si ton ancien code l’utilise en global)
import toastr from 'toastr';
import 'toastr/build/toastr.css';
window.toastr = toastr;

// (optionnel) expose lodash, moment, etc.
// import _ from 'lodash'; window._ = _;
