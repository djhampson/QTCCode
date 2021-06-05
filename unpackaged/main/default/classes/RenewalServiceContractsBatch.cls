/*******************************************************************************************************
* @Class Name   : RenewalServiceContractsBatch
* @description  : Batch class to Renew Service Contract
* @author       : Carlos Roy Billones
* @date         : 16/12/2020
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Carlos Roy Billones   16/12/2020      1000        Initial version
* Yi Zhang              12/03/2021      2000        Applied comments
* Yi Zhang              16/03/2021      3000        Applied fix around auto order
******************************************************************************************************/
public class RenewalServiceContractsBatch implements
Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    Set<id> oppIdset = new Set<Id>();

    private String contractId;
    
    public RenewalServiceContractsBatch() {}

    public RenewalServiceContractsBatch(String contractId) {
        this.contractId = contractId;
    }
    /***
    * @name	        : start
    * @description  : Standard start method for batch class 
    * @author		: Carlos Roy Billones
    * @param 		: Database.BatchableContext bc - required parameter for standard batch methods
    */    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
            'SELECT ID, SBQQSC__RenewalOpportunity__c, Auto_Renewal_Date__c, Auto_Renewal_End_Date__c, Auto_Order__c, Stop_Auto_Renewal__c, SBQQSC__RenewalForecast__c, AccountId, SBQQSC__Opportunity__c ' +
            'FROM ServiceContract ' +
            'WHERE Deal_Type__c NOT IN (\'Term\', \'Perpetual on Cloud\') AND SBQQSC__RenewalOpportunity__c = NULL AND Auto_Renewal_Date__c <= TODAY AND '+ 
            'Auto_Renewal_Treatment__c IN (\'Auto-Renew continuously – 12 months\', \'Auto-Create Opportunity and Quote\') AND '+
            '(Auto_Renewal_End_Date__c >= TODAY OR Auto_Renewal_End_Date__c = NULL) '
            + ((contractId == null) ? '' : ' AND Id = \''+ contractId + '\'')
        );
    }

    /***
    * @name	        : execute
    * @description  : Required function for batchable context
    * @author		: Carlos Roy Billones
    * @param 		: Database.BatchableContext bc - required parameter for standard batch methods
    * @param 		: List<ServiceContract> scope - Batch scope
    */    
    public void execute(Database.BatchableContext bc, List<ServiceContract> scope){
        // process each batch of records
        System.debug('Scope: ' + scope);
        List<ServiceContract> serviceContracts = new List<ServiceContract>();
        Map<Id,List<ServiceContract>> serviceContractMap = new Map<Id,List<ServiceContract>>();
        
        // group service contracts by account
        for(ServiceContract serviceContract : scope) {
            if(serviceContractMap.get(serviceContract.AccountId) == null)
            {
                serviceContractMap.put(serviceContract.AccountId, new List<ServiceContract>{serviceContract});
            }
            else{
                serviceContractMap.get(serviceContract.AccountId).add(serviceContract);
            }
        }
        
        // update in-scope service contracts
        List<ServiceContract> sctoupdate = new List<ServiceContract>();
        
        for(ServiceContract sc : scope){
             	sc.Renewal_Pricing_Method__c = 'Uplift';
            	sctoupdate.add(sc);
        }
       
        if(sctoupdate.size() > 0){
            try{
                update sctoupdate;
            }catch(exception e){
                INSERT DM_ApplicationLog.createApplicationLog(e); 
                System.debug(e.getMessage());
            }
        }
        
        for(Id acctId : serviceContractMap.keySet()){
            if(serviceContractMap.get(acctId) != null){
                for(ServiceContract servcon :serviceContractMap.get(acctId)){
                    
                    ServiceContract serviceContract = new ServiceContract();
                    
                    if(serviceContract.Auto_Renewal_Treatment__c == 'Auto-Renew continuously – 12 months' && String.isBlank(serviceContract.Stop_Auto_Renewal__c)){
                        serviceContract.Auto_Order__c = true;
                    }
                    serviceContract.Id = servcon.Id;
                    serviceContract.Auto_Renew__c = true;
                    //serviceContract.SBQQSC__RenewalUpliftRate__c = 0;
                    serviceContract.SBQQSC__RenewalForecast__c = true;
                    serviceContract.SBQQSC__RenewalQuoted__c = true;
                    serviceContracts.add(serviceContract);
                    recordsProcessed = recordsProcessed + 1;
                    oppIdset.add(serviceContract.SBQQSC__Opportunity__c);
                }
            }
        }
        
        if(serviceContracts.size() > 0){
            try{
                update serviceContracts;
            }catch(exception e){
                INSERT DM_ApplicationLog.createApplicationLog(e); 
                System.debug(e.getMessage());
            }
        }
        
        // update quote lines
        List<ContractLineItem> contractlineitem = [SELECT ID, SBQQSC__QuoteLine__c, Scheduled_End_Date__c FROM ContractLineItem WHERE ServiceContractId IN :serviceContracts];
        System.debug('contractlineitem: ' + contractlineitem);
        List<SBQQ__QuoteLine__c> quotelineitems = [SELECT ID,SBQQSC__RenewedContractLine__c FROM SBQQ__QuoteLine__c WHERE SBQQSC__RenewedContractLine__c IN :contractlineitem];
        Map<Id, ContractLineItem> contractlineitemMap = new Map<Id,ContractLineItem>(contractlineitem);
        
        for(SBQQ__QuoteLine__c quotelineitem: quotelineitems)
        {
            if(contractlineitemMap.get(quotelineitem.SBQQSC__RenewedContractLine__c).Scheduled_End_Date__c != null){
                quotelineitem.SBQQ__EndDate__c = contractlineitemMap.get(quotelineitem.SBQQSC__RenewedContractLine__c).Scheduled_End_Date__c;
                System.debug('Quote Line Item SBQQ__EndDate__c: ' + quotelineitem.SBQQ__EndDate__c);
            }
        }
        
        if(quotelineitems.size() > 0){
            update quotelineitems;
        }
    }
    


    /***
    * @name	        : finish
    * @description  : Required function for batchable context
    * @author		: Carlos Roy Billones
    * @param 		: Database.BatchableContext bc - required parameter for standard batch methods
    */
    public void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        System.debug('Apex Async Job ' + job);
        
        //Database.executeBatch(new OrderAndContractOpportunityBatch(oppIdset));
    }    
}