@isTest(SeeAllData=true)
public class TestDataBuilder_Test {
    
       static testmethod void createAccountTest(){
        Account acc = new Account();
        acc.Name = 'Test Account 1';
        acc.Type = 'Prospect';
        acc.Vertical_Market__c = 'Education';
        acc.T1_Industry__c = 'Private Training Provider';
        acc.CountryArea__c = 'Australia';
        acc.Region__c = 'ACT';
        acc.CurrencyIsoCode = 'AUD';

       }
    
        static testmethod void createOpportunityTest(){
        Account acc= TestDataBuilder.createAccounts(1, true)[0];     
        ID RType = RecordTypeUtil.getRecordTypeIdByName(Opportunity.SObjectType, 'Licence Fee');
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = RType;
        opp.Name = 'Opportunity 1';
          
        opp.AccountId = acc.Id;
        opp.Type = 'Existing Business';  
        opp.Start_Date__c = date.today();      
        opp.CloseDate = date.today();
        opp.StageName = '1 - Discovery';
        opp.LeadSource = 'Web';
        opp.Amount = 2000;
        opp.CurrencyIsoCode = 'AUD';
        opp.Overview__c = 'Test Overview ' + 1;
        opp.Include_in_Forecast__c = true;
        opp.ConsultingS_Required__c = 'Yes';
        opp.Project_Start_Date__c = date.today();
            
    }
    
    
    
}