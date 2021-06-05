/**
 * @description       : T1 Order Trigger Handler Test
 * @author            : Alfredo Edo
 * @group             : 
 * @last modified on  : 20-04-2021
 * @last modified by  : Alfredo Edo
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   20-04-2021   Alfredo Edo              Initial Version
**/
@isTest
public class T1OrderTriggerHandlerTest {
   
    static testmethod void T1OrderTriggerWhenReducedAndRemove() {
        
        //Original value
        Double Ori_SBQQ_Quantity_c = 3;
        Double Ori_SBQQSC_Quantity_c = 5;
        Double Ori_SBQQSC_RenewalQuantity_c = 5;
        
        //Renewal Quote quantity
        Double l_SBQQ_Quantity_c = 1;

         
        //Basic Setup
        Account a = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        INSERT a;        

        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test billing rule', blng__Active__c = true, blng__InitialBillingTrigger__c = 'Order Product Activation Date  ', blng__GenerateInvoices__c = 'Yes');
        INSERT billingRule;
        
        blng__RevenueRecognitionRule__c rrRule = new blng__RevenueRecognitionRule__c(blng__CreateRevenueSchedule__c = 'Yes', Name = 'Test Revenue Recog Rule', blng__Active__c = true);
        INSERT rrRule;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'Yes', Name = 'Test Tax Rule');
        INSERT taxRule;
        
        // product
        Id pricebookId = Test.getStandardPricebookId();
        Product2 product1 = new Product2(Name = 'test p', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SPS');
        Product2 product2 = new Product2(Name = 'test p2', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SPS');        
        Product2 product3 = new Product2(Name = 'test p3', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance');
        insert new List<Product2>{product1, product2, product3};
        
        PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe2 =new PricebookEntry(product2Id = product2.Id, UnitPrice = -100, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe3 =new PricebookEntry(product2Id = product3.Id, UnitPrice = 0, pricebook2Id = pricebookId, IsActive = true);
        INSERT new List<PricebookEntry>{pbe1, pbe2, pbe3};
        
            
        // Original opportunity
        Opportunity oriOpp1 = new Opportunity(AccountId = a.Id, Deal_Type__c = 'Saas', StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, 
                                           Name = 'Original Opp', Pricebook2Id = pricebookId);

        INSERT new List<Opportunity>{oriOpp1};
       
        // Original quotes
        SBQQ__Quote__c oriQuote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = oriOpp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = Date.today() + 365, 
                                                   SBQQ__ExpirationDate__c = Date.today() + 30);
        INSERT new List<SBQQ__Quote__c>{oriQuote1};
            
        SBQQ__QuoteLine__c oriQuote1QL1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oriQuote1.Id, SBQQ__AllowAssetRefund__c=false, SBQQ__Bundle__c=true, 
                                                          SBQQ__Quantity__c = Ori_SBQQ_Quantity_c,
                                                          SBQQ__Bundled__c=false, SBQQ__CarryoverLine__c=false, 
                                                          SBQQ__ChargeType__c='One-Time', SBQQ__ComponentCost__c=0.00, 
                                                          SBQQ__ComponentDiscountedByPackage__c=false, SBQQ__ComponentListTotal__c=28472.68,
                                                          SBQQ__ComponentTotal__c=22382.27, SBQQ__ComponentUpliftedByPackage__c=false,
                                                          SBQQ__ConfigurationRequired__c=false, SBQQ__CostEditable__c=false,
                                                          SBQQ__CustomerPrice__c=0.00, 
                                                          SBQQ__Existing__c=false, SBQQ__HasConsumptionSchedule__c=false, 
                                                          SBQQ__Hidden__c=false, SBQQ__Incomplete__c=false, 
                                                          SBQQ__ListPrice__c=0.00, SBQQ__NetPrice__c=0.00, 
                                                          SBQQ__NonDiscountable__c=false, SBQQ__NonPartnerDiscountable__c=false, 
                                                          SBQQ__Number__c=1, SBQQ__Optional__c=false, SBQQ__OriginalPrice__c=0.00, 
                                                          SBQQ__PartnerPrice__c=0.00, SBQQ__PriceEditable__c=false, 
                                                          SBQQ__PricebookEntryId__c=pbe1.Id, 
                                                          SBQQ__PricingMethodEditable__c=false, SBQQ__PricingMethod__c='List', 
                                                          SBQQ__ProductSubscriptionType__c='One-time', 
                                                          SBQQ__Product__c=product1.Id, SBQQ__ProrateMultiplier__c=4.060273972602739, SBQQ__ProratedListPrice__c=0.00, 
                                                          SBQQ__ProratedPrice__c=0.00, SBQQ__RegularPrice__c=0.00, SBQQ__Renewal__c=false, 
                                                          SBQQ__SpecialPrice__c=0.00, SBQQ__SubscriptionBase__c='List', 
                                                          SBQQ__SubscriptionScope__c='Quote', SBQQ__SubscriptionType__c='One-time', 
                                                          SBQQ__Taxable__c=false, SBQQ__UpliftAmount__c=0.00, SBQQ__Uplift__c=0.00, Fee_Type__c='License', 
                                                          Eligible_NFP_Discount__c=0.00, Status__c='Current', Module_Swap__c=false, Is_License__c=false, Category__c='Product');
               
            
        INSERT new List<SBQQ__QuoteLine__c>{oriQuote1QL1};    
            
            
        // service contracts
        ServiceContract sc1 = new ServiceContract(Name = 'Test Contract1', SBQQSC__PreserveBundleStructureUponRenewals__c = true, 
                                                   SBQQSC__Quote__c = oriQuote1.Id, SBQQSC__Opportunity__c = oriOpp1.Id,
                                                  StartDate = System.today(), EndDate = System.today().addYears(3) + 365, AccountId = a.Id, Pricebook2Id = pricebookId);    
        INSERT new List<ServiceContract>{sc1};    
          
         // Contract Line
         
         //Plan to be  Reduce in Quote
         ContractLineItem contLine1 = new ContractLineItem(ServiceContractId = sc1.Id, StartDate = sc1.startdate, EndDate=sc1.EndDate, PricebookEntryId=pbe1.Id,
                                                         Quantity=3.00, UnitPrice=4111.03, SBQQSC__Account__c=a.Id, SBQQSC__BillingFrequency__c='Annual', SBQQSC__BillingType__c='Advance', 
                                                         SBQQSC__Bundle__c=true, SBQQSC__BundledQuantity__c=1.00, SBQQSC__Bundled__c=false, SBQQSC__ChargeType__c='Recurring',
                                                         SBQQSC__ComponentSubscriptionScope__c='Components', SBQQSC__CustomerPrice__c=4111.03,SBQQSC__HasConsumptionSchedule__c=false,  
                                                         SBQQSC__NetPrice__c=4111.03, SBQQSC__Number__c=3, SBQQSC__OptionLevel__c=1, SBQQSC__OptionType__c='Component', //SBQQSC__OrderProduct__c=8022O000000VSg2QAG, 
                                                         SBQQSC__PricingMethod__c='Percent Of Total', SBQQSC__ComponentDiscountedByPackage__c=false, 
                                                         SBQQSC__ProductSubscriptionType__c='Renewable', SBQQSC__Product__c=product1.Id, 
                                                         SBQQSC__Quantity__c=Ori_SBQQSC_Quantity_c, 
                                              SBQQSC__RegularPrice__c=4111.03, 
                                              SBQQSC__RenewalQuantity__c= ori_SBQQSC_RenewalQuantity_c, 
                                                         SBQQSC__SpecialPrice__c=4111.03, SBQQSC__SubscriptionEndDate__c=System.today().addYears(3), 
                                                         SBQQSC__SubscriptionStartDate__c=System.today(), SBQQSC__SubscriptionType__c='Renewable', SBQQSC__ProrateMultiplier__c=1.0000,
                                                         SBQQSC__SubscriptionPricing__c='Percent Of Total', Additional_Disc__c=0, Fee_Type__c='ASM', Category__c='Support Fee',
                                                         Deal_Type__c='Perpetual');
        //Plan To be Remove in Quote 
       ContractLineItem contLine2 = new ContractLineItem(ServiceContractId = sc1.Id, StartDate = sc1.startdate, EndDate=sc1.EndDate, PricebookEntryId=pbe2.Id,
                                                         Quantity=3.00, UnitPrice=4111.03, SBQQSC__Account__c=a.Id, SBQQSC__BillingFrequency__c='Annual', SBQQSC__BillingType__c='Advance', 
                                                         SBQQSC__Bundle__c=true, SBQQSC__BundledQuantity__c=1.00, SBQQSC__Bundled__c=false, SBQQSC__ChargeType__c='Recurring',
                                                         SBQQSC__ComponentSubscriptionScope__c='Components', SBQQSC__CustomerPrice__c=4111.03,SBQQSC__HasConsumptionSchedule__c=false,  
                                                         SBQQSC__NetPrice__c=4111.03, SBQQSC__Number__c=3, SBQQSC__OptionLevel__c=1, SBQQSC__OptionType__c='Component', //SBQQSC__OrderProduct__c=8022O000000VSg2QAG, 
                                                   SBQQSC__PricingMethod__c='Percent Of Total', SBQQSC__ComponentDiscountedByPackage__c=false, 
                                                         SBQQSC__ProductSubscriptionType__c='Renewable', SBQQSC__Product__c=product2.Id, 
                                                         SBQQSC__Quantity__c=Ori_SBQQSC_Quantity_c, 
                                              SBQQSC__RegularPrice__c=4111.03, 
                                              SBQQSC__RenewalQuantity__c= ori_SBQQSC_RenewalQuantity_c, 
                                                         SBQQSC__SpecialPrice__c=4111.03, SBQQSC__SubscriptionEndDate__c=System.today().addYears(3), 
                                                         SBQQSC__SubscriptionStartDate__c=System.today(), SBQQSC__SubscriptionType__c='Renewable', SBQQSC__ProrateMultiplier__c=1.0000,
                                                         SBQQSC__SubscriptionPricing__c='Percent Of Total', Additional_Disc__c=0, Fee_Type__c='ASM', Category__c='Support Fee',
                                                         Deal_Type__c='Perpetual');
        //Plan to be reduce
         ContractLineItem contLine3 = new ContractLineItem(ServiceContractId = sc1.Id, StartDate = sc1.startdate, EndDate=sc1.EndDate, PricebookEntryId=pbe3.Id,
                                                         Quantity=3.00, UnitPrice=4111.03, SBQQSC__Account__c=a.Id, SBQQSC__BillingFrequency__c='Annual', SBQQSC__BillingType__c='Advance', 
                                                         SBQQSC__Bundle__c=true, SBQQSC__BundledQuantity__c=1.00, SBQQSC__Bundled__c=false, SBQQSC__ChargeType__c='Recurring',
                                                         SBQQSC__ComponentSubscriptionScope__c='Components', SBQQSC__CustomerPrice__c=4111.03,SBQQSC__HasConsumptionSchedule__c=false,  
                                                         SBQQSC__NetPrice__c=4111.03, SBQQSC__Number__c=3, SBQQSC__OptionLevel__c=1, SBQQSC__OptionType__c='Component', //SBQQSC__OrderProduct__c=8022O000000VSg2QAG, 
                                                         SBQQSC__PricingMethod__c='Percent Of Total', SBQQSC__ComponentDiscountedByPackage__c=false, 
                                                         SBQQSC__ProductSubscriptionType__c='Renewable', SBQQSC__Product__c=product3.Id, 
                                                         SBQQSC__Quantity__c=Ori_SBQQSC_Quantity_c, 
                                              SBQQSC__RegularPrice__c=4111.03, 
                                              SBQQSC__RenewalQuantity__c= ori_SBQQSC_RenewalQuantity_c, 
                                                         SBQQSC__SpecialPrice__c=4111.03, SBQQSC__SubscriptionEndDate__c=System.today().addYears(3), 
                                                         SBQQSC__SubscriptionStartDate__c=System.today(), SBQQSC__SubscriptionType__c='Renewable', SBQQSC__ProrateMultiplier__c=1.0000,
                                                         SBQQSC__SubscriptionPricing__c='Percent Of Total', Additional_Disc__c=0, Fee_Type__c='ASM', Category__c='Support Fee',
                                                         Deal_Type__c='Perpetual');
         
        INSERT new List<ContractLineItem>{contLine1,contLine2,contLine3}; 
         
        // renewal opportunity
        Opportunity opp1 = new Opportunity(AccountId = a.Id, Deal_Type__c = 'Perpetual', StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, 
                                           Name = 'Original Opp', Pricebook2Id = pricebookId, SBQQSC__RenewedServiceContract__c = sc1.id);
 		INSERT new List<Opportunity>{opp1};
            
            
        
        // renewal quotes
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = Date.today() + 365, 
                                                   SBQQ__ExpirationDate__c = Date.today() + 30, SBQQ__Type__c = 'Renewal');

        INSERT new List<SBQQ__Quote__c>{quote1};
            
        SBQQ__QuoteLine__c quote1QL1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = Quote1.Id, SBQQ__AllowAssetRefund__c=false, SBQQ__Bundle__c=true, 
                                                          SBQQ__Quantity__c = l_SBQQ_Quantity_c,
                                                          SBQQSC__RenewedContractLine__c = contLine1.id,
                                                          SBQQ__Bundled__c=false, SBQQ__CarryoverLine__c=false, 
                                                          SBQQ__ChargeType__c='One-Time', SBQQ__ComponentCost__c=0.00, 
                                                          SBQQ__ComponentDiscountedByPackage__c=false, SBQQ__ComponentListTotal__c=28472.68,
                                                          SBQQ__ComponentTotal__c=22382.27, SBQQ__ComponentUpliftedByPackage__c=false,
                                                          SBQQ__ConfigurationRequired__c=false, SBQQ__CostEditable__c=false,
                                                          SBQQ__CustomerPrice__c=0.00, 
                                                          SBQQ__Existing__c=false, SBQQ__HasConsumptionSchedule__c=false, 
                                                          SBQQ__Hidden__c=false, SBQQ__Incomplete__c=false, 
                                                          SBQQ__ListPrice__c=0.00, SBQQ__NetPrice__c=0.00, 
                                                          SBQQ__NonDiscountable__c=false, SBQQ__NonPartnerDiscountable__c=false, 
                                                          SBQQ__Number__c=1, SBQQ__Optional__c=false, SBQQ__OriginalPrice__c=0.00, 
                                                          SBQQ__PartnerPrice__c=0.00, SBQQ__PriceEditable__c=false, 
                                                          SBQQ__PricebookEntryId__c=pbe1.Id, 
                                                          SBQQ__PricingMethodEditable__c=false, SBQQ__PricingMethod__c='List', 
                                                          SBQQ__ProductSubscriptionType__c='One-time', 
                                                          SBQQ__Product__c=product1.Id, SBQQ__ProrateMultiplier__c=4.060273972602739, SBQQ__ProratedListPrice__c=0.00, 
                                                          SBQQ__ProratedPrice__c=0.00, SBQQ__RegularPrice__c=0.00, SBQQ__Renewal__c=false, 
                                                          SBQQ__SpecialPrice__c=0.00, SBQQ__SubscriptionBase__c='List', 
                                                          SBQQ__SubscriptionScope__c='Quote', SBQQ__SubscriptionType__c='One-time', 
                                                          SBQQ__Taxable__c=false, SBQQ__UpliftAmount__c=0.00, SBQQ__Uplift__c=0.00, Fee_Type__c='License', 
                                                          Eligible_NFP_Discount__c=0.00, Status__c='Current', Module_Swap__c=false, Is_License__c=false, Category__c='Product');
        
        SBQQ__QuoteLine__c quote1QL3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = Quote1.Id, SBQQ__AllowAssetRefund__c=false, SBQQ__Bundle__c=true, 
                                                          SBQQ__Quantity__c = l_SBQQ_Quantity_c,
                                                          SBQQSC__RenewedContractLine__c = contLine3.id,
                                                          SBQQ__Bundled__c=false, SBQQ__CarryoverLine__c=false, 
                                                          SBQQ__ChargeType__c='One-Time', SBQQ__ComponentCost__c=0.00, 
                                                          SBQQ__ComponentDiscountedByPackage__c=false, SBQQ__ComponentListTotal__c=28472.68,
                                                          SBQQ__ComponentTotal__c=22382.27, SBQQ__ComponentUpliftedByPackage__c=false,
                                                          SBQQ__ConfigurationRequired__c=false, SBQQ__CostEditable__c=false,
                                                          SBQQ__CustomerPrice__c=0.00, 
                                                          SBQQ__Existing__c=false, SBQQ__HasConsumptionSchedule__c=false, 
                                                          SBQQ__Hidden__c=false, SBQQ__Incomplete__c=false, 
                                                          SBQQ__ListPrice__c=0.00, SBQQ__NetPrice__c=0.00, 
                                                          SBQQ__NonDiscountable__c=false, SBQQ__NonPartnerDiscountable__c=false, 
                                                          SBQQ__Number__c=1, SBQQ__Optional__c=false, SBQQ__OriginalPrice__c=0.00, 
                                                          SBQQ__PartnerPrice__c=0.00, SBQQ__PriceEditable__c=false, 
                                                          SBQQ__PricebookEntryId__c=pbe3.Id, 
                                                          SBQQ__PricingMethodEditable__c=false, SBQQ__PricingMethod__c='List', 
                                                          SBQQ__ProductSubscriptionType__c='One-time', 
                                                          SBQQ__Product__c=product3.Id, SBQQ__ProrateMultiplier__c=4.060273972602739, SBQQ__ProratedListPrice__c=0.00, 
                                                          SBQQ__ProratedPrice__c=0.00, SBQQ__RegularPrice__c=0.00, SBQQ__Renewal__c=false, 
                                                          SBQQ__SpecialPrice__c=0.00, SBQQ__SubscriptionBase__c='List', 
                                                          SBQQ__SubscriptionScope__c='Quote', SBQQ__SubscriptionType__c='One-time', 
                                                          SBQQ__Taxable__c=false, SBQQ__UpliftAmount__c=0.00, SBQQ__Uplift__c=0.00, Fee_Type__c='License', 
                                                          Eligible_NFP_Discount__c=0.00, Status__c='Current', Module_Swap__c=false, Is_License__c=false, Category__c='Product');
                           
        INSERT new List<SBQQ__QuoteLine__c>{quote1QL1,quote1QL3};   
        
        Test.startTest();       
        
        Order ord = new Order(Name='Test Order-00001',
                              AccountId = a.Id,
                              Auto_Amendment__c = false,
                              SBQQ__Quote__c = quote1.Id,
                              EffectiveDate = System.today(),
                              
                              Status = 'Draft',
                              blng__BillingDayOfMonth__c = '1');
        
        insert ord;
       
        //Get the latest data after updated in trigger
        Order CheckedOrder = [SELECT ID, RenewalReductions__c FROM Order WHERE Id = :ord.Id]; 
        
 
        Test.stopTest();
        
        double l_diff = Ori_SBQQSC_Quantity_c - l_SBQQ_Quantity_c;
        string ExpectedReduceValue1 = product1.Name + ' has been reduced by ' + l_diff + ' from ' + 
            Ori_SBQQSC_Quantity_c.format()+'.00' + ' To '+ l_SBQQ_Quantity_c.format()+'.00' +'. ';
        String ExpectedRemoveValue = product2.Name + ' has been removed. ';
        string ExpectedReduceValue2 = product3.Name + ' has been reduced by ' + l_diff + ' from ' + 
            Ori_SBQQSC_Quantity_c.format()+'.00' + ' To '+ l_SBQQ_Quantity_c.format()+'.00' +'.';

        System.assertNotEquals(null, CheckedOrder.RenewalReductions__c);
        System.assertEquals(ExpectedReduceValue1 + ExpectedRemoveValue + ExpectedReduceValue2, CheckedOrder.RenewalReductions__c );
       
        
    }
    
    static testmethod void T1OrderTriggerGivenNonRenewalOrder() {
         
        Account a = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        INSERT a;        
        Id pricebookId = Test.getStandardPricebookId();
        // Original opportunity
        Opportunity oriOpp1 = new Opportunity(AccountId = a.Id, Deal_Type__c = 'Saas', StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, 
                                           Name = 'Original Opp', Pricebook2Id = pricebookId);
        INSERT new List<Opportunity>{oriOpp1};
        
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = oriOpp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = Date.today() + 365, 
                                                   SBQQ__ExpirationDate__c = Date.today() + 30, SBQQ__Type__c = 'Quote');
        INSERT new List<SBQQ__Quote__c>{quote1};
        
        Test.startTest();       
        
        Order ord = new Order(Name='Test Order-00001',
                              AccountId = a.Id,
                              Auto_Amendment__c = false,
                              SBQQ__Quote__c = quote1.Id,
                              EffectiveDate = System.today(),
                              
                              Status = 'Draft',
                              blng__BillingDayOfMonth__c = '1');
        
        insert ord;
       
        //Get the latest data after updated in trigger
        Order CheckedOrder = [SELECT ID, RenewalReductions__c FROM Order WHERE Id = :ord.Id]; 
        
 
        Test.stopTest();

        System.assertEquals(null, CheckedOrder.RenewalReductions__c);
    }
    
}