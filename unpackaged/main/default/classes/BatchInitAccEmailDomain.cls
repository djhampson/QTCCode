global class BatchInitAccEmailDomain implements 
   Database.Batchable<sObject>{

   /*
    execute this class via Developer Console with the following code
        BatchInitAccEmailDomain c = new BatchInitAccEmailDomain();
        Database.executeBatch(c);
   */
       
   global Database.QueryLocator start(Database.BatchableContext BC){
       // query hardcoded for ease
      String query = 'select id, type, name, email_domain__c, support_live__c from Account where type = \'Customer\'';
       
      if(Test.isRunningTest())
          query = 'select id, type, name, email_domain__c, support_live__c from Account where type = \'Customer\' limit 100';
       
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

        list<Account> l_Accs = new list<Account>(); //list of accounts to be updated
        List<Account> accountList = scope;
        
        //For all ideas
        for (Account updAcc : accountList) {
            Set<String> emDomains = new Set<String>();
            //Map<String, Integer> emdom = new Map<String, Integer>();
            Integer intIndex = 0;
            Integer intLength = 0;
            String sEmailDomain = '';
            //build a list of domains for this Account
            List<Contact> contList = [Select c.Email From Contact c where c.AccountId = :updAcc.Id and c.Email <> null and c.employment_status__c = 'Employed'];
            if (contList.isEmpty()==false){
                for (Contact contObj:contList) {
                    intIndex = contObj.Email.indexOf('@');
                    intLength = contObj.Email.length();
                    sEmailDomain = contObj.Email.substring(intIndex + 1, intLength);
                    system.debug('Email domain = ' + sEmailDomain);
                    emDomains.add(sEmailDomain);
                }
            }
            String semdom = '';
            //process the list of domains and insert multi values into the field
            if (emDomains.size() > 0) {
                for (String sDom:emDomains){
                    if (semDom == ''){
                        semDom = sDom;
                    }
                    else {
                        semdom = semdom + ' ' + sDom;
                    }
                    /* if (emDomains.size() == 1) {
                        updAcc.Email_Domain__c = sDom;
                        l_Accs.add(updAcc);
                        break;
                    } */
                    //get the count into map
                    /* String sDomQuery = '%' + sDom + '%';
                    Integer domcount = [Select count() from contact c where c.AccountId = :updAcc.Id and c.Email like :sDomQuery];
                    if (domcount > 0)
                        emdom.put(sDom, domcount); */
                }
                //now we have the count for each domain we can find the domain with the largest number of contacts
               /*  String semdom = '';
                Integer semCount = 0;
                for (String dommap : emdom.keySet()){
                    if (emdom.get(dommap) > semCount){
                        semCount = emdom.get(dommap);
                        semdom = dommap;
                    }
                }
                // we now have the domain with the largest number of contacts
                //update the account with the appropriate domain
                if (semdom > ''){
                    updAcc.Email_Domain__c = semdom;
                    l_Accs.add(updAcc);
                } */
                if (semdom > ''){
                    updAcc.Email_Domain__c = semdom;
                }
            }
            updAcc.Support_Live__c = true;
            l_Accs.add(updAcc);
            system.debug('Account: ' + updAcc.Name + ', Email Domain: ' + semdom);
        }
        
        if (!l_Accs.isEmpty()) {
            system.debug('Accounts effected ' + l_Accs.size());
            // DML statement
            Database.SaveResult[] srList = Database.update(l_Accs, false);
            
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
       mail.setSubject('BatchInitAccEmailDomain Status: ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }

       
       
}