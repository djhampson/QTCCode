@isTest(SeeAllData=True)
public class TestMyExtension{
    public testMethod static void testExt() {
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
        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true];
        
        Case c = new Case();
        c.AccountId = ac.id;
        c.ContactId = con.id;
        c.CurrencyIsoCode = 'AUD';
        c.BusinessHoursId = bhs.id;
        c.Status = 'New';
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
        
        ApexPages.StandardController sc = new ApexPages.standardController(c);
        myExtension e = new myExtension(sc);
        
        String title = e.getTitle();
        System.assertEquals('Case: ' + c.id, title);
        e.save();
    }
}