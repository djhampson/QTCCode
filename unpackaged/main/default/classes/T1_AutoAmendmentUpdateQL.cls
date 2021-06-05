/*******************************************************************************************************
* Class Name      	: T1_AutoAmendmentUpdateQL
* Description		: UPDATE AMENDMENT QL AUTOMATICALLY FOR AUTO AMENDMENTS
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 2-12-2020
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon 		2-12-2020   		Initial version 
* Yi Zhang              04/03/2021          Amended codes to include logic for Flip to SaaS & Perpetual on Cloud Contracts
******************************************************************************************************/
public class T1_AutoAmendmentUpdateQL implements Schedulable {
    Set<String> QuoteIds;
    Map<Id,Increase_Rate__c> IRTypeToIRateMap;
    public T1_AutoAmendmentUpdateQL(Set<String> QuoteIds, Map<Id,Increase_Rate__c> IRTypeToIRateMap) {
        this.QuoteIds = QuoteIds;
        this.IRTypeToIRateMap = IRTypeToIRateMap;
    }
    
    public void execute(SchedulableContext sc) {
        try {
            if( Test.isRunningTest() && T1_AutoAmendmentBatchTest2.throwExceptionFlag == true){
                throw new T1_AutoAmendmentUpdateQLException();
            }
            Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();
            List<SBQQ__QuoteLine__c> QuoteLineList = Database.query('SELECT SBQQ__Quote__r.SBQQSC__MasterServiceContract__r.Initial_Period_Increase_Rate__c, SBQQ__Quote__r.SBQQSC__MasterServiceContract__r.Deal_Type__c, '+string.join(new List<String>(mfields.keySet()), ',')+' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :QuoteIds');
            // EXISTING LINES
            List<SBQQ__QuoteLine__c> UpdateOriginalLines = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c QLRec :QuoteLineList){
                System.debug(loggingLevel.ERROR, '@@ SERVICE CONTRACT DEAL TYPE ' + QLRec.SBQQ__Quote__r.SBQQSC__MasterServiceContract__r.Deal_Type__c);
                System.debug(loggingLevel.ERROR, '@@ FEE TYPE ' + QLRec.Fee_Type__c);
                System.debug(loggingLevel.ERROR, '@@ SOURCE' + QLRec.SBQQ__Source__c);
                Decimal IRatePercent = IRTypeToIRateMap.get(QLRec.SBQQ__Quote__r?.SBQQSC__MasterServiceContract__r?.Initial_Period_Increase_Rate__c).Increase_Rate__c;
                // Original Service Contract's Deal Type = 'Term' (COTB-1178)
                if(QLRec.SBQQ__Quote__r.SBQQSC__MasterServiceContract__r.Deal_Type__c == T1_ContractAmender.DT_TERM && QLRec.SBQQ__Source__c == null){
                    SBQQ__QuoteLine__c QLRecToUpdate = QLRec.No_Indexation__c == false ? new SBQQ__QuoteLine__c(Id = QLRec.Id, Auto_Amendment_Increase_Rate__c = IRatePercent, SBQQ__Quantity__c = 0) : new SBQQ__QuoteLine__c(Id = QLRec.Id, SBQQ__Quantity__c = 0);
                    UpdateOriginalLines.add(QLRecToUpdate);
                }
                // Original Service Contract's Deal type IN ('Perpetual on Cloud', 'Perpetual', 'SaaS') (COTB-1487)
                else if(T1_ContractAmender.DTS_SAAS_PERPETUAL.contains(QLRec.SBQQ__Quote__r.SBQQSC__MasterServiceContract__r.Deal_Type__c) && QLRec.SBQQ__Source__c == null) {
                    SBQQ__QuoteLine__c QLRecToUpdate = QLRec.No_Indexation__c == false ? new SBQQ__QuoteLine__c(Id = QLRec.Id, Auto_Amendment_Increase_Rate__c = IRatePercent, SBQQ__Quantity__c = 0) : new SBQQ__QuoteLine__c(Id = QLRec.Id, SBQQ__Quantity__c = 0);
                    UpdateOriginalLines.add(QLRecToUpdate);
                    
                }
            }
            If(UpdateOriginalLines.size() > 0 && !Test.isRunningTest()){
                UPDATE UpdateOriginalLines;
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
    
     class T1_AutoAmendmentUpdateQLException extends Exception{}
}