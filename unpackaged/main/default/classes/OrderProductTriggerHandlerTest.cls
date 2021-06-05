/*******************************************************************************************************
* @Class Name   : OrderProductTriggerHandlerTest
* @description  : Test class for OrderProductTriggerHandler
* @author       : Yi Zhang
* @date         : 17/02/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              17/02/2021      1000        Initial version
* Yi Zhang              01/03/2021      2000        Modified test method to test TOCB-1422 & has posted invoice line
* Gerald Arzadon        09/03/2021      3000        Added test method for revenue amount calculation and invoice plane scenario
******************************************************************************************************/
@isTest
private class OrderProductTriggerHandlerTest {
   @isTest
    static void calculateRevenueAmount_Test() {
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
        
        blng__LegalEntity__c LegalEntity = new blng__LegalEntity__c(Name='TechnologyOne Limited', blng__Active__c=true,
                                                                    blng__City__c='Fortitude Valley', blng__Country__c='Australia', blng__County__c='Australia', 
                                                                    blng__State__c='QLD', blng__Street1__c='Level 11', blng__Street2__c='TechnologyOne HQ, 540 Wickham Street', 
                                                                    blng__ZipPostalCode__c='4006');
        INSERT LegalEntity;
        
        INSERT new Billing_CS__c(SetupOwnerId=UserInfo.getOrganizationId(), Legal_Entity_ID__c=LegalEntity.Id);
        INSERT new T1_Control_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Workflow__c=TRUE, Bypass_Triggers__c=TRUE, Bypass_Validation_Rules__c=TRUE, T1_Timeout_milliseconds__c = 10000);
        
        // product
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 product = new Product2(Name = 'test p', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', SBQQ__SubscriptionTerm__c = 12);
        Product2 product2 = new Product2(Name = 'test p2', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', SBQQ__SubscriptionTerm__c = 12);
        Product2 product3 = new Product2(Name = 'test p3', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id);
        insert new List<Product2>{product, product2,product3};
        
        List<PricebookEntry> pbes = new List<PricebookEntry>{
            new PricebookEntry(product2Id = product.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true),
            new PricebookEntry(product2Id = product2.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true),
            new PricebookEntry(product2Id = product3.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true)
        };
        insert pbes;
        
        SBQQ__ProductOption__c POB1 = new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c=product3.Id,SBQQ__Number__c=1, SBQQ__OptionalSKU__c=product2.Id);
        SBQQ__ProductOption__c POSPS = new  SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c=product3.Id,  SBQQ__OptionalSKU__c=product.Id,SBQQ__Number__c=1);
        INSERT new List<SBQQ__ProductOption__c>{POB1,POSPS};
        
        // opportunity
        Opportunity opp1 = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, Name = 'Test Opp', Pricebook2Id = pricebookId);
        insert new List<Opportunity>{opp1};
        
        // quotes
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5',Streamline_Revenue__c = TRUE); 
       
        insert new List<SBQQ__Quote__c>{quote1};
                    
        SBQQ__QuoteLineGroup__c testQLGroup1 = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = quote1.Id,SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(2).addDays(-1));
        SBQQ__QuoteLineGroup__c testQLGroup2 = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = quote1.Id, SBQQ__StartDate__c = System.today().addYears(2),SBQQ__EndDate__c = System.today().addYears(4).addDays(-1));
        //INSERT new List<SBQQ__QuoteLineGroup__c>{testQLGroup1,testQLGroup2};
            
        // quote lines
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = 'License', SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product3.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                   SBQQ__ChargeType__c = 'One-Time',SBQQ__StartDate__c = System.today(), SBQQ__EndDate__c = System.today().addYears(2).addDays(-1)),
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = 'License', SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product3.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                   SBQQ__ChargeType__c = 'One-Time',SBQQ__StartDate__c = System.today().addYears(2), SBQQ__EndDate__c = System.today().addYears(4).addDays(-1))
        };
        insert lines;
        
        List<SBQQ__QuoteLine__c> childLines = new List<SBQQ__QuoteLine__c>{
            // CLOUD PRODUCTS
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, 
                                   SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Annual', 
                                   SBQQ__BillingType__c = 'Advance',SBQQ__RequiredBy__c=lines[0].Id,SBQQ__ProductOption__c = POB1.Id,SBQQ__StartDate__c = System.today(), SBQQ__EndDate__c = System.today().addYears(2).addDays(-1)),
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, 
                                   SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Annual', 
                                   SBQQ__BillingType__c = 'Advance',SBQQ__RequiredBy__c=lines[1].Id,SBQQ__ProductOption__c = POB1.Id,SBQQ__StartDate__c = System.today().addYears(2), SBQQ__EndDate__c = System.today().addYears(4).addDays(-1)),
           // ASM PRODUCTS
           new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_ASM, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, 
                                   SBQQ__Product__c = product.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Annual', 
                                   SBQQ__BillingType__c = 'Advance',SBQQ__RequiredBy__c=lines[0].Id,SBQQ__ProductOption__c = POSPS.Id,SBQQ__StartDate__c = System.today(), SBQQ__EndDate__c = System.today().addYears(2).addDays(-1)),
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_ASM, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, 
                                   SBQQ__Product__c = product.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Annual', 
                                   SBQQ__BillingType__c = 'Advance',SBQQ__RequiredBy__c=lines[1].Id,SBQQ__ProductOption__c = POSPS.Id,SBQQ__StartDate__c = System.today().addYears(2), SBQQ__EndDate__c = System.today().addYears(4).addDays(-1))
                };
        test.startTest();
        insert childLines;
       
        // order
        quote1.SBQQ__Ordered__c = true;
        update quote1;
        
        test.stopTest();
        
        Order o = [SELECT Id FROM Order];
        o.Status = 'Activated';
        update o;
        Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get('OrderItem').getDescribe().fields.getMap();
        List<OrderItem> OrderItemList = Database.query('SELECT '+string.join(new List<String>(mfields.keySet()), ',')+' FROM OrderItem');
        OrderProductTriggerHandler.totalPriceAsRevenueAmount(OrderItemList);
        OrderProductTriggerHandler.translateBillingFrequency('Monthly');
        OrderProductTriggerHandler.translateBillingFrequency('Quarterly');
        OrderProductTriggerHandler.translateBillingFrequency('Semiannual');
        OrderProductTriggerHandler.calculateASMRevenue(100,100,100);
        OrderProductTriggerHandler.calculatePOTCloudRevenue(100,100,100);
        OrderProductTriggerHandler.calculateNonPOTCloudRevenue(100,100,100);
    }
   @isTest
    static void testSyncInvoicingDates_HasNoInvoiceLinesAmendmentInThePast() {
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
        
        blng__LegalEntity__c LegalEntity = new blng__LegalEntity__c(Name='TechnologyOne Limited', blng__Active__c=true,
                                                                    blng__City__c='Fortitude Valley', blng__Country__c='Australia', blng__County__c='Australia', 
                                                                    blng__State__c='QLD', blng__Street1__c='Level 11', blng__Street2__c='TechnologyOne HQ, 540 Wickham Street', 
                                                                    blng__ZipPostalCode__c='4006');
        // INSERT LegalEntity;
        
        // INSERT new Billing_CS__c(SetupOwnerId=UserInfo.getOrganizationId(), Legal_Entity_ID__c=LegalEntity.Id);
         INSERT new T1_Control_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Workflow__c=TRUE, Bypass_Triggers__c=TRUE, Bypass_Validation_Rules__c=TRUE);
        
        // product
        Id pricebookId = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'test p', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', SBQQ__SubscriptionTerm__c = 12);
        Product2 product2 = new Product2(Name = 'test p2', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', SBQQ__SubscriptionTerm__c = 12);
        insert new List<Product2>{product, product2};
        
        //PricebookEntry pbe = new PricebookEntry(product2Id = product.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        List<PricebookEntry> pbes = new List<PricebookEntry>{
            new PricebookEntry(product2Id = product.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true),
            new PricebookEntry(product2Id = product2.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true)
        };
        insert pbes;
        
        // opportunity
        Opportunity opp1 = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, Name = 'Test Opp', Pricebook2Id = pricebookId);
        Opportunity opp2 = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, Name = 'Amendment Opp', Pricebook2Id = pricebookId);
        insert new List<Opportunity>{opp1, opp2};
        
        // quotes
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5'); 
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp2.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', SBQQ__Type__c = 'Amendment'); 

        insert new List<SBQQ__Quote__c>{quote1, quote2};
        // quote lines
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Annual', SBQQ__BillingType__c = 'Advance')
        };
        insert lines;

        // order
        quote1.SBQQ__Ordered__c = true;
        update quote1;
        
        Order o = [SELECT Id FROM Order];
        
        // invoice
        o.Status = 'Activated';
        o.blng__BillNow__c = true;
        update o;

        // post invoice lines
        List<blng__InvoiceLine__c> invoiceLines = new List<blng__InvoiceLine__c>();
        for(blng__InvoiceLine__c line : [SELECT Id FROM blng__InvoiceLine__c]) {
            line.blng__InvoiceLineStatus__c = 'Posted';
        }
        update invoiceLines;

        Test.startTest();
        // create service contract and associate with order
        ServiceContract sc = new ServiceContract(Name = 'Test SC', SBQQSC__Order__c = o.Id, StartDate = Date.today(), EndDate = Date.today() + 365, AccountId = a.Id, SBQQSC__Opportunity__c = opp1.Id);
        insert sc;

        // associated quote2 with service contract
        quote2.SBQQSC__MasterServiceContract__c = sc.Id;
        update quote2;

        // setup line for quote2 (if included above will produce error FIELD_CUSTOM_VALIDATION_EXCEPTION, Price Book Entry ID: id value of incorrect type)
        SBQQ__QuoteLine__c line2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote2.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Annual', SBQQ__BillingType__c = 'Advance');
        insert line2;

        // create order & order product
        Order order2 = new Order(AccountId = a.Id, Type = 'Amendment', OpportunityId = opp2.Id, SBQQ__Quote__c = quote2.Id, EffectiveDate = Date.today() - 30, 
                                 Status = 'Draft', Pricebook2Id = pricebookId);
        insert order2;
        
        

        List<OrderItem> items = new List<OrderItem>{
            new OrderItem(OrderId = order2.Id, Product2Id = product2.Id, Quantity = 1, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', 
                          SBQQ__BillingFrequency__c = 'Annual', ServiceDate = Date.today() - 30, blng__NextBillingDate__c = Date.today() - 30, 
                          blng__TaxRule__c = taxRule.Id, blng__BillingRule__c = billingRule.Id, PricebookEntryId = pbes[1].Id, UnitPrice = 1000, 
                          SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__Status__c = 'Draft')
        };
        insert items;
        order2.Status = 'Activated';
        update order2;
        
        items[0].SBQQ__Status__c = 'Activated';
        items[0].blng__LastChargeToDate__c = Date.today() + 105;
        update items;

        Test.stopTest();
    }
    
    @isTest
    static void testSyncInvoicingDates_HasNoInvoiceLinesAmendmentInTheFuture() {
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
        
         blng__LegalEntity__c LegalEntity = new blng__LegalEntity__c(Name='TechnologyOne Limited', blng__Active__c=true,
                                                                    blng__City__c='Fortitude Valley', blng__Country__c='Australia', blng__County__c='Australia', 
                                                                    blng__State__c='QLD', blng__Street1__c='Level 11', blng__Street2__c='TechnologyOne HQ, 540 Wickham Street', 
                                                                    blng__ZipPostalCode__c='4006');
        INSERT LegalEntity;
        
        INSERT new Billing_CS__c(SetupOwnerId=UserInfo.getOrganizationId(), Legal_Entity_ID__c=LegalEntity.Id);
        INSERT new T1_Control_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Workflow__c=TRUE, Bypass_Triggers__c=TRUE, Bypass_Validation_Rules__c=TRUE, T1_Timeout_milliseconds__c = 10000);
        
        // product
        Id pricebookId = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'test p', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', SBQQ__SubscriptionTerm__c = 12);
        Product2 product2 = new Product2(Name = 'test p2', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', SBQQ__SubscriptionTerm__c = 12);
        insert new List<Product2>{product, product2};
        
        //PricebookEntry pbe = new PricebookEntry(product2Id = product.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        List<PricebookEntry> pbes = new List<PricebookEntry>{
            new PricebookEntry(product2Id = product.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true),
            new PricebookEntry(product2Id = product2.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true)
        };
        insert pbes;
        
        // opportunity
        Opportunity opp1 = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, Name = 'Test Opp', Pricebook2Id = pricebookId);
        Opportunity opp2 = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, Name = 'Amendment Opp', Pricebook2Id = pricebookId);
        insert new List<Opportunity>{opp1, opp2};
        
        // quotes
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5'); 
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp2.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', SBQQ__Type__c = 'Amendment'); 

        insert new List<SBQQ__Quote__c>{quote1, quote2};
        // quote lines
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Annual', SBQQ__BillingType__c = 'Advance')
        };
        insert lines;

        // order
        quote1.SBQQ__Ordered__c = true;
        update quote1;
        
        Order o = [SELECT Id FROM Order];
        
        // invoice
        o.Status = 'Activated';
        o.blng__BillNow__c = true;
        update o;

        // post invoice lines
        List<blng__InvoiceLine__c> invoiceLines = new List<blng__InvoiceLine__c>();
        for(blng__InvoiceLine__c line : [SELECT Id FROM blng__InvoiceLine__c]) {
            line.blng__InvoiceLineStatus__c = 'Posted';
        }
        update invoiceLines;


        Test.startTest();
        // create service contract and associate with order
        ServiceContract sc = new ServiceContract(Name = 'Test SC', SBQQSC__Order__c = o.Id, StartDate = Date.today(), EndDate = Date.today() + 365, AccountId = a.Id, SBQQSC__Opportunity__c = opp1.Id);
        insert sc;

        // associated quote2 with service contract
        quote2.SBQQSC__MasterServiceContract__c = sc.Id;
        update quote2;

        // setup line for quote2 (if included above will produce error FIELD_CUSTOM_VALIDATION_EXCEPTION, Price Book Entry ID: id value of incorrect type)
        SBQQ__QuoteLine__c line2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote2.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Annual', SBQQ__BillingType__c = 'Advance');
        insert line2;

        // create order & order product
        Order order2 = new Order(AccountId = a.Id, Type = 'Amendment', OpportunityId = opp2.Id, SBQQ__Quote__c = quote2.Id, EffectiveDate = Date.today() + 366, 
                                 Status = 'Draft', Pricebook2Id = pricebookId);
        insert order2;
        
        
        List<OrderItem> items = new List<OrderItem>{
            new OrderItem(OrderId = order2.Id, Product2Id = product2.Id, Quantity = 1, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', 
                          SBQQ__BillingFrequency__c = 'Annual', ServiceDate = Date.today() + 366, blng__NextBillingDate__c = Date.today() + 366, 
                          blng__TaxRule__c = taxRule.Id, blng__BillingRule__c = billingRule.Id, PricebookEntryId = pbes[1].Id, UnitPrice = 1000, 
                          SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__Status__c = 'Draft')
        };
        insert items;
        order2.Status = 'Activated';
        update order2;
        
        items[0].SBQQ__Status__c = 'Activated';
        items[0].blng__LastChargeToDate__c = Date.today() + 105;
        update items;

        Test.stopTest();
    }
    
    /**
    * @description  To test scenario for TOCB-1422 and order product has invoice lines generated and posted
    * @author Yi Zhang | 01/03/2021 
    **/
    @isTest
    static void testSyncInvoicingDates_HasPostedInvoiceLines() {
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
        
        blng__LegalEntity__c LegalEntity = new blng__LegalEntity__c(Name='TechnologyOne Limited', blng__Active__c=true,
                                                                    blng__City__c='Fortitude Valley', blng__Country__c='Australia', blng__County__c='Australia', 
                                                                    blng__State__c='QLD', blng__Street1__c='Level 11', blng__Street2__c='TechnologyOne HQ, 540 Wickham Street', 
                                                                    blng__ZipPostalCode__c='4006');
        INSERT LegalEntity;
        
        INSERT new Billing_CS__c(SetupOwnerId=UserInfo.getOrganizationId(), Legal_Entity_ID__c=LegalEntity.Id);
        INSERT new T1_Control_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Workflow__c=TRUE, Bypass_Triggers__c=TRUE, Bypass_Validation_Rules__c=TRUE, T1_Timeout_milliseconds__c = 10000);
        
        // product
        Id pricebookId = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'test p', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', SBQQ__SubscriptionTerm__c = 12);
        Product2 product2 = new Product2(Name = 'test p2', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', SBQQ__SubscriptionTerm__c = 12);
        insert new List<Product2>{product, product2};
        
        //PricebookEntry pbe = new PricebookEntry(product2Id = product.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        List<PricebookEntry> pbes = new List<PricebookEntry>{
            new PricebookEntry(product2Id = product.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true),
            new PricebookEntry(product2Id = product2.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true)
        };
        insert pbes;
        
        // opportunity
        Opportunity opp1 = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, Name = 'Test Opp', Pricebook2Id = pricebookId);
        Opportunity opp2 = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, Name = 'Amendment Opp', Pricebook2Id = pricebookId);
        insert new List<Opportunity>{opp1, opp2};
        
        // quotes
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5'); 
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp2.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', SBQQ__Type__c = 'Amendment'); 

        insert new List<SBQQ__Quote__c>{quote1, quote2};
        // quote lines
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Annual', SBQQ__BillingType__c = 'Advance')
        };
        insert lines;

        // order
        quote1.SBQQ__Ordered__c = true;
        update quote1;
        
        Order o = [SELECT Id FROM Order];
        
        // invoice
        o.Status = 'Activated';
        o.blng__BillNow__c = true;
        update o;
        
        System.debug('Limts.getCpuTime after set up 1st invoice: ' + Limits.getCpuTime());

        // post invoice lines
        // List<blng__InvoiceLine__c> invoiceLines = new List<blng__InvoiceLine__c>();
        // for(blng__InvoiceLine__c line : [SELECT Id FROM blng__InvoiceLine__c]) {
        //     line.blng__InvoiceLineStatus__c = 'Posted';
        // }
        // update invoiceLines;
        System.debug('check invoice lines');
        System.debug([SELECT Id, blng__InvoiceLineStatus__c FROM blng__InvoiceLine__c]);

        Test.startTest();
        // create service contract and associate with order
        ServiceContract sc = new ServiceContract(Name = 'Test SC', SBQQSC__Order__c = o.Id, StartDate = Date.today(), EndDate = Date.today() + 365, AccountId = a.Id, SBQQSC__Opportunity__c = opp1.Id);
        insert sc;

        // associate quote2 with service contract
        // quote2.SBQQSC__MasterServiceContract__c = sc.Id;
        // update quote2;
        // associate opp2 with service contract
        opp2.SBQQSC__RenewedServiceContract__c = sc.Id;
        update opp2;

        // setup line for quote2 (if included above will produce error FIELD_CUSTOM_VALIDATION_EXCEPTION, Price Book Entry ID: id value of incorrect type)
        SBQQ__QuoteLine__c line2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote2.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Annual', SBQQ__BillingType__c = 'Advance');
        insert line2;

        // create order & order product
        Order order2 = new Order(AccountId = a.Id, Type = 'Amendment', OpportunityId = opp2.Id, SBQQ__Quote__c = quote2.Id, EffectiveDate = Date.today() + 366, 
                                 Status = 'Draft', Pricebook2Id = pricebookId);
        insert order2;
        
        List<OrderItem> items = new List<OrderItem>{
            new OrderItem(OrderId = order2.Id, Product2Id = product2.Id, Quantity = 1, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', 
                          SBQQ__BillingFrequency__c = 'Semiannual', ServiceDate = Date.today() + 366, blng__NextBillingDate__c = Date.today() + 366, 
                          blng__TaxRule__c = taxRule.Id, blng__BillingRule__c = billingRule.Id, PricebookEntryId = pbes[1].Id, UnitPrice = 1000, 
                          SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__Status__c = 'Draft')
        };
        insert items;
        order2.Status = 'Activated';
        update order2;
        
        // manually create invoice (instead of using Bill Now)
        blng__Invoice__c invoice2 = new blng__Invoice__c(blng__Account__c = a.Id, blng__InvoiceDate__c = Date.today(), blng__DueDate__c = Date.today() + 30);
        insert invoice2;
        List<blng__InvoiceLine__c> invoiceLines = new List<blng__InvoiceLine__c>{
        	new blng__InvoiceLine__c(blng__CalculatedQuantity__c = 1, blng__Quantity__c = 1, blng__ChargeType__c = 'Recurring', blng__UnitPrice__c = 1000, blng__Subtotal__c = 1000,
                                    blng__TotalAmount__c = 1000, blng__BillingFrequency__c = 'Semiannual', blng__Invoice__c = invoice2.Id, blng__OrderProduct__c = items[0].Id, 
                                    blng__InvoiceLineStatus__c = 'Posted')
        };
        insert invoiceLines;
        
        System.debug('Limts.getCpuTime before startTest(): ' + Limits.getCpuTime());

        
        items[0].SBQQ__Status__c = 'Activated';
        items[0].blng__LastChargeToDate__c = Date.today();
        update items;

        Test.stopTest();
    }
}