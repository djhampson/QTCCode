@isTest(SeeAllData=True)
public class CaseTriggerHandlerTest 
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
        // removing as Simplus removed the Required setting for the field
        //ac.Country_Code__c = '11';
        insert ac;
       
        Contact con = new Contact();
        con.AccountId = ac.id;
        con.FirstName = 'Test';
        con.LastName = 'TContact';
        con.Title = 'Mr';
        con.Job_Classification__c = 'A';
        con.Email = '1@234.com';
        con.Profile_Name__c = 'Customer Community Login User Support';
        insert con;
        
        // Profile pf = [Select id,name from Profile where name ='Customer Community Login User Support' limit 1];

        // User u2 = new User(contactId=con.Id, username=con.Email, firstname=con.FirstName,
        // lastname=con.LastName, email=con.Email,communityNickname = con.LastName + '_' + Date.today(),
        // alias = string.valueof(con.FirstName.substring(0,1) + con.LastName.substring(0,1)), profileid = pf.Id, emailencodingkey='UTF-8',
        // languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles');
        // insert u2;

        ID rectypeid;
        
        List<RecordType> RecType = [select id, name from RecordType where sobjecttype = 'Case'];
        
        for (RecordType recT :RecType){
            if (recT.name == 'I require Consulting services')
                rectypeid = recT.id;
        }
        
        Case case1 = new Case();
        case1.Case_Comments_Priority__c = 'try high';
        case1.Priority = 'Medium';
        case1.Description = 'A Description';
        case1.Customer_Product__c = 'Financials (FIN)';
        case1.Affected_Version__c = 'non-Production';
        case1.Subject = 'A subject';
        case1.Work_around_Details__c = 'A bit of text';
        case1.CFunctional_Area__c = 'testing';
        case1.RecordTypeId = rectypeid;
        case1.Has_it_worked_before__c = 'No';
        case1.Is_there_a_scalable_work_around__c = 'No';
        case1.Steps_to_reproduce__c = 'Steps Reproduce 123';
        case1.AccountId = ac.id;
        case1.ContactId = con.id;
        case1.Interim_Solution_Provided__c = false;
        
        insert case1;
        System.assert(case1.Interim_Solution_Provided__c == false);
        case1.Interim_Solution_Provided__c = True;
        update case1;
        System.assert(case1.Interim_Solution_Provided__c == True);
        case1.Status = 'Resolved';
        case1.Resolution__c = 'Resolution';
        case1.Reason = 'Configuration';
        update case1;
        Datetime myDateTime = Datetime.newInstance(2018, 2, 17);
        case1.AwaitInfoFinalFollowupDue__c = myDateTime;
        case1.AwaitInfoFirstFollowupDue__c = myDateTime;
        case1.AwaitInfoSecondFollowupDue__c = myDateTime;
        case1.Last_Status_Change__c = null;
        case1.Time_With_Customer__c = null;
        case1.Time_With_Support__c = null;
        case1.Case_Age_In_Business_Hours__c = null;
            
        update case1;        

        myDateTime = Datetime.newInstance(2018, 7, 17);
        case1.Quote_Reminder__c = myDateTime;
        update case1;   
        
        myDateTime = Datetime.newInstance(2018, 7, 17);
        case1.Quote_Expiry__c = myDateTime;
        update case1; 
        
        //case1.Status = 'Closed';
        //update case1;
        
        case1.Jira_Issue_No__c = '12345';
        update case1;
        
        case1.Status = 'Awaiting Resource Allocation';
        case1.Last_Status_Change__c = Datetime.newInstance(2018, 7, 01);
        update case1;

        case1.Status = 'Scheduled';
        update case1;
        
        for (RecordType recT :RecType){
            if (recT.name == 'I am experiencing an issue')
                rectypeid = recT.id;
        }
        
        Case case2 = new Case();
        case2.Case_Comments_Priority__c = 'try high';
        case2.Priority = 'Medium';
        case2.Description = 'A Description 2';
        case2.Customer_Product__c = 'Financials (FIN)';
        case2.Affected_Version__c = 'non-Production';
        case2.Subject = 'A subject 2';
        case2.Work_around_Details__c = 'A bit of text';
        case2.CFunctional_Area__c = 'testing';
        case2.RecordTypeId = rectypeid;
        case2.Has_it_worked_before__c = 'No';
        case2.Is_there_a_scalable_work_around__c = 'No';
        case2.Steps_to_reproduce__c = 'Steps Reproduce 123';
        case2.AccountId = ac.id;
        case2.ContactId = con.id;
        case2.Interim_Solution_Provided__c = false;
        //case2.SuppliedEmail = '1@abc.com';
        insert case2;

        Case case3 = new Case();
        case3.Case_Comments_Priority__c = 'try high';
        case3.Priority = 'Medium';
        case3.Description = 'A Description 2';
        case3.Customer_Product__c = 'Financials (FIN)';
        case3.Affected_Version__c = 'non-Production';
        case3.Subject = 'A subject 2';
        case3.Work_around_Details__c = 'A bit of text';
        case3.CFunctional_Area__c = 'testing';
        case3.RecordTypeId = rectypeid;
        case3.Has_it_worked_before__c = 'No';
        case3.Is_there_a_scalable_work_around__c = 'No';
        case3.Steps_to_reproduce__c = 'Steps Reproduce 123';
        case3.AccountId = ac.id;
        case3.ContactId = con.id;
        case3.Interim_Solution_Provided__c = false;
        //case3.SuppliedEmail = '1@abc.com';
        insert case3;

        Case case4 = new Case();
        case4.Case_Comments_Priority__c = 'try high';
        case4.Priority = 'Medium';
        case4.Description = 'A Description 2';
        case4.Customer_Product__c = 'Financials (FIN)';
        case4.Affected_Version__c = 'non-Production';
        case4.Subject = 'A subject 2';
        case4.Work_around_Details__c = 'A bit of text';
        case4.CFunctional_Area__c = 'testing';
        case4.RecordTypeId = rectypeid;
        case4.Has_it_worked_before__c = 'No';
        case4.Is_there_a_scalable_work_around__c = 'No';
        case4.Steps_to_reproduce__c = 'Steps Reproduce 123';
        case4.AccountId = ac.id;
        case4.ContactId = con.id;
        case4.Interim_Solution_Provided__c = false;
        //case4.SuppliedEmail = '1@abc.com';
        insert case4;
        
        Case case5 = new Case();
        case5.Case_Comments_Priority__c = 'try high';
        case5.Priority = 'Medium';
        case5.Description = 'A Description 5';
        case5.Customer_Product__c = 'Financials (FIN)';
        case5.Affected_Version__c = 'non-Production';
        case5.Subject = 'Automatic Reply';
        case5.Work_around_Details__c = 'A bit of text';
        case5.CFunctional_Area__c = 'testing';
        case5.RecordTypeId = rectypeid;
        case5.Has_it_worked_before__c = 'No';
        case5.Is_there_a_scalable_work_around__c = 'No';
        case5.Steps_to_reproduce__c = 'Steps Reproduce 123';
        case5.AccountId = ac.id;
        case5.ContactId = con.id;
        case5.Interim_Solution_Provided__c = false;
        //case5.SuppliedEmail = '1@abc.com';
        insert case5;
        
        case2.Last_Status_Change__c = null;
        update case2;
        
        case1.Status = 'Closed';
        update case1;

        case1.Status = 'In Progress';
        update case1;

        case5.Customer_Product__c = 'Asset Management (AM)';
        case5.Status = 'New';
        update case5;

        
        
        
        

    }
}