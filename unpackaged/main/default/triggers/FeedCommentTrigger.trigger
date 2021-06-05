trigger FeedCommentTrigger on FeedComment (Before insert, After insert, Before update, After update, Before Delete) {

    // bypass trigger processing START
    T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
     
    if( s.Bypass_Triggers__c) return; // skip trigger...
    // bypass trigger processing END

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            FeedCommentTriggerHandler.onBeforeInsert(Trigger.new);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            FeedCommentTriggerHandler.onAfterInsert(Trigger.new);
        }
    }
   

}