/*******************************************************************************************************
* Class Name      	: T1_QuoteCreateOrder
* Description		: CREATE ORDER AUTOMATICALLY FOR AUTO AMENDMENTS
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 2-12-2020
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	2-12-2020		Initial version 
******************************************************************************************************/
public class T1_QuoteCreateOrder implements Schedulable {
    List<SBQQ__Quote__c> QuoteLstToUpdate;
    
    public T1_QuoteCreateOrder(List<SBQQ__Quote__c> QuoteLstToUpdate) {
        this.QuoteLstToUpdate = QuoteLstToUpdate;
    }
    
    public void execute(SchedulableContext sc) {
        try {
            
            if(Test.isRunningTest() && T1_AutoAmendmentBatchTest2.throwExceptionFlag == true){
                throw new T1_QuoteCreateOrderException();
            }
            If(QuoteLstToUpdate.size() > 0){
                // UPDATE QUOTE DATES AND CREATE ORDER
                for(SBQQ__Quote__c  QuoteRec :QuoteLstToUpdate){
                    QuoteRec.SBQQ__Ordered__c = TRUE;
                }
                If(!Test.isRunningTest()){
                    UPDATE QuoteLstToUpdate; 
                }
            }
        } catch (Exception e) {
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString()); 
            INSERT DM_ApplicationLog.createApplicationLog(e); 
        } finally {
            System.abortJob(sc.getTriggerId());
        }
    }
    class T1_QuoteCreateOrderException extends Exception{}
}