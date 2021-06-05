/*******************************************************************************************************
* Class Name      	: T1_AutoAmendmentLevel4QL
* Description		: 
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    				Initial version 
* Yi Zhang              04/03/2021          Amended codes to include logic for Flip to SaaS & Perpetual on Cloud Contracts
******************************************************************************************************/
public class T1_AutoAmendmentLevelQL implements Schedulable {
    Set<String> QuoteIds;
    Set<Id> LevelQLIds;
    Map<Id,ServiceContract> ServiceContractMap;
    Map<Id,Increase_Rate__c> IRTypeToIRateMap;
    public T1_AutoAmendmentLevelQL(Set<String> QuoteIds,Set<Id> LevelQLIds,Map<Id,ServiceContract> ServiceContractMap,Map<Id,Increase_Rate__c> IRTypeToIRateMap) {
        this.QuoteIds = QuoteIds;
        this.LevelQLIds = LevelQLIds;
        this.ServiceContractMap = ServiceContractMap;
        this.IRTypeToIRateMap = IRTypeToIRateMap;
    }
    public void execute(SchedulableContext sc) {
        
        
        List<SBQQ__QuoteLine__c> ClonedQuoteLineListToUpdate = new List<SBQQ__QuoteLine__c>();
        Map<Id,Id> OriginalIdToClonedId = new Map<Id,Id>();
        try {
            if(Test.isRunningTest() && T1_AutoAmendmentBatchTest2.throwExceptionFlag == true){
                throw new T1_AutoAmendmentLevelQLException();
            }
            
            Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();
            List<SBQQ__QuoteLine__c> QuoteLineList = Database.query('SELECT SBQQ__Quote__r.SBQQSC__MasterServiceContract__c, '+string.join(new List<String>(mfields.keySet()), ',')+' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :QuoteIds');
            // POPULATE MAP
            
            for(SBQQ__QuoteLine__c QLRec :QuoteLineList){
                If(QLRec.SBQQ__Source__c <> null){
                    If(OriginalIdToClonedId.get(QLRec.SBQQ__Source__c) == null){
                        OriginalIdToClonedId.put(QLRec.SBQQ__Source__c,QLRec.Id);
                    } 
                }
            }
            
            ClonedQuoteLineListToUpdate.addAll(T1_ContractAmender.createDependentLines(OriginalIdToClonedId,LevelQLIds,mfields,ServiceContractMap,QuoteLineList,IRTypeToIRateMap));
            
            If(ClonedQuoteLineListToUpdate.size() > 0 && !Test.isRunningTest()){
                INSERT ClonedQuoteLineListToUpdate;  
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
    
    class T1_AutoAmendmentLevelQLException extends Exception{}
}