trigger CS_FeedItemTrigger on FeedItem (Before insert, After insert, Before update, After update, Before Delete) {

    // bypass trigger processing START
    T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
     
    if( s.Bypass_Triggers__c) return; // skip trigger...
    // bypass trigger processing END

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            CSFeedItemTriggerHandler.onAfterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            CSFeedItemTriggerHandler.onAfterUpdate(Trigger.new);
        }
    }
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            CSFeedItemTriggerHandler.onBeforeInsert(Trigger.new);
        }
    }
}