trigger Jira_Dev_Issue_Trigger on Jira_Dev_Issue__c (Before insert, After insert, Before update, After update, Before Delete, After delete) {

    // bypass trigger processing START
    T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
     
    if( s.Bypass_Triggers__c) return; // skip trigger...
    // bypass trigger processing END  

    if(Trigger.isBefore){
        if(Trigger.isInsert){
           // Jira_Dev_IssueTriggerHandler.onBeforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            //Jira_Dev_IssueTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            //Jira_Dev_IssueTriggerHandler.onBeforeDelete(Trigger.new, Trigger.oldMap);
        }
   }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            Jira_Dev_IssueTriggerHandler.onAfterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            Jira_Dev_IssueTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            Jira_Dev_IssueTriggerHandler.onAfterDelete(Trigger.old);
        }
    }

}