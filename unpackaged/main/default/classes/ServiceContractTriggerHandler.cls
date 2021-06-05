/*******************************************************************************************************
* @Class Name   : ServiceContractTriggerHandler
* @description  : Handler for ServiceContractTrigger
* @author       : Carlos Roy Billones
* @date         : 21/01/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Carlos Roy Billones   21/01/2021      1000        Initial version
* Yi Zhang              12/03/2021      2000        Applied comments
* Yi Zhang              15/03/2021      3000        Refactored methods OnBeforeUpdate & getConditionalIncreaseRates(Id)
* Gerald Arzadon        18/03/2021      4000        Added a method to handle perpetual to saas scenario
******************************************************************************************************/
public class ServiceContractTriggerHandler {
    
    /**
    * @description 
    * @author Carlos Roy Billones | 21/01/2021 
    * @param List<ServiceContract> oldObjects 
    * @param List<ServiceContract> updatedObjects 
    * @param Map<Id ServiceContract> oldServiceContracts 
    * @param Map<Id ServiceContract> newServiceContracts 
    **/
    public void OnBeforeUpdate(List<ServiceContract> oldObjects, List<ServiceContract> updatedObjects, Map<Id, ServiceContract> oldServiceContracts, Map<Id, ServiceContract> newServiceContracts){
        //BEFORE UPDATE LOGIC
        
        /* Note: Below codes have been refactored and moved into populateContractLineItemsRenewalUpliftRate method
        List<ContractLineItem> contractLineItems = [SELECT ServiceContractId, SBQQSC__RenewalUpliftRate__c, No_Indexation__c FROM ContractLineItem WHERE ServiceContractId IN :newServiceContracts.keySet() AND No_Indexation__c = false];
        Map<Id, ContractLineItem> contractLineItemMap = new Map<Id, ContractLineItem>(contractLineItems);
        
        for(ServiceContract sc :newServiceContracts.values()){
            
            if(oldServiceContracts.get(sc.Id).SBQQSC__RenewalQuoted__c == false && newServiceContracts.get(sc.Id).SBQQSC__RenewalQuoted__c == true){
                
                for(ContractLineItem cli :contractLineItems){
                    if(newServiceContracts.get(cli.ServiceContractId).Auto_Renewal_Treatment__c == 'Auto-Renew continuously – 12 months' && 
                       newServiceContracts.get(cli.ServiceContractId).Original_End_Date__c > newServiceContracts.get(cli.ServiceContractId).EndDate && 
                       newServiceContracts.get(cli.ServiceContractId).Initial_Period_Increase_Rate__c != null){
                        cli.SBQQSC__RenewalUpliftRate__c = getConditionalIncreaseRates(newServiceContracts.get(cli.ServiceContractId).Initial_Period_Increase_Rate__c);
                    }
                    
                    if(newServiceContracts.get(cli.ServiceContractId).Auto_Renewal_Treatment__c == 'Auto-Renew continuously – 12 months' && 
                       newServiceContracts.get(cli.ServiceContractId).EndDate >= newServiceContracts.get(cli.ServiceContractId).Original_End_Date__c && 
                       newServiceContracts.get(cli.ServiceContractId).Extensions_Increase_Rate__c != null){
                        cli.SBQQSC__RenewalUpliftRate__c = getConditionalIncreaseRates(newServiceContracts.get(cli.ServiceContractId).Extensions_Increase_Rate__c);
                    }
                    
                    if(newServiceContracts.get(cli.ServiceContractId).Auto_Renewal_Treatment__c == 'Auto-Create Opportunity and Quote' && 
                       newServiceContracts.get(cli.ServiceContractId).EndDate >= newServiceContracts.get(cli.ServiceContractId).Original_End_Date__c && 
                       newServiceContracts.get(cli.ServiceContractId).Options_Increase_Rate__c != null){
                        cli.SBQQSC__RenewalUpliftRate__c = getConditionalIncreaseRates(newServiceContracts.get(cli.ServiceContractId).Options_Increase_Rate__c);
                    }
                }
            }
        }
        
		update contractLineItems;
        */     
        

        
        Set<Id> ContractIds = new Set<Id>();
        Set<Id> QuoteIds = new Set<Id>();
        Map<Id,ServiceContract> ServiceContractsMap = new Map<Id,ServiceContract>([SELECT Id,SBQQSC__Quote__c, SBQQSC__Quote__r.Billing_Holidays__c, SBQQSC__Quote__r.Deal_Type__c, SBQQSC__Quote__r.SBQQ__Type__c,
                                                                                   SBQQSC__Order__c,SBQQSC__Order__r.blng__BillingAccount__c FROM ServiceContract WHERE Id IN: updatedObjects]); 
        
        List<ServiceContract> ServiceContToupdate = new List<ServiceContract>();
        for(ServiceContract sc : ServiceContractsMap.values()){
            System.debug(LoggingLevel.ERROR, '@@@ SERVICE CONTRACT TYPE' + sc.SBQQSC__Quote__r.SBQQ__Type__c);
            System.debug(LoggingLevel.ERROR, '@@@ SERVICE CONTRACT > ORDER BILLING ACCOUNT CHECKER ' + sc.SBQQSC__Order__r.blng__BillingAccount__c);
            System.debug(LoggingLevel.ERROR, '@@@ SERVICE CONTRACT > ORDER ID CHECKER ' + sc.SBQQSC__Order__c);
            If(sc.SBQQSC__Quote__r.SBQQ__Type__c == 'Quote'){
                QuoteIds.add(sc.SBQQSC__Quote__c);
            }

        }
        
        for(ServiceContract sc : updatedObjects){
            If(sc.SBQQSC__RenewalTerm__c <> 12 && ServiceContractsMap.get(sc.Id).SBQQSC__Quote__r.Billing_Holidays__c > 0){
                sc.SBQQSC__RenewalTerm__c = 12;
            }
        }
        
        
        
        // CHECK SET IF NOT NULL OR NOT EMPTY
        If(QuoteIds <> null && !QuoteIds.IsEmpty()){
            // GET ORDERS AND BILLING ACCOUNT
            List<Order> Orderlist = [SELECT Id,SBQQ__Quote__c,blng__BillingAccount__c FROM Order WHERE SBQQ__Quote__c IN: QuoteIds]; 
            Map<Id,Order> QuoteIdToOrder= new Map<Id,Order>();
            
            // POPULATE MAP
            for(Order Ord:Orderlist){
                If(QuoteIdToOrder.get(Ord.SBQQ__Quote__c) == null){
                    QuoteIdToOrder.put(Ord.SBQQ__Quote__c,Ord);
                }
            }
            System.debug(loggingLevel.ERROR, '@@ QuoteIdToOrder ' + QuoteIdToOrder);
            
            // CHECK MAP IF NOT NULL OR NOT EMPTY
            If(QuoteIdToOrder <> null && !QuoteIdToOrder.IsEmpty()){
                // UPDATE BILLING ACCOUNT FIELD ON SERVICE CONTRACT IF ORDER HAS A VALUE
                for(ServiceContract sc : updatedObjects){
                    System.debug(LoggingLevel.ERROR, '@@@ SERVICE CONTRACT TYPE ' + sc.SBQQSC__Quote__r.SBQQ__Type__c);
                    System.debug(LoggingLevel.ERROR, '@@@ QUOTE TO ORDER CHECKER => ' + QuoteIdToOrder.get(sc.SBQQSC__Quote__c));
                    If(QuoteIdToOrder.get(sc.SBQQSC__Quote__c) <> null){
                       sc.Billing_Account__c = QuoteIdToOrder.get(sc.SBQQSC__Quote__c).blng__BillingAccount__c;
                    }
                }
            } 
        }

        populateContractLineItemsRenewalUpliftRate(oldServiceContracts, newServiceContracts);
    }
    
    /**
    * @description 
    * @author Carlos Roy Billones | 21/01/2021 
    * @param List<ServiceContract> oldObjects 
    * @param List<ServiceContract> updatedObjects 
    * @param Map<Id ServiceContract> oldObjectMap 
    **/
    public void OnAfterUpdate(List<ServiceContract> oldObjects, List<ServiceContract> updatedObjects, Map<Id, ServiceContract> oldObjectMap){
        //AFTER UPDATE LOGIC
        UpdateWeightedAverage(updatedObjects);
        NotificationRequest req = new NotificationRequest();
        req.Notification = new List<NotificationModel>();
        
        for(ServiceContract c : updatedObjects){
            ServiceContract oc = oldObjectMap.get(c.Id);
            
            if(oc.ApprovalStatus <> c.ApprovalStatus && c.ApprovalStatus == 'Activated'){
                NotificationModel tmp = new NotificationModel();
                tmp.Notif_ID = StaticUtil.getGUUID();
                tmp.Notif_Type = 'ServiceContract';
                tmp.Notif_Obj_ID = c.Id;
                tmp.Notif_Status = 'Activated';
                tmp.Notif_CreateDate = System.now().format('yyyy-MM-dd HH:mm:ss'); //'2020-10-10 08:30:00'

                req.Notification.add(tmp);
            }
        }

        if(req.Notification.size() > 0)
            NotificationService.notifyF(JSON.serialize(req));
    }
    
    /**
    * @description - Update weighted average
    * @author Gerald Arzadon
    * @param List<ServiceContract> ServiceContracts 
    **/
    public static void UpdateWeightedAverage(List<ServiceContract> ServiceContracts){
        // Set<Id> ContractIds = new Set<Id>();
        // GET ALL CONTRACT LINES ON THE SAME CONTRACT
        List<ContractLineItem> ContractLineItemList = [SELECT Id,ServiceContractId,CreatedDate,
                                                       Weighted_Average_Price__c,SBQQSC__RevisedSubscription__c
                                                       FROM ContractLineItem
                                                       WHERE ServiceContractId IN : ServiceContracts 
                                                       AND SBQQSC__RevisedSubscription__c != null];
        If(ContractLineItemList <> null && ContractLineItemList.size() > 0 && !ContractLineItemList.IsEmpty()){
            // SCHEDULE SERVICE CONTRACTS FOR PROCESSING
            Integer i = 1;
            String jobName = OrderTriggerHandler.getJobName('SC_Average');
            T1_ServiceContract job = new T1_ServiceContract(ContractLineItemList);
            String cronString = OrderTriggerHandler.getJobCronString(i);  //1 minute;
            String jobId = System.schedule(jobName, cronString, job); 
            i++;
        }
    }
    /**
    * @description LINK SERVICE CONTRACTS FOR PERPETUAL ON CLOUD TO SAAS SCENARIO
    * @author Gerald Arzadon
    * @param List<ServiceContract> ServiceContracts 
    **/
    public static void LinkPerpetualCloudServiceContracts(List<ServiceContract> ServiceContracts){
        Set<Id> ContractIds = new Set<Id>();
        Set<Id> CompoundInterestContractIds = new Set<Id>();
        List<ServiceContract> ServiceContractslist = [SELECT Id,SBQQSC__Opportunity__r.Auto_Renewed__c,Auto_Renewed_Ordered__c,SBQQSC__Quote__c, SBQQSC__Quote__r.Deal_Type__c, SBQQSC__Quote__r.SBQQ__Type__c,
                                                      SBQQSC__Order__c,SBQQSC__Order__r.blng__BillingAccount__c FROM ServiceContract WHERE Id IN: ServiceContracts]; 
        
        List<ServiceContract> ServiceContToupdate = new List<ServiceContract>();
        for(ServiceContract sc : ServiceContractslist){
           
            // GET ALL SERVICE CONTRACTS IDS THAT ARE DEAL TYPE OF PERPETUAL ON CLOUD
            If(sc.SBQQSC__Quote__r.Deal_Type__c == 'Perpetual on Cloud'){
                ContractIds.add(sc.Id);
            }
            
            If(sc.SBQQSC__Quote__r.SBQQ__Type__c == 'Renewal'){
                CompoundInterestContractIds.add(sc.Id);
            } 
        }

        System.debug(loggingLevel.ERROR, '@@ ContractIds ' + ContractIds);
        
        // CHECK IF EMPTY AND SCHEDULE SERVICE CONTRACTS FOR PROCESSING
        if(!ContractIds.IsEmpty()){
            Integer i = 1;
            String jobName = OrderTriggerHandler.getJobName('PerpetualToSaaS');
            T1_PerpetualToSaaS job = new T1_PerpetualToSaaS(ContractIds);
            String cronString = OrderTriggerHandler.getJobCronString(i);  //1 minute
            String jobId = System.schedule(jobName, cronString, job); 
            i = i + 1;  
        } 
        
        System.debug('CompoundInterestContractIds IDs ' + CompoundInterestContractIds.size());
        // CHECK IF EMPTY AND SCHEDULE SERVICE CONTRACTS FOR PROCESSING
        if(!CompoundInterestContractIds.IsEmpty()){
            AssetCompoundInterestScheduleAsync(CompoundInterestContractIds);
        } 
    }
        /**
    * @description - SCHEDULE ASYNC JOB TO UPDATE COMPOUND INTEREST OF ASSETS
    * @author GERALD ARZADON | 5/5/2021
    * @param Set<Id> CompoundInterestContractIds
    **/
    public static void AssetCompoundInterestScheduleAsync(Set<Id> CompoundInterestContractIds){
        Integer i = 1;
        String jobName = OrderTriggerHandler.getJobName('AssetCompoundInterest');
        T1_AssetCompoundInterest job = new T1_AssetCompoundInterest(CompoundInterestContractIds);
        String cronString = OrderTriggerHandler.getJobCronString(i);  //1 minute
        String jobId = System.schedule(jobName, cronString, job); 
    }
    /**
    * @description - Populate RenewalUpliftRate__c of contract line items of contracts of which RenewalQuoted__c has become true, refactored method of logic in OnBeforeUpdate
    * @author Yi Zhang | 15/03/2021 
    * @param Map<Id ServiceContract> oldServiceContracts 
    * @param Map<Id ServiceContract> newServiceContracts 
    **/
    public static void populateContractLineItemsRenewalUpliftRate(Map<Id, ServiceContract> oldServiceContracts, Map<Id, ServiceContract> newServiceContracts) {

        Map<Id, ContractLineItem> cliToUpdate = new Map<Id, ContractLineItem>();

        // find service contracts of which SBQQSC__RenewalQuoted__c has become true
        Map<Id, ServiceContract> renewalQuotedContracts = new Map<Id, ServiceContract>();
        for(ServiceContract newContract : newServiceContracts.values()) {
            ServiceContract oldContract = oldServiceContracts.get(newContract.Id);
            if(oldContract.SBQQSC__RenewalQuoted__c == false && newContract.SBQQSC__RenewalQuoted__c == true) {
                renewalQuotedContracts.put(newContract.Id, newContract);
            }
        }
        if(renewalQuotedContracts.isEmpty()) return;

            
        // collect contract line items (along with increase rate type ids) which meets criteria
        Map<Id, Id> cliIrtMap = new Map<Id, Id>(); // key = cli Id, val = increase rate type id
        for(ContractLineItem cli : [SELECT ServiceContractId, SBQQSC__RenewalUpliftRate__c, No_Indexation__c FROM ContractLineItem WHERE ServiceContractId IN :renewalQuotedContracts.keySet() AND No_Indexation__c = false]) {
            ServiceContract renewalQuotedContract = renewalQuotedContracts.get(cli.ServiceContractId);
            if(renewalQuotedContract.Auto_Renewal_Treatment__c == 'Auto-Renew continuously – 12 months' && renewalQuotedContract.Original_End_Date__c > renewalQuotedContract.EndDate && renewalQuotedContract.Initial_Period_Increase_Rate__c != null){
                    cliIrtMap.put(cli.Id, renewalQuotedContract.Initial_Period_Increase_Rate__c);
            }
            
            if(renewalQuotedContract.Auto_Renewal_Treatment__c == 'Auto-Renew continuously – 12 months' && renewalQuotedContract.EndDate >= renewalQuotedContract.Original_End_Date__c && renewalQuotedContract.Extensions_Increase_Rate__c != null){
                    cliIrtMap.put(cli.Id, renewalQuotedContract.Extensions_Increase_Rate__c);
            }
            
            if(renewalQuotedContract.Auto_Renewal_Treatment__c == 'Auto-Create Opportunity and Quote' && renewalQuotedContract.EndDate >= renewalQuotedContract.Original_End_Date__c && renewalQuotedContract.Options_Increase_Rate__c != null){
                    cliIrtMap.put(cli.Id, renewalQuotedContract.Options_Increase_Rate__c);
            }
        }
        if(cliIrtMap.isEmpty()) return;
        
        // populate contract line items' SBQQSC__RenewalUpliftRate__c and update them
        Map<Id, Increase_Rate_Types__c> rateTypeMap = new Map<Id, Increase_Rate_Types__c>([SELECT Id, Name FROM Increase_Rate_Types__c WHERE Id = :cliIrtMap.values()]);
        Map<String, AggregateResult> increaseRateMap = new Map<String, AggregateResult>([SELECT Increase_Rate_Type__r.Name Id, MAX(Effective_From__c) EffectiveFrom, MAX(Increase_Rate__c) IncreaseRate FROM Increase_Rate__c WHERE Increase_Rate_Type__c != null GROUP BY Increase_Rate_Type__r.Name]); 

        for(Id cliId : cliIrtMap.keySet()) {
            cliToUpdate.put(cliId, new contractLineItem(Id = cliId, Renewal_Uplift_Type__c = rateTypeMap.get(cliIrtMap.get(cliId)).Name, SBQQSC__RenewalUpliftRate__c = getConditionalIncreaseRates(rateTypeMap.get(cliIrtMap.get(cliId)).Name, increaseRateMap)));
        }

        try {
            update cliToUpdate.values();
        } catch(Exception e) {insert DM_ApplicationLog.createApplicationLog(e);
            System.debug('failed to update contract line items in ServiceContractTriggerHandler.OnBeforeUpdate ' + e.getMessage());
        }


    }

    /**
    * @description - Extracted logic from original getConditionalIncreaseRates(Id IncreateRateTypeId) method
    * @author Yi Zhang | 15/03/2021 
    * @param String increaseRateTypeName 
    * @param Map<String AggregateResult> increaseRateMap 
    * @return decimal 
    **/
    public static decimal getConditionalIncreaseRates(String increaseRateTypeName, Map<String, AggregateResult> increaseRateMap) {
        Decimal increaseRatepercentage = 0;
        Decimal value1 = 0;
        Decimal value2 = 0;
        if(increaseRateTypeName == 'GREATESTOFCPIANDAIIA'){
            value1 = (Decimal)increaseRateMap.get('CPI').get('IncreaseRate') <> null ? (Decimal)increaseRateMap.get('CPI').get('IncreaseRate') : 0;
            value2 = (Decimal)increaseRateMap.get('AIIA').get('IncreaseRate') <> null ? (Decimal)increaseRateMap.get('AIIA').get('IncreaseRate') : 0;
            
            if(value1 > value2){
                increaseRatepercentage = value1;
            }
            else{
                increaseRatepercentage = value2;
            }
        }
        else if(increaseRateTypeName == 'GREATOFNZCPIANDAIIA'){
            value1 = (Decimal)increaseRateMap.get('NZCPI').get('IncreaseRate') <> null ? (Decimal)increaseRateMap.get('NZCPI').get('IncreaseRate') : 0;
            value2 = (Decimal)increaseRateMap.get('AIIA').get('IncreaseRate') <> null ? (Decimal)increaseRateMap.get('AIIA').get('IncreaseRate') : 0;
            
            if(value1 > value2){
                increaseRatepercentage = value1;
            }
            else{
                increaseRatepercentage = value2;
            }
        }
        else if(increaseRateTypeName == 'LOWESTOFCPIANDAIIA'){
            value1 = (Decimal)increaseRateMap.get('CPI').get('IncreaseRate') <> null ? (Decimal)increaseRateMap.get('CPI').get('IncreaseRate') : 0;
            value2 = (Decimal)increaseRateMap.get('AIIA').get('IncreaseRate') <> null ? (Decimal)increaseRateMap.get('AIIA').get('IncreaseRate') : 0;
            
            if(value1 < value2){
                increaseRatepercentage = value1;
            }
            else{
                increaseRatepercentage = value2;
            }
        }
        else if(increaseRateTypeName == 'CPIOR3%'){
            value1 = (Decimal)increaseRateMap.get('CPI').get('IncreaseRate') <> null ? (Decimal)increaseRateMap.get('CPI').get('IncreaseRate') : 0;
            value2 = 3;
            
            if(value1 > value2){
                increaseRatepercentage = value1;
            }
            else{
                increaseRatepercentage = value2;
            }
        }
        else if(increaseRateTypeName == 'CPIOR4.5%'){
            value1 = (Decimal)increaseRateMap.get('CPI').get('IncreaseRate') <> null ? (Decimal)increaseRateMap.get('CPI').get('IncreaseRate') : 0;
            value2 = 4.5;
            
            if(value1 > value2){
                increaseRatepercentage = value1;
            }
            else{
                increaseRatepercentage = value2;
            }
        }
        else if(increaseRateTypeName == 'CPIOR6%'){
            value1 = (Decimal)increaseRateMap.get('CPI').get('IncreaseRate') <> null ? (Decimal)increaseRateMap.get('CPI').get('IncreaseRate') : 0;
            value2 = 6;
            
            if(value1 > value2){
                increaseRatepercentage = value1;
            }
            else{
                increaseRatepercentage = value2;
            }
        }
        else if(increaseRateTypeName == 'NZCPICAP3%'){
            
        }
        else if(increaseRateTypeName == 'NZCPIOR6%'){
            value1 = (Decimal)increaseRateMap.get('NZCPI').get('IncreaseRate') <> null ? (Decimal)increaseRateMap.get('NZCPI').get('IncreaseRate') : 0;
            value2 = 6;
            
            if(value1 > value2){
                increaseRatepercentage = value1;
            }
            else{
                increaseRatepercentage = value2;
            }
        }
        else if(increaseRateTypeName == 'UKCPIOR3%'){
            value1 = (Decimal)increaseRateMap.get('UKCPI').get('IncreaseRate') <> null ? (Decimal)increaseRateMap.get('UKCPI').get('IncreaseRate') : 0;
            value2 = 3;
            
            if(value1 > value2){
                increaseRatepercentage = value1;
            }
            else{
                increaseRatepercentage = value2;
            }
        }
        else if(increaseRateTypeName == 'UKCPIOR6%'){
            value1 = (Decimal)increaseRateMap.get('UKCPI').get('IncreaseRate') <> null ? (Decimal)increaseRateMap.get('UKCPI').get('IncreaseRate') : 0;
            value2 = 6;
            
            if(value1 > value2){
                increaseRatepercentage = value1;
            }
            else{
                increaseRatepercentage = value2;
            }
        }
        else if(increaseRateTypeName == 'UKCPIORAIIA'){
            value1 = (Decimal)increaseRateMap.get('UKCPI').get('IncreaseRate') <> null ? (Decimal)increaseRateMap.get('UKCPI').get('IncreaseRate') : 0;
            value2 = (Decimal)increaseRateMap.get('AIIA').get('IncreaseRate') <> null ? (Decimal)increaseRateMap.get('AIIA').get('IncreaseRate') : 0;
            
            if(value1 > value2){
                increaseRatepercentage = value1;
            }
            else{
                increaseRatepercentage = value2;
            }
        }
        else if(increaseRateMap.containsKey(increaseRateTypeName)){
            increaseRatepercentage = (Decimal)increaseRateMap.get(increaseRateTypeName).get('IncreaseRate') <> null ? (Decimal)increaseRateMap.get(increaseRateTypeName).get('IncreaseRate') : 0;
            System.debug('increaseRatepercentage: ' + increaseRatepercentage);
        }
        return increaseRatepercentage;
    }
    
    /**
    * @description - handle assignment of increase rates
    *                15/03/2021 Yi Zhang: refactored/bulkified method
    * @author Carlos Roy Billones
    * @param Id IncreateRateTypeId 
    * @return decimal 
    **/
    public static decimal getConditionalIncreaseRates(Id IncreateRateTypeId){
        Decimal increaseRatepercentage = 0;
        Decimal value1 = 0;
        Decimal value2 = 0;
        Increase_Rate_Types__c increaseRateType = [SELECT Id, Name FROM Increase_Rate_Types__c WHERE Id = :IncreateRateTypeId LIMIT 1];
        List<AggregateResult> increaseRates = [SELECT Increase_Rate_Type__r.Name Id, MAX(Effective_From__c) EffectiveFrom, MAX(Increase_Rate__c) IncreaseRate FROM Increase_Rate__c WHERE Increase_Rate_Type__c != null GROUP BY Increase_Rate_Type__r.Name];
        Map<String, AggregateResult> increaseRateMap = new Map<String, AggregateResult>(increaseRates); 
        // for(AggregateResult increaserate :increaseRates){
            /* Note: below logic has been refactored into methdo getConditionalIncreaseRates(String, Map<String, AggregateResult>)
            if(increaseRateType.Name == 'GREATESTOFCPIANDAIIA'){
                value1 = (Decimal)increaseRateMap.get('CPI').get('IncreaseRate');
                value2 = (Decimal)increaseRateMap.get('AIIA').get('IncreaseRate');
                
                if(value1 > value2){
                    increaseRatepercentage = value1;
                }
                else{
                    increaseRatepercentage = value2;
                }
            }
            else if(increaseRateType.Name == 'GREATOFNZCPIANDAIIA'){
                value1 = (Decimal)increaseRateMap.get('NZCPI').get('IncreaseRate');
                value2 = (Decimal)increaseRateMap.get('AIIA').get('IncreaseRate');
                
                if(value1 > value2){
                    increaseRatepercentage = value1;
                }
                else{
                    increaseRatepercentage = value2;
                }
            }
            else if(increaseRateType.Name == 'LOWESTOFCPIANDAIIA'){
                value1 = (Decimal)increaseRateMap.get('CPI').get('IncreaseRate');
                value2 = (Decimal)increaseRateMap.get('AIIA').get('IncreaseRate');
                
                if(value1 < value2){
                    increaseRatepercentage = value1;
                }
                else{
                    increaseRatepercentage = value2;
                }
            }
            else if(increaseRateType.Name == 'CPIOR3%'){
                value1 = (Decimal)increaseRateMap.get('CPI').get('IncreaseRate');
                value2 = 3;
                
                if(value1 > value2){
                    increaseRatepercentage = value1;
                }
                else{
                    increaseRatepercentage = value2;
                }
            }
            else if(increaseRateType.Name == 'CPIOR4.5%'){
                value1 = (Decimal)increaseRateMap.get('CPI').get('IncreaseRate');
                value2 = 4.5;
                
                if(value1 > value2){
                    increaseRatepercentage = value1;
                }
                else{
                    increaseRatepercentage = value2;
                }
            }
            else if(increaseRateType.Name == 'CPIOR6%'){
                value1 = (Decimal)increaseRateMap.get('CPI').get('IncreaseRate');
                value2 = 6;
                
                if(value1 > value2){
                    increaseRatepercentage = value1;
                }
                else{
                    increaseRatepercentage = value2;
                }
            }
            else if(increaseRateType.Name == 'NZCPICAP3%'){
                
            }
            else if(increaseRateType.Name == 'NZCPIOR6%'){
                value1 = (Decimal)increaseRateMap.get('NZCPI').get('IncreaseRate');
                value2 = 6;
                
                if(value1 > value2){
                    increaseRatepercentage = value1;
                }
                else{
                    increaseRatepercentage = value2;
                }
            }
            else if(increaseRateType.Name == 'UKCPIOR3%'){
                value1 = (Decimal)increaseRateMap.get('UKCPI').get('IncreaseRate');
                value2 = 3;
                
                if(value1 > value2){
                    increaseRatepercentage = value1;
                }
                else{
                    increaseRatepercentage = value2;
                }
            }
            else if(increaseRateType.Name == 'UKCPIOR6%'){
                value1 = (Decimal)increaseRateMap.get('UKCPI').get('IncreaseRate');
                value2 = 6;
                
                if(value1 > value2){
                    increaseRatepercentage = value1;
                }
                else{
                    increaseRatepercentage = value2;
                }
            }
            else if(increaseRateType.Name == 'UKCPIORAIIA'){
                value1 = (Decimal)increaseRateMap.get('UKCPI').get('IncreaseRate');
                value2 = (Decimal)increaseRateMap.get('AIIA').get('IncreaseRate');
                
                if(value1 > value2){
                    increaseRatepercentage = value1;
                }
                else{
                    increaseRatepercentage = value2;
                }
            }
            else if(increaseRateType.Name == increaserate.get('Id')){
                increaseRatepercentage = (Decimal)increaseRateMap.get(increaseRateType.Name).get('IncreaseRate');
                System.debug('increaserateId: ' + increaserate.get('Id'));
                System.debug('increaseRatepercentage: ' + increaseRatepercentage);
            }
            
        */
        // }
        increaseRatepercentage = getConditionalIncreaseRates(increaseRateType.Name, increaseRateMap);
        
        return increaseRatepercentage;
    }
}