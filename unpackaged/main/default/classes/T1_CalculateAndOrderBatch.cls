/*******************************************************************************************************
* Class Name      	: T1_CalculateAndOrderBatch
* Description		: Batch Class for Auto Amendment - Auto Calculate and Auto creation of Order
					  System.schedule('Auto Amendment - Auto Calculate and Auto Order', '0 30 * * * ?', new T1_CalculateAndOrderBatch());
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 6-1-2021
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	6-1-2021			Initial version 
******************************************************************************************************/
global class T1_CalculateAndOrderBatch  implements Database.Batchable<sObject>, Schedulable {
    private Set<Id> QuoteIds;
    FINAL STATIC STRING AUTO_AMENDMENT_EXCEPTION = 'Auto-Amendment for Increase Exception. Maximum Calculation.';
    FINAL STATIC STRING ERR_MESSAGE = 'Maximum calculation attempts exceeded please see record:';
    
    global T1_CalculateAndOrderBatch(){}
    global T1_CalculateAndOrderBatch(Set<Id> QuoteIds){
        This.QuoteIds = QuoteIds;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = ' SELECT Id,SBQQ__Uncalculated__c,Calculate_Trigger__c ' +
            ' FROM SBQQ__Quote__c WHERE Auto_Amendment__c = TRUE AND SBQQ__Ordered__c = FALSE AND SBQQ__Primary__c = TRUE AND SBQQ__CustomerAmount__c != 0';
        If(QuoteIds <> null){
            query += ' AND Id IN: QuoteIds';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> scope){
        try {
            List<SBQQ__Quote__c> quoteToCalculate = new List<SBQQ__Quote__c>();
            
            for(SBQQ__Quote__c qt :scope){
                if(!Test.isRunningTest() && !qt.SBQQ__Uncalculated__c && Limits.getQueueableJobs() < 50){
                    System.enqueueJob(new T1_AsyncOrderCreation(qt));
                }else{
                    if(qt.Calculate_Trigger__c == null || qt.Calculate_Trigger__c <= 3){
                        Decimal attempts = qt.Calculate_Trigger__c <> null ? qt.Calculate_Trigger__c : 0; 
                        quoteToCalculate.add(new SBQQ__Quote__c(Id = qt.Id, Calculate_Trigger__c = ++attempts ,Calculation_Trigger__c = generateRandNum()));  
                    }else if(qt.Calculate_Trigger__c == 4){
                        Decimal attempts = qt.Calculate_Trigger__c <> null ? qt.Calculate_Trigger__c : 0; 
                        INSERT DM_ApplicationLog.createApplicationLog(AUTO_AMENDMENT_EXCEPTION,ERR_MESSAGE + qt.Id);  
                        quoteToCalculate.add(new SBQQ__Quote__c(Id = qt.Id, Calculate_Trigger__c = ++attempts ,Calculation_Trigger__c = generateRandNum()));  
                    }
                }
            }
            
            if(!quoteToCalculate.IsEmpty()){
                UPDATE quoteToCalculate;
            }
        } catch (Exception e) {
            INSERT DM_ApplicationLog.createApplicationLog(e); 
        } 
    } 
    
    global void finish(Database.BatchableContext bc){}
    
    /*
    *@Description: SCHEDULABLE METHOD TO SCHEDULE THIS JOB
    *@params: N/A
    *@author: Gerald A- Simplus
    */ 
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new T1_CalculateAndOrderBatch(),1);
    }
    
    /*
    *@Description: METHOD TO GENERATE RANDOM NUMBER
    *@params: N/A
    *@author: Gerald A- Simplus
    */ 
    global static Integer generateRandNum(){
        return Integer.valueOf((Math.random() * 10000));
    }
}