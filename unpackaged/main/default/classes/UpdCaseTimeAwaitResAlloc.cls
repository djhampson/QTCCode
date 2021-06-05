global class UpdCaseTimeAwaitResAlloc implements
   Database.Batchable<sObject>{

   /*
    execute this class via Developer Console with the following code
        UpdCaseTimeAwaitResAlloc c = new UpdCaseTimeAwaitResAlloc();
        Database.executeBatch(c);
   */
       
   //global final String query;
   
   //global batchProcess(String q) {
   //    query = q;
   //}

   global Database.QueryLocator start(Database.BatchableContext BC){
       // query hardcoded for ease
      String query = 'select id, CaseNumber, CreatedDate, BusinessHoursId, Status, Time_Await_Res_Alloc__c, Contact.AccountId, AccountId, RecordType.Name, IsClosed, Resolved_Date__c, ClosedDate, Last_Status_Change__c from Case where recordtype.name in (\'I require Consulting services\', \'I require an AMS service\') and Status = \'Awaiting Resource Allocation\'';
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
                    
        if(s.Bypass_Triggers__c == false || s.Bypass_Validation_Rules__c == false || s.Bypass_Workflow__c == false) {
            system.debug('Triggers etc have not been bypassed. No processing has occurred. ');           
            return; 
        }

        list <case> l_cases = new list<case>(); //list of cases to be updated
        Datetime dateFrom = null;
        Datetime dateTo = null;
        Integer numCases = 0;
        Id busHrsToUse;
        Integer hrsInDay = 1;
        
        // TechnologyOne Account used to verify valid Case Contact
        Account t1Acc = [select id from Account where name = 'TechnologyOne' limit 1];
 
        //Get the default business hours 
        //Default Business Hours carry the work day hours. We take Monday Start and End Times to calculate the hours in the day.
        List<BusinessHours> BusHrs = [select Id, MondayStartTime, MondayEndTime from BusinessHours where IsDefault=true limit 1];
        for (BusinessHours BusHr:BusHrs){
            busHrsToUse = BusHr.Id;
            hrsInDay = (BusHr.MondayEndTime.hour() - BusHr.MondayStartTime.hour());
        }
        
        if(busHrsToUse == null)
        {
            system.debug('No default Business Hours');
            return;
        }
                    
        List<Case> casesToUpd = scope;
        
        //For all cases
        for (Case updCase : casesToUpd) {
            
            // bypass if invalid contact - Lookup demands T1 Account or Contact Account
            /*if (updCase.Contact.AccountId != updCase.AccountId && updCase.AccountId != t1Acc.Id){
                system.debug('Invalid Case Contact ' + updCase.CaseNumber);
                continue;
            }*/
            
            system.debug('Case ' + updCase.CaseNumber + ' Status ' + updCase.Status);
            
            // initialise values
            updCase.Time_Await_Res_Alloc__c = 0;
            numCases ++;
            
            // Now calculate the time to complete values
            //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
            //Calculate Duration 
            Double duration;
            duration = BusinessHours.diff(busHrsToUse, updCase.Last_Status_Change__c, system.now())/3600000.0;
            System.debug(duration);
            duration = duration / hrsInDay;
            updCase.Time_Await_Res_Alloc__c = duration;
            
            // only update the case if we have some change that warrants it
            if (updCase.Time_Await_Res_Alloc__c > 0){
                l_cases.add(updCase);
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
       mail.setSubject('Batch Update Time Await Res Alloc Status: ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }
}