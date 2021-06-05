/*******************************************************************************************************
* @Class Name   : T1_RenewalServiceBatchSchedulable
* @description  : Schedulable to start RenewalServiceContractsBatch & OrderAndContractOpportunityBatch
                  Assume this batch should run on hourly basis
                  System.schedule('Auto Renewal Hourly', '0 24 * * * ?', new T1_RenewalServiceBatchSchedulable());
* @author       : Carlos Roy Billones
* @date         : 09/03/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Carlos Roy Billones   09/03/2021      1000        Initial version
* Yi Zhang              12/03/2021      2000        Applied comments
* Yi Zhang              15/03/2021      2001        Merge with Scheduler_Class
* Yi Zhang              16/03/2021      2002        Changed batch size to 1 to avoid violating governor limit
******************************************************************************************************/
global class T1_RenewalServiceBatchSchedulable implements Schedulable {

    /***
    * @name	        : execute
    * @description  : Required function for schedulable context
    * @author       : Carlos Roy Billones
    * @param        : SchedulableContext bc - required parameter for standard schedulable methods
    */    
    global void execute(SchedulableContext sc)
    {
        // renew service contracts
        // batch size is set to 1, if to be increased, please test thoroughly
        Database.executebatch(new RenewalServiceContractsBatch(),1);

        // order & contract renewal quotes (which are generated from batch above)
        // batch size is set to 1, if to be increased, please test thoroughly
        Database.executeBatch(new OrderAndContractOpportunityBatch(),1);
    }
   
}