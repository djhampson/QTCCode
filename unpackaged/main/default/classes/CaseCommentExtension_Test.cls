/**
 * File Info
 * ----------------------------------
 * @filename       CaseCommentExtension_Test.cls
 * @created        24.SEPT.2014
 * @author         Kristian Vegerano
 * @description    Test Class for Case Triggers Handler Class
 */
@isTest(SeeAllData=True)
private class CaseCommentExtension_Test {
    /**
     * @description    This method tests the constructor and saving of case comment record
     * @author         Kristian Vegerano - 24.SEPT.2014
     */
    static testMethod void Test_CreateCommentOnPriorityChange() {
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
        insert con;
        
        Case testCase = new Case(Case_Comments_Priority__c = 'try high', Priority = 'Medium', Description = 'A Description', Customer_Product__c = 'Financials (FIN)', Affected_Version__c = 'non-Production', 
                                 Subject = 'A subject', Work_around_Details__c = 'A bit of text', CFunctional_Area__c = 'testing', 
                                 Has_it_worked_before__c = 'No', Is_there_a_scalable_work_around__c = 'No', Steps_to_reproduce__c = '12345678910', AccountId = ac.id, ContactId = con.id);
        insert testCase;
        
        CaseCommentExtension testExtension;
        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(testCase);
            testExtension = new CaseCommentExtension(sc);
            testExtension.saveandrefresh();
            List<SelectOption> testList = testExtension.getCaseStatus();
        Test.stopTest();
        
        System.assertEquals(true, testExtension.refreshPage);
    }
}