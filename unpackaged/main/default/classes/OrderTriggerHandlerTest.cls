/*******************************************************************************************************
* @Class Name   : OrderTriggerHandlerTest
* @description  : Test clas for OrderTriggerHandler
* @author       : Carlos Roy Billones
* @date         : 24/02/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Carlos Roy Billones   24/02/2021      1000        Initial version
******************************************************************************************************/
@isTest
public class OrderTriggerHandlerTest {
    @isTest
    public static void OrderTriggerHandlerTest1(){

        Account a = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        insert a;
        

        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test-BillingRule-TEMPLATE', blng__Active__c = true, blng__InitialBillingTrigger__c = 'Order Product Activation Date', blng__GenerateInvoices__c = 'Yes',
                                                                    blng__PartialPeriodTreatment__c = 'Separate');
        insert billingRule;
        
        blng__RevenueRecognitionRule__c rrRule = new blng__RevenueRecognitionRule__c(blng__CreateRevenueSchedule__c = 'Yes', Name = 'Test Revenue Recog Rule', blng__Active__c = true);
        insert rrRule;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'Yes', Name = 'Test Tax Rule');
        insert taxRule;
        
        blng__FinanceBook__c bfb = new blng__FinanceBook__c(Name='Test Financial Book', 
                                                            blng__PeriodType__c = 'Accounting');
        insert bfb;
        
        blng__LegalEntity__c ble = new blng__LegalEntity__c(Name='Test Legal Entity', 
                                                            blng__Active__c=true);
        insert ble;
        
        blng__BillingTreatment__c bt = new blng__BillingTreatment__c(Name='TEMPLATE - Billing - Treatment',
                                                                     blng__BillingRule__c = billingRule.Id,
                                                                     blng__Active__c = true, 
                                                                     blng__BillingFinanceBook__c = bfb.Id,
                                                                     blng__BillingLegalEntity__c = ble.Id,
                                                                     blng__CancellationRule__c = 'Legacy');
        insert bt;
        
        
        // product
        Id pricebookId = Test.getStandardPricebookId();
        Product2 product1 = new Product2(Name = 'test p', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SPS');
        Product2 product2 = new Product2(Name = 'test p2', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SPS');        
        Product2 product3 = new Product2(Name = 'Test p3', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance');
        insert new List<Product2>{product1, product2, product3};
            
            PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe2 =new PricebookEntry(product2Id = product2.Id, UnitPrice = -100, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe3 =new PricebookEntry(product2Id = product3.Id, UnitPrice = 0, pricebook2Id = pricebookId, IsActive = true);
        insert new List<PricebookEntry>{pbe1, pbe2, pbe3};
            

            Opportunity opp1 = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, Name = 'Original Opp', Pricebook2Id = pricebookId);
        insert new List<Opportunity>{opp1};
            
 
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), Auto_Amendment__c = true, SBQQ__Opportunity2__c = opp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                       SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = Date.today() + 365, SBQQ__ExpirationDate__c = Date.today() + 30);
        
        
        insert new List<SBQQ__Quote__c>{quote1};

            List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{
                new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product1.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                       SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12), 
                    new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', Category__c = SM_SplitInvoice.QUOTELINE_CATEGORY_COMMITMENT_REBATE, SBQQ__CustomerPrice__c = -100, SBQQ__Quantity__c = 1, SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                           SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12)
                    };
                        insert lines;
        Test.startTest();
        Customer_Invoice_Plan__c cip = new Customer_Invoice_Plan__c(Quote__c = quote1.Id);
        insert cip;
        
        /*Quote_CIP__c qcip = new Quote_CIP__c(Quote__c = quote1.Id,Fee_Type__c='License',Customer_Invoice_Plan__c = cip.Id);
        insert qcip;*/
        
        Customer_Invoice_Plan_Line__c cipl = new Customer_Invoice_Plan_Line__c(Customer_Invoice_Plan__c = cip.Id,Invoice_Date__c = System.today(),Name = 'CIPL-0001',Processing_Order__c = 1,Amount__c = 1);
        insert cipl;
        
        cip.Active__c = true;
        update cip;
        
        
        Order ord = new Order(Name='Test Order-00001',
                              AccountId = a.Id,
                              Auto_Amendment__c = true,
                              SBQQ__Quote__c = quote1.Id,
                              EffectiveDate = System.today(),
                              Status = 'Draft',
                              blng__BillingDayOfMonth__c = '1');
        
        insert ord;
        
        blng__InvoicePlan__c bip = new blng__InvoicePlan__c(blng__BillingScheduleCreation__c = 'Manual', Order_Id__c = ord.Id);
        insert bip;
        
        OrderItem orderProduct = new OrderItem(blng__BillingRule__c = billingRule.Id,
                                               blng__RevenueRecognitionRule__c = rrRule.Id,
                                               blng__TaxRule__c = taxRule.Id,
                                               OrderId = ord.Id,
                                               PricebookEntryId = pbe1.Id,
                                               SBQQ__ChargeType__c = 'One-Time',
                                               UnitPrice = 1,
                                               Quantity = 3);
        
        insert orderProduct;
        
        ord.Status = 'Activated';
        
        update ord;
        Test.stopTest();
        
    }
}