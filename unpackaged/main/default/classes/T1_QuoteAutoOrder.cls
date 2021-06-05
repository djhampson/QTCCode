/*******************************************************************************************************
* Class Name      	: T1_QuoteAutoOrder
* Description		: AUTOMATICALLY UPDATE DATE VALUES ON QUPTE
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 2-12-2020
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	2-12-2020		Initial version 
******************************************************************************************************/
public class T1_QuoteAutoOrder implements Schedulable {
    Set<String> QuoteIds;
    Set<String> contractIds;
    
    public T1_QuoteAutoOrder(Set<String> QuoteIds,Set<String> contractIds) {
        this.QuoteIds = QuoteIds;
        this.contractIds = contractIds;
    }
    
    public void execute(SchedulableContext sc) {
        try {
            // UPDATE SERVICE CONTRACT NUMBER OF AUTO AMENDMENTS FIELD
            List<ServiceContract> OriginalContractsToUpdate = new List<ServiceContract>();
            // GET ALL NEW AMENDMENT QUOTES     
            List<SBQQ__Quote__c> QuoteLst = [SELECT Id,SBQQ__StartDate__c,
                                             SBQQSC__MasterServiceContract__r.No_of_Auto_Ammendments__c,
                                             SBQQSC__MasterServiceContract__c,SBQQ__Uncalculated__c,
                                             SBQQSC__MasterServiceContract__r.Initial_Period_Increase_Rate__r.Name
                                             FROM SBQQ__Quote__c 
                                             WHERE Id IN :QuoteIds];
            // GET ALL ORIGINAL CONTRACTS
            List<ServiceContract> OriginalContracts = [SELECT Id,SBQQSC__Order__r.blng__InvoiceBatch__c,StartDate,
                                                       No_of_Auto_Ammendments__c,Initial_Period_Increase_Rate__c 
                                                       FROM ServiceContract 
                                                       WHERE Id IN: contractIds];
            
            // MAP OF ORIGINAL CONTRACTS 
            Map<Id,ServiceContract> OriginalServiceContractMap = new Map<Id,ServiceContract>();
            for(ServiceContract ServCont: OriginalContracts){
                if(OriginalServiceContractMap.get(ServCont.Id) == null){
                    OriginalServiceContractMap.put(ServCont.Id,ServCont);
                }
            }
            
            // UPDATE NEW AMENDMENT QUOTES
            List<SBQQ__Quote__c> QuoteLstToUpdate = new List<SBQQ__Quote__c>();
            Set<Id> ProcessSCIdChecker = new Set<Id>();
            
            for(SBQQ__Quote__c  QuoteRec :QuoteLst){
                if(!QuoteRec.SBQQ__Uncalculated__c){
                    Integer NumRun = QuoteRec.SBQQSC__MasterServiceContract__r.No_of_Auto_Ammendments__c <> null ? (Integer) QuoteRec.SBQQSC__MasterServiceContract__r.No_of_Auto_Ammendments__c  : 0;
                    System.debug(LoggingLevel.ERROR,'NUM RUN ' + NumRun);
                    If(NumRun > 0){
                        QuoteLstToUpdate.add(quoteAmendment(QuoteRec.Id,OriginalServiceContractMap.get(QuoteRec.SBQQSC__MasterServiceContract__c).StartDate.addYears(NumRun + 1),QuoteRec.SBQQSC__MasterServiceContract__r.Initial_Period_Increase_Rate__r.Name));
                    }else{   
                        QuoteLstToUpdate.add(quoteAmendment(QuoteRec.Id,OriginalServiceContractMap.get(QuoteRec.SBQQSC__MasterServiceContract__c).StartDate.addYears(1),QuoteRec.SBQQSC__MasterServiceContract__r.Initial_Period_Increase_Rate__r.Name)); 
                    }
                    
                    // UPDATE SERVICE CONTRACT NUMBER OF AUTO AMENDMENT RUN
                    If(!ProcessSCIdChecker.contains(QuoteRec.SBQQSC__MasterServiceContract__c)){
                        OriginalContractsToUpdate.add(new ServiceContract(Id = QuoteRec.SBQQSC__MasterServiceContract__c,
                                                                          No_of_Auto_Ammendments__c = NumRun + 1,
                                                                          Auto_Amendment_Override_Date__c = null)); 
                        ProcessSCIdChecker.add(QuoteRec.SBQQSC__MasterServiceContract__c);
                    }
                }
            }
            If(!Test.isRunningTest()){
                // UPDATE ORIGINAL CONTRACT NUMBER OF AUTO AMENDMENT RUN
                If(OriginalContractsToUpdate.size() > 0){
                    UPDATE OriginalContractsToUpdate;
                }
                
                // UPDATE QUOTE DATES AND CREATE ORDER
                If(QuoteLstToUpdate.size() > 0){
                    UPDATE QuoteLstToUpdate;
                }
            }
            
            /*Integer i = 10;
            String jobName = OrderTriggerHandler.getJobName('Auto Amendment - Create Order');
            T1_QuoteCreateOrder job = new T1_QuoteCreateOrder(QuoteLstToUpdate);
            String cronString = OrderTriggerHandler.getJobCronString(i);   
            String jobId = System.schedule(jobName, cronString, job);   */         
            
            
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
    
    public static SBQQ__Quote__c quoteAmendment(Id QuoteId, Date StartDate, String IncreaseRateType){
        /*Integer randNum = 0;
        System.debug(LoggingLevel.ERROR, 'Random Number is => ' + randNum); 
        If(currentNum == null){
            randNum = Integer.valueOf((Math.random() * 10000));
        }else{
            randNum = Integer.valueOf((Math.random() * 10000));
            if(randNum == Integer.valueOf(currentNum)){
                randNum = Integer.valueOf((Math.random() * 10000));
            }
        }*/
        SBQQ__Quote__c qt = new SBQQ__Quote__c(Id = QuoteId,
                                               SBQQ__StartDate__c = StartDate,
                                               Auto_Amendment__c = TRUE,
                                               Increase_Rate_Type__c = IncreaseRateType);//,
                                               // Calculation_Trigger__c = randNum);
        return qt;
    }
}