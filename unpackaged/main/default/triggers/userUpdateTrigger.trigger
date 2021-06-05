trigger userUpdateTrigger on User (after insert, after update) {
    // bypass trigger processing START
    T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
        
    if( s.Bypass_Triggers__c) return; // skip trigger...
    // bypass trigger processing END
    
    Map<Id, String> userIds = new Map<Id, String>();
    for (User u : Trigger.new) {
        String whatsUpdated = '';
        if(Trigger.isUpdate){
            User beforeUpdate = Trigger.oldMap.get(u.Id);
            if (u.ContactId != null){
                if (u.ProfileId != beforeUpdate.ProfileId || u.IsActive != beforeUpdate.IsActive)
                    whatsUpdated = whatsUpdated + 'profile';
                if (u.Phone != beforeUpdate.Phone)  
                    whatsUpdated = whatsUpdated + 'phone';
                if (u.MobilePhone != beforeUpdate.MobilePhone) 
                    whatsUpdated = whatsUpdated + 'mobile';
                if (u.Email != beforeUpdate.Email)
                    whatsUpdated = whatsUpdated + 'email';
                if (u.FirstName != beforeUpdate.FirstName)
                    whatsUpdated = whatsUpdated + 'first';
                if (u.LastName != beforeUpdate.LastName)
                    whatsUpdated = whatsUpdated + 'last';
                if (u.Title != beforeUpdate.Title)
                    whatsUpdated = whatsUpdated + 'title';
                if (whatsUpdated > '')
                    userIds.put(u.Id, whatsUpdated);
            }
        }
        if(Trigger.isInsert){
            if (u.ContactId != null){
                whatsUpdated = whatsUpdated + 'profile';
                userIds.put(u.Id, whatsUpdated);
            }
        }
    }
    
    if (userIds.size() > 0) {
        updateContact.updateIt(userIds);
    }
}