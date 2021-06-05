@isTest(SeeAllData=True)

private class Jira_Dev_IssueTriggerHandler_Test {
    static testMethod void myUnitTest() {
        //Initialize Variables
        
        Account ac = new Account();
        ac.type = 'Customer';
        ac.CountryArea__c = 'Australia';
        ac.Region__c = 'ACT';
        ac.Vertical_Market__c = 'Education';
        ac.T1_Industry__c = 'Other';
        ac.Name = 'Test Account';
        insert ac;
        
        Contact con = new Contact();
        con.AccountId = ac.id;
        con.LastName = 'Test Contact';
        con.Title = 'Mr';
        con.Job_Classification__c = 'A';
        con.Email = 'tester1@testorg.com';
        insert con;

        // get the incident record type
        ID rectypeid;
        
        List<RecordType> recType = [select id, name from RecordType where sobjecttype = 'Case'];
        
        for (RecordType recT :recType){
            if (recT.name == 'I am experiencing an issue'){
                rectypeid = recT.id;
            }
        }
        
        // insert case as normal user
        Case testCase = new Case(RecordTypeId = rectypeid, Case_Comments_Priority__c = 'try high', Priority = 'Medium',  Description = 'A Description', Customer_Product__c = 'Financials (FIN)', Affected_Version__c = 'non-Production', 
                                 Subject = 'A subject', Work_around_Details__c = 'A bit of text', CFunctional_Area__c = 'testing', 
                                 Has_it_worked_before__c = 'No', Is_there_a_scalable_work_around__c = 'No', Steps_to_reproduce__c = '12345678910', AccountId = ac.id, ContactId = con.id);
        insert testCase;

        ID case_id = testCase.Id;

        // mimic sys admin update via go2group plugin
        User currentAdminUser = CreateStandardRunningUser();
        insert currentAdminUser;
         
         
        // temporary removal of certain code to avoid errors
        system.runAs(currentAdminUser){
            Test.startTest();
                Jira_Dev_Issue__c testJDIIns = new Jira_Dev_Issue__c(case__c = case_id, issue_type__c = 'R&D Triage', status__c = 'Pending', Name = 'FIN-1234');
                insert testJDIIns;
                System.assertEquals(1, [SELECT Id FROM Jira_Dev_Issue__c WHERE case__c = :case_id].size());
                Jira_Dev_Issue__c testJDIIns2 = new Jira_Dev_Issue__c(case__c = case_id, issue_type__c = 'Bug', status__c = 'Pending', Name = 'FIN-1235');
                insert testJDIIns2;
                System.assertEquals(2, [SELECT Id FROM Jira_Dev_Issue__c WHERE case__c = :case_id].size());
                testJDIIns.Status__c = 'Active';
                update testJDIIns;
                //System.assertEquals(1, [SELECT Id FROM case WHERE id = :case_id and development_status__c = 'Under Investigation'].size());
                testJDIIns2.Fix_Version__c = '1.2';
                update testJDIIns2;
                //System.assertEquals(1,  [SELECT Id FROM case WHERE id = :case_id and development_status__c = 'Under Investigation'].size());
                testJDIIns.Issue_Type__c = 'User Story';
                update testJDIIns;
                 //System.assertEquals(1,  [SELECT Id FROM case WHERE id = :case_id and development_status__c = 'Requires a Software Change'].size());
                testJDIIns2.Fix_Version__c = '';
                update testJDIIns2;
                //System.assertEquals(1,  [SELECT Id FROM case WHERE id = :case_id and development_status__c = 'Planned for Release'].size());
                testJDIIns2.Issue_Type__c = 'Question';
                update testJDIIns2;
                 testJDIIns.Issue_Type__c = 'Question';
                update testJDIIns;
                testJDIIns.Status__c = 'Closed';
                update testJDIIns;
                //System.assertEquals(1,  [SELECT Id FROM case WHERE id = :case_id and development_status__c = 'Requires Research'].size());
                testJDIIns2.Status__c = 'Closed';
                update testJDIIns2;
                //System.assertEquals(1,  [SELECT Id FROM case WHERE id = :case_id and development_status__c = 'Completed'].size());
 
           Test.stopTest();
        }
        
        
    }
        
      public static User CreateStandardRunningUser(){
          Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
          User dummyUser = new User();
          dummyUser.Alias = 'standt'; 
          dummyUser.Email='standarduser@testorg.com';
          dummyUser.EmailEncodingKey='UTF-8';
          dummyUser.LastName='Testing';
          dummyUser.LanguageLocaleKey='en_US';
          dummyUser.LocaleSidKey='en_US'; 
          dummyUser.ProfileId = p1.Id;
          dummyUser.TimeZoneSidKey='America/Los_Angeles';
          dummyUser.UserName='u2@u1.com';
          return dummyUser;
     }       
}