@isTest
public class T1_RevRecognitionServiceTest { 

    public static  String masterRuleName = 'Test Rev Rec Master rule';
    public static  Date finBook1StartDate = Date.newInstance( Date.today().year(),1,1 );
    public static Date finBook1EndDate = Date.newInstance( Date.today().year()+4,12,31 );
    public static Date finBook2StartDate = Date.newInstance( Date.today().year()+5,1,1 );
    public static Date finBook2EndDate = Date.newInstance( Date.today().year()+9,12,31 );

    public static Boolean throwExceptionFlag = false;



    @TestSetup
    static void makeData(){


            /***************************CONFIG SETUP *************************/

            // create Revenue Recognition Rule Hierarchy for generating Revenue Schedules and transaction for 10 year Order
            List<blng__FinanceBook__c> financeBooks = new List<blng__FinanceBook__c>();
            financeBooks.add( TestUtility.createFinanceBook( 'Test Rev Book1','Monthly','Revenue') );
            financeBooks.add( TestUtility.createFinanceBook( 'Test Rev Book2','Monthly','Revenue') );
            insert financeBooks;

            // create legal entity
            blng__LegalEntity__c legalEntity = TestUtility.createLegalEntity();
            insert legalEntity;

            // create Revenue Distribution Method
            blng__RevenueDistributionMethod__c revDistributedMethod = TestUtility.createRevenueDistributionMethod();
            insert revDistributedMethod;

            // insert GL Rule
            blng__GLRule__c glRule = TestUtility.createGLRule();
            insert glRule;

            // create Master Revenue Recognitionn Rule
            blng__RevenueRecognitionRule__c masterRevScheduleCreateRule = TestUtility.createRevRecRule (masterRuleName,true,null,null,null);
            insert masterRevScheduleCreateRule;

            // crete Child Revc Rec Rules with FinancialPeriods information
            List<blng__RevenueRecognitionRule__c> childRuleList = new List<blng__RevenueRecognitionRule__c>();
            Date finStartDate = finBook1StartDate;
            Date finEndDate = finBook1EndDate;
            childRuleList.add( TestUtility.createRevRecRule ('Test Rev Rec Rule 1',true,masterRevScheduleCreateRule.Id,finStartDate,finEndDate ) );
            finStartDate = finBook2StartDate;
            finEndDate  = finBook2EndDate;
            childRuleList.add( TestUtility.createRevRecRule ('Test Rev Rec Rule 2',true,masterRevScheduleCreateRule.Id,finStartDate,finEndDate) );

            // create 'No Revenue' rule
            childRuleList.add( TestUtility.createRevRecRule ('No Revenue',true,null,null,null) );
            insert childRuleList;

            // insert Rule treatments for 2 child rules
            List<blng__RevenueRecognitionTreatment__c> treatmentList = new List<blng__RevenueRecognitionTreatment__c>();
            treatmentList.add( TestUtility.createRevRecognitionTreatment('Test Rev Rec Treatment 1',childRuleList[0].ID,financeBooks[0].Id,legalEntity.Id,revDistributedMethod.Id,glRule.Id) );
            treatmentList.add( TestUtility.createRevRecognitionTreatment('Test Rev Rec Treatment 2',childRuleList[1].ID,financeBooks[1].Id,legalEntity.Id,revDistributedMethod.Id,glRule.Id) );
            insert treatmentList;

            // insert Billing Rule
            blng__BillingRule__c  billRule = TestUtility.createBillingRule();
            insert billRule;

            //insert Tax Rule
            blng__TaxRule__c taxRule = TestUtility.createTaxRule();
            insert taxRule;

            /*************************** RECORDS SETUP *************************/
            // create Account
            Account testAccount = TestUtility.createAccount('Test Account');
            insert testAccount;

            // Create Opportunity
            Id oppRecTypeId = TestUtility.getRecordTypeId('Opportunity',TestUtility.OPPORTUNITY_LICENSEFEE_REC_TYPE);
            Opportunity testOpportunity = TestUtility.createOpportunity( testAccount.Id , oppRecTypeId );
            insert testOpportunity;

            // create Products ,one with master Rev Rec Rule and One with No Revenue Rule
            List<Product2> productsToInsert = new List<Product2>();
            productsToInsert.add( TestUtility.initializeProduct('Financials', 'MOBILE','Module', 'Code1', masterRevScheduleCreateRule.Id, billRule.Id, taxRule.Id) );
            productsToInsert.add( TestUtility.initializeProduct('Enterprise Cash Receipting', 'MOBILE','Module','Code2', childRuleList[2].Id,billRule.Id,taxRule.Id) );

            insert productsToInsert;


            // Create a pricebook entry for product
            List<PricebookEntry> pbEntriesToInsert = new List<PricebookEntry>();
            pbEntriesToInsert.add( TestUtility.initializeProductPricebook( TestUtility.STANDARD_PRICEBOOK_ID, productsToInsert[0].id) );
            pbEntriesToInsert.add( TestUtility.initializeProductPricebook( TestUtility.STANDARD_PRICEBOOK_ID, productsToInsert[1].id) );
          
            insert pbEntriesToInsert;

            // Create Primary Quote
            Date quoteStartDate = Date.newInstance( Date.today().year(),5,1 );
            Date quoteEndDate = Date.newInstance( Date.today().year()+8,8,1 );
            SBQQ__Quote__c testQuote = TestUtility.createQuote( testOpportunity.Id ,quoteStartDate, quoteEndDate);
            testQuote.SBQQ__Primary__c = true;
            insert testQuote;

            testQuote = [ SELECT SBQQ__StartDate__c,End_Date__c,SBQQ__EndDate__c,SBQQ__Ordered__c,SBQQ__Account__c,SBQQ__Opportunity2__c,Opportunity_Model__c,SBQQ__Status__c,(SELECT SBQQ__Product__r.Name FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c WHERE Id = :testQuote.Id ];
            testQuote.SBQQ__EndDate__c = quoteEndDate;
            update testQuote;

            // create quotelines for quote
            List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
            quoteLinesToInsert.add( TestUtility.createQuoteLines( testQuote.Id, productsToInsert[0].Id , 900000.00,100000.00 ,pbEntriesToInsert[0].Id) );
            quoteLinesToInsert.add( TestUtility.createQuoteLines( testQuote.Id, productsToInsert[1].Id  , 600000.00,100000.00, pbEntriesToInsert[1].Id) );
            
            insert quoteLinesToInsert;

            quoteLinesToInsert = [select SBQQ__EffectiveEndDate__c, SBQQ__EffectiveStartDate__c from SBQQ__QuoteLine__c WHERE Id IN :quoteLinesToInsert];

            // Order the Quote
            testQuote = [ SELECT SBQQ__StartDate__c,End_Date__c,SBQQ__EndDate__c,SBQQ__Ordered__c,SBQQ__Account__c,SBQQ__Opportunity2__c,Opportunity_Model__c,SBQQ__Status__c,(SELECT SBQQ__Product__r.Name FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c WHERE Id = :testQuote.Id ];

            testQuote.SBQQ__Ordered__c = true;
            update testQuote;

            // query the Order that got generated
            Order orderVar  = [ SELECT SBQQ__Quote__c,Status,Type,Deal_Type__c,EffectiveDate FROM Order WHERE SBQQ__Quote__c = :testQuote.Id];
            List<OrderItem> oiItems = T1_RevRecognitionServiceUtility.selectOrderItemsByOrderId(new Set<Id>{orderVar.Id});



    }


    /* Test Case 1: Positive, When Order Start date is within 1st financial book period and End Date is in 2nd financial book period 
    // asserting the response from queueable method
    // calling the queueable method inside test block
    */
    @isTest
    public static void testCreateRevenueScheduleTransactionRecordPositive(){
        Order orderVar = [ SELECT Id,EffectiveDate,EndDate FROM Order LIMIT 1];
        
        // blng__RevenueRecognitionRule__c masterRule = [ SELECT ID,(SELECT Parent_Revenue_Recognition_Rule__c,Financial_Start_Date__c,Financial_End_Date__c FROM Revenue_Recognition_Rules__r) FROM blng__RevenueRecognitionRule__c WHERE Name = :masterRuleName];
        // List<blng__RevenueRecognitionRule__c> childRevRecRules = masterRule.Revenue_Recognition_Rules__r;
        List<blng.RevenueRecognitionInput> revenueInputs = new List<blng.RevenueRecognitionInput>();
        List<blng.RevenueRecognitionResponse>  response =  new List<blng.RevenueRecognitionResponse>();
        Test.startTest();

            revenueInputs = T1_RevRecognitionService.generateRevRecognitionInputsFromOrders( new Set<Id> {orderVar.Id});
            response = T1_RevRecognitionServiceUtility.generateRevenueRecognitionRecords( revenueInputs );

        Test.stopTest();

        system.assert(response.size() > 0);
        system.assert(response[0].totalNumberOfInputsWithoutErrors == 2);

    }

     /* Test Case 2: Positive, When Order Start date is within 1st financial book period and End Date is in 2nd financial book period 
    // activating the order
    */
    @isTest
    public static void testCreateRevenueScheduleTransactionRecordPositive2() {
        Order orderVar = [ SELECT Id,EffectiveDate,EndDate FROM Order LIMIT 1];
        // Profile salesProfile =  [SELECT Id FROM Profile WHERE Name='Sales']; 
        // User u = new User(Alias = 'salesUsr', Email='testSalesUser@testorg.com', 
        //     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        //     LocaleSidKey='en_US', ProfileId = salesProfile.Id, 
        //     TimeZoneSidKey='America/Los_Angeles', UserName='testSalesUser@testorg.com');

       
       
        Test.startTest();
            // System.runAs(u) {
                orderVar.Status = 'Activated';
                update orderVar;
            //}
        Test.stopTest();
    }

    /*
    Test Scenario: Negative: 0 order products to process
    Description: passing invalid order object Id in function
    */
    @isTest
    public static void testZeroInputs(){
        List<blng.RevenueRecognitionInput> revenueInputs = new List<blng.RevenueRecognitionInput>();
        List<blng.RevenueRecognitionResponse>  response =  new List<blng.RevenueRecognitionResponse>();

        Test.startTest();
            revenueInputs = T1_RevRecognitionService.generateRevRecognitionInputsFromOrders(new Set<Id>{'a3k2O0000000dmcQAA'});
           
            response = T1_RevRecognitionServiceUtility.generateRevenueRecognitionRecords( revenueInputs );

        Test.stopTest();
        system.assert( response.size() == 1);
        system.assert( response[0].totalNumberOfInputsWithoutErrors == 0);
        system.assert( response[0].totalNumberOfInputsWithErrors == 0);
    }

     /*
    Test Scenario: Negative: Handling Exception
    Description: passing non order object Id in function
    */
    @isTest
    public static void testException(){
        throwExceptionFlag = true;
        Test.startTest();

            T1_RevRecognitionService.generateRevRecognitionScheduleAndTransactions(new Set<Id>{'a3k2O0000000dmcQAA'});

        Test.stopTest();

        List<Error_Log__c> errLog = T1_ErrorLogService.queryErrorLogs(new Set<Id>{'a3k2O0000000dmcQAA'});
        system.assert(errLog.size() != 0);
        system.assertEquals(errLog[0].Error_Source__c,'Apex Class');
        system.assertEquals(errLog[0].Error_Source_Name__c,'T1_RevRecognitionService');
        system.assertEquals(errLog[0].Type__c,'T1_RevRecognitionService.T1_RevRecognitionServiceException');
    }

}