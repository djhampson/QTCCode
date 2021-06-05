/**
 * @description       : 
 * @author            : Grant Hamlyn
 * @group             : 
 * @last modified on  : 24-03-2021
 * @last modified by  : Grant Hamlyn
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   
 * 1.1   05-03-2021   Grant Hamlyn   (SCE-881) Bypass code until we implement this ECM integration properly   
**/
public class AccountTriggerHandler {
    
    static public void onAfterInsert(Account[] newAccounts) {
        
        ECMSettings__c s = ECMSettings__c.getOrgDefaults(); 

         // 05-03-2021 Temporary bypass of processing
        if(!Test.isRunningTest()){
            return;
        }
         // 05-03-2021 Temporary bypass of processing
        
        String ECM_url = '';
        String ECM_params = '';
        If(s.url__c != null){
            ECM_url = s.url__c; 
        }
        If(s.params_csv__c != null){
            ECM_params = s.params_csv__c; 
        }
        
        for (Account newAccount : newAccounts) {
            if (newAccount.Type == 'Prospect' && !Test.isRunningTest()){
                ECMCallout.createCustomerIndex(newAccount.Name, newAccount.Id, ECM_url, ECM_params);
            }
        }
    }

    /* static public void onAfterUpdate(Account[] updatedAccounts, Map<ID, Account> oldMap) {
        for (Account updatedAccount : updatedAccounts) {
            Account beforeUpdate = oldMap.get(updatedAccount.Id);
            if (updatedAccount.Type != beforeUpdate.Type && updatedAccount.Type == 'Prospect') { 
            }
        }
    } */
}