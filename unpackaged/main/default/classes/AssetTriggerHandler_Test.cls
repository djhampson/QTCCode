@IsTest
public class AssetTriggerHandler_Test {
    @IsTest
    public static void AssetTriggerHandler_Test1(){
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Account acc = new Account(Name = 'Test Account', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        INSERT acc;
        
        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test billing rule', blng__Active__c = true, 
                                                                    blng__InitialBillingTrigger__c = 'Order Product Activation Date	', blng__GenerateInvoices__c = 'Yes');
        INSERT billingRule;
        
        blng__RevenueRecognitionRule__c rrRule = new blng__RevenueRecognitionRule__c(blng__CreateRevenueSchedule__c = 'Yes', Name = 'Test Revenue Recog Rule', blng__Active__c = true);
        INSERT rrRule;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'Yes', Name = 'Test Tax Rule');
        INSERT taxRule;
        
        Product2 product1 = new Product2(Name = 'Product 1', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, 
                                         blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'T1TEST');
        INSERT product1;
        
        PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        INSERT pbe1;
        
        
        Asset positiveAsset = new Asset(AccountId=acc.Id, Product2Id=product1.Id, IsCompetitorProduct=false, Name='TechnologyOne Supply Chain Management', Price=0, 
                                        Quantity=1, SBQQ__Bundle__c=true, SBQQ__Bundled__c=false, SBQQ__ChargeType__c='One-Time', SBQQ__ComponentDiscountedByPackage__c=false, 
                                        SBQQ__DistributorDiscount__c=0, SBQQ__FromServiceCloud__c=true, SBQQ__ListPrice__c=0, 
                                        SBQQ__Number__c=1, SBQQ__PricingMethod__c='List', SBQQ__RegularPrice__c=0, Status = 'Active');
        INSERT positiveAsset;
        Test.startTest();
        Asset negativeAsset = new Asset(AccountId=acc.Id, Product2Id=product1.Id, SBQQ__RevisedAsset__c=positiveAsset.Id, IsCompetitorProduct=false, Name='TechnologyOne Supply Chain Management', Price=0, 
                                        Quantity=-1, SBQQ__Bundle__c=true, SBQQ__Bundled__c=false, SBQQ__ChargeType__c='One-Time', SBQQ__ComponentDiscountedByPackage__c=false, 
                                        SBQQ__DistributorDiscount__c=0, SBQQ__FromServiceCloud__c=true, SBQQ__ListPrice__c=0, 
                                        SBQQ__Number__c=1, SBQQ__PricingMethod__c='List', SBQQ__RegularPrice__c=0);
        INSERT negativeAsset;
        Test.stopTest();
        List<Asset> AssetList = [SELECT Id FROM Asset];
        System.debug('AssetList size ' + AssetList.size());

        
    }
}