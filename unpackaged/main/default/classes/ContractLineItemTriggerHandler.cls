/**
 * @description       : Acquires the Accounts affected by the Contract Line items being maintained.
 *                      The set of Accounts is then used to ensure the Account Service Products match the licenced products based on Active Contracts.
 * @author            : Grant Hamlyn
 * @group             : 
 * @last modified on  : 11-03-2021
 * @last modified by  : Grant Hamlyn
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-03-2021   Grant Hamlyn   Initial Version (SCE-881)
 * 2.0   08-03-2021   Grant Hamlyn   Add the call to process all affected Accounts
 * 2.1   10-03-2021   Grant Hamlyn   Process both before and after for update just in case Account was changed                                  
**/
public class ContractLineItemTriggerHandler {
    
    static public void onAfterInsert(ContractLineItem[] newCLI) {
        // Build list of Accounts
        set<Id> accountSet = buildAccountSet(newCLI);
        AccServProdProcess.processAccounts(accountSet);
    }

    static public void onAfterUpdate(ContractLineItem[] newCLI, Map<ID, ContractLineItem> oldMap) {
        // Build list of Accounts
        set<Id> accountIds = new set<Id>();
        for(ContractLineItem updatedCLI : newCLI) {
            ContractLineItem beforeUpdate = oldMap.get(updatedCLI.Id);
            accountIds.add(updatedCLI.SBQQSC__Account__c);
            accountIds.add(beforeUpdate.SBQQSC__Account__c); // just in case the account changed
        }
        AccServProdProcess.processAccounts(accountIds);
    }

    static public void onAfterDelete(Map<ID, ContractLineItem> oldMap) {
        // build the Account set from the old map
        list <ContractLineItem> newCLI = oldMap.values();
        set<Id> accountSet = buildAccountSet(newCLI);
        AccServProdProcess.processAccounts(accountSet);
    } 
 
    static public Set<Id> buildAccountSet (ContractLineItem[] newCLI){
        // create the set of Account Ids
        set<Id> accountIds = new set<Id>(); // list of Account Id's from ContractLineItems
                    
        for(ContractLineItem newCLIs : newCLI){
            // Include the Account if Service Fee related
            if(newClIs.Category__c == 'Support Fee'){
                accountIds.add(newCLIs.SBQQSC__Account__c);
            }
        } 
        
        return accountIds;

    } 

}