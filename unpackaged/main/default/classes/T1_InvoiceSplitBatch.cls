/*******************************************************************************************************
* Class Name      	: T1_InvoiceSplitBatch
* Description		: Batch/Schedulable class for Invoice Split
                      Assume this batch should run on hourly basis
                      System.schedule('Split Invoice Hourly', '0 14 * * * ?', new T1_InvoiceSplitBatch());
* Author          	: Simplus - Yi Zhang
* Created On      	: 15/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              15/02/2021		1000				Initial version
* Yi Zhang              02/03/2021		2000				Make the class Schedulable
******************************************************************************************************/
global class T1_InvoiceSplitBatch implements Database.Batchable<sObject>, Schedulable {

    /***
    * @name	        : start
    * @description  : Standard start method for batch class. 
    * @author		: Yi Zhang
    * @param 		: Database.BatchableContext bc - required parameter for standard batch methods
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, blng__Invoice__c, blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quote__c ' + 
        ' FROM blng__InvoiceLine__c ' + 
        ' WHERE Split_Flag__c = true ' + 
        ' AND Split_Done__c = false');

        // twin field also implemented: Split_Flag__c on QuoteLine, OrderProduct, InvoiceLine
        // when order/invoice generated properly, Split_Flag__c value is copied from QuoteLine to InvoiceLine
        // above query can be tweaked to check InvoiceLine's Split_Flag__c instead of associated QuoteLine's
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
        SM_SplitInvoice.splitInvoices((List<blng__InvoiceLine__c>) scope);
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
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new T1_InvoiceSplitBatch());
     }
}