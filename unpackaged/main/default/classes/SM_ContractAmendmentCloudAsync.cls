/*******************************************************************************************************
* @Class Name   : SM_ContractAmendmentCloudAsync
* @description  : Schedulable class to asynchronously amend Cloud Service Contract in Quote Trigger context 
* @jira         : TOCB-1630/TOCB-34
* @author       : Yi Zhang
* @date         : 18/03/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              18/03/2021      1000        Initial version
******************************************************************************************************/
global class SM_ContractAmendmentCloudAsync implements Schedulable, Database.AllowsCallouts {

    private Id serviceContractId;
    private Id originalQuoteId;
    
    /**
    * @description - Constructor
    * @author Yi Zhang | 18/03/2021 
    * @param Id serviceContractId 
    * @param Id originalQuoteId 
    **/
    global SM_ContractAmendmentCloudAsync(Id contractId, Id quoteId) {
        this.serviceContractId = contractId;
        this.originalQuoteId = quoteId;
    }


    /**
    * @description - Standard execute method for schedulable class
    * @author Yi Zhang | 18/03/2021 
    * @param SchedulableContext sc 
    **/
    global void execute(SchedulableContext sc) {
        // amend contract etc.
        SM_ContractAmendment.autoAmendCloudContract(serviceContractId, originalQuoteId);

        // clean up the job
        AsyncFrameworkUtil.cleanUpOneOffJob(sc);

    }

    /**
    * @description - Schedule the job
    * @author Yi Zhang | 18/03/2021 
    * @param Id contractId 
    * @param Id originalQuoteId 
    * @param Decimal delayInMinutes 
    **/
    global static void schedule(Id contractId, Id quoteId, Decimal delayInMinutes) {
        System.schedule(
            'Auto amend cloud service contract; ' + contractId + '; ' + String.valueOf(DateTime.now()), 
            AsyncFrameworkUtil.getJobCronString(delayInMinutes), 
            new SM_ContractAmendmentCloudAsync(contractId, quoteId)
        );    
    }
}