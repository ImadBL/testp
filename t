angular.module('app', [])
.factory('UserApi', function($http) {
  const base = '/api/ldap/users';
  return {
    exists:  uid   => $http.get(`${base}/${encodeURIComponent(uid)}/exists`), // -> {exists:true|false}
    create:  body  => $http.post(base, body),                                  // {uid, firstName, lastName, email, ...}
    update:  (uid, body) => $http.put(`${base}/${encodeURIComponent(uid)}`, body)
  };
})
.controller('UsersCtrl', function($timeout, UserApi) {
  const vm = this;
  vm.rows = [{ country:'', username:'', organismes:'', roles:'', exists:null, loading:false }];

  vm.addEmptyRow = () => vm.rows.push({ country:'', username:'', organismes:'', roles:'', exists:null });

  // Anti-bounce: on attend 400ms après la saisie pour éviter trop d’appels
  let debounce;
  vm.onUsernameChange = (row) => {
    row.exists = null;
    if (debounce) $timeout.cancel(debounce);
    if (!row.username || !row.username.trim()) return;

    debounce = $timeout(() => {
      row.loading = true;
      UserApi.exists(row.username.trim())
        .then(res => row.exists = !!(res.data && res.data.exists))
        .catch(() => row.exists = null)   // en cas d’erreur, on ne bloque pas l’UI
        .finally(() => row.loading = false);
    }, 400);
  };

  vm.add = (row) => {
    if (!row.username) return;
    row.loading = true;

    const payload = mapToBackend(row);
    UserApi.create(payload)
      .then(() => {
        row.exists = true;               // créé → il “existe” désormais
        toast('User créé dans LDAP');
      })
      .catch(err => toast('Erreur création: ' + (err.data && err.data.message || 'inconnue'), true))
      .finally(() => row.loading = false);
  };

  vm.update = (row) => {
    row.loading = true;
    const payload = mapToBackend(row);
    UserApi.update(row.username, payload)
      .then(() => toast('User mis à jour'))
      .catch(err => toast('Erreur update: ' + (err.data && err.data.message || 'inconnue'), true))
      .finally(() => row.loading = false);
  };

  function mapToBackend(row) {
    // adapte ce mapping à ton backend: il lui faut au minimum uid, sn, cn/mail
    const [firstName='', lastName=''] = guessNames(row.username);
    return {
      uid: row.username,
      firstName,
      lastName,
      email: `${row.username}@example.com`,
      country: row.country,
      organismes: row.organismes,
      roles: row.roles
    };
  }

  function guessNames(uid) {
    // helper basique: remplace par ta vraie saisie si tu as des champs prénom/nom
    // ex: 'jdoe' -> ['John','Doe'] (mock)
    return [uid, 'User'];
  }

  function toast(msg, isError) {
    if (isError) console.error(msg);
    else console.log(msg);
    // branche ici ton toaster préféré (angular-toastr, etc.)
  }
});

<div ng-app="app" ng-controller="UsersCtrl as vm" class="p-4">
  <table class="table table-striped">
    <thead>
      <tr>
        <th>Country</th>
        <th>Username</th>
        <th>Organismes</th>
        <th>Roles</th>
        <th style="width:180px;">Actions</th>
      </tr>
    </thead>
    <tbody>
      <tr ng-repeat="row in vm.rows">
        <td>
          <input class="form-control" ng-model="row.country">
        </td>
        <td>
          <input class="form-control"
                 ng-model="row.username"
                 ng-change="vm.onUsernameChange(row)"
                 placeholder="uid LDAP">
          <small ng-if="row.exists" class="text-success">existe dans LDAP</small>
          <small ng-if="row.exists === false" class="text-muted">non trouvé</small>
        </td>
        <td>
          <input class="form-control" ng-model="row.organismes">
        </td>
        <td>
          <input class="form-control" ng-model="row.roles">
        </td>
        <td>
          <button class="btn btn-primary"
                  ng-click="vm.add(row)"
                  ng-disabled="row.loading || row.exists">
            Add
          </button>
          <button class="btn btn-warning"
                  ng-if="row.exists"
                  ng-click="vm.update(row)"
                  ng-disabled="row.loading">
            Update
          </button>
        </td>
      </tr>
    </tbody>
  </table>

  <button class="btn btn-outline-secondary" ng-click="vm.addEmptyRow()">+ Row</button>
</div>


