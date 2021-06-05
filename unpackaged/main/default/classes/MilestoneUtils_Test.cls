@isTest(SeeAllData=True)
private class MilestoneUtils_Test{

 
 
 static testMethod void testCompleteMilestoneCase(){
    
        User u3;
    
        try{
            u3 = [SELECT Id FROM User WHERE UserName='timreynolds177@gmail.com.dev']; // DEV user
        }
        catch(Exception e)
        {
            try{
                u3 = [SELECT Id FROM User WHERE UserName='timreynolds177@gmail.com.uat']; // UAT user
            }
            catch(Exception e2)
            {
                try{
                    u3 = [SELECT Id FROM User WHERE UserName='testpartner1@technologyonecorp.com']; //Prod user
                }
                catch(Exception e3)
                {
                    try{
                        u3 = [SELECT Id FROM User WHERE UserName='timreynolds177@gmail.com']; // Prod user
                
                    }
                    catch(Exception e4)
                    {
                        
                    }
                }
            }
            
        }
        
        ID rectypeid;
        List<RecordType> RecType = [select id, name from RecordType where sobjecttype = 'Case'];
        
        for (RecordType recT :RecType){
            if (recT.name == 'I am experiencing an issue')
                rectypeid = recT.id;
        }

        Account ac = new Account();
                    ac.type = 'Customer';
                    ac.CountryArea__c = 'Australia';
                    ac.Region__c = 'ACT';
                    ac.Vertical_Market__c = 'Education';
                    ac.T1_Industry__c = 'Other';
                    ac.Name = 'Test Account';
        Insert ac;
            
        //run as partner user
        System.runAs(u3) {

             SlaProcess slaProc = [Select id From SlaProcess  where isactive = true and name like 'gitc%' order by versionnumber desc limit 1];
             
             Contact con = new Contact();
                    con.AccountId = ac.id;
                    con.LastName = 'Test Contact';
                    con.Title = 'Mr';
                    con.Job_Classification__c = 'A';
                    con.email = 'abc@123.com';
             Insert con;
                    
             Entitlement ent = new Entitlement();
                    ent.name = 'Test Entitlement';
                    ent.AccountId = ac.id;
                    ent.StartDate = Date.Today() - 1;
                    ent.EndDate = Date.Today() + 1;
                    ent.SlaProcessId = slaProc.Id;
             Insert ent;
                                    
            
            List<Case> cases = new List<Case>{};
            if (ent.Id != null){
              Case c = new Case(Subject = 'Test Case with Entitlement ', EntitlementId = ent.Id, AccountId = ac.id, ContactId = con.Id, Jira_Issue_No__c = 'ABC',
                               Description = 'A Description', Customer_Product__c = 'Financials (FIN)', Affected_Version__c = 'non-Production', 
                                 Work_around_Details__c = 'A bit of text', CFunctional_Area__c = 'testing', 
                                 Has_it_worked_before__c = 'No', Is_there_a_scalable_work_around__c = 'No', Steps_to_reproduce__c = '12345678910',
                                 RecordTypeId = rectypeid );
              cases.add(c);
            }
            
            // Insert the Account records that cause the trigger to execute.
            if (cases.isEmpty()==false){
              insert cases;
              List<Id> caseIds = new List<Id>();
              for (Case cL : cases){
                caseIds.add(cL.Id);
              }
              milestoneUtils.completeMilestone(caseIds, 'First Response', System.now());
                }
        }
     
     // run as admin
     SlaProcess slaProc = [Select id From SlaProcess  where isactive = true and name like 'gitc%' order by versionnumber desc limit 1];
     Account ac2 = new Account();
     ac2.type = 'Customer';
     ac2.CountryArea__c = 'Australia';
     aC2.Region__c = 'ACT';
     ac2.Vertical_Market__c = 'Education';
     ac2.T1_Industry__c = 'Other';
     ac2.Name = 'Test Account2';
     Insert ac2;
     
     Contact con = new Contact();
     con.AccountId = ac2.id;
     con.LastName = 'Test Contact2';
     con.Title = 'Mr';
     con.Job_Classification__c = 'A';
     con.email = 'abc2@123.com';
     Insert con;
     
     Entitlement ent = new Entitlement();
     ent.name = 'Test Entitlement2';
     ent.AccountId = ac2.id;
     ent.StartDate = Date.Today() - 1;
     ent.EndDate = Date.Today() + 1;
     ent.SlaProcessId = slaProc.Id;
     Insert ent;
     
     
     List<Case> cases = new List<Case>{};
         if (ent.Id != null){
             Case c = new Case(Subject = 'Test Case with Entitlement ', EntitlementId = ent.Id, AccountId = ac2.id, ContactId = con.Id, Jira_Issue_No__c = 'ABC',
                              Description = 'A Description', Customer_Product__c = 'Financials (FIN)', Affected_Version__c = 'non-Production', 
                                 Work_around_Details__c = 'A bit of text', CFunctional_Area__c = 'testing', 
                                 Has_it_worked_before__c = 'No', Is_there_a_scalable_work_around__c = 'No', Steps_to_reproduce__c = '12345678910',
                                 RecordTypeId = rectypeid );
             cases.add(c);
         }
     
     // Insert the Account records that cause the trigger to execute.
     if (cases.isEmpty()==false){
         insert cases;
         List<Id> caseIds = new List<Id>();
         for (Case cL : cases){
             caseIds.add(cL.Id);
         }
         milestoneUtils.completeMilestone(caseIds, 'First Response', System.now());
     }
    }
  
    static testMethod void testCompleteMilestoneViaCase(){
    
        User u3;
    
        try{
            u3 = [SELECT Id FROM User WHERE UserName='timreynolds177@gmail.com.dev']; // DEV user
        }
        catch(Exception e)
        {
            try{
                u3 = [SELECT Id FROM User WHERE UserName='timreynolds177@gmail.com.uat']; // UAT user
            }
            catch(Exception e2)
            {
                try{
                    u3 = [SELECT Id FROM User WHERE UserName='testpartner1@technologyonecorp.com']; //Prod user
                }
                catch(Exception e3)
                {
                    try{
                        u3 = [SELECT Id FROM User WHERE UserName='timreynolds177@gmail.com']; // Prod user
                
                    }
                    catch(Exception e4)
                    {
                        
                    }
                }
            }
        }  

        ID rectypeid;   
        List<RecordType> RecType = [select id, name from RecordType where sobjecttype = 'Case'];
        
        for (RecordType recT :RecType){
            if (recT.name == 'I am experiencing an issue')
                rectypeid = recT.id;
        }

         SlaProcess slaProc = [Select id From SlaProcess  where isactive = true and name like 'gitc%' order by versionnumber desc limit 1];
            // Perform data preparation
         Account ac = new Account();
                ac.type = 'Customer';
                ac.CountryArea__c = 'Australia';
                ac.Vertical_Market__c = 'Education';
                ac.T1_Industry__c = 'Other';
                ac.Region__c = 'ACT';
                ac.Name = 'Test Account3';
         Insert ac;
        
         Contact con = new Contact();
                con.AccountId = ac.id;
                con.LastName = 'Test Contact3';
                con.Title = 'Mr';
                con.Job_Classification__c = 'A';
                con.email = 'abc3@123.com';
         Insert con;
                
         Entitlement ent = new Entitlement();
                ent.name = 'Test Entitlement3';
                ent.AccountId = ac.id;
                ent.StartDate = Date.Today() - 1;
                ent.EndDate = Date.Today() + 1;
                ent.SlaProcessId = slaProc.Id;
         Insert ent;
            
        List<Case> cases = new List<Case>{};
        //for(Integer i = 0; i < 1; i++){
            Case c1 = new Case(Subject = 'Test Case 1', AccountId = ac.id, ContactId = con.Id, Description = 'A Description', Customer_Product__c = 'Financials (FIN)', Affected_Version__c = 'non-Production', 
                                 Work_around_Details__c = 'A bit of text', CFunctional_Area__c = 'testing', 
                                 Has_it_worked_before__c = 'No', Is_there_a_scalable_work_around__c = 'No', Steps_to_reproduce__c = '12345678910',
                                 New_Customer_Attachment__c = true, RecordTypeId = rectypeid);
            cases.add(c1);
            if (ent.Id != null){
                c1 = new Case(Subject = 'Test Case with Entitlement 1', EntitlementId = ent.Id, AccountId = ac.id, ContactId = con.Id, Jira_Issue_No__c = 'ABC',
                             Description = 'A Description', Customer_Product__c = 'Financials (FIN)', Affected_Version__c = 'non-Production', 
                                 Work_around_Details__c = 'A bit of text', CFunctional_Area__c = 'testing', 
                                 Has_it_worked_before__c = 'No', Is_there_a_scalable_work_around__c = 'No', Steps_to_reproduce__c = '12345678910',
                                 RecordTypeId = rectypeid);
                cases.add(c1);
            }
        //}
        
        // Insert the Account records that cause the trigger to execute.
        insert cases;
        
        list <case> lcasea = new list<case>();
        for(Case c : cases){
          c.New_Customer_Attachment__c = true;
          lcasea.add(c);
        }
        if (!lcasea.isEmpty()){
            update lcasea;
        }

        List<CaseComment> ccs = new List<CaseComment>{};
        for(Case c : cases){
            CaseComment cc = new CaseComment(CommentBody='TestPublic', IsPublished=true, ParentId=c.Id);
            ccs.add(cc);
            cc = new CaseComment(CommentBody='TestPrivate', IsPublished=false, ParentId=c.Id);
            ccs.add(cc);
        }
        if (ccs.isEmpty()==false)
            insert ccs;

        // feed items
        // run as partner user
        
        // was commented from here
     /*   System.runAs(u3) {   
            List<FeedItem> fis = new List<FeedItem>{};
            list <case> lcase = new list<case>();
            for(Case c : cases){
                FeedItem fi = new FeedItem(Title='Test', Body='Test Post', Type='TextPost', Visibility='AllUsers', ParentId=c.Id);
                fis.add(fi);
                c.status = 'In Progress';
                lcase.add(c);
                //update c;
    
            }
            if (!lcase.isEmpty()){
                update lcase;
            }
            
            if (fis.isEmpty()==false){
                insert fis;
            
                List<FeedComment> fcs = new List<FeedComment>{};
                for(FeedItem fi : fis){
                    FeedComment fc = new FeedComment(CommentBody='Test Post', CommentType='TextComment', FeedItemId=fi.Id);
                    fcs.add(fc);
        
                }
                if (fcs.isEmpty()==false)
                    insert fcs;
                }
        }
    
        List<FeedItem> fis = new List<FeedItem>{};
        list <case> lcase = new list<case>();
        for(Case c : cases){
            FeedItem fi = new FeedItem(Title='Test', Body='Test Post', Type='TextPost', Visibility='AllUsers', ParentId=c.Id);
            fis.add(fi);
            c.status = 'In Progress';
            lcase.add(c);
            //update c;
            
        }
        if (!lcase.isEmpty()){
            update lcase;
        }
            
        if (fis.isEmpty()==false){
            insert fis;
            
            List<FeedComment> fcs = new List<FeedComment>{};
                for(FeedItem fi : fis){
                    FeedComment fc = new FeedComment(CommentBody='Test Post', CommentType='TextComment', FeedItemId=fi.Id);
                    fcs.add(fc);
                    
                }
            if (fcs.isEmpty()==false)
                insert fcs;
        }
 
    // Now create emailmessage objects for them.
    
    
        List<EmailMessage> emails = new List<EmailMessage>();
        for(Case c : cases){
            emails.add(new EmailMessage(parentId = c.id, toAddress = con.Email));
        }
        if(emails.isEmpty()==false)
            insert(emails);
     /*   
        for(Case c : cases){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddr = new String[] {'servicecloudadmin@technologyonecorp.com'};
            mail.setToAddresses(toAddr);
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(c.ContactId);
            mail.setWhatId(c.Id);
            mail.setHtmlBody('TestHTMLBody');
            mail.setPlainTextBody('TestTextBody');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    // was commented to here
    */
        list <case> lcase2 = new list<case>();
        for(Case c : cases){
          c.Status = 'Closed';
          c.Reason = 'Software Change';
          c.resolution__c = 'Resolved in some way';
          c.Delivered_Release__c = '2020B'; // added due to new val rule sce-287
          lcase2.add(c);
        }
        if (!lcase2.isEmpty()){
            update lcase2;
        }

        lcase2.clear();
        for(Case c : cases){
          c.Status = 'In Progress';
          lcase2.add(c);
        }
        if (!lcase2.isEmpty()){
            update lcase2;
        }    
        // Query the database for the newly inserted records.
        /*List<Case> insertedCases = [SELECT Subject,
                                          Description,
                                          (SELECT IsPublished, CommentBody From CaseComments),
                                          (SELECT TextBody, Subject, Incoming From EmailMessages)
                                          FROM Case
                                           WHERE Id IN :cases];
        */
    }
}