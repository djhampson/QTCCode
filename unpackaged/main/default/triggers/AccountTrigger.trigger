trigger AccountTrigger on Account (after insert, after update) {

    // bypass trigger processing START
    T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
     
    if( s.Bypass_Triggers__c) return; // skip trigger...
    // bypass trigger processing END
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            AccountTriggerHandler.onAfterInsert(Trigger.new);
        }
        /*if(Trigger.isUpdate){
            AccountTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }*/
    }

}