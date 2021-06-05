/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=True)
private class contDocLinkCaseUpdTest {

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
        
        Case testCase = new Case(Case_Comments_Priority__c = 'try high', Priority = 'Medium',  Description = 'A Description', Customer_Product__c = 'Financials (FIN)', Affected_Version__c = 'non-Production', 
                                 Subject = 'A subject', Work_around_Details__c = 'A bit of text', CFunctional_Area__c = 'testing', 
                                 Has_it_worked_before__c = 'No', Is_there_a_scalable_work_around__c = 'No', Steps_to_reproduce__c = '12345678910', AccountId = ac.id, ContactId = con.id);
        insert testCase;
        User currentAdminUser = CreateStandardRunningUser();
        insert currentAdminUser;
        //get an existing Document
        ContentVersion testVer = [SELECT Id, ContentDocumentId FROM ContentVersion where IsLatest = true order by createddate desc limit 1];
        
        ContentDocumentLink testDocLink;
        
        //return; // exiting test due to unknown error cause
        
        //system.runAs(currentAdminUser){
            Test.startTest();
                testDocLink = new ContentDocumentLink(LinkedEntityId = testCase.Id, ContentDocumentId = testVer.ContentDocumentId, ShareType = 'V', Visibility = 'AllUsers');
                insert testDocLink;
            Test.stopTest();
        //}
        
        System.assertEquals(1, [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :testCase.Id and ContentDocumentId = :testVer.ContentDocumentId].size());
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