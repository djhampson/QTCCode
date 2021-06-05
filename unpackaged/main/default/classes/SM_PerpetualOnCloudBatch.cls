/*******************************************************************************************************
* @Class Name   : SM_PerpetualOnCloudBatch
* @description  : Batch/Schedulable class for Perpectual on cloud service contract (a sibling of T1_FlipToSaaSBatch)
* @author       : Yi Zhang
* @date         : 23/02/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              23/02/2021      1000        Initial version
******************************************************************************************************/
global class SM_PerpetualOnCloudBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    
    private Id serviceContractId;
    
    global SM_PerpetualOnCloudBatch() {}
    
    global SM_PerpetualOnCloudBatch(Id serviceContractId) {
        this.serviceContractId = serviceContractId;
    }
    /***
    * @name	        : start
    * @description  : Standard start method for batch class. 
    * @author		: Yi Zhang
    * @param 		: Database.BatchableContext bc - required parameter for standard batch methods
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // find new perpetual on cloud service contract is created and not processed

        String query = 'SELECT Id, ' + 
            ' (SELECT Id, ' + 
            ' ServiceContract.StartDate, ' + 
            ' ServiceContract.EndDate, ' +
            ' ServiceContractId, ' + 
            ' SBQQSC__QuoteLine__r.SBQQSC__RenewedContractLine__r.ServiceContractId' + 
            ' FROM ContractLineItems )' + 
            ' FROM ServiceContract ' + 
            ' WHERE Perpetual_On_Cloud_Status__c = null ' + 
            ' AND SBQQSC__Quote__r.Deal_Type__c = \'' + SM_PerpetualOnCloud.PERPETUAL_ON_CLOUD + '\'';
        
        If(serviceContractId != null){
            query += ' AND Id = \''+ serviceContractId + '\'';
            // unit test
            // query += Test.isRunningTest() ? (' OR Id = \''+ serviceContractId + '\'') : '';
        }
        return Database.getQueryLocator(query);
    }

    /***
    * @name	        : execute
    * @description  : Required function for batchable context
    * @author		: Yi Zhang
    * @param 		: Database.BatchableContext bc - required parameter for standard batch methods
    * @param 		: List<sObject> scope - Batch scope
    */
    global void execute(Database.BatchableContext batchContext, List<sObject> scope){
        /**
         * Business Logic:
         *  Amend the original contract, set the start date to the start date of the perpetual on cloud contract
         *  locate the T1 product bundles in amendment quote, set the existing Service Pack quote lines to qty = 0
         *  add a new quote line with No ASM (migrated to Perpetual on Cloud) to amendment quote
         *  order and contract the amendment quote
         */
        SM_PerpetualOnCloud.amendOriginalContractsEtc((List<ServiceContract>) scope);
    }    

    /***
    * @name	        : finish
    * @description  : Required function for batchable context
    * @author		: Yi Zhang
    * @param 		: Database.BatchableContext bc - required parameter for standard batch methods
    */
    global void finish(Database.BatchableContext bc){
    }    
    
    /***
    * @name	        : execute
    * @description  : Required function for schedulable context
    * @author		: Yi Zhang
    * @param 		: SchedulableContext bc - required parameter for standard schedulable methods
    */
    global void execute(SchedulableContext SC) {
        Database.executebatch(new SM_CloneInvoiceBatch(), 1);
    }
}