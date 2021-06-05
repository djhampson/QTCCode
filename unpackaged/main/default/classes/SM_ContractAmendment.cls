/*******************************************************************************************************
* @Class Name   : SM_ContractAmendment
* @description  : Service layer for Contract Amendment, methods are to be called in different context
                  e.g. async scheduleable, batchable
* @author       : Yi Zhang
* @date         : 18/03/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              18/03/2021      1000        Initial version
******************************************************************************************************/
public class SM_ContractAmendment {
    
    /**
    * @description  : Amend service contract and populate 'Twin Quote' field on amendment quote and original quote
    * @jira         : TOCB-1630/TOCB-34
    * @author       : Yi Zhang | 18/03/2021 
    * @param Id serviceContractId
    * @param Id originalQuoteId 
    **/
    @future(callout=true)
    public static void autoAmendCloudContract(Id serviceContractId, Id originalQuoteId) {

        // use CPQ API to amend the service contract
        QuoteModel amendmentQuote = T1_ContractAmender.load(serviceContractId);

        // update 'Twin Quote' field on amendment quote & original quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        quotes.add(new SBQQ__Quote__c(Id = originalQuoteId, Twin_Quote__c = amendmentQuote.record.Id));
        quotes.add(new SBQQ__Quote__c(Id = amendmentQuote.record.Id, Twin_Quote__c = originalQuoteId));

        try {
            if(Test.isRunningTest() && SM_ContractAmendmentCloudAsyncTest.throwExceptionFlag == true){
                throw new SM_ContractAmendmentException();
            }
            update quotes;
        } catch(Exception e) {
            System.debug('Failed to amend service contract and populate Twin Quote field due to: ' + e.getMessage());
            insert DM_ApplicationLog.createApplicationLog(e);
        }
    }
    
    class SM_ContractAmendmentException extends Exception{}
}