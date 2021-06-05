/*******************************************************************************************************
* Trigger Name     	: CustomerInvoicePlanTrigger
* Description		: Trigger for sobject Customer_Invoice_Plan__c (following existing trigger pattern)
* @author            : Yi Zhang
* Author          	: Simplus - Yi Zhang
* Created On      	: 11/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              11/02/2021		1000				Initial version
******************************************************************************************************/
trigger CustomerInvoicePlanTrigger on Customer_Invoice_Plan__c (before insert, after insert, before update, after update) {

    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            CustomerInvoicePlanTriggerHandler.doBeforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate) {
            CustomerInvoicePlanTriggerHandler.doBeforeUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }

    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            CustomerInvoicePlanTriggerHandler.doAfterInsert(Trigger.new);
        }
        if(Trigger.isUpdate) {
            CustomerInvoicePlanTriggerHandler.doAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }
}