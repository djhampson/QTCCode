/**
 * File Info
 * ----------------------------------
 * @filename       CSAttachmentHandler_Test.cls
 * @created        24.SEPT.2014
 * @author         Kristian Vegerano
 * @description    Test Class for Attachment Triggers Handler Class
 */
@isTest(SeeAllData=True)
private class CSAttachmentHandler_Test {
    /**
     * @description    This method tests attachment replication on attachment to case
     * @author         Kristian Vegerano - 24.SEPT.2014
     */
    /*static testMethod void Test_AttachmentToParentCase() {
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
        
        Case testCase = new Case(Case_Comments_Priority__c = 'try high', Priority = 'Medium',  Description = 'A Description', Customer_Product__c = 'Financials (FIN)', Affected_Version__c = 'non-Production', 
                                 Subject = 'A subject', Work_around_Details__c = 'A bit of text', CFunctional_Area__c = 'testing', 
                                 Has_it_worked_before__c = 'No', Is_there_a_scalable_work_around__c = 'No', Steps_to_reproduce__c = '123', AccountId = ac.id, ContactId = con.id);
        insert testCase;
        User currentAdminUser = CreateStandardRunningUser();
        insert currentAdminUser;
        EmailMessage testEmail = new EmailMessage(ParentId = testCase.Id, fromaddress = con.Email);
        insert testEmail;
        
        Attachment testAttachment;
        
        system.runAs(currentAdminUser){
            Test.startTest();
                testAttachment = new Attachment(ParentId = testEmail.Id, Name = 'TestAttachment', Body = Blob.valueOf('TestAttachmentBody'));
                insert testAttachment;
            Test.stopTest();
        }
        
        System.assertEquals(1, [SELECT Id FROM Attachment WHERE ParentId = :testCase.Id].size());
    }
    */
    /**
     * @description    This method tests attachment replication on attachment to case
     * @author         Kristian Vegerano - 24.SEPT.2014
     */
    static testMethod void Test_AttachmentFlag() {
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
        con.Email = 'tester2@testorg.com';
        insert con;
        
        Case testCase = new Case(Case_Comments_Priority__c = 'try high', Priority = 'Medium', Description = 'A Description', Customer_Product__c = 'Financials (FIN)', Affected_Version__c = 'non-Production', 
                                 Subject = 'A subject', Work_around_Details__c = 'A bit of text', CFunctional_Area__c = 'testing', 
                                 Has_it_worked_before__c = 'No', Is_there_a_scalable_work_around__c = 'No', Steps_to_reproduce__c = '12345678910', AccountId = ac.id, ContactId = con.id);
        insert testCase;
        User currentAdminUser = CreateStandardRunningUser();
        insert currentAdminUser;

        Attachment testAttachment;
        
        system.runAs(currentAdminUser){
            Test.startTest();
                testAttachment = new Attachment(ParentId = testCase.Id, Name = 'TestAttachment', Body = Blob.valueOf('TestAttachmentBody'));
                insert testAttachment;
            Test.stopTest();
        }
        
        System.assertEquals(1, [SELECT Id FROM Attachment WHERE ParentId = :testCase.Id].size());
    }
    
    /**
      * @description Test method for creating running user with standard profile.
      * @author Kristian Vegerano - 24.SEPT.2014
      */
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