global class AuthRegHandler implements Auth.RegistrationHandler{
    global User createUser(Id portalId, Auth.UserData data) {
        User u = [SELECT Id FROM User WHERE Email =: data.email and IsActive = True];
        return u;
    }
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
    }
}