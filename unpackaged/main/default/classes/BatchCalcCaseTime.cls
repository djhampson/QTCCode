global class BatchCalcCaseTime implements 
   Database.Batchable<sObject>{

   /*
    execute this class via Developer Console with the following code
        batchCalcCaseTime c = new batchCalcCaseTime();
        Database.executeBatch(c);
   */
       
   //global final String query;
   
   //global batchProcess(String q) {
   //    query = q;
   //}

   global Database.QueryLocator start(Database.BatchableContext BC){
       // query hardcoded for ease
      String query = 'select id, CaseNumber, CreatedDate, BusinessHoursId, Status, Time_With_Customer__c, Time_With_Support__c, Contact.AccountId, AccountId, RecordType.Name, IsClosed, Resolved_Date__c, ClosedDate, Last_Status_Change__c, Duration_to_Closed_Cal_Days__c, Duration_to_Resolved_Cal_Days__c, (select CreatedDate, NewValue, OldValue from histories where field = \'Status\' order by CreatedDate Asc) from Case where Jira_Issue_No__c = null and lastmodifieddate < 2019-01-22T00:00:00Z limit 10000';

      if(Test.isRunningTest())
	       query = 'select id, CaseNumber, CreatedDate, BusinessHoursId, Status, Time_With_Customer__c, Time_With_Support__c, Contact.AccountId, AccountId, RecordType.Name, IsClosed, Resolved_Date__c, ClosedDate, Last_Status_Change__c, Duration_to_Closed_Cal_Days__c, Duration_to_Resolved_Cal_Days__c, (select CreatedDate, NewValue, OldValue from histories where field = \'Status\' order by CreatedDate Asc) from Case limit 100';
      
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
        
        Datetime Last_Status_Change = null;
        Integer numCases = 0;
        Double Closed_Cal_Days = 0;
        Double Resolved_Cal_Days = 0;
        Id busHrsToUse;
        Integer hrsInDay = 1;
        
        //Get the stop statuses
        Set<String> stopStatusSet = new Set<String>();
        for (Stop_Status__c stopStatus:[Select Name From Stop_Status__c]) {
            stopStatusSet.add(stopStatus.Name);
        }

        // TechnologyOne Account used to verify valid Case Contact
        Account t1Acc = [select id from Account where name = 'TechnologyOne' limit 1];
 
        //Get the default business hours 
        //Default Business Hours carry the work day hours. We take Monday Start and End Times to calculate the hours in the day.
        List<BusinessHours> BusHrs = [select Id, MondayStartTime, MondayEndTime from BusinessHours where IsDefault=true limit 1];
        for (BusinessHours BusHr:BusHrs){
            busHrsToUse = BusHr.Id;
            hrsInDay = (BusHr.MondayEndTime.hour() - BusHr.MondayStartTime.hour());
        }
                    
        //Get the closed statuses (because at the point of this trigger Case.IsClosed won't be set yet)
        Set<String> closedStatusSet = new Set<String>();
        for (CaseStatus status:[Select MasterLabel From CaseStatus where IsClosed=true]) {
            closedStatusSet.add(status.MasterLabel);
        }
        
        List<Case> caseWithHistory = scope;
        
        //For all cases
        for (Case updCase : caseWithHistory) {
            
            // bypass if invalid contact - Lookup demands T1 Account or Contact Account
            /*if (updCase.Contact.AccountId != updCase.AccountId && updCase.AccountId != t1Acc.Id){
                system.debug('Invalid Case Contact ' + updCase.CaseNumber);
                continue;
            }*/
            
            // bypass Change Requests
            if (updCase.RecordType.Name == 'Change Control'){
                continue;
            }

            system.debug('Case ' + updCase.CaseNumber + ' Status ' + updCase.Status);
            Last_Status_Change = updCase.CreatedDate; // initialise the date for the Case
            //On the off-chance that the business hours on the case are null, use the default ones instead
            Id hoursToUse = updCase.BusinessHoursId!=null?updCase.BusinessHoursId:busHrsToUse;
            
            // initialise values
            updCase.Time_With_Customer__c = 0;
            updCase.Time_With_Support__c = 0;
            updCase.Duration_to_Closed_Cal_Days__c = 0;
            updCase.Duration_to_Resolved_Cal_Days__c = 0;
            numCases ++;
            
            // get status history                
            for (CaseHistory caseHistory : updCase.histories) {
                 
                 //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
                 Double timeSinceLastStatus = BusinessHours.diff(hoursToUse, Last_Status_Change, caseHistory.CreatedDate)/3600000.0;
                 System.debug(timeSinceLastStatus);
                 
                 //We decide which bucket to add it to based on whether it was in a stop status before
                 if (stopStatusSet.contains(string.valueOf(caseHistory.OldValue).Trim())) {
                     updCase.Time_With_Customer__c += timeSinceLastStatus;
                     system.debug('Time with Customer ' + updCase.Time_With_Customer__c);
                 } else {
                     updCase.Time_With_Support__c += timeSinceLastStatus;
                     system.debug('Time with Support ' + updCase.Time_With_Support__c);
                 }
                 
                 if (closedStatusSet.contains(string.valueOf(caseHistory.NewValue).Trim())) {
                     updCase.Case_Age_In_Business_Hours__c = updCase.Time_With_Customer__c + updCase.Time_With_Support__c;
                 }
                 
                 if (string.valueOf(caseHistory.NewValue).Trim()=='Resolved') {
                     updCase.Resolved_Date__c = caseHistory.CreatedDate;
                 }

                 Last_Status_Change = caseHistory.CreatedDate;
                 updCase.Last_Status_Change__c = caseHistory.CreatedDate;
                 
            }
            
            // Finished processing History, let's check if we set the Resolved Date
            if (updCase.IsClosed == True && updCase.Resolved_Date__c == null && updCase.ClosedDate != null) {
                updCase.Resolved_Date__c = updCase.ClosedDate;
            }
            
            // Now calculate the time to complete values
            if (updCase.ClosedDate != null) {
                //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
                //Calculate Duration to Closed
                Double duration;
                duration = BusinessHours.diff(busHrsToUse, updCase.CreatedDate, updCase.ClosedDate)/3600000.0;
                System.debug(duration);
                Closed_Cal_Days = duration / hrsInDay;
                updCase.Duration_to_Closed_Cal_Days__c = Closed_Cal_Days;
            }
            if (updCase.Resolved_Date__c != null) {
                //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
                //Calculate Duration to Resolved
                Double duration;
                duration = BusinessHours.diff(busHrsToUse, updCase.CreatedDate, updCase.Resolved_Date__c)/3600000.0;
                System.debug(duration);
                Resolved_Cal_Days = duration / hrsInDay;
                updCase.Duration_to_Resolved_Cal_Days__c = Resolved_Cal_Days;
            }
            
            // only update the case if we have some change that warrants it
            if (updCase.Time_With_Customer__c > 0 || updCase.Time_With_Support__c > 0 || updCase.Resolved_Date__c != null || updCase.Duration_to_Closed_Cal_Days__c > 0 || updCase.Duration_to_Resolved_Cal_Days__c > 0){
                l_cases.add(updCase);
            }
            
            Last_Status_Change = null;
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
       mail.setSubject('Batch calcCaseTime Status: ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }
}