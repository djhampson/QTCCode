/**
 * @description       : Class to update Account Service Products from active Service Contracts for All Accounts where licensing is managed via CPQ
 * @author            : Grant Hamlyn
 * @group             : 
 * @last modified on  : 01-06-2021
 * @last modified by  : Grant Hamlyn
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   16-03-2021   Edo Manik      Initial Version
 * 1.1   24-03-2021   Grant Hamlyn   Rename class and tidy up
 * 1.2   01-06-2021   Grant Hamlyn   Correct spelling mistake in soql string
**/
global class BatchBulkAccServProdCPQ implements 
   Database.Batchable<sObject>{

   /*
    execute this class via Developer Console with the following code
        BatchBulkAccServProdCPQ c = new BatchBulkAccServProdCPQ();
        Database.executeBatch(c);
   */
       
   global Database.QueryLocator start(Database.BatchableContext BC){
        // query hardcoded for ease
        // Process all Customer Accounts where licensing is managed by CPQ. SRS Accounts are handled differently.
      String query = 'select id from Account where Type = \'Customer\' and cpq_migration_status__c = \'Complete\'';
       
      if(Test.isRunningTest())
          query = 'select id from Account where Type = \'Customer\' and cpq_migration_status__c = \'Complete\' limit 100';
       
      return Database.getQueryLocator(query);
   }
   
   global void execute(
                Database.BatchableContext BC, 
                List<sObject> scope){

        // ensure triggers, workflow and validation rules are deactivated          
        T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
        s.Bypass_Triggers__c = true;
        s.Bypass_Validation_Rules__c = true;
        s.Bypass_Workflow__c = true;
        s.Customer_Community_URL__c = '';
        s.Employee_Community_URL__c = '';
        s.Internal_URL__c = '';
        s.Closed_Date_for_Archiving_Email__c = null;
        upsert s;
                    
        // ensure triggers, workflow and validation rules are deactivated    
        if(s.Bypass_Triggers__c == false || s.Bypass_Validation_Rules__c == false || s.Bypass_Workflow__c == false) {
            system.debug('Triggers etc have not been bypassed. No processing has occurred. ');           
            return; 
        }

        Set<Id> AccIdSet = new Set<Id>(); //set of ids to be proceed
        List<Account> accountList = scope;
        
        for (Account updAcc : accountList) {
            
              	AccIdSet.add(updAcc.Id);                 
            
        }
        
        if (!AccIdSet.isEmpty()) {
            system.debug('Accounts effected ' + AccIdSet.size());
            AccServProdProcess.processAccounts(AccIdSet);
        }
                    
   }

   global void finish(Database.BatchableContext BC){
       AsyncApexJob a = 
           [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =
            :BC.getJobId()];
       
       // Now reset the bypass values        
       T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
       s.Bypass_Triggers__c = false;
       s.Bypass_Validation_Rules__c = false;
       s.Bypass_Workflow__c = false;
       s.Customer_Community_URL__c = '';
       s.Employee_Community_URL__c = '';
       s.Internal_URL__c = '';
       s.Closed_Date_for_Archiving_Email__c = null;
       upsert s;
                                
       // Send an email to the Apex job's submitter 
       // notifying of job completion. 
       //   
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('BatchBulkAccServProdCPQ Status: ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }

       
       
}