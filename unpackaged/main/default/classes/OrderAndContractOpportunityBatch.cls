/*******************************************************************************************************
* @Class Name   : OrderAndContractOpportunityBatch
* @description  : Batch class to order and contract opportunity which requires auto renewal
* @author       : Carlos Roy Billones
* @date         : 16/12/2020
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Carlos Roy Billones   16/12/2020      1000        Initial version
* Yi Zhang              12/03/2021      2000        Applied comments
* Yi Zhang              15/03/2021      3000        Updated codes for order activation and contracting (use Async framework)
******************************************************************************************************/
public class OrderAndContractOpportunityBatch implements
Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    private Set<Id> RecordId;
    public OrderAndContractOpportunityBatch(){}
    public OrderAndContractOpportunityBatch(Set<Id> RecordId) {
        This.RecordId = RecordId;
    } 

    /***
    * @name	        : start
    * @description  : Standard start method for batch class 
    * @author		: Carlos Roy Billones
    * @param 		: Database.BatchableContext bc - required parameter for standard batch methods
    */    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT Id, Auto_Renew__c , Auto_Order__c, SBQQ__Ordered__c, SBQQ__Contracted__c ' + 
            'FROM Opportunity ' +
            'WHERE Auto_Renew__c = true AND SBQQ__PrimaryQuote__c != null AND SBQQSC__AmendedServiceContract__c = null AND SBQQ__Ordered__c = FALSE AND Auto_Order__c = TRUE';
        If(This.RecordId != null ){
            query += ' AND Id IN :RecordId';
        }
        
        System.debug(query);
        return Database.getQueryLocator(query);
        
    }

    /***
    * @name	        : execute
    * @description  : Required function for batchable context
    * @author		: Carlos Roy Billones
    * @param 		: Database.BatchableContext bc - required parameter for standard batch methods
    * @param 		: List<Opportunity> scope - Batch scope
    */
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        try {
            
            if(Test.isRunningTest() && OrderAndContractOpportunityBatchTest.throwExceptionFlag == true){
                throw new OrderAndContractOpportunityBatchException();
            }
            
            // process each batch of records
            Set<Id> OppIds = new Set<Id>(); 
            List<Opportunity> oppList = [SELECT Id,SBQQ__PrimaryQuote__c,
                                         Auto_Order__c,
                                         SBQQSC__RenewedServiceContract__r.EndDate,
                                         SBQQSC__RenewedServiceContract__r.Original_End_Date__c,
                                         SBQQSC__RenewedServiceContract__r.Auto_Renewal_Treatment__c,
                                         SBQQSC__RenewedServiceContract__r.Initial_Period_Increase_Rate__c,
                                         SBQQSC__RenewedServiceContract__r.Extensions_Increase_Rate__c,
                                         SBQQSC__RenewedServiceContract__r.Options_Increase_Rate__c,
                                         SBQQSC__RenewedServiceContract__r.Initial_Period_Increase_Rate__r.Name,
                                         SBQQSC__RenewedServiceContract__r.Extensions_Increase_Rate__r.Name,
                                         SBQQSC__RenewedServiceContract__r.Options_Increase_Rate__r.Name
                                         FROM Opportunity WHERE Id IN: scope];
            
            List<Opportunity> opps = new List<Opportunity>();
            List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
            
            
            // order opportunities
            for(Opportunity opp : oppList){
                OppIds.add(opp.Id);
                if(!Test.isRunningTest()){
                    opp.SBQQ__Ordered__c = true;
                }
                opp.Auto_Order__c = false;
                opp.Auto_Renew__c = false;
                opp.Auto_Renewed__c = true;
                
                // GET INCREASE RATE NAME
                String IncreaseRateType = getIncreaseRateType(opp);
                
                // CHECK IF TYPE IS NOT NULL
                If(IncreaseRateType <> null){
                    quotesToUpdate.add(new SBQQ__Quote__c(Id = opp.SBQQ__PrimaryQuote__c,Increase_Rate_Type__c = IncreaseRateType));
                }
                opps.add(opp);
                // increment the instance member counter
                recordsProcessed = recordsProcessed + 1;
            }
            
            // UPDATE QUOTES
            If(quotesToUpdate.size() > 0){
                UPDATE quotesToUpdate;
            }
            update opps;
            
            // activate orders
            List<Order> OrdersToActivate = [SELECT Id, SBQQ__Contracted__c, Status FROM Order WHERE Status = 'Draft' AND SBQQ__Contracted__c = FALSE AND OpportunityId IN: OppIds];
            List<Order> OrdersToUpdate = new List<Order>();
            
            // use Async framework to activate and contract order (similar code in OrderTriggerHandler)
            // NOTES: update Status directly will trigger System.AsyncException: Future method cannot be called from a future or batch method: T1_RevRecognitionService.generateRevRecognitionScheduleAndTransactions(Set<Id>)
            Integer i = 1;
            for(Order orderRec : OrdersToActivate) {
                System.schedule(
                    OrderTriggerHandler.getJobName(orderRec.Id), 
                    OrderTriggerHandler.getJobCronString(i++),   //1 minute
                    new T1_ActivateOrder(orderRec)); 
                // Order NewOrder = new Order(Id = Ord.Id, Status = 'Activated');
                // OrdersToUpdate.add(NewOrder);  
            }
        } catch (Exception e) {
            INSERT DM_ApplicationLog.createApplicationLog(e); 
        }
        
        // If(OrdersToUpdate.size() > 0) {
        //     update OrdersToUpdate;
        // }
        
        // // contract orders
        // OrdersToUpdate.clear();
        // List<Order> OrdersToContract = [SELECT Id,SBQQ__Contracted__c,Status FROM Order WHERE Status = 'Activated' AND SBQQ__Contracted__c = FALSE AND Id IN:OrdersToActivate];
        // for(Order Ord : OrdersToContract) {
        //     Order NewOrder = new Order(Id = Ord.Id, SBQQ__Contracted__c = TRUE);
        //     OrdersToUpdate.add(NewOrder);  
        // }
        
        // If(OrdersToUpdate.size() > 0) {
        //     update OrdersToUpdate;
        // }
        
    }
    
    /***
    * @name	        : finish
    * @description  : Required function for batchable context
    * @author		: Carlos Roy Billones
    * @param 		: Database.BatchableContext bc - required parameter for standard batch methods
    */
    public void finish(Database.BatchableContext bc) {
        System.debug(recordsProcessed + ' records processed. Shazam!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        // call some utility to send email
        //EmailUtils.sendMessage(job, recordsProcessed);
    }
    
    public static string getIncreaseRateType(Opportunity opp){
        String IncreaseRateType;
        if(opp.SBQQSC__RenewedServiceContract__r.Auto_Renewal_Treatment__c == 'Auto-Renew continuously – 12 months' && opp.SBQQSC__RenewedServiceContract__r.Original_End_Date__c > opp.SBQQSC__RenewedServiceContract__r.EndDate && opp.SBQQSC__RenewedServiceContract__r.Initial_Period_Increase_Rate__c != null){
            IncreaseRateType = opp.SBQQSC__RenewedServiceContract__r.Initial_Period_Increase_Rate__r.Name;
        }
        
        if(opp.SBQQSC__RenewedServiceContract__r.Auto_Renewal_Treatment__c == 'Auto-Renew continuously – 12 months' && opp.SBQQSC__RenewedServiceContract__r.EndDate >= opp.SBQQSC__RenewedServiceContract__r.Original_End_Date__c && opp.SBQQSC__RenewedServiceContract__r.Extensions_Increase_Rate__c != null){
            IncreaseRateType = opp.SBQQSC__RenewedServiceContract__r.Extensions_Increase_Rate__r.Name; 
        }
        
        if(opp.SBQQSC__RenewedServiceContract__r.Auto_Renewal_Treatment__c == 'Auto-Create Opportunity and Quote' && opp.SBQQSC__RenewedServiceContract__r.EndDate >= opp.SBQQSC__RenewedServiceContract__r.Original_End_Date__c && opp.SBQQSC__RenewedServiceContract__r.Options_Increase_Rate__c != null){
            IncreaseRateType = opp.SBQQSC__RenewedServiceContract__r.Options_Increase_Rate__r.Name;
        }
        return IncreaseRateType;
    }
     class OrderAndContractOpportunityBatchException extends Exception{}
}