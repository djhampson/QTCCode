/*******************************************************************************************************
* Class Name      	: InvoiceTriggerHandler
* Description		: Trigger handler for sobject blng__Invoice__c
* Author          	: Simplus - Yi Zhang
* Created On      	: 22/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              22/02/2021		1000				Initial version
******************************************************************************************************/
public class InvoiceTriggerHandler {
    
    public static void doAfterInsert(List<blng__Invoice__c> invoices) {
        // clone invoices
        SM_CloneInvoice.cloneBillNowInvoices(invoices);
    }

    public static void doAfterUpdate(Map<Id, blng__Invoice__c> oldMap, Map<Id,blng__Invoice__c> newMap) {
        syncFieldsToT1Invoices(oldMap, newMap);
    }

    /**
    * @description 
    * @jira TOCB-1679: Apex code: update T1 Invoice with invoice changes
    * @author Yi Zhang | 24/03/2021 
    * @param Map<Id blng__Invoice__c> oldMap 
    * @param Map<Id blng__Invoice__c> newMap 
    **/
    public static void syncFieldsToT1Invoices(Map<Id, blng__Invoice__c> oldMap, Map<Id,blng__Invoice__c> newMap) {
        // find invoices which are:
        // (invoice ready to sync is updated OR
        // invoice due date is updated OR
        // invoice status is updated)
        // AND invoice status previous value = draft
        Map<Id, blng__Invoice__c> updatedInvoices = new Map<Id, blng__Invoice__c>();
        for(blng__Invoice__c oldInvoice : oldMap.values()) {
            blng__Invoice__c newInvoice = newMap.get(oldInvoice.Id);
            if((oldInvoice.Ready_to_sync__c != newInvoice.Ready_to_sync__c || oldInvoice.blng__DueDate__c != newInvoice.blng__DueDate__c || oldInvoice.blng__InvoiceStatus__c != newInvoice.blng__InvoiceStatus__c) && oldInvoice.blng__InvoiceStatus__c == 'Draft') {
                updatedInvoices.put(newInvoice.Id, newInvoice);
            }
        }
        if(updatedInvoices.isEmpty()) return;

        // find associated T1 invoices status previous value != posted
        // traverse via Invoice - Invoice Line - Order - T1 Invoice
        // find Invoice - Order map first
        Map<Id, blng__Invoice__c> orderIdInvoiceMap = new Map<Id, blng__Invoice__c>();
        for(blng__InvoiceLine__c line : [SELECT Id, blng__Invoice__c, blng__OrderProduct__r.OrderId FROM blng__InvoiceLine__c WHERE blng__Invoice__c IN :updatedInvoices.KeySet()]) {
            if(String.isNotBlank(line.blng__OrderProduct__r?.OrderId) && orderIdInvoiceMap.containsKey(line.blng__OrderProduct__r.OrderId) == false) {
                orderIdInvoiceMap.put(line.blng__OrderProduct__r.OrderId, updatedInvoices.get(line.blng__Invoice__c));
            }
        }
        if(orderIdInvoiceMap.isEmpty()) return;

        // find T1 invoices which aren't Posted
        List<T1_Invoice__c> t1InvoicesToUpdate = new List<T1_Invoice__c>();
        for(T1_Invoice__c t1Invoice : [SELECT Id, Order__c FROM T1_Invoice__c WHERE Order__c IN :orderIdInvoiceMap.KeySet() AND InvoiceStatus__c != 'Posted']) {
            t1Invoice.Ready_to_sync__c = orderIdInvoiceMap.get(t1Invoice.Order__c).Ready_to_sync__c;
            t1Invoice.DueDate__c = orderIdInvoiceMap.get(t1Invoice.Order__c).blng__DueDate__c;
            t1Invoice.InvoiceStatus__c = orderIdInvoiceMap.get(t1Invoice.Order__c).blng__InvoiceStatus__c;
            t1InvoicesToUpdate.add(t1Invoice);
        }

        if(t1InvoicesToUpdate.size() > 0) {
            update t1InvoicesToUpdate;
        }
    }
}