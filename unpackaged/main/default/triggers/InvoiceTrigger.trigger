/*******************************************************************************************************
* Trigger Name     	: InvoiceTrigger
* Description		: Trigger for sobject blng__Invoice__c
* Author          	: Simplus
* Created On      	: 07/12/2020
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         07/12/2020		1000				Initial version
* Yi Zhang              22/02/2021		2000				Added after insert context and codes
* Yi Zhang              24/03/2021		3000				Added after update context and codes
******************************************************************************************************/
trigger InvoiceTrigger on blng__Invoice__c (after insert, after update) {

    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            InvoiceTriggerHandler.doAfterInsert(Trigger.new);
        }
        if(Trigger.isUpdate) {
            InvoiceTriggerHandler.doAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }
}