@isTest
public class T1_CreditNoteLineServiceTest {
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

        blng__RevenueRecognitionRule__c masterFullRevRecRule = TestUtility.createRevRecRule ('Full Recognition - Master',true,null,null,null);
        masterFullRevRecRule.Full_Revenue_Recognition__c = true;
        insert masterFullRevRecRule;
        List<blng__RevenueRecognitionRule__c> chilFullRevRec = new List<blng__RevenueRecognitionRule__c>();
        chilFullRevRec.add( TestUtility.createRevRecRule ('Full Recognition - 1',true,masterFullRevRecRule.Id,finBook1StartDate,finBook1StartDate.addYears(7).addMonths(11).addDays(30)) );
        chilFullRevRec.add( TestUtility.createRevRecRule ('Full Recognition - 2',true,masterFullRevRecRule.Id,finBook1StartDate.addYears(8),finBook1StartDate.addYears(15).addMonths(11).addDays(30)) );

        insert chilFullRevRec;

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

        // create Products ,one with master Rev Rec Rule and One with No Revenue Rule
        List<Product2> productsToInsert = new List<Product2>();
        productsToInsert.add( TestUtility.initializeProduct('Financials', 'MOBILE','Module', 'Code1', masterRevScheduleCreateRule.Id, billRule.Id, taxRule.Id) );
        productsToInsert.add( TestUtility.initializeProduct('Technology ADF', 'MOBILE','Module', 'Code1', masterFullRevRecRule.Id, billRule.Id, taxRule.Id) );
        insert productsToInsert;


        // Create a pricebook entry for product
        List<PricebookEntry> pbEntriesToInsert = new List<PricebookEntry>();
        pbEntriesToInsert.add( TestUtility.initializeProductPricebook( TestUtility.STANDARD_PRICEBOOK_ID, productsToInsert[0].id) );
        insert pbEntriesToInsert;
    
        blng__CreditNote__c creditNote1 = TestUtility.createCreditNote(testAccount.Id);
        insert creditNote1;
        blng__CreditNoteLine__c cnLine1 = TestUtility.createCreditNoteLine(creditNote1.Id,finBook1StartDate.addYears(3),finBook2StartDate.addYears(3),productsToInsert[0].Id,500000);
        insert cnLine1;

        Account testAccount2 = TestUtility.createAccount('Test Account2');
        insert testAccount2;

        blng__CreditNote__c creditNote2 = TestUtility.createCreditNote(testAccount2.Id);
        insert creditNote2;
        blng__CreditNoteLine__c cnLine2 = TestUtility.createCreditNoteLine(creditNote2.Id,finBook1StartDate.addYears(3),finBook2StartDate.addYears(3),productsToInsert[1].Id,100000);
        insert cnLine2;


    }

    @isTest
    public static void testCreditNoteServiceMasterRuleTestFuture(){
        Account accountObj = [ SELECT ID FROM Account WHERE Name = 'Test Account' ];
        blng__CreditNote__c creditNote = [ SELECT blng__Status__c FROM blng__CreditNote__c WHERE blng__Account__c = :accountObj.Id];
        Test.startTest();
            creditNote.blng__Status__c = 'Posted';
            update creditNote;
        Test.stopTest();

    }

    @isTest
    public static void testCreditNoteServiceMasterRuleCreateInputs(){
        blng__RevenueRecognitionRule__c testRule1 = [ SELECT Name FROM blng__RevenueRecognitionRule__c WHERE Name='Test Rev Rec Rule 1'];
        Account accountObj = [ SELECT ID FROM Account WHERE Name = 'Test Account' ];
        blng__CreditNote__c creditNote = [ SELECT blng__Status__c FROM blng__CreditNote__c WHERE blng__Account__c = :accountObj.Id];

        blng__CreditNoteLine__c creditNoteLine = [ SELECT blng__CreditNote__r.blng__Account__c,blng__Subtotal__c FROM blng__CreditNoteLine__c WHERE blng__CreditNote__c = :creditNote.Id ];
        List<blng.RevenueRecognitionInput> apiInputs;
        Test.startTest();
            apiInputs = T1_CreditNoteLineService.generateRevRecognitionInputsFromCNLineItems( new Set<Id>{creditNote.Id});
        Test.stopTest();
        
        system.assert(apiInputs != null);
        system.assert(apiInputs.size() > 0);
        Boolean containRule = false;
        for(blng.RevenueRecognitionInput inputVar : apiInputs ){
            system.debug('inputVar #### ' + inputVar);
            if(inputVar.revenueRecognitionRuleId == testRule1.Id){
                containRule = true;
            }
        }

        system.assert(containRule);
        
        system.assert(apiInputs[0].source == creditNoteLine.Id);
        system.assert(apiInputs[1].source == creditNoteLine.Id);

    }

    @isTest
    public static void testProcessCreditNoteLinesForRevRecMasterRule(){
        blng__RevenueRecognitionRule__c testRule1 = [ SELECT Name FROM blng__RevenueRecognitionRule__c WHERE Name='Test Rev Rec Rule 1'];
        Account accountObj = [ SELECT ID FROM Account WHERE Name = 'Test Account' ];
        blng__CreditNote__c creditNote = [ SELECT blng__Status__c FROM blng__CreditNote__c WHERE blng__Account__c = :accountObj.Id];
        Test.startTest();
            T1_CreditNoteLineService.processCreditNoteLinesForRevRec( new Set<Id>{creditNote.Id});
        Test.stopTest();
        

    }

    @isTest
    public static void testProcessCreditNoteLinesForRevRecException(){
        Account accountObj = [ SELECT ID FROM Account WHERE Name = 'Test Account' ];
        blng__CreditNote__c creditNote = [ SELECT blng__Status__c FROM blng__CreditNote__c WHERE blng__Account__c = :accountObj.Id];
        
        throwExceptionFlag = true;
        Test.startTest();
        try{
            T1_CreditNoteLineService.processCreditNoteLinesForRevRec( new Set<Id>{creditNote.Id});
        }catch( Exception e){
            system.assert(e.getTypeName() == 'T1_CreditNoteLineService.T1_CreditNoteLineServiceException');
        }
        Test.stopTest();
        

    }

    @isTest
    public static void testCreditNoteServiceFullRevRecRuleCreateInputs(){
        blng__RevenueRecognitionRule__c fullRevRule = [ SELECT blng__Active__c,Full_Revenue_Recognition__c,  ( SELECT Parent_Revenue_Recognition_Rule__c,Financial_End_Date__c ,Financial_Start_Date__c  FROM Revenue_Recognition_Rules__r ORDER BY Financial_Start_Date__c ASC) FROM blng__RevenueRecognitionRule__c WHERE  Name='Full Recognition - Master'];
        Account accountObj = [ SELECT ID FROM Account WHERE Name = 'Test Account2' ];
        blng__CreditNote__c creditNote = [ SELECT blng__Status__c FROM blng__CreditNote__c WHERE blng__Account__c = :accountObj.Id];
        blng__CreditNoteLine__c creditNoteLine = [SELECT ID,blng__CreditNote__c FROM blng__CreditNoteLine__c WHERE blng__CreditNote__c = :creditNote.Id];
        List<blng.RevenueRecognitionInput> apiInputs;
        Test.startTest();
            apiInputs = T1_CreditNoteLineService.generateRevRecognitionInputsFromCNLineItems( new Set<Id>{creditNote.Id});
        Test.stopTest();
        
        system.assert(apiInputs != null);
        system.assertEquals(apiInputs.size(), 1);
        Boolean containRule = false;
        for(blng__RevenueRecognitionRule__c ruleVar : fullRevRule.Revenue_Recognition_Rules__r ){
            system.debug('ruleVar #### ' + ruleVar);
            if(apiInputs[0].revenueRecognitionRuleId == ruleVar.Id){
                containRule = true;
            }
        }

        system.assert(containRule);
        
        system.assert(apiInputs[0].source == creditNoteLine.Id);


    }


    @isTest
    public static void testCreditNoteNotificationService(){
        
        // create Notification Service test data
        insert new T1_Control_Settings__c(
            T1_OAuth_Endpoint__c =  'https://test.notification.url/oauth',
            Notification_URL__c = 'https://test.notification.url/notify',
            T1_Max_Attempts__c = 8,
            T1_Retry_Frequency__c = 120
        );

        insert new T1_OAuth_Token__c();

        Account accountObj = [ SELECT ID FROM Account WHERE Name = 'Test Account' ];
        blng__CreditNote__c creditNote = [ SELECT Approval_Status__c, blng__Status__c FROM blng__CreditNote__c WHERE blng__Account__c = :accountObj.Id];
        
        Map<String,Object> r1 = (Map<String,Object>)JSON.deserializeUntyped('{        "access_token": "2YotnFZFEjr1zCsicMWpAA",        "token_type": "example",        "expires_in": 3600,        "refresh_token": "tGzv3JOkF0XG5Qx2TlKWIA"    }');

        AnyServiceMockImpl.postResponse.put(
            '/oauth',
            r1
        );

        AnyServiceMockImpl.postResponse.put(
            '/notify',
            '<?xml version="1.0" encoding="UTF-8"?>' +
            '<QTCnotres>' +
            '	<res_result>Success</res_result>' +
            '	<res_msg>string</res_msg>' +
            '</QTCnotres>'
        );

        Test.setMock(HttpCalloutMock.class, new AnyServiceMockImpl());
        
        Test.startTest();
        creditNote.Approval_Status__c = 'Approved';
        update creditNote;
        Test.stopTest();

    }


        
}