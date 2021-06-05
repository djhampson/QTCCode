global class batchDeleteAccServProd implements 
   Database.Batchable<sObject>{

   /*
    execute this class via Developer Console with the following code
        batchDeleteAccServProd c = new batchDeleteAccServProd();
        Database.executeBatch(c);
   */
       
   global Database.QueryLocator start(Database.BatchableContext BC){
       // query hardcoded for ease
      String query = 'SELECT id FROM Account_Service_Product__c ';
       
      if(Test.isRunningTest())
          query = 'SELECT id FROM Account_Service_Product__c limit 100';
       
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
            T1_Process_Log__c procLog = new T1_Process_Log__c(Process_Name__c = 'batchDeleteAccServProd',
                                      Process_Message__c = 'Triggers etc have not been bypassed. No processing has occurred.');
            insert procLog;
            system.debug('Triggers etc have not been bypassed. No processing has occurred. ');           
            return; 
        }

        Try {
            List<Account_Service_Product__c> l_asp = scope;
            
            if (!l_asp.isEmpty()) {
                T1_Process_Log__c procLog = new T1_Process_Log__c(Process_Name__c = 'batchDeleteAccServProd',
                                          Process_Message__c = 'Account Service Products deleted ' + l_asp.size());
                insert procLog;
                system.debug('Account Service Products deleted ' + l_asp.size());
                delete l_asp;
                DataBase.emptyRecycleBin(l_asp);
            }
        } catch(Exception e) {
            T1_Process_Log__c procLog = new T1_Process_Log__c(Process_Name__c = 'batchDeleteAccServProd',
                Process_Message__c =  e.getMessage().substring(0,254));
                insert procLog;
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
       //   notifying of job completion. 
       //   
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Batch batchDeleteAccServProd Status: ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }

       
       
}