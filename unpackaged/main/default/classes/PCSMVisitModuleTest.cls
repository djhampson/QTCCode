@isTest
public class PCSMVisitModuleTest 
{

	public static testmethod void testController()
    {
    	Account acc= new Account(name= 'Test Account');
   		acc.type = 'Customer';
    	acc.CountryArea__c = 'Australia';
        acc.Region__c = 'ACT';
    	acc.Vertical_Market__c = 'Education';
    	acc.T1_Industry__c = 'Other';	
		insert acc;
		
		Product2 prod = new Product2();
		prod.Name = 'Enterprise Case Receipting';   
		prod.Family = 'Enterprise Case Receipting';		
        prod.CurrencyIsoCode = 'AUD';
		prod.Product_or_Module__c = 'Product';
		prod.IsActive=true;
		insert prod;
		
    	
    	Asset ass = new Asset(AccountId=acc.id, product2id=prod.id, name='ABC');
    	ass.product__c='TechnologyOne Financials';
    	insert ass;
    	
    	PCSM_Visit_Cyc__c csm = new PCSM_Visit_Cyc__c( account__c=acc.id );
    	csm.product__c='TechnologyOne Financials';
    	insert csm;
    	
       	PCSMVisitModules c = new PCSMVisitModules( new ApexPages.StandardController( csm ) );

       	system.assertNotEquals(null, c);
       	system.assertEquals(1, c.modules.size());
    }

}