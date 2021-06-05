trigger IdeaCommentAfter on IdeaComment (After insert, After update) {
    // Grant Hamlyn 28/01/2020 Only process Active User Subscribers - Expand select statement
    
    // bypass trigger processing START
    T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
     
    if( s.Bypass_Triggers__c) return; // skip trigger...
    // bypass trigger processing END

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            List<Idea_Email_Notification__c> l_ien = new List<Idea_Email_Notification__c>();
            for(IdeaComment ideaL : Trigger.new){
                for(acideas__brIdeaSubscription__c ideaSub : [SELECT acideas__User__c 
                                                                FROM acideas__brIdeaSubscription__c 
                                                                WHERE acideas__Idea__c = :ideaL.IdeaId
                                                             	AND acideas__User__c <> :ideaL.CreatedById
                                                                AND acideas__User__r.IsActive = True]){
                    Idea_Email_Notification__c ien = new Idea_Email_Notification__c(
                    	Idea__c = ideaL.IdeaId,
                    	User__c = ideaSub.acideas__User__c,
                		Reason__c = 'Comment');
                	l_ien.add(ien);                                               
                }
            }
            if (!l_ien.isEmpty()){
                insert l_ien;
            }
        }
    }
    
    
    set<Id> ideaCommentIds = new set<Id>();
    for(IdeaComment ideaL : Trigger.new){
        if (String.valueOf(ideaL.CommentBody).containsIgnoreCase('/download/')){ // it contains at least one image
            ideaCommentIds.add(ideaL.Id);  
        }
    }
    
    if (!ideaCommentIds.isEmpty()){
        IdeaImageProcess.processIdeaCommentImages(ideaCommentIds);
    }
}