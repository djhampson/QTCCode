@isTest(SeeAllData=True)
public class BatchCalcCaseTimeTest 
{
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
        
        //RecordType rectypeid = [Select Id From RecordType where sobjecttype = 'Case' and name = 'I require Consulting services'];
        
        List<Case> lstCase = new List<Case>();
        for(Integer i=0 ;i <10;i++)
        {
            Case case1 = new Case();
            case1.Case_Comments_Priority__c = 'try high';
            case1.Priority = 'Medium';
            case1.Description = 'A Description'+i;
            case1.Customer_Product__c = 'Financials (FIN)';
            case1.Affected_Version__c = 'non-Production';
            case1.Subject = 'A subject'+i;
            case1.Work_around_Details__c = 'A bit of text';
            case1.CFunctional_Area__c = 'testing';
            //case.RecordTypeId = rectypeid.Id;
            case1.Has_it_worked_before__c = 'No';
            case1.Is_there_a_scalable_work_around__c = 'No';
            case1.Steps_to_reproduce__c = '12345678910';
            case1.AccountId = ac.id;
            case1.ContactId = con.id;
            lstCase.add(case1);
        }
        
        insert lstCase;

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
            batchCalcCaseTime c = new batchCalcCaseTime();
        	Database.executeBatch(c);
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
    
    static testMethod void testMethod2() 
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
        
        //RecordType rectypeid = [Select Id From RecordType where sobjecttype = 'Case' and name = 'I require Consulting services'];
        
        List<Case> lstCase = new List<Case>();
        for(Integer i=0 ;i <10;i++)
        {
            Case case1 = new Case();
            case1.Case_Comments_Priority__c = 'try high';
            case1.Priority = 'Medium';
            case1.Description = 'A Description'+i;
            case1.Customer_Product__c = 'Financials (FIN)';
            case1.Affected_Version__c = 'non-Production';
            case1.Subject = 'A subject'+i;
            case1.Work_around_Details__c = 'A bit of text';
            case1.CFunctional_Area__c = 'testing';
            //case.RecordTypeId = rectypeid.Id;
            case1.Has_it_worked_before__c = 'No';
            case1.Is_there_a_scalable_work_around__c = 'No';
            case1.Steps_to_reproduce__c = '12345678910';
            case1.AccountId = ac.id;
            case1.ContactId = con.id;
            lstCase.add(case1);
        }
        
        insert lstCase;

        Test.startTest();
            batchCalcCaseTime c = new batchCalcCaseTime();
        	Database.executeBatch(c);
        Test.stopTest();
        

    }
}