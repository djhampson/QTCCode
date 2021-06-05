trigger IdeaAfter on Idea (After insert, After update) {

    // Grant Hamlyn 28/01/2020 Only process Active User Subscribers - Expand select statement
       // bypass trigger processing START
    T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
     
    if( s.Bypass_Triggers__c) return; // skip trigger...
    // bypass trigger processing END
    // 
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            List<Idea_Email_Notification__c> l_ien = new List<Idea_Email_Notification__c>();
            for(Idea ideaL : Trigger.new){
                Idea beforeUpdate = Trigger.oldMap.get(ideaL.Id);
                if (ideaL.Status != beforeUpdate.Status){
                    for(acideas__brIdeaSubscription__c ideaSub : [SELECT acideas__User__c 
                                                                    FROM acideas__brIdeaSubscription__c 
                                                                    WHERE acideas__Idea__c = :ideaL.Id
                                                                    AND acideas__User__c <> :ideaL.LastModifiedById
                                                                    AND acideas__User__r.IsActive = True
                                                                    ]){
                        Idea_Email_Notification__c ien = new Idea_Email_Notification__c(
                            Idea__c = ideaL.Id,
                            User__c = ideaSub.acideas__User__c,
                            Reason__c = 'Status');
                        l_ien.add(ien);                                               
                    }
                }
            }
            if (!l_ien.isEmpty()){
                insert l_ien;
            }
        }
    }
    
    set<Id> ideaIds = new set<Id>();
    for(Idea ideaL : Trigger.new){
        if (String.valueOf(ideaL.Body).containsIgnoreCase('/download/')){ // it contains at least one image
            ideaIds.add(ideaL.Id);  
        }
    }
    
    if (!ideaIds.isEmpty()){
        IdeaImageProcess.processIdeaImages(ideaIds);
    }
}