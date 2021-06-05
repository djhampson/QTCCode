/*******************************************************************************************************
* Class Name      	: T1_FlipToSaaSAutoOrder
* Description		: CREATE ORDER AUTOMATICALLY FOR FLIP TO SAAS
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 2-17-2020
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	2-17-2020		Initial version 
******************************************************************************************************/
public class T1_FlipToSaaSAutoOrder implements Schedulable{
    Set<String> QuoteIds;
    Map<Id,Date> ContractIdsToFlipDateMap;
    public T1_FlipToSaaSAutoOrder(Set<String> QuoteIds, Map<Id,Date> ContractIdsToFlipDateMap) {
        this.QuoteIds = QuoteIds;
        this.ContractIdsToFlipDateMap = ContractIdsToFlipDateMap;
    }
    
    public void execute(SchedulableContext sc) {
        try {
            // GET ALL AMENDMENT QUOTES 
            List<SBQQ__Quote__c> QuoteLst = [SELECT Id,SBQQ__EndDate__c,SBQQSC__MasterServiceContract__c 
                                             FROM SBQQ__Quote__c 
                                             WHERE Id IN:QuoteIds];
            // UPDATE NEW AMENDMENT QUOTES
            List<SBQQ__Quote__c> QuoteLstToUpdate = new List<SBQQ__Quote__c>();
            
            for(SBQQ__Quote__c  QuoteRec :QuoteLst){
                SBQQ__Quote__c Quote = new SBQQ__Quote__c(Id = QuoteRec.Id,
                                                          SBQQ__StartDate__c = ContractIdsToFlipDateMap.get(QuoteRec.SBQQSC__MasterServiceContract__c),
                                                          Auto_Amendment__c = TRUE,
                                                          FTS_Auto_Amendment__c = TRUE); 
                QuoteLstToUpdate.add(Quote);
            }
            
            // CHECK COLLECTION AND UPDATE
            If(!QuoteLstToUpdate.IsEmpty()){
                UPDATE QuoteLstToUpdate;
            }
            
            scheduleFTSAsync( QuoteLstToUpdate);
            
        } catch (Exception e) {
            System.debug('Error: ' + e);
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());   
            INSERT DM_ApplicationLog.createApplicationLog(e); 
        } finally {     
            System.abortJob(sc.getTriggerId());
        }
    }
    
    public static void scheduleFTSAsync(List<SBQQ__Quote__c> QuoteLstToUpdate){
        Integer i = 3;
        String jobName = OrderTriggerHandler.getJobName('FTS - Create Order');
        T1_QuoteCreateOrder job = new T1_QuoteCreateOrder(QuoteLstToUpdate);
        String cronString = OrderTriggerHandler.getJobCronString(i);
        String jobId = System.schedule(jobName, cronString, job);   
    }
}