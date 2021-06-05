public with sharing class T1CommunitiesSelfRegController {
    @AuraEnabled
     public static String createExternalUser(
        String username, String password, String startUrl, String fname, String lname, String accountId, String orgkey, String title, String phone,
            String company) {
            Savepoint sp = null;
            try {
                sp = Database.setsavepoint();
                system.debug(sp);
                
                // Creating a user object. 
                User u = new User();
                u.Username = username;
                u.Email = username;
                u.FirstName = fname;
                u.LastName = lname;
                u.Org_Support_Key_Supplied__c = orgkey;
                u.Title = title;
                u.Phone = phone;
                u.CompanyName = company;

                // set profile
                //Profile pf = [Select id, name from Profile where name ='Customer Community Login User Contributor' limit 1];
                //u.ProfileId = pf.Id;

                // Default UI for mobile is set to S1 for user created using site object. 
                // Enable this perm to change it to community.
                u.UserPreferencesHideS1BrowserUI = true;
                
                // Generating unique value for community nickname. 
                String nickname = ((fname != null && fname.length() > 0) ? fname.substring(0,1) : '' ) + lname.substring(0,1);
                nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
                u.CommunityNickname = nickname;
                
                System.debug('creating user');
                
                // Creating portal user. 
                // Passing in null account ID forces the system to read this from the network setting (set using Community Workspaces).
                String userId = Site.createExternalUser(u, accountId, password, true);
                
                 // Other contact information can be updated here
                Contact contact = new Contact();
                contact.Id = u.ContactId;
                contact.Title = title;
                update(contact);
                
                // return login url. 
               /*  if (userId != null && password != null && password.length() > 1) {  
                    ApexPages.PageReference lgn = Site.login(username, password, startUrl);
                    return lgn.getUrl();
                } */
                if (userId != null) {  
                    //ApexPages.PageReference lgn = Site.login(username, password, startUrl);
                    //return lgn.getUrl();
                    return userId;
                }
            }
            catch (Exception ex) {
                Database.rollback(sp);
                System.debug(ex.getMessage());
                return null;
            }
            return null; 
        }   
    }