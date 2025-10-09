<form name="userForm" novalidate ng-controller="NewUserCtrl as vm">

  <!-- Username -->
  <md-input-container>
    <label>Username</label>
    <input type="text"
           ng-model="vm.newUser.username"
           ng-change="vm.resetState()"
           required />
  </md-input-container>

  <!-- Country -->
  <md-input-container>
    <label>Country</label>
    <md-select ng-model="vm.newUser.countryCode"
               ng-disabled="!vm.state.enableFields">
      <md-option value=""></md-option>
      <md-option value="FRA">FRA</md-option>
      <md-option value="GBR">GBR</md-option>
      <md-option value="ITA">ITA</md-option>
      <md-option value="DEU">DEU</md-option>
      <md-option value="ESP">ESP</md-option>
      <md-option value="NLD">NLD</md-option>
      <md-option value="BEL">BEL</md-option>
    </md-select>
  </md-input-container>

  <!-- Fullname -->
  <md-input-container>
    <label>Full Name</label>
    <input type="text"
           ng-model="vm.newUser.fullname"
           ng-disabled="!vm.state.enableFields" />
  </md-input-container>

  <!-- Organismes -->
  <md-input-container>
    <label>Organismes ( , )</label>
    <input type="text"
           ng-model="vm.newUser.organismes"
           ng-disabled="!vm.state.enableFields" />
  </md-input-container>

  <!-- Roles -->
  <md-input-container>
    <label>Roles ( , )</label>
    <input type="text"
           ng-model="vm.newUser.roles"
           ng-disabled="!vm.state.enableFields" />
  </md-input-container>

  <!-- Buttons -->
  <div layout="row" layout-align="start center" layout-gap="8">
    <!-- Check -->
    <md-button class="md-primary md-raised"
               ng-click="vm.check()"
               ng-disabled="!vm.newUser.username || vm.state.loading">
      Check
    </md-button>

    <!-- Add -->
    <md-button class="md-primary md-raised"
               ng-click="vm.add()"
               ng-if="vm.state.checked && vm.state.exists === false"
               ng-disabled="vm.state.loading || !vm.state.enableFields">
      Add
    </md-button>

    <!-- Update -->
    <md-button class="md-warn md-raised"
               ng-click="vm.update()"
               ng-if="vm.state.checked && vm.state.exists === true"
               ng-disabled="vm.state.loading || !vm.state.enableFields">
      Update
    </md-button>

    <span ng-if="vm.state.checked && vm.state.exists === true"
          class="md-caption" style="margin-left:8px;color:#388e3c">
      déjà présent dans LDAP
    </span>
    <span ng-if="vm.state.checked && vm.state.exists === false"
          class="md-caption" style="margin-left:8px;color:#1976d2">
      non trouvé (vous pouvez l'ajouter)
    </span>
  </div>
</form>

angular.module('app', [])
  .factory('UserApi', function($http) {
    const base = '/api';
    return {
      exists: uid => $http.get(`${base}/ldap/users/${encodeURIComponent(uid)}/exists`),
      create: body => $http.post(`${base}/users`, body),
      update: (uid, body) => $http.put(`${base}/users/${encodeURIComponent(uid)}`, body)
    };
  })
  .controller('NewUserCtrl', function(UserApi) {
    const vm = this;

    vm.newUser = { username: '', countryCode: '', fullname: '', organismes: '', roles: '' };
    vm.state = {
      loading: false,
      checked: false,
      exists: null,
      enableFields: false
    };

    vm.resetState = function() {
      vm.state.checked = false;
      vm.state.exists = null;
      vm.state.enableFields = false;
    };

    vm.check = function() {
      if (!vm.newUser.username) return;
      vm.state.loading = true;
      UserApi.exists(vm.newUser.username.trim())
        .then(res => {
          vm.state.exists = !!(res.data && res.data.exists);
          vm.state.checked = true;
          vm.state.enableFields = true; // active les champs après vérification
        })
        .catch(() => {
          vm.state.exists = null;
          vm.state.checked = true;
        })
        .finally(() => vm.state.loading = false);
    };

    vm.add = function() {
      const body = mapToBackend(vm.newUser);
      vm.state.loading = true;
      UserApi.create(body)
        .then(() => {
          vm.state.exists = true;
        })
        .finally(() => vm.state.loading = false);
    };

    vm.update = function() {
      const body = mapToBackend(vm.newUser);
      vm.state.loading = true;
      UserApi.update(vm.newUser.username.trim(), body)
        .finally(() => vm.state.loading = false);
    };

    function mapToBackend(row) {
      const uid = row.username.trim();
      const [firstName, ...last] = (row.fullname || uid).split(' ');
      const lastName = last.join(' ') || 'User';
      return {
        uid,
        firstName,
        lastName,
        email: `${uid}@example.com`,
        country: row.countryCode,
        organismes: row.organismes,
        roles: row.roles
      };
    }
  });


