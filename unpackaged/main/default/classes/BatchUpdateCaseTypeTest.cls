@isTest(SeeAllData=True)
public class BatchUpdateCaseTypeTest {

 	static testMethod void testMethod1() 
    {
    	
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
        
        RecordType rectypeid = [Select Id From RecordType where sobjecttype = 'Case' and name = 'Service Request'];
        
        Case case1 = new Case();
        case1.Case_Comments_Priority__c = 'try high';
        case1.Priority = 'Medium';
        case1.Description = 'A Description';
        case1.Customer_Product__c = 'Financials (FIN)';
        case1.Affected_Version__c = 'non-Production';
        case1.Subject = 'A subject';
        case1.Work_around_Details__c = 'A bit of text';
        case1.CFunctional_Area__c = 'testing';
        case1.RecordTypeId = rectypeid.Id;
        case1.Has_it_worked_before__c = 'No';
        case1.Is_there_a_scalable_work_around__c = 'No';
        case1.Steps_to_reproduce__c = '123';
        case1.AccountId = ac.id;
        case1.ContactId = con.id;
        case1.type = 'Garbage';
        insert case1;
        
        Case case2 = new Case();
        rectypeid = [Select Id From RecordType where sobjecttype = 'Case' and name = 'Consulting - Question'];
        case2.Case_Comments_Priority__c = 'try high';
        case2.Priority = 'Medium';
        case2.Description = 'A Description2';
        case2.Customer_Product__c = 'Financials (FIN)';
        case2.Affected_Version__c = 'non-Production';
        case2.Subject = 'A subject2';
        case2.Work_around_Details__c = 'A bit of text';
        case2.CFunctional_Area__c = 'testing';
        case2.RecordTypeId = rectypeid.Id;
        case2.Has_it_worked_before__c = 'No';
        case2.Is_there_a_scalable_work_around__c = 'No';
        case2.Steps_to_reproduce__c = '123';
        case2.AccountId = ac.id;
        case2.ContactId = con.id;
        case2.type = 'Garbage';
        insert case2;

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

        Test.startTest();
            BatchUpdateCaseType c2 = new BatchUpdateCaseType();
        	Database.executeBatch(c2);
        Test.stopTest();
        
        s.Bypass_Triggers__c = false;
        s.Bypass_Validation_Rules__c = false;
        s.Bypass_Workflow__c = false;
        s.Customer_Community_URL__c = '';
        s.Employee_Community_URL__c = '';
        s.Internal_URL__c = '';
        s.Closed_Date_for_Archiving_Email__c = null;
        upsert s;
    } 
}