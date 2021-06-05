global class BatchInitIdeaNumber implements 
   Database.Batchable<sObject>{

   /*
    execute this class via Developer Console with the following code
        BatchInitIdeaNumber c = new BatchInitIdeaNumber();
        Database.executeBatch(c);
   */
       
   global Database.QueryLocator start(Database.BatchableContext BC){
       // query hardcoded for ease
      String query = 'select id, Idea_Number__c, Body, CommunityId from Idea';
       
      if(Test.isRunningTest())
          query = 'select id, Idea_Number__c, Body, CommunityId from Idea limit 100';
       
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

        Integer numIdeas = 0;
        list<Idea> l_ideas = new list<Idea>(); //list of ideas to be updated
        List<Idea> ideaList = scope;
        
        //For all ideas
        for (Idea updIdea : ideaList) {
            
            // bypass if already contains Idea Number in Body
            /*if (updIdea.Body.startsWithIgnoreCase('Idea Number - 2')){
                continue;
            }*/

            String strZone;
            strZone = [SELECT name 
                FROM Community
                WHERE Id = :updIdea.CommunityId ].name;

            if (strZone.startsWithIgnoreCase('Internal')) {
              continue;
            }
            
            String strBody;
            String strToReplace;
            strToReplace = 'Idea Number - ' + updIdea.Idea_Number__c.trim() + '<br>';
            try{
                strBody = updIdea.Body.replace(strToReplace, '');
            }
            catch(Exception e){
                continue;
            }
            
            system.debug('Before - ' + updIdea.Body);
            updIdea.Body = strBody;
            system.debug('After - ' + updIdea.Body);
            numIdeas ++;
            l_ideas.add(updIdea);
            
        }
        
        if (!l_ideas.isEmpty()) {
            system.debug('Ideas effected ' + numIdeas);
            // DML statement
            Database.SaveResult[] srList = Database.update(l_ideas, false);
            
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
       mail.setSubject('Batch initIdeaNmuber Status: ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }

       
       
}