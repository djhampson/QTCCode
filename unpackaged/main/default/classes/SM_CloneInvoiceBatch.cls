/*******************************************************************************************************
* @Class Name   : SM_CloneInvoiceBatch
* @description  : Batchable & Schedulable class to clone invoices from blng__Invoice__c to T1_Invoice__c (& lines)
                  To invoke the class to run every hour, run below command in Anonymous Window:
                  System.schedule('Clone Invoice Hourly', '0 3 * * * ?', new SM_CloneInvoiceBatch());

* @author       : Yi Zhang
* @date         : 22/02/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              22/02/2021      1000        Initial version
******************************************************************************************************/
global class SM_CloneInvoiceBatch implements Database.Batchable<sObject>, Schedulable {

    /***
    * @name	        : start
    * @description  : Standard start method for batch class. 
    * @author		: Yi Zhang
    * @param 		: Database.BatchableContext bc - required parameter for standard batch methods
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // In batch context, only clone invoices which are:
        // - order is null (meaning it came from billing scheduler)
        // - clone flag is false
        return Database.getQueryLocator('SELECT Id FROM blng__Invoice__c WHERE blng__Order__c = null AND Cloned_To_T1_Invoice__c = false');
    }

    /***
    * @name	        : execute
    * @description  : 
    * @author		: Yi Zhang
    * @param 		: Database.BatchableContext bc - required parameter for standard batch methods
    * @param 		: List<sObject> scope - Batch scope
    */
    global void execute(Database.BatchableContext batchContext, List<sObject> scope){
        //execute block
        SM_CloneInvoice.cloneInvoicesAndLines((List<blng__Invoice__c>) scope);


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
        Database.executebatch(new SM_CloneInvoiceBatch());
    }
}