trigger ContDocLinkTrigger on ContentDocumentLink (Before insert, After insert, Before update, After update, Before Delete) {

    // bypass trigger processing START
    T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
     
    if( s.Bypass_Triggers__c) return; // skip trigger...
    // bypass trigger processing END

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ContDocLinkTriggerHandler.onBeforeInsert(Trigger.new);
        }
        //if(Trigger.isUpdate){
        //    ContDocLinkTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        //}
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ContDocLinkTriggerHandler.onAfterInsert(Trigger.new);
        }
        //if(Trigger.isUpdate){
        //    ContDocLinkTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        //}
    }
}