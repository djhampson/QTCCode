trigger CPECRequestTrigger on CPEC_Request__c (Before insert, After insert, Before update, After update, Before Delete) {

    // bypass trigger processing START
    T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
     
    if( s.Bypass_Triggers__c) return; // skip trigger...
    // bypass trigger processing END

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            CPECRequestTriggerHandler.onBeforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            //CPECRequestTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            CPECRequestTriggerHandler.onAfterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            //CPECRequestTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}