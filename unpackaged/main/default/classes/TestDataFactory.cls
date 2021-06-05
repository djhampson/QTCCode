/*******************************************************************************************************
* @Class Name   : TestDataFactory
* @description  : Test data factory
* @author       : Carlos Roy Billones
* @date         : 08/12/2020
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Carlos Roy Billones   08/12/2020      1000        Initial version
* Yi Zhang              12/03/2021      2000        Applied comments
******************************************************************************************************/
@isTest
public class TestDataFactory {
	
    public static SBQQ__Quote__c createQuote() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        
        quote.SBQQ__StartDate__c = Date.today();
        
        return quote;
    }
    
    public static SBQQ__QuoteLineGroup__c createQuoteLineGroup(SBQQ__Quote__c quote) {
       SBQQ__QuoteLineGroup__c quotelinegroup = new SBQQ__QuoteLineGroup__c();
        quotelinegroup.SBQQ__Quote__c = quote.Id;
        quotelinegroup.Period_Type__c = 'Free Period';
        quotelinegroup.Name = 'Free Period';
        quotelinegroup.SBQQ__StartDate__c = Date.today();
        quotelinegroup.SBQQ__EndDate__c = Date.today().addMonths(3);
        
        return quotelinegroup;
    }
    
    public static SBQQ__QuoteLine__c createQuoteLine(SBQQ__Quote__c quote) {
       SBQQ__QuoteLine__c quoteline = new SBQQ__QuoteLine__c();
        quoteline.SBQQ__Quote__c = quote.Id;
        return quoteline;
    }
    
    public static ServiceContract createServiceContractforRenewalBatchApex() {
       ServiceContract serveCon = new ServiceContract(Name='Test Service Contract',
                                                      StartDate=Date.newInstance(2021, 1, 6),
                                                      EndDate=Date.newInstance(2022, 1, 6),
                                                      Auto_Renewal_Date__c=Date.newInstance(2021, 1, 6),
                                                      Auto_Renewal_Treatment__c='Auto-Renew continuously – 12 months',
                                                      Auto_Renewal_End_Date__c = Date.newInstance(2022, 1, 6),
                                                      Stop_Auto_Renewal__c = null);
        return serveCon;
    }
    
    public static Opportunity createOpportunityforRenewalBatchApex() {
       Opportunity opp = new Opportunity(Name='Test Opportunity Carlos123', 
                                         CloseDate=Date.newInstance(2022, 1, 6),
                                         StageName='Discovery',
                                         Auto_Renew__c = true);

        return opp;
    }
    
    public static Account createAccount() {
       Account acct = new Account(Name='Carlos Test Account',
                                  CountryArea__c='Australia', 
                                  Region__c='Western Australia', 
                                  T1_Industry__c='Other Education', 
                                  Vertical_Market__c='Education', 
                                  Type='Customer',
                                  Country_Code__c='11');

        return acct;
    }
    
    
}