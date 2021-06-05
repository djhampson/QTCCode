/*******************************************************************************************************
* @Class Name   : DS_QuoteLineTest
* @description  : Test class for DS_QuoteLine
* @author       : Carlos Roy Billones
* @date         : 11/12/2020
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Carlos Roy Billones   11/12/2020      1000        Initial version
* Yi Zhang              12/03/2021      2000        Applied comments & assertions
******************************************************************************************************/
@isTest
private class DS_QuoteLineTest {
	@isTest
    static void getQuoteLineByQuoteIdTest(){

        Test.startTest();
        SBQQ__Quote__c quote = TestDataFactory.createQuote();
        insert quote;
        List<SBQQ__QuoteLine__c> lines = DS_QuoteLine.getQuoteLineByQuoteId(quote.Id);
        System.assertEquals(0, lines.size());
        Test.stopTest();
    }
    
    @isTest
    static void getClonedQuoteLinesTest(){
        Test.startTest();
        SBQQ__Quote__c quote = TestDataFactory.createQuote();
        insert quote;
        
        List<SBQQ__QuoteLineGroup__c> quotelinegroupList = new List<SBQQ__QuoteLineGroup__c>();
        quotelinegroupList.add(TestDataFactory.createQuoteLineGroup(quote));
        insert quotelinegroupList;
        
        //SBQQ__QuoteLine__c quoteline = TestDataFactory.createQuoteLine(quote);
        
        List<SBQQ__QuoteLine__c> quotelineList = new List<SBQQ__QuoteLine__c>();
        //quotelineList.add(quoteline);
        //insert quotelineList;
        
        List<SBQQ__QuoteLine__c> lines = DS_QuoteLine.getClonedQuoteLines(quotelinegroupList, quotelineList);
        System.assertEquals(0, lines.size());
        Test.stopTest();
    }
}