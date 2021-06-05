/*******************************************************************************************************
* Trigger Name      : QuoteTrigger
* Description       : Trigger for sobject SBQQ__Quote__c
* Author            : Simplus - Gerald Arzadon
* Created On        : 24/01/2021
* Modification Log  :
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Modification ID     Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon        24/01/2021      1000                Initial version
* Yi Zhang              19/03/2021      2000                Added handler for after insert
******************************************************************************************************/
trigger QuoteTrigger on SBQQ__Quote__c (before update, after insert) {
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            if(QuoteTriggerHandler.runOnce()){
                QuoteTriggerHandler.doBeforeUpdate(Trigger.newMap);
                QuoteTriggerHandler.asyncCreateOrders(Trigger.oldMap,Trigger.new);
            }
        }
    }
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            QuoteTriggerHandler.doAfterInsert(Trigger.new);
        }
    }
}