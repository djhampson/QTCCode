@isTest(SeeAllData=True)
public class T1EditControllerTest {

    private static testmethod void testGetCase() {
        
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
        con.Profile_Name__c = 'Customer Community Login User Support';
        insert con;
        
        RecordType rectypeid = [Select Id From RecordType where sobjecttype = 'Case' and name = 'I require Consulting services'];
        
        Case testCase = new Case(Case_Comments_Priority__c = 'try high', Priority = 'Medium', Description = 'A Description', Customer_Product__c = 'Financials (FIN)', Affected_Version__c = 'non-Production', 
                                 Subject = 'A subject', Work_around_Details__c = 'A bit of text', CFunctional_Area__c = 'testing', RecordTypeId = rectypeid.Id,
                                 Has_it_worked_before__c = 'No', Is_there_a_scalable_work_around__c = 'No', Steps_to_reproduce__c = '123', AccountId = ac.id, ContactId = con.id);
        insert testCase;
        
        testCase.Status = 'Awaiting Quote Approval';
        update testCase;
        
        Case myCase = t1EditController.getCase(testCase.Id);
        System.assert(myCase.Id != null);
        
        boolean nothing = t1EditController.returnnothing();
        System.assert(nothing == true);

        string burl = t1EditController.getbaseURL();

 
            
    }
        
}