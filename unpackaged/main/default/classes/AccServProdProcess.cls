/**
 * @description       : Class to maintain current Account Service Products based on active Service Contracts
 *                      Accounts still managed via SRS are updated daily.
 * @author            : Grant Hamlyn
 * @group             : 
 * @last modified on  : 24-03-2021
 * @last modified by  : Grant Hamlyn
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   08-03-2021   Grant Hamlyn   Initial Version (SCE-881)
 * 2.0   09-03-2021   Grant Hamlyn   Change from Async to Sync
**/
public class AccServProdProcess {

    public static void processAccounts(Set<Id> accountSet) {

        if (accountSet.isEmpty()){
            return;
        }     

        Date todaysDate = system.today();

        // set of Active Service Contracts for the Account set
        Set<Id> serviceContractSet = new Set<Id>();
        List<ServiceContract> servicecontracts = [select id from ServiceContract where accountId in :accountSet
                                                        and startdate <= :todaysDate and enddate >= :todaysDate];  
        for (ServiceContract servcontract : servicecontracts) {  
            serviceContractSet.add(servContract.id);
            system.debug('Service Contract Id ' + servContract.Id);
        }

        if (serviceContractSet.IsEmpty()){
            return;
        }

        // Build a map of Active Contract Line Items for each Service Contract
        List<ContractLineItem> contLineItems = [select Id, SBQQSC__ProductName__c,SBQQSC__RequiredById__c,SBQQSC__SubscriptionStartDate__c,End_Terminated_Date__c,
                                                    Category__c, SBQQSC__RequiredByProduct__c, SBQQSC__Account__c
                                                    from ContractLineItem
                                                    where Category__c = 'Support Fee'
                                                    and ServiceContractId in :serviceContractSet 
                                                    and SBQQSC__SubscriptionStartDate__c <= :todaysDate
                                                    and End_Terminated_Date__c >= :todaysDate];
        Map<Id, List<ContractLineItem>> accountCLIMap = new Map<Id, List<ContractLineItem>>(); 
 
        for (ContractLineItem cliItem : contLineItems) {
            if (accountCLIMap.containsKey(cliItem.SBQQSC__Account__c)) {
                accountCLIMap.get(cliItem.SBQQSC__Account__c).add(cliItem);
            }
            else {
                accountCLIMap.put(cliItem.SBQQSC__Account__c, new List<ContractLineItem>{ cliItem });
            }
        }

        // Build a map of current Account Service Products for each Account
        List<Account_Service_Product__c> aspItems = [select id, AccountId__c, Service_Product_LU__c
                                                    from Account_Service_Product__c
                                                    where AccountId__c in :accountSet];
        Map<Id, Set<Id>> aspMap = new Map<Id, Set<Id>>(); 

        for (Account_Service_Product__c aspItem : aspItems) {
            if (aspMap.containsKey(aspItem.AccountId__c)) {
                aspMap.get(aspItem.AccountId__c).add(aspItem.Service_Product_LU__c);
            }
            else {
                aspMap.put(aspItem.AccountId__c, new Set<Id>{ aspItem.Service_Product_LU__c });
            }
        }

        // build a map of the Service Product/Sales Product
        List<Product2> prodItems = [SELECT Id,Service_Product__c FROM Product2 where service_product__c != null];
        Map<Id, String> prodMap = new Map<Id, String>(); 

        for (Product2 prodItem : prodItems) {
            prodMap.put(prodItem.Id, prodItem.Service_Product__c);
        }

        List<Account_Service_Product__c> aspInsert = new List<Account_Service_Product__c>();
        List<Account_Service_Product__c> aspDelete = new List<Account_Service_Product__c>();
        Set<String> aspDelSet = new Set<String>();

        //Process the Accounts
        for (Id accId :accountSet){
            Set<Id> cliServProd = new Set<Id>(); // the list of service products built from the Contract Line Items
            Set<Id> accServProd = new Set<Id>();
            
            if (aspMap.containsKey(accId)) { // build the list of Service products for this account
                accServProd = (aspMap.get(accId));
            }

            if (!accountCLIMap.containsKey(accId)) { // we have an account but no Contract Line Items
                // delete all the accservprod records
                for (Id aspId :accServProd){
                    aspDelSet.add(accId + ':' + aspId);
                }
                continue; 
            }
            //get the contract line items for the account
            if (accountCLIMap.containsKey(accId)) {
                List<ContractLineItem> accCliLineItems = accountCLIMap.get(accId);
                Id servProdId = null;
                for (ContractLineItem accCliLineItem : accCliLineItems) {
                    //build Service Product Set from the contract line items for this Account
                    if (prodMap.containsKey(accCliLineItem.SBQQSC__RequiredByProduct__c)) {
                        servProdId = prodMap.get(accCliLineItem.SBQQSC__RequiredByProduct__c);
                        cliServProd.add(servProdId);
                    }
                }

                // look for service products that are no longer required
                for (Id aspId :accServProd){
                    if (!cliServProd.contains(aspId)){
                        aspDelSet.add(accId + ':' + aspId);
                    }
                } 
                // look for service products that do not exist yet
                for (Id cliaspId :cliServProd){
                    if (accServProd.contains(cliaspId)){
                        continue;
                    }
                    else{
                        Account_Service_Product__c aspi = new Account_Service_Product__c(
                            AccountId__c = accId,
                            Service_Product_LU__c = cliaspId);
                        aspInsert.add(aspi);
                    }
                } 
            }
        }

        // We've processed all the accounts
        // build the list of Account Service Product rows to be deleted based on the set we built
        if (!aspDelSet.isEmpty()){
            for (Account_Service_Product__c aspToDelete : aspItems) {
                if (aspDelSet.contains(aspToDelete.AccountId__c + ':' + aspToDelete.Service_Product_LU__c)){
                    aspDelete.add(aspToDelete);
                }
            } 
        }

        if (!aspInsert.isEmpty()){
            insert aspInsert;
        }

        if (!aspDelete.isEmpty()){
            delete aspDelete;
        }

    }


}