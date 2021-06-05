public class updateContact{

    @future
    public static void updateIt(Map<Id, String> userIds) {

        Set<Id> contactIds = new Set<Id>();
        Map<Id, User> userm = new Map<Id, User>();
        Map<Id, String> profilesm = new Map<Id, String>();
        Map<Id, String> contactprofilem = new Map<Id, String>();
        Map<Id, String> contactwhatsUpdated = new Map<Id, String>();
        
        List<Profile> profiles = [select id, name from Profile];
        
        for (Profile p : profiles) {
            profilesm.put(p.Id, p.name);
        }
        
        for (User u : [select Id, ContactId, Profileid, IsActive,
                        Email, FirstName, LastName, MobilePhone, Phone, Title from User where Id in :userIds.keySet()] ) {
          if (u.ContactId != null){
            String whatsUpdated = userids.get(u.id);
            if (whatsUpdated > ''){
              contactIds.add(u.ContactId); // something was updated so add to contacts to update
              userm.put(u.ContactId, u); // link contact and user
              contactwhatsUpdated.put(u.ContactId, whatsUpdated); //link contact and whats changed
            }
            // now set the profile name if it needs to be updated
            if (whatsUpdated.contains('profile')){
              if (u.IsActive == true){
                contactprofilem.put(u.Contactid, profilesm.get(u.ProfileId));
              }
              else{
                contactprofilem.put(u.Contactid, '');
              }
            }
          }
        } 
        
        //now we process only what's changed for each contact
        if (contactIds.size() > 0) {
        
          List<Contact> contacts = [select id, Profile_Name__c, Phone, MobilePhone, Email, FirstName, LastName, Title from Contact where Id in :contactIds];
        
          for (Contact c : contacts) {
            String whatsUpdated = contactwhatsUpdated.get(c.id);
            if (whatsUpdated.contains('profile'))
              c.Profile_Name__c = contactprofilem.get(c.Id);
            if (whatsUpdated.contains('phone')) 
              c.Phone = userm.get(c.id).Phone;
            if (whatsUpdated.contains('mobile')) 
              c.MobilePhone = userm.get(c.id).MobilePhone;
            if (whatsUpdated.contains('email'))
              c.Email = userm.get(c.id).Email;
            if (whatsUpdated.contains('first'))
              c.FirstName = userm.get(c.id).FirstName;
            if (whatsUpdated.contains('last'))
              c.LastName = userm.get(c.id).LastName;
            if (whatsUpdated.contains('title'))
              c.Title = userm.get(c.id).Title;
          }
        
          update contacts;
        }
    }

}