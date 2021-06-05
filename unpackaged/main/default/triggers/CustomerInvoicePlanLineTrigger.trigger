/*******************************************************************************************************
* Trigger Name     	: CustomerInvoicePlanLineTrigger
* Description		: Trigger for sobject Customer_Invoice_Plan_Line__c (following existing trigger pattern)
* @author            : Yi Zhang
* Author          	: Simplus - Yi Zhang
* Created On      	: 11/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              11/02/2021		1000				Initial version
******************************************************************************************************/
trigger CustomerInvoicePlanLineTrigger on Customer_Invoice_Plan_Line__c (before insert, after insert, before update, after update, before delete, after delete) {

    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            CustomerInvoicePlanLineTriggerHandler.doBeforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate) {
            CustomerInvoicePlanLineTriggerHandler.doBeforeUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }

    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            CustomerInvoicePlanLineTriggerHandler.doAfterInsert(Trigger.new);
        }
        if(Trigger.isUpdate) {
            CustomerInvoicePlanLineTriggerHandler.doAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }
        if(Trigger.isDelete) {
            CustomerInvoicePlanLineTriggerHandler.doafterDelete(Trigger.old);
        }
    }
}