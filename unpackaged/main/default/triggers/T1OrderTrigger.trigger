/**
 * @description       : T1 Order Trigger
 * @author            : Alfredo Edo
 * @group             : 
 * @last modified on  : 13-04-2021
 * @last modified by  : Alfredo Edo
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   13-04-2021   Alfredo Edo              Initial Version
**/
trigger T1OrderTrigger on Order (After Insert) {
  // bypass trigger processing START
    T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
     
    if( s.Bypass_Triggers__c) return; // skip trigger...
    // bypass trigger processing END
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            T1OrderTriggerHandler.onAfterInsert(Trigger.new);
        }       
    }        
}