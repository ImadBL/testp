
public void updateUserRoles(UserAdminDto userAdminDto,
                            Collection<String> currentRoles,
                            UpdateResource updateResource) {

    // 1) desired roles (depuis l’écran)
    Set<String> desired = new HashSet<>(userAdminDto.getRoles()); // cochés

    // 2) current roles (déjà existants pour l'user)
    Set<String> current = new HashSet<>(currentRoles);

    // 3) Calcul des diffs
    Set<String> rolesToAdd = new HashSet<>(desired);
    rolesToAdd.removeAll(current); // desired - current

    Set<String> rolesToRemove = new HashSet<>(current);
    rolesToRemove.removeAll(desired); // current - desired

    // 4) AddGroup
    rolesToAdd.stream()
        .map(role -> getGroupIds().get(role))
        .filter(Objects::nonNull)
        .map(this::buildAddGroupEntity)
        .forEach(entity -> updateResource.getAddGroup().add(entity));

    // 5) RemoveGroup
    rolesToRemove.stream()
        .map(role -> getGroupIds().get(role))
        .filter(Objects::nonNull)
        .map(this::buildRemoveGroupEntity) // ou buildAddGroupEntity si même format
        .forEach(entity -> updateResource.getRemoveGroup().add(entity));


