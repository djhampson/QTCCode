/*******************************************************************************************************
* Class Name      	: T1_FlipToSaaSBatch
* Description		: Batch class for Flip to SaaS - System.schedule('FTS Auto Amendment Batch', '0 30 * * * ?', new T1_FlipToSaaSBatch());
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 2-15-2020
* -----------------------------------------------------------------------------------------------------
* Developer				Date					Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	2-15-2020				Initial version 
******************************************************************************************************/
global class T1_FlipToSaaSBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    private Id ServiceContractId;
    global T1_FlipToSaaSBatch(){}
    global T1_FlipToSaaSBatch(Id ServiceContractId){
        This.ServiceContractId = ServiceContractId;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 	'SELECT Id,(SELECT Id,ServiceContract.StartDate,ServiceContract.EndDate,Flipped_from_Asset__r.Status,' +
            ' ServiceContractId,Flipped_from_Asset__c,Flipped_from_Contract_Line__r.ServiceContractId,Product2Id,' +
            ' Flipped_from_Contract_Line__r.ServiceContract.EndDate FROM ContractLineItems )' + 
            ' FROM ServiceContract WHERE Flip_to_SaaS_Status__c = null AND SBQQSC__Quote__r.Transaction_Type__c = \'Flip to SaaS\' AND Flipped_Lines__c >0';
        
        If(ServiceContractId <> null){
            query += ' AND Id = \''+ServiceContractId+ '\'';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<ServiceContract> scope){
        try {
            // GET ALL OLD CONTRACTS TO AUTO AMEND
            Set<Id> ContractIdsToAmend = new Set<Id>();
            // OLD CONTRACT MAP TO FLIP CONTRACT DATE
            Map<Id,Date> ContractIdsToFlipDateMap = new Map<Id,Date>();
            Map<Id,Date> ContractIdsToFlipEndDateMap = new Map<Id,Date>();
            Map<Id,Set<Id>> OriginalContractToFlipAssetLines = new Map<Id,Set<Id>>();
            Set<Id> AssetIdsToCancel = new Set<Id>();
            //List<ServiceContract> PerpServCont = new List<ServiceContract>();
            Set<Id> ContractIdsToInProgress = new Set<Id>();
            for(ServiceContract ServCont:scope){
                // Id MasterServiceContractId;
                for(ContractLineItem Newlines: ServCont.ContractLineItems){
                    
                    // GET FLIP LINES
                    If(Newlines.Flipped_from_Asset__c <> null && Newlines.Flipped_from_Asset__r.Status <> 'Cancelled'){
                        AssetIdsToCancel.add(Newlines.Flipped_from_Asset__c);
                    }
                    
                    // GET PERPETUAL IDS
                    If(Newlines.Flipped_from_Contract_Line__r.ServiceContractId <> null){
                        ContractIdsToAmend.add(Newlines.Flipped_from_Contract_Line__r.ServiceContractId); 
                        ContractIdsToInProgress.add(ServCont.Id);
                    }
                    
                    // POPULATE OLD CONTRACT MAP TO FLIP CONTRACT DATE
                    if(ContractIdsToFlipDateMap.get(Newlines.Flipped_from_Contract_Line__r.ServiceContractId) == null ){
                        ContractIdsToFlipDateMap.put(Newlines.Flipped_from_Contract_Line__r.ServiceContractId,Newlines.ServiceContract.StartDate); 
                    }
                }
            }
            
            /*// UPDATE PERPETUAL START DATE BEFORE CREATING AMENDMENT RECORDS
                for(Id ContractId :ContractIdsToAmend){
                PerpServCont.add(new ServiceContract(Id = ContractId,StartDate = ContractIdsToFlipDateMap.get(ContractId)));  
                }
                
                If(!PerpServCont.IsEmpty()){
                UPDATE PerpServCont;
                }*/
            
            // CREATE AMENDMENT RECORDS
            Set<String> QuoteIds = new Set<String>(); 
            for(Id SerContractId :ContractIdsToAmend){
                QuoteModel quote = T1_ContractAmender.load(SerContractId);
                QuoteIds.add(quote.record.Id);
            }
            
            // UPDATE FLIP CONTRACTS STATUS TO IN PROGRESS
            List<ServiceContract> FlipContractsToInProgress = new List<ServiceContract>();
            for(Id ContractId:ContractIdsToInProgress){
                ServiceContract ServCont = new ServiceContract(Id = ContractId,Flip_to_SaaS_Status__c = 'In progress');  
                FlipContractsToInProgress.add(ServCont);
            }
            
            System.debug('FlipContractsToInProgress ' + FlipContractsToInProgress);
            System.debug('FlipContractsToInProgress size ' + FlipContractsToInProgress.size());
            If(!FlipContractsToInProgress.IsEmpty()){
                UPDATE FlipContractsToInProgress;
            }
            
            // GET ALL QUOTE LINE FIELDS
            Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();
            
            // GET AMENDMENT QUOTE LINES
            List<SBQQ__QuoteLine__c> QuoteLineList = Database.query('SELECT SBQQ__Product__r.Flip_to_Product__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c,SBQQ__Quote__r.SBQQSC__MasterServiceContract__r.EndDate,SBQQ__Quote__r.SBQQSC__MasterServiceContract__c, '+string.join(new List<String>(mfields.keySet()), ',')+' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :QuoteIds');
            List<SBQQ__QuoteLine__c> QuoteLineListToUpdate = new List<SBQQ__QuoteLine__c>();
            System.debug(LoggingLevel.ERROR, '@@ AssetIdsToCancel ' + AssetIdsToCancel);
            // LOOP ON ALL AMENDMENT QL
            for(SBQQ__QuoteLine__c AmendmentQL: QuoteLineList){
                If(AssetIdsToCancel <> null && AssetIdsToCancel.size() > 0){
                    System.debug(LoggingLevel.ERROR, '@@ AssetIdsToCancel ' + AssetIdsToCancel);
                    System.debug(LoggingLevel.ERROR, '@@ AssetIdsToCancel size => ' + AssetIdsToCancel.size());
                    If(AssetIdsToCancel.contains(AmendmentQL.SBQQ__UpgradedAsset__c)){
                        System.debug(LoggingLevel.ERROR, '!! CONDITION SATISFIED! ');
                        SBQQ__QuoteLine__c QL = new SBQQ__QuoteLine__c(Id = AmendmentQL.Id,
                                                                       SBQQ__Quantity__c = 0); 
                        QuoteLineListToUpdate.add(QL);
                    } 
                }
            }
            
            System.debug('QuoteLineListToUpdate ' + QuoteLineListToUpdate);
            System.debug('QuoteLineListToUpdate size ' + QuoteLineListToUpdate.size());
            // UPDATE QL QUANTITY
            If(!QuoteLineListToUpdate.IsEmpty() && !Test.isRunningTest()){
                UPDATE QuoteLineListToUpdate;
            }
            
            // ASYNC TO CREATE ORDER AND UPDATE QUOTE START DATE FOR AMENDMENT QUOTES
            Integer i = 1;
            String jobName = OrderTriggerHandler.getJobName('FTS - Update Quote Date');
            T1_FlipToSaaSAutoOrder job = new T1_FlipToSaaSAutoOrder(QuoteIds,ContractIdsToFlipDateMap);
            String cronString = OrderTriggerHandler.getJobCronString(i);  //1 minute
            String jobId = System.schedule(jobName, cronString, job); 
            
            // ASYNC TO UPDATE FLIP CONTRACTS
            Integer t = 15;
            String FlipJobName = OrderTriggerHandler.getJobName('FTS - Update Contract status');
            T1_FlipToSaaSProcessed FlipJob = new T1_FlipToSaaSProcessed(ContractIdsToInProgress);
            String FlipCronString = OrderTriggerHandler.getJobCronString(i);  //2 minute
            String FlipJobId = System.schedule(FlipJobName, FlipCronString, FlipJob);  
        } catch (Exception e) {
            INSERT DM_ApplicationLog.createApplicationLog(e); 
        }
    }
    global void finish(Database.BatchableContext bc){}
    
    // SCHEDULABLE JOB TO SCHEDULE THIS JOB
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new T1_FlipToSaaSBatch(),1);
    }
}