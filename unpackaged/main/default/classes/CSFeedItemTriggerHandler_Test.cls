/**
 * File Info
 * ----------------------------------
 * @filename       CSFeedItemTriggerHandler_Test.cls
 * @created        24.SEPT.2014
 * @author         Kristian Vegerano
 * @description    Test Class for FeedItem Triggers Handler Class
 */
@isTest(SeeAllData=True)
private class CSFeedItemTriggerHandler_Test {
    /**
     * @description    This method tests case comment creation on case priority change
     * @author         Kristian Vegerano - 24.SEPT.2014
     */
     static testMethod void Test_SetCasePortalFlag() {
        //Initialize Variables
        Case testCase;
        User currentAdminUser = CreateStandardRunningUser();
        currentAdminUser.UserRoleId = [SELECT Id FROM UserRole LIMIT 1].Id;
        insert currentAdminUser;
        
        //Create Account and Contact for the CommunityUser
        Account testAccount;
        Contact testContact;
        system.runAs(currentAdminUser){
                        testAccount = new Account(Name = 'Test Account',
                                      CountryArea__c = 'Australia',
									  Region__c = 'ACT',                                                  
                                      Type = 'Customer',
                                      T1_Industry__c = 'State Government',
                                      Vertical_Market__c = 'Education');
            insert testAccount;
            
            testContact = new Contact(LastName = 'TestContact', AccountId = testAccount.Id, Job_Classification__c = 'A', Title = 'Mr');
            insert testContact;
            insert testCase = new Case(Description = 'A Description', Customer_Product__c = 'Financials (FIN)', Affected_Version__c = 'non-Production', 
                                 Subject = 'A subject', Work_around_Details__c = 'A bit of text', CFunctional_Area__c = 'testing', 
                                 Has_it_worked_before__c = 'No', Is_there_a_scalable_work_around__c = 'No', Steps_to_reproduce__c = '12345678910', AccountId = testAccount.Id);

        }
        
        User currentCommunityUser = CreateCommunityRunningUser();
        currentCommunityUser.contactId = testContact.Id;
        insert currentCommunityUser;
        
        system.runAs(currentAdminUser){
            Test.startTest();
                FeedItem testFeedItem = new FeedItem(Type = 'TextPost', ParentId = testCase.Id, Body = 'TestBody');
                insert testFeedItem;
            Test.stopTest();
        }
        
        System.assertEquals(true, [SELECT Id, new_portal_case_comment__c FROM Case WHERE Id = :testCase.Id].new_portal_case_comment__c);
    }
    
    /**
     * @description    This method tests case comment creation on case owner change
     * @author         Kristian Vegerano - 24.SEPT.2014
     */
    static testMethod void Test_SetCasePortalAttachmentFlag() {
        //Initialize Variables
        Case testCase;
        User currentAdminUser = CreateStandardRunningUser();
        currentAdminUser.UserRoleId = [SELECT Id FROM UserRole LIMIT 1].Id;
        insert currentAdminUser;
        
        //Create Account and Contact for the CommunityUser
        Account testAccount;
        Contact testContact;
        system.runAs(currentAdminUser){
           
            testAccount = new Account(Name = 'Test Account',
                                      CountryArea__c = 'Australia',
                                      Region__c = 'ACT',
                                      Type = 'Customer',
                                      T1_Industry__c = 'State Government',
                                      Vertical_Market__c = 'Education');
            insert testAccount;
            testContact = new Contact(LastName = 'TestContact', AccountId = testAccount.Id, Job_Classification__c = 'A', Title = 'Mr');
            insert testContact;
            insert testCase = new Case(Description = 'A Description', Customer_Product__c = 'Financials (FIN)', Affected_Version__c = 'non-Production', 
                                 Subject = 'A subject', Work_around_Details__c = 'A bit of text', CFunctional_Area__c = 'testing', 
                                 Has_it_worked_before__c = 'No', Is_there_a_scalable_work_around__c = 'No', Steps_to_reproduce__c = '12345678910', AccountId = testAccount.Id);
        }
        
        User currentCommunityUser = CreateCommunityRunningUser();
        currentCommunityUser.contactId = testContact.Id;
        insert currentCommunityUser;
        
        system.runAs(currentAdminUser){
            Test.startTest();
                FeedItem testFeedItem = new FeedItem(Type = 'ContentPost', ParentId = testCase.Id, Body = 'TestBody', ContentFileName = 'TestFileName', ContentData = Blob.valueOf('TestPost'));
                insert testFeedItem;
            Test.stopTest();
        }
        
        System.assertEquals(true, [SELECT Id, new_customer_attachment__c FROM Case WHERE Id = :testCase.Id].new_customer_attachment__c);
    }
    
    /**
      * @description Test method for creating running user with standard profile.
      * @author Kristian Vegerano - 24.SEPT.2014
      */
     @isTest(SeeAllData=True) public static User CreateStandardRunningUser(){
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
     
     /**
      * @description Test method for creating running user with standard profile.
      * @author Kristian Vegerano - 24.SEPT.2014
      */
     @isTest(SeeAllData=True) public static User CreateCommunityRunningUser(){
          Profile p1 = [SELECT Id FROM Profile WHERE Name LIKE '%Customer Support Community%' LIMIT 1]; 
          User dummyUser = new User();
          dummyUser.Alias = 'commun'; 
          dummyUser.Email='communityuser@testorg.com';
          dummyUser.EmailEncodingKey='UTF-8';
          dummyUser.LastName='Community';
          dummyUser.LanguageLocaleKey='en_US';
          dummyUser.LocaleSidKey='en_US'; 
          dummyUser.ProfileId = p1.Id;
          dummyUser.TimeZoneSidKey='America/Los_Angeles';
          dummyUser.UserName='c2@u1.com';
          return dummyUser;
     }
}