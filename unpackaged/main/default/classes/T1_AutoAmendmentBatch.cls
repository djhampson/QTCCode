/*******************************************************************************************************
* Class Name      	: T1_AutoAmendmentBatch
* Description		: Batch Class for Auto Amendment - System.schedule('Auto Amendment Batch', '0 0 * * * ?', new T1_AutoAmendmentBatch());
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 2-12-2020
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	2-12-2020			Initial version 
* Yi Zhang              04/03/2021          Amended query to include contracts for Flip to SaaS & Perpetual on Cloud
******************************************************************************************************/
global class T1_AutoAmendmentBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    private Id ServiceContractId;
    global T1_AutoAmendmentBatch(){}
    global T1_AutoAmendmentBatch(Id ServiceContractId){
        This.ServiceContractId = ServiceContractId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = ' SELECT Id,Initial_Period_Increase_Rate__r.Name ' +
        ' FROM ServiceContract ' +
        ' WHERE Initial_Period_Increase_Rate__c != null ' +
        ' AND (X28_Days_before_Anniversary__c <= TODAY OR Auto_Amendment_Override_Date__c <= TODAY)' +
        ' AND Auto_Amendment_Control__c = FALSE ' +
        ' AND Initial_Period_Increase_Rate__r.Name != \'NOINCREASE\'' +
        ' AND (' +
        ' Deal_Type__c = \'Term\' ' +
        ' OR (Deal_Type__c = \'SaaS\' AND SBQQSC__Quote__r.Transaction_Type__c = \'Flip to SaaS\' AND Start_End_Date_Difference__c > 365)' +
        ' OR (Deal_Type__c IN (\'Perpetual on Cloud\') AND Start_End_Date_Difference__c > 365)' +
        ' )';
        If(ServiceContractId <> null){
            query += ' AND Id = \''+ServiceContractId+'\'';
        }
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext bc, List<ServiceContract> scope){
        System.debug(LoggingLevel.ERROR, 'SCOPE: ' + scope);
        Set<String> contractIds = new Set<String>();
        for(ServiceContract ServCont :scope){
            contractIds.add(ServCont.Id); 
        }
        System.debug(LoggingLevel.ERROR,'CONTRACT IDS ' + contractIds);
        System.debug(LoggingLevel.ERROR, 'ENTERING AUTO AMENDMENTS');
        // PROCESS RECORDS FOR AUTO AMENDMENT
        T1_ContractAmender.doAutoAmendment(contractIds);
    }
    
    global void finish(Database.BatchableContext bc){}
    
    // SCHEDULABLE JOB TO SCHEDULE THIS JOB
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new T1_AutoAmendmentBatch(),1);
    }
}