/*******************************************************************************************************
* @Class Name   : SM_SplitInvoiceTest
* @description  : Test class for SM_SplitInvoice
* @author       : Yi Zhang
* @date         : 16/02/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              16/02/2021      1000        Initial version
* Yi Zhang              19/02/2021		2000		Codes for Commitment Rebate changes
* Yi Zhang              22/02/2021		3000		Test multiple active CIPs per quote
* Yi Zhang              26/02/2021		4000		Added test data for T1 invoice's Order && PO Number fields
* Yi Zhang              22/03/2021		5000		TOCB-1658 copy unsplit invoice lines into custom invoice objects
******************************************************************************************************/
@isTest
private class SM_SplitInvoiceTest {
    @isTest
    static void testManageCustomerInvoicePlan() {
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
        Product2 product3 = new Product2(Name = 'test p3', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance');              
        Product2 product4 = new Product2(Name = 'Commitment Fee', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance');    
        insert new List<Product2>{product1, product2, product3, product4};
        
        PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe2 =new PricebookEntry(product2Id = product2.Id, UnitPrice = -100, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe3 =new PricebookEntry(product2Id = product3.Id, UnitPrice = 2000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe4 =new PricebookEntry(product2Id = product4.Id, UnitPrice = 500, pricebook2Id = pricebookId, IsActive = true);
        insert new List<PricebookEntry>{pbe1, pbe2, pbe3, pbe4};
        
        // opportunity
        Opportunity opp = new Opportunity(AccountId = a.Id, StageName = '2 - Qualify', CloseDate = Date.today() + 30, Name = 'Test Opp', Pricebook2Id = pricebookId);
        insert opp;
        
        // quotes
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = Date.today() + 365, SBQQ__ExpirationDate__c = Date.today() + 30,
                                                   Purchase_Order_Number__c = 'PON-Master');

        insert new List<SBQQ__Quote__c>{quote1};
        // quote lines
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, 
                                   SBQQ__Product__c = product1.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', 
                                   SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12), 
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Category__c = SM_SplitInvoice.QUOTELINE_CATEGORY_COMMITMENT_REBATE, SBQQ__CustomerPrice__c = -100, SBQQ__Quantity__c = 1, 
                                   SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', 
                                   SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12), 
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_LICENSE, SBQQ__CustomerPrice__c = 2000, SBQQ__Quantity__c = 1, 
                                   SBQQ__Product__c = product3.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', 
                                   SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12), 
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Category__c = SM_SplitInvoice.QUOTELINE_CATEGORY_COMMITMENT_FEE, SBQQ__CustomerPrice__c = 500, SBQQ__Quantity__c = 1, 
                                    SBQQ__Product__c = product4.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', 
                                    SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12)
        };
        insert lines;

        Test.startTest();
        // create CIP
        Customer_Invoice_Plan__c plan1 = new Customer_Invoice_Plan__c(Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.PLAN_FEE_TYPE_SAAS, Include_Commitment_Fee__c = true);
        Customer_Invoice_Plan__c plan2 = new Customer_Invoice_Plan__c(Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.PLAN_FEE_TYPE_LICENCE);
        insert new List<Customer_Invoice_Plan__c>{plan1, plan2};
        
        // create CIPL
        List<Customer_Invoice_Plan_Line__c> planLines = new List<Customer_Invoice_Plan_Line__c>{
            new Customer_Invoice_Plan_Line__c(Customer_Invoice_Plan__c = plan1.Id, Type__c = 'Amount', Amount__c = 800, Commitment_Rebate__c = -50, Purchase_Order_Number__c = 'PON-00001'),
            new Customer_Invoice_Plan_Line__c(Customer_Invoice_Plan__c = plan1.Id, Type__c = 'Remainder'),
            new Customer_Invoice_Plan_Line__c(Customer_Invoice_Plan__c = plan2.Id, Type__c = 'Amount', Amount__c = 1500),
            new Customer_Invoice_Plan_Line__c(Customer_Invoice_Plan__c = plan2.Id, Type__c = 'Remainder')
        };
        insert planLines;
        
        // activate plan
        plan1.Active__c = true;
        plan2.Active__c = true;
        update new List<Customer_Invoice_Plan__c>{plan1, plan2};
        
        // add new amount CIPL
        Customer_Invoice_Plan_Line__c amountLine = new Customer_Invoice_Plan_Line__c(Customer_Invoice_Plan__c = plan1.Id, Type__c = 'Amount', Amount__c = 100);
        insert amountLine;
        
        // amend amount CIPL to exceed limit
        amountLine.Amount__c = 300;
        try {
            update amountLine;
        } catch(Exception e) {}
        
        // delete amount CIPL
        delete amountLine;
        
        // order
        quote1.SBQQ__Ordered__c = true;
        update quote1;
        
        Order o = [SELECT Id FROM Order];
        
        // invoice
        o.Status = 'Activated';
        o.blng__BillNow__c = true;
        update o;
        
        // test schedulable
        System.schedule('Split Invoice Hourly Test', '0 23 * * * ?', new T1_InvoiceSplitBatch());
         
        // test batchable
        Database.executeBatch(new T1_InvoiceSplitBatch());
        
        Test.stopTest();
        
        System.assertEquals(5, [SELECT Id FROM T1_Invoice__c].size(), '5 split T1 invoices should have been created.');
    }
}