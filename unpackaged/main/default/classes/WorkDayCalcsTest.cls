@isTest(SeeAllData=True)
public class WorkDayCalcsTest{
    
    public static testmethod void testWorkDayCalcs() {


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
        con.Job_Classification__c = 'abc';
        con.title = 'Mr';
        insert con;
        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true];
        
        Case c = new Case();
        c.AccountId = ac.id;
        c.ContactId = con.id;
        c.CurrencyIsoCode = 'AUD';
        c.BusinessHoursId = bhs.id;
        c.Status = 'New';
        c.AwaitInfoFinalFollowupDue__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        c.AwaitInfoFirstFollowupDue__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        c.AwaitInfoSecondFollowupDue__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        c.Quote_Reminder__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        c.Quote_Expiry__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        c.Description = 'A Description';
        c.Customer_Product__c = 'Financials (FIN)';
        c.Affected_Version__c = 'non-Production';
        c.Subject = 'A subject';
        c.Work_around_Details__c = 'A bit of text';
        c.CFunctional_Area__c = 'testing';
        c.Has_it_worked_before__c = 'No';
        c.Is_there_a_scalable_work_around__c = 'No';
        c.Steps_to_reproduce__c = '12345678910'; 
        insert c;
        
        c.AwaitInfoFinalFollowupDue__c = datetime.newInstance(2016, 1, 1, 12, 30, 1);
        c.AwaitInfoFirstFollowupDue__c = datetime.newInstance(2016, 1, 1, 12, 30, 1);
        c.AwaitInfoSecondFollowupDue__c = datetime.newInstance(2016, 1, 1, 12, 30, 1);
        update c;
        
        List<Holiday> hols = [Select StartTimeInMinutes, Name, ActivityDate From Holiday];
        
        c.AwaitInfoSecondFollowupDue__c = Workdaycalcs.calculateNthWorkingDay(date.newInstance(2016, 02, 01), 5, hols);
 
    }
    

}