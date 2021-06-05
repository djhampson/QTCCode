/*******************************************************************************************************
* @Class Name   : DS_QuoteTest
* @description  : Test class for DS_Quote
* @author       : Carlos Roy Billones
* @date         : 22/12/2020
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Carlos Roy Billones   22/12/2020      1000        Initial version
* Yi Zhang              12/03/2021      2000        Applied comments & assertions
******************************************************************************************************/
@isTest
private class DS_QuoteTest {

    @isTest
    static void getQuoteByIdTest(){
        Test.startTest();
        SBQQ__Quote__c quote = TestDataFactory.createQuote();
        insert quote;
        
        SBQQ__Quote__c retrievedQuote = DS_Quote.getQuoteById(quote.Id);
        System.assertEquals(quote.Id, retrievedQuote.Id);
        Test.stopTest();
    }
}