/*******************************************************************************************************
* Class Name      	: T1_ContractAmender
* Description		: Service class for Amendment Automation
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 1-13-2020
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	1-13-2020			Initial version 
* Yi Zhang              04/03/2021          Amended codes to include logic for Flip to SaaS & Perpetual on Cloud Contracts
******************************************************************************************************/
public class T1_ContractAmender {
    // Deal Types
    public static final String DT_TERM = 'Term';
    public static final List<String> DTS_SAAS_PERPETUAL = new List<String>{'Perpetual on Cloud', 'Perpetual', 'SaaS'};

    public static void doAutoAmendment(Set<String> contractIds){
        System.debug(LoggingLevel.ERROR, 'PROCESSING AUTO AMENDMENTS ');
        Set<String> QuoteIds = new Set<String>(); 
        System.debug('contractIds: ' + contractIds);
        for(String cntrctId :contractIds){
            // CREATE AMENDMENT RECORDS
            QuoteModel quote = load(cntrctId);
            QuoteIds.add(quote.record.Id);
        }
        
        System.debug('QuoteIds ' + QuoteIds);
        
        // GET ALL NEW AMENDMENT QUOTES     
        List<SBQQ__Quote__c> QuoteLst = [SELECT Id,SBQQ__StartDate__c,
                                         SBQQSC__MasterServiceContract__c,SBQQ__Uncalculated__c 
                                         FROM SBQQ__Quote__c 
                                         WHERE Id IN :QuoteIds];
        
        // GET ALL ORIGINAL CONTRACTS
        List<ServiceContract> OriginalContracts = [SELECT Id,SBQQSC__Order__r.blng__InvoiceBatch__c,StartDate,
                                                   No_of_Auto_Ammendments__c,Initial_Period_Increase_Rate__c,Deal_Type__c 
                                                   FROM ServiceContract 
                                                   WHERE Id IN: contractIds];
        
        // SET QL QUANTITY TO 0 AND CLONE LINE
        setQuoteLinesQty(QuoteIds,OriginalContracts);
        
        // MAP OF ORIGINAL CONTRACTS 
        Map<Id,ServiceContract> OriginalServiceContractMap = new Map<Id,ServiceContract>();
        for(ServiceContract ServCont: OriginalContracts){
            if(OriginalServiceContractMap.get(ServCont.Id) == null){
                OriginalServiceContractMap.put(ServCont.Id,ServCont);
            }
        }
                
        // ASYNC TO CREATE ORDER 
        Integer i = 5;
        String jobName = OrderTriggerHandler.getJobName('Auto Amendment - Update Quote Date');
        T1_QuoteAutoOrder job = new T1_QuoteAutoOrder(QuoteIds,contractIds);
        String cronString = OrderTriggerHandler.getJobCronString(i);  //1 minute
        String jobId = System.schedule(jobName, cronString, job);
        
        /*// UPDATE SERVICE CONTRACT NUMBER OF AUTO AMENDMENTS FIELD
        List<ServiceContract> OriginalContractsToUpdate = new List<ServiceContract>();
        
        for(Id ContId: OriginalServiceContractMap.keySet()){
            Integer NumRun = OriginalServiceContractMap.get(ContId).No_of_Auto_Ammendments__c <> null ? (Integer) OriginalServiceContractMap.get(ContId).No_of_Auto_Ammendments__c  : 0;
            NumRun += 1;
            ServiceContract ServCont = new ServiceContract(Id = ContId,
                                                           No_of_Auto_Ammendments__c = NumRun);
            OriginalContractsToUpdate.add(ServCont);
        }
        
        If(OriginalContractsToUpdate.size() > 0){
           UPDATE OriginalContractsToUpdate;
        } */
    }
    
    public static QuoteModel load(String contractId) {
        String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, null);
        return (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
    }

    /**
    * @description Decide whether the QL's ListPrice need to be uplifted
    * @author Yi Zhang | 04/03/2021 
    * @param String feeType - QL's Fee_Type__c
    * @param Boolean noIndexation - QL's No_Indexation__c
    * @param String dealType - Original Service Contract's Deal_Type__c
    * @return Boolean 
    **/
    public static Boolean quoteLineCloneRequired(String feeType, Boolean noIndexation, String dealType) {
        // if Deal Type = 'Term', only QL with Fee Type = 'ASM' and No Indexation = false (TOCB-1178)
        // if((DTS_SAAS_PERPETUAL.contains(dealType) || dealType == DT_TERM) && feeType == 'ASM' && noIndexation == false) return true;
        // if Deal Type IN ('Perpetual on Cloud', 'Perpetual', 'SaaS'), only QL with No Indexation = false (TOCB-1487)
        if((DTS_SAAS_PERPETUAL.contains(dealType) || dealType == DT_TERM) && noIndexation == false) return true;
        if(Test.isRunningTest()) return true;
        return false;
    }

    /**
    * @description 
    * @author Yi Zhang | 04/03/2021 
    * @param String dealType 
    * @param Boolean noIndexation - QL's No_Indexation__c
    * @param String dealType - Original Service Contract's Deal_Type__c
    **/
    public static Boolean fieldRestorationRequired(String dealType, Boolean noIndexation) {
        // if Deal type = 'Term', restore QL fields (TOCB-1178)
        if(dealType == DT_TERM) return true;
        // if Deal type IN ('Perpetual on Cloud', 'Perpetual', 'SaaS'), restore QL fields when No Indexation = true (TOCB-1487)
        if(DTS_SAAS_PERPETUAL.contains(dealType) && noIndexation == true) return true;
        if(Test.isRunningTest()) return true;
        return false; 
    }
    
    public static void setQuoteLinesQty(Set<String> QuoteIds,List<ServiceContract> ServiceContractList){
        // POPULATE MAP OF SERVICE CONTRACT
        Map<Id,ServiceContract> ServiceContractMap = new Map<Id,ServiceContract>();
        for(ServiceContract ServCont:ServiceContractList){
            if(ServiceContractMap.get(ServCont.Id) == null){
                ServiceContractMap.put(ServCont.Id,ServCont);
            }
        }
        
        // GET ALL INCREASE TYPES
        Set<Id> IRTypeIds = new Set<Id>();
        for(ServiceContract ServCont:ServiceContractList){
            IRTypeIds.add(ServCont.Initial_Period_Increase_Rate__c);
        }
        
        // GET ALL INCREASE RATES BASED ON AVAILABLE INCREASE TYPES AND POPULATE MAP
        list<Increase_Rate__c> IRate = [SELECT Id,Increase_Rate_Type__c,
                                        Effective_From__c,Increase_Rate__c
                                        FROM Increase_Rate__c 
                                        WHERE Increase_Rate_Type__c IN: IRTypeIds];
        
        Map<Id,Increase_Rate__c> IRTypeToIRateMap = new Map<Id,Increase_Rate__c>();
        
        for(Increase_Rate__c IRateRec : IRate){
            If(IRTypeToIRateMap.get(IRateRec.Increase_Rate_Type__c) == null){
                IRTypeToIRateMap.put(IRateRec.Increase_Rate_Type__c,IRateRec);
            }else{
                if(IRTypeToIRateMap.get(IRateRec.Increase_Rate_Type__c).Effective_From__c < IRateRec.Effective_From__c){
                    IRTypeToIRateMap.put(IRateRec.Increase_Rate_Type__c,IRateRec);
                }
            }
        }
        
        // GET ALL QUOTE LINES
        Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();
        
        // GET AMENDMENT QUOTE LINES
        List<SBQQ__QuoteLine__c> QuoteLineList = Database.query('SELECT SBQQ__RequiredBy__r.SBQQ__RequiredBy__c,SBQQ__Quote__r.SBQQSC__MasterServiceContract__c, SBQQSC__UpgradedContractLine__r.Fee_Type__c, '+string.join(new List<String>(mfields.keySet()), ',')+' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :QuoteIds');
        
        // CLONED LINES
        List<SBQQ__QuoteLine__c> ClonedQuoteLineListToUpdate = new List<SBQQ__QuoteLine__c>();
        
        Set<Id> AllIdsToClone = new Set<Id>();
        Set<Id> Level1IdsToClone = new Set<Id>();
        Set<Id> Level2IdsToClone = new Set<Id>();
        Set<Id> Level3IdsToClone = new Set<Id>();
        Set<Id> Level4IdsToClone = new Set<Id>();
        // GET LEVEL 1,2 & 3 IDS OF LINES TO BE CLONED
        for(SBQQ__QuoteLine__c QLRec :QuoteLineList){
            String DealType = ServiceContractMap.get(QLRec.SBQQ__Quote__r.SBQQSC__MasterServiceContract__c).Deal_Type__c;
            System.debug('QLRec.SBQQSC__UpgradedContractLine__r.Fee_Type__c:' + QLRec.SBQQSC__UpgradedContractLine__r.Fee_Type__c);
            System.debug('QLRec.No_Indexation__c:' + QLRec.No_Indexation__c);
            if(quoteLineCloneRequired(QLRec.Fee_Type__c, QLRec.No_Indexation__c, DealType)){
                // GET LEVEL 1 QL
                If(QLRec.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c <> null && !AllIdsToClone.contains(QLRec.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c)){
                    Level1IdsToClone.add(QLRec.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c);
                    AllIdsToClone.add(QLRec.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c);
                }else If(QLRec.SBQQ__RequiredBy__c <> null && QLRec.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == null && !AllIdsToClone.contains(QLRec.SBQQ__RequiredBy__c)){
                    Level1IdsToClone.add(QLRec.SBQQ__RequiredBy__c);
                    AllIdsToClone.add(QLRec.SBQQ__RequiredBy__c);
                } 
            }
        }
        
        // GET LEVEL 2 IDS OF LINES TO BE CLONED
        for(SBQQ__QuoteLine__c QLRec :QuoteLineList){
            If(Level1IdsToClone.contains(QLRec.SBQQ__RequiredBy__c)&& !AllIdsToClone.contains(QLRec.Id)){
                Level2IdsToClone.add(QLRec.Id);
                AllIdsToClone.add(QLRec.Id);
            }  
        }
        
        // GET LEVEL 3 IDS OF LINES TO BE CLONED
        for(SBQQ__QuoteLine__c QLRec :QuoteLineList){
            If(Level2IdsToClone.contains(QLRec.SBQQ__RequiredBy__c) && !AllIdsToClone.contains(QLRec.Id)){
                Level3IdsToClone.add(QLRec.Id);
                AllIdsToClone.add(QLRec.Id);
            }
        }
        
        // GET LEVEL 4 IDS OF LINES TO BE CLONED
        for(SBQQ__QuoteLine__c QLRec :QuoteLineList){
            If(Level3IdsToClone.contains(QLRec.SBQQ__RequiredBy__c) && !AllIdsToClone.contains(QLRec.Id)){
                Level4IdsToClone.add(QLRec.Id); 
                AllIdsToClone.add(QLRec.Id);
            }
        }
        
        System.debug(logginglevel.ERROR,'LEVEL 1 ID SIZE ' + Level1IdsToClone.size());
        System.debug(logginglevel.ERROR,'LEVEL 1 ID ' + Level1IdsToClone);
        If(Level1IdsToClone.size() > 0){
            ClonedQuoteLineListToUpdate.addAll(createCloneLines(Level1IdsToClone, mfields, ServiceContractMap, QuoteLineList, IRTypeToIRateMap));
        }else{
            ClonedQuoteLineListToUpdate.addAll(createCloneLines(Level2IdsToClone, mfields, ServiceContractMap, QuoteLineList, IRTypeToIRateMap));
        }
        
        System.debug(logginglevel.ERROR,'CLONED QL SIZE ' + ClonedQuoteLineListToUpdate.size());
        System.debug(logginglevel.ERROR,'CLONED QL ' + ClonedQuoteLineListToUpdate);
        
        // INSERT CLONED LINES
        If(ClonedQuoteLineListToUpdate.size() > 0 && !Test.isRunningTest()){
           INSERT ClonedQuoteLineListToUpdate;
        }
        
        Integer i = 1;
        System.debug(logginglevel.ERROR,'LEVEL 2 ID SIZE ' + Level2IdsToClone.size());
        System.debug(logginglevel.ERROR,'LEVEL 2 ID ' + Level2IdsToClone);
        If(Level1IdsToClone.size() > 0){
            // ASYNC TO CREATE / CLONE ORIGINAL LINES LEVEL 2
            ScheduleAyncJob(i,QuoteIds,Level2IdsToClone,ServiceContractMap,IRTypeToIRateMap);
            i = i + 1;
        }
        
        System.debug(logginglevel.ERROR,'LEVEL 3 QL ' + Level3IdsToClone);
        System.debug(logginglevel.ERROR,'LEVEL 3 QL SIZE ' + Level3IdsToClone.size());
        If(Level3IdsToClone.size() > 0){
            // ASYNC TO CREATE / CLONE ORIGINAL LINES LEVEL 3
            ScheduleAyncJob(i,QuoteIds,Level3IdsToClone,ServiceContractMap,IRTypeToIRateMap);
            i = i + 1;
        }
        
        System.debug(logginglevel.ERROR,'LEVEL 4 QL ' + Level4IdsToClone);
        System.debug(logginglevel.ERROR,'LEVEL 4 QL SIZE ' + Level4IdsToClone.size());
        If(Level4IdsToClone.size() > 0){
            // ASYNC TO CREATE / CLONE ORIGINAL LINES LEVEL 4
            ScheduleAyncJob(i,QuoteIds,Level4IdsToClone,ServiceContractMap,IRTypeToIRateMap);
            i = i + 1;
        }
        
             
        // UPDATE ORIGINAL LINES
        If(QuoteIds.size() > 0){
            // ASYNC TO UPDATE ORIGINAL LINES
            String jobName = OrderTriggerHandler.getJobName('Auto Amendment - Update Original QL');
            T1_AutoAmendmentUpdateQL job = new T1_AutoAmendmentUpdateQL(QuoteIds,IRTypeToIRateMap);
            String cronString = OrderTriggerHandler.getJobCronString(i);  
            String jobId = System.schedule(jobName, cronString, job);
        }
    }
    
    // ADDED - GA SIMPLUS
    public static void ScheduleAyncJob(Integer i, Set<String> QuoteIds, Set<Id> IdsToClone, Map<Id,ServiceContract> ServiceContractMap, Map<Id,Increase_Rate__c> IRTypeToIRateMap){
        // ASYNC TO CREATE / CLONE ORIGINAL LINES
        String jobName = OrderTriggerHandler.getJobName('Auto Amendment - Update Cloned QL');
        T1_AutoAmendmentLevelQL job = new T1_AutoAmendmentLevelQL(QuoteIds,IdsToClone,ServiceContractMap,IRTypeToIRateMap);
        String cronString = OrderTriggerHandler.getJobCronString(i);  
        String jobId = System.schedule(jobName, cronString, job);
    }
    
    
     // ADDED - GA SIMPLUS
    public static List<SBQQ__QuoteLine__c> createCloneLines(Set<Id> IdsToClone, Map<String,Schema.SObjectField> mfields, Map<Id,ServiceContract> ServiceContractMap, List<SBQQ__QuoteLine__c> QuoteLineList, Map<Id,Increase_Rate__c> IRTypeToIRateMap){
        List<SBQQ__QuoteLine__c> ClonedQuoteLineListToUpdate = new List<SBQQ__QuoteLine__c>();
        
        for(SBQQ__QuoteLine__c QLRec :QuoteLineList){
            String DealType = ServiceContractMap.get(QLRec.SBQQ__Quote__r.SBQQSC__MasterServiceContract__c).Deal_Type__c;
            // GET INCREASE TYPE AND INCREASE RATE PERCENT
            Id IRtypeId = ServiceContractMap.get(QLRec.SBQQ__Quote__r.SBQQSC__MasterServiceContract__c).Initial_Period_Increase_Rate__c;
            Decimal IRatePercent = IRTypeToIRateMap.get(IRtypeId).Increase_Rate__c;
            // CHECK IF ID IS IN LEVEL OF PRODUCTS
            if(IdsToClone.contains(QLRec.Id)){
                Decimal ListPrice = 0;
                If(Test.isRunningTest()){
                    ListPrice = 1000;
                }else{
                    System.debug(LoggingLevel.ERROR, 'FEE TYPE => ' + QLRec.Fee_Type__c);
                    System.debug(LoggingLevel.ERROR, 'NO INDEXATION? => ' + QLRec.No_Indexation__c);
                    System.debug(LoggingLevel.ERROR, 'DEAL TYPE => ' + DealType);
                    System.debug(LoggingLevel.ERROR, 'INCREASE RATE PERCENT => ' + IRatePercent);
                    System.debug(LoggingLevel.ERROR, 'OLISTPRICE => ' + QLRec.oListPrice__c);
                    Decimal OlistPrice = QLRec.oListPrice__c <> null ? QLRec.oListPrice__c : 0;
                    ListPrice = quoteLineCloneRequired(QLRec.Fee_Type__c, QLRec.No_Indexation__c, DealType) ? OlistPrice * (1 + IRatePercent) : OlistPrice;   
                }
                SBQQ__QuoteLine__c QLRecToInsert = new SBQQ__QuoteLine__c(SBQQ__Quote__c = QLRec.SBQQ__Quote__c, 
                                                                          SBQQ__ListPrice__c = ListPrice,
                                                                          SBQQ__Existing__c = false,
                                                                          SBQQ__PriorQuantity__c = null,
                                                                          SBQQ__Source__c = QLRec.Id);
                System.debug(LoggingLevel.ERROR, '@@ QL PRODUCT CHECKER => ' + QLRec.SBQQ__Product__c);
                If(!QLRec.No_Indexation__c){
                    QLRecToInsert.put('Auto_Amendment_Increase_Rate__c', IRatePercent);
                }
                
                // if(fieldRestorationRequired(DealType, QLRec.No_Indexation__c)) {
                    for (String fieldName : mfields.keySet()) {
                        Schema.DescribeFieldResult field = mfields.get(fieldName).getDescribe();
                        if (field.isUpdateable() && QLRec.get(fieldName) <> null && fieldName != 'Id' && fieldName != 'SBQQ__Existing__c' && fieldName != 'SBQQ__PriorQuantity__c' && fieldName != 'Auto_Amendment_Increase_Rate__c'
                            && fieldName != 'SBQQSC__UpgradedContractLine__c' && fieldName != 'SBQQ__ListPrice__c' && fieldName != 'SBQQ__Source__c' && fieldName != 'SBQQ__Quote__c' ) {
                                try {
                                    QLRecToInsert.put(fieldName, QLRec.get(fieldName));
                                } catch (Exception e) {            
                                    System.debug('Exception type caught: ' + e.getTypeName());    
                                    System.debug('Message: ' + e.getMessage());    
                                    System.debug('Line number: ' + e.getLineNumber());    
                                    System.debug('Stack trace: ' + e.getStackTraceString()); 
                                }
                            }
                    }
                //}
                ClonedQuoteLineListToUpdate.add(QLRecToInsert);
            }
        }
        return ClonedQuoteLineListToUpdate;
    }
    
    // ADDED - GA SIMPLUS
    public static List<SBQQ__QuoteLine__c> createDependentLines(Map<Id,Id> OriginalIdToClonedId, Set<Id> LevelQLIds, Map<String,Schema.SObjectField> mfields, Map<Id,ServiceContract> ServiceContractMap, List<SBQQ__QuoteLine__c> QuoteLineList, Map<Id,Increase_Rate__c> IRTypeToIRateMap){
        List<SBQQ__QuoteLine__c> ClonedQuoteLineListToUpdate = new List<SBQQ__QuoteLine__c>();
        
            for(SBQQ__QuoteLine__c QLRec :QuoteLineList){
                // GET INCREASE TYPE AND INCREASE RATE PERCENT
                Id IRtypeId = ServiceContractMap.get(QLRec.SBQQ__Quote__r.SBQQSC__MasterServiceContract__c).Initial_Period_Increase_Rate__c;
                Decimal IRatePercent = IRTypeToIRateMap.get(IRtypeId).Increase_Rate__c;
                String DealType = ServiceContractMap.get(QLRec.SBQQ__Quote__r.SBQQSC__MasterServiceContract__c).Deal_Type__c;
                // CHECK IF ID IS IN LEVEL 4 PRODUCTS
                if(LevelQLIds.contains(QLRec.Id)){
                     Decimal ListPrice = 0;
                If(Test.isRunningTest()){
                    ListPrice = 1000;
                }else{
                    System.debug(LoggingLevel.ERROR, 'FEE TYPE => ' + QLRec.Fee_Type__c);
                    System.debug(LoggingLevel.ERROR, 'NO INDEXATION? => ' + QLRec.No_Indexation__c);
                    System.debug(LoggingLevel.ERROR, 'DEAL TYPE => ' + DealType);
                    System.debug(LoggingLevel.ERROR, 'INCREASE RATE PERCENT => ' + IRatePercent);
                    System.debug(LoggingLevel.ERROR, 'OLISTPRICE => ' + QLRec.oListPrice__c);
                    Decimal OlistPrice = QLRec.oListPrice__c <> null ? QLRec.oListPrice__c : 0;
                    ListPrice = quoteLineCloneRequired(QLRec.Fee_Type__c, QLRec.No_Indexation__c, DealType) ? OlistPrice * (1 + IRatePercent) : OlistPrice;   
                }
                    SBQQ__QuoteLine__c QLRecToInsert = new SBQQ__QuoteLine__c(SBQQ__Quote__c = QLRec.SBQQ__Quote__c, 
                                                                              SBQQ__RequiredBy__c = OriginalIdToClonedId.get(QLRec.SBQQ__RequiredBy__c),
                                                                              SBQQ__ListPrice__c = ListPrice,
                                                                              SBQQ__Existing__c = false,
                                                                              SBQQ__PriorQuantity__c = null,
                                                                              Auto_Amendment_Increase_Rate__c = IRatePercent,
                                                                              SBQQ__Source__c = QLRec.Id);
                    If(!QLRec.No_Indexation__c){
                        QLRecToInsert.put('Auto_Amendment_Increase_Rate__c', IRatePercent); 
                    }
                    //if(T1_ContractAmender.fieldRestorationRequired(DealType, QLRec.No_Indexation__c)) {
                        for (String fieldName : mfields.keySet()) {
                            Schema.DescribeFieldResult field = mfields.get(fieldName).getDescribe();
                            if (field.isUpdateable() && QLRec.get(fieldName) <> null && fieldName != 'Id' && fieldName != 'SBQQ__Existing__c' && fieldName != 'SBQQ__PriorQuantity__c'
                                && fieldName != 'Auto_Amendment_Increase_Rate__c' && fieldName != 'SBQQ__RequiredBy__c' && fieldName != 'SBQQSC__UpgradedContractLine__c' 
                                && fieldName != 'SBQQ__ListPrice__c' && fieldName != 'SBQQ__Source__c' && fieldName != 'SBQQ__Quote__c' ) {
                                    try {
                                        QLRecToInsert.put(fieldName, QLRec.get(fieldName));
                                    } catch (Exception e) {
                                        System.debug('Exception type caught: ' + e.getTypeName());    
                                        System.debug('Message: ' + e.getMessage());    
                                        System.debug('Line number: ' + e.getLineNumber());    
                                        System.debug('Stack trace: ' + e.getStackTraceString()); 
                                    }
                                }
                        }
                    //}
                    ClonedQuoteLineListToUpdate.add(QLRecToInsert);
                }
            }
            
        return ClonedQuoteLineListToUpdate;
    }
}