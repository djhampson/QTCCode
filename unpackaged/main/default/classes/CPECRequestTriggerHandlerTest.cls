@isTest(SeeAllData=True)
public class CPECRequestTriggerHandlerTest 
{
    static testMethod void testMethod1() 
    {
        Account ac = new Account();
        ac.type = 'Customer';
        ac.CountryArea__c = 'Australia';
        ac.Vertical_Market__c = 'Education';
        ac.T1_Industry__c = 'Other';
        ac.Name = 'Test Account for Request';
        ac.Region__c = 'Queensland';
        insert ac;
       
        Contact con = new Contact();
        con.AccountId = ac.id;
        con.LastName = 'Test Contact';
        con.Title = 'Mr';
        con.Job_Classification__c = 'A';
        con.Email = '1@234.com';
        insert con;
        
        CPEC_Request__c req = new CPEC_Request__c();
        req.Account__c = ac.Id;
        req.Approval_Level__c = 'CRC';
        //req.Cost_to_TechnologyOne__c = 1000;
        req.Customer_Status__c = 'Existing';
        req.Customer_Type__c = 'SaaS';
        req.Item_Details__c = 'Testing';
        req.Request_Type__c = 'Module Swap';
        req.Approval_Methodology__c = 'CRC Approval';
        //req.Requested_Items__c = 'Module Swap';
        insert req;

        CPEC_Request__c req2 = new CPEC_Request__c();
        req2.Account__c = ac.Id;
        req2.Approval_Level__c = 'CEO';
        //req2.Cost_to_TechnologyOne__c = 2000;
        req2.Customer_Status__c = 'Existing';
        req2.Customer_Type__c = 'SaaS';
        req2.Item_Details__c = 'Testing';
        req2.Request_Type__c = 'Waiver of Annual increase';
        req2.Approval_Methodology__c = 'CRC Approval';
        //req2.Requested_Items__c = 'Non-standard contract terms';
        insert req2;


    
        
        /*case1.Case_Comments_Priority__c = 'try high';
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
        case1.Steps_to_reproduce__c = '123';
        case1.AccountId = ac.id;
        case1.Interim_Solution_Provided__c = false;
        
        insert case1;
        System.assert(case1.Interim_Solution_Provided__c == false);*/
 
        

    }
}