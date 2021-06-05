global class BatchUpdateCaseType implements 
   Database.Batchable<sObject>{

   /*
    execute this class via Developer Console with the following code
        BatchUpdateCaseType c = new BatchUpdateCaseType ();
        Database.executeBatch(c);
   */
       
   global integer numcases = 0;
   //global final String query;
   
   //global batchProcess(String q) {
   //    query = q;
   //}

   global Database.QueryLocator start(Database.BatchableContext BC){
       // query hardcoded for ease
      String query = 'SELECT id, RecordType.Name, Type, CaseNumber FROM Case c';
      
      if(Test.isRunningTest())
          query = 'SELECT id, RecordType.Name, Type, CaseNumber FROM Case c order by CaseNumber desc limit 100';
          
      return Database.getQueryLocator(query);
   }
   
   global void execute(
                Database.BatchableContext BC,
                List<sObject> scope){
   
        // ensure triggers, workflow and validation rules are deactivated          
        T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
     
        if(s.Bypass_Triggers__c == false || s.Bypass_Validation_Rules__c == false || s.Bypass_Workflow__c == false) {
            system.debug('Triggers etc have not been bypassed. No processing has occurred. ');           
            return; 
        }

        list <case> l_cases = new list<case>(); //list of cases to be updated
        
        Datetime lastDate   = null;
        numCases = 0;
        String caseType = '';
                    
        List<Case> cases = scope;
                    

        //For all cases
        for (Case updCase : cases) {
            
            // bypass Change Requests
            if (updCase.RecordType.Name == 'Change Control'){
                continue;
            }

            //system.debug('Case ' + updCase.CaseNumber);
           
            if (updCase.RecordType.Name == 'Consulting - Question'){
                caseType = 'Consulting Question';
            }
            else if (updCase.RecordType.Name == 'I am experiencing an issue'){
                caseType = 'Incident';
            }
            else if (updCase.RecordType.Name == 'I have a Question'){
                caseType = 'Question';
            }
            else if (updCase.RecordType.Name == 'I require Consulting services'){
                caseType = 'Service Request';
            }
            else if (updCase.RecordType.Name == 'I require a TechnologyOne Cloud service'){
                caseType = 'Service Request';
            }
            else if (updCase.RecordType.Name == 'I require an AMS service'){
                caseType = 'Service Request';
            }
             else if (updCase.RecordType.Name == 'Service Request'){
                caseType = 'Service Request';
            }
            else {
                continue;
            }
            
            if (updCase.Type != caseType ) {
                updCase.Type = caseType;
                l_cases.add(updCase);
                system.debug('Case ' + updCase.CaseNumber);
                numCases ++;

        	}
        }
        
        if (!l_cases.isEmpty()) {
            system.debug('Cases effected ' + numCases);
            // DML statement
            Database.SaveResult[] srList = Database.update(l_cases, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
   }

   global void finish(Database.BatchableContext BC){
       AsyncApexJob a = 
           [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =
            :BC.getJobId()];
                          
       // Send an email to the Apex job's submitter 
       //   notifying of job completion. 
       //   
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Batch Update Case Type Status: ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }
}