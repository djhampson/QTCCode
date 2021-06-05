@isTest
private class AuthRegHandlerTest {
static testMethod void testCreateAndUpdateUser() {
    AuthRegHandler handler = new AuthRegHandler();
    Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
        'testFirst testLast', 'raffertyalbert@gmail.com', null, 'testuserlong', 'en_US', 'facebook', null, new Map<String, String>{'language' => 'en_US'}
        );
    User u = handler.createUser(null, sampleData);
    handler.updateuser(u.id, null, sampleData);
    }
    
}