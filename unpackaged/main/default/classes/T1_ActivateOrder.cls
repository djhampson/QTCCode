/*******************************************************************************************************
* Class Name      	: T1_ActivateOrder
* Description		: Schedulable class for Activating Order for Auto Amendment Scenario.
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 1-14-2020
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	1-14-2020			Initial version 
* Yi Zhang              16/03/2021          Refactored logic to be reused by Auto Renewal scenario
******************************************************************************************************/
public class T1_ActivateOrder implements Schedulable {
    public Order ord;
    
    public T1_ActivateOrder(Order o) {
        this.ord = o;
    }
    
    public void execute(SchedulableContext sc) {
        try {
            // Order toUpdate = [SELECT Id,SBQQ__Quote__r.SBQQSC__MasterServiceContract__c 
            //                   FROM Order 
            //                   WHERE Id =: ord.Id];
            
            // ServiceContract ServCont = [SELECT Id,SBQQSC__Order__r.blng__InvoiceBatch__c 
            //                             FROM ServiceContract 
            //                             WHERE Id =: toUpdate.SBQQ__Quote__r.SBQQSC__MasterServiceContract__c];
            
            // System.debug('Order to update: ' + JSON.serialize(toUpdate));
            //     toUpdate.blng__InvoiceBatch__c = ServCont.SBQQSC__Order__r.blng__InvoiceBatch__c;
            //     toUpdate.Status = 'Activated';
            //     System.debug('Saving Order: ' + JSON.serialize(toUpdate));
            //     UPDATE toUpdate;

            // Refactor above codes so that it can work for Auto Renewal as well
            Order toUpdate = [
                SELECT Id
                , blng__InvoiceBatch__c
                , SBQQ__Quote__r.SBQQSC__MasterServiceContract__c 
                , SBQQ__Quote__r.SBQQSC__MasterServiceContract__r.SBQQSC__Order__r.blng__InvoiceBatch__c
                FROM Order 
                WHERE Id =: ord.Id];
            
            System.debug('Order to update: ' + JSON.serialize(toUpdate));

            // populate InvoiceBatch__c for amendment order, i.e. with:
            // - order - quote - master service contract (original contract) - order's InvoiceBatch__c
            toUpdate.blng__InvoiceBatch__c = (String.isNotBlank(toUpdate.SBQQ__Quote__r?.SBQQSC__MasterServiceContract__r?.SBQQSC__Order__r?.blng__InvoiceBatch__c)) ? toUpdate.SBQQ__Quote__r.SBQQSC__MasterServiceContract__r.SBQQSC__Order__r.blng__InvoiceBatch__c : toUpdate.blng__InvoiceBatch__c;
            // activate order
            toUpdate.Status = 'Activated';
            System.debug('Saving Order: ' + JSON.serialize(toUpdate));
            update toUpdate;
            
        } catch (Exception ex) { DM_ApplicationLog.createApplicationLog(ex);
            System.debug('Error: ' + ex);
        } finally {
            // contract order   
            Order toUpdate = new Order(Id = ord.Id,SBQQ__Contracted__c = TRUE);
            update toUpdate;
            OrderTriggerHandler.abortPreviousJobs(ord.Id);
        }
    }
}