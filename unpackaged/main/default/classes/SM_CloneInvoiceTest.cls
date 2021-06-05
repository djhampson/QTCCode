/*******************************************************************************************************
* @Class Name   : SM_CloneInvoiceTest
* @description  : Test class for SM_CloneInvoice
* @author       : Yi Zhang
* @date         : 22/02/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              22/02/2021      1000        Initial version
* Yi Zhang              26/02/2021		2000		Added test data for T1 invoice's Order && PO Number fields
******************************************************************************************************/
@isTest
private class SM_CloneInvoiceTest {
    @isTest
    static void testCloneSchedulerGeneratedInvoice() {
        // Account
        Account a = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        insert a;
        
        // Billing Rule
        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test billing rule', blng__Active__c = true, blng__InitialBillingTrigger__c = 'Order Product Activation Date	', blng__GenerateInvoices__c = 'Yes');
        insert billingRule;
        
        blng__RevenueRecognitionRule__c rrRule = new blng__RevenueRecognitionRule__c(blng__CreateRevenueSchedule__c = 'Yes', Name = 'Test Revenue Recog Rule', blng__Active__c = true);
        insert rrRule;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'Yes', Name = 'Test Tax Rule');
        insert taxRule;
        
        // product
        Id pricebookId = Test.getStandardPricebookId();
        Product2 product1 = new Product2(Name = 'test p', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance');
        Product2 product2 = new Product2(Name = 'test p2', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance');        
        insert new List<Product2>{product1, product2};
        
        PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe2 =new PricebookEntry(product2Id = product2.Id, UnitPrice = -100, pricebook2Id = pricebookId, IsActive = true);
        insert new List<PricebookEntry>{pbe1, pbe2};
        
        // opportunity
        Opportunity opp = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, Name = 'Test Opp', Pricebook2Id = pricebookId);
        insert opp;
        
        // quotes
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = Date.today() + 365, SBQQ__ExpirationDate__c = Date.today() + 30,
                                                   Purchase_Order_Number__c = 'PON-Scheduler');

        insert new List<SBQQ__Quote__c>{quote1};
        // quote lines
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product1.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                  SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12), 
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Category__c = SM_SplitInvoice.QUOTELINE_CATEGORY_COMMITMENT_REBATE, SBQQ__CustomerPrice__c = -100, SBQQ__Quantity__c = 1, SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                   SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12)
        };
        insert lines;

        Test.startTest();        
        
        // order
        quote1.SBQQ__Ordered__c = true;
        update quote1;
        
        Order o = [SELECT Id FROM Order];
        
        // manually create invoice (instead of using Bill Now)
        blng__Invoice__c invoice = new blng__Invoice__c(blng__Account__c = a.Id, blng__InvoiceDate__c = Date.today(), blng__DueDate__c = Date.today() + 30);
        insert invoice;
        List<blng__InvoiceLine__c> invoiceLines = new List<blng__InvoiceLine__c>{
        	new blng__InvoiceLine__c(blng__CalculatedQuantity__c = 1, blng__Quantity__c = 1, blng__ChargeType__c = 'Recurring', blng__UnitPrice__c = 1000, blng__Subtotal__c = 1000,
                                    blng__TotalAmount__c = 1000, blng__BillingFrequency__c = 'Annual', blng__Invoice__c = invoice.Id, blng__OrderProduct__c = [SELECT Id FROM OrderItem LIMIT 1].Id)
        };
        insert invoiceLines;
        
        // test schedulable
        System.schedule('Clone Invoice Hourly Test', '0 3 * * * ?', new SM_CloneInvoiceBatch());
         
        // test batchable
        Database.executebatch(new SM_CloneInvoiceBatch());
        
        Test.stopTest();
        
        System.assertEquals(1, [SELECT Id FROM T1_Invoice__c].size(), '1 invoice should have been cloned');
    }
    
    @isTest
    static void testCloneBillNowInvoice() {
        // Account
        Account a = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        insert a;
        
        // Billing Rule
        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test billing rule', blng__Active__c = true, blng__InitialBillingTrigger__c = 'Order Product Activation Date	', blng__GenerateInvoices__c = 'Yes');
        insert billingRule;
        
        blng__RevenueRecognitionRule__c rrRule = new blng__RevenueRecognitionRule__c(blng__CreateRevenueSchedule__c = 'Yes', Name = 'Test Revenue Recog Rule', blng__Active__c = true);
        insert rrRule;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'Yes', Name = 'Test Tax Rule');
        insert taxRule;
        
        // product
        Id pricebookId = Test.getStandardPricebookId();
        Product2 product1 = new Product2(Name = 'test p', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance');
        Product2 product2 = new Product2(Name = 'test p2', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance');        
        insert new List<Product2>{product1, product2};
        
        PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe2 =new PricebookEntry(product2Id = product2.Id, UnitPrice = -100, pricebook2Id = pricebookId, IsActive = true);
        insert new List<PricebookEntry>{pbe1, pbe2};
        
        // opportunity
        Opportunity opp = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, Name = 'Test Opp', Pricebook2Id = pricebookId);
        insert opp;
        
        // quotes
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = Date.today() + 365, SBQQ__ExpirationDate__c = Date.today() + 30,
                                                   Purchase_Order_Number__c = 'PON-BillNow');

        insert new List<SBQQ__Quote__c>{quote1};
        // quote lines
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product1.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                  SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12), 
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Category__c = SM_SplitInvoice.QUOTELINE_CATEGORY_COMMITMENT_REBATE, SBQQ__CustomerPrice__c = -100, SBQQ__Quantity__c = 1, SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                   SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12)
        };
        insert lines;

        Test.startTest();        
        
        // order
        quote1.SBQQ__Ordered__c = true;
        update quote1;
        
        Order o = [SELECT Id FROM Order];
        
        // invoice
        o.Status = 'Activated';
        o.blng__BillNow__c = true;
        update o;
        
        Test.stopTest();
        
        System.assertEquals(1, [SELECT Id FROM T1_Invoice__c].size(), '1 invoice should have been cloned');
    }
}