/**
 * @description       : 
 * @author            : Grant Hamlyn
 * @group             : 
 * @last modified on  : 10-03-2021
 * @last modified by  : Grant Hamlyn
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-03-2021   Grant Hamlyn   Initial Version
 * 1.1   10-03-2021   Grant Hamlyn   Process the oldmap as well for update
**/
trigger ContractLineItemTrigger on ContractLineItem(After insert, After update, After Delete) {

    // bypass trigger processing START
    T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
     
    if( s.Bypass_Triggers__c) return; // skip trigger...
    // bypass trigger processing END

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ContractLineItemTriggerHandler.onAfterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            ContractLineItemTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            ContractLineItemTriggerHandler.onAfterDelete(Trigger.oldMap);
        }
    }
}