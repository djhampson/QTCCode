@isTest
public class TestDataBuilder{
    public static Account createAccountTest(Integer i){
        Account acc = new Account();
        acc.Name = 'Test Account ' + i;
        acc.Type = 'Prospect';
        acc.Vertical_Market__c = 'Education';
        acc.T1_Industry__c = 'Private Training Provider';
        acc.CountryArea__c = 'Australia';
        acc.Region__c = 'ACT';
        acc.CurrencyIsoCode = 'AUD';
        return acc;
    }

    public static Opportunity createOpportunityTest(Integer i, Account acc, String userCurrencyIsoCode, String stageName, Decimal amount /*String recType*/){
        
        ID RType = RecordTypeUtil.getRecordTypeIdByName(Opportunity.SObjectType, 'Licence Fee');
        
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = RType;
        opp.Name = 'Opportunity ' + i;
        opp.AccountId = acc.Id;
        opp.Type = 'Existing Business';  
        opp.Start_Date__c = date.today();      
        opp.CloseDate = date.today();
        opp.StageName = stageName;
        opp.LeadSource = 'Web';
        opp.Amount = amount;
        opp.CurrencyIsoCode = userCurrencyIsoCode;
        opp.Overview__c = 'Test Overview ' + i;
        opp.Include_in_Forecast__c = true;
        opp.ConsultingS_Required__c = 'Yes';
        opp.Project_Start_Date__c = date.today();

        return opp;
    }
    
    public static List<Opportunity> createOpportunities(integer noOfRecords, Boolean applyDML, Id recordTypeId){
        List<Opportunity> opps = new List<Opportunity>();
        for(integer i=0;i<noOfRecords;i++){
            Opportunity oNewOpp= new Opportunity();
            oNewOpp.name= 'Opp'+i;
            oNewOpp.closedate = date.newinstance(2035,11,11);
            oNewOpp.stagename ='1 - Discovery';
            oNewOpp.Overview__c = 'Test Pusher';
            oNewOpp.Type='New Business';
            oNewOpp.LeadSource = 'Web';
            oNewOpp.Win_Price_Customer_Budget__c=10000;
            oNewOpp.RecordTypeId =recordTypeId;
            opps.add(oNewOpp);
        }
        if(applyDML){
            insert opps;
        }
        return opps;
    }


    public static Product2 initializeProduct( String name, String family, String pOrM, Boolean applyDML)
    {
        Product2 prod = new Product2();
        prod.Name = name;
        prod.Family = family;
        prod.CurrencyIsoCode = 'AUD';
        prod.Product_or_Module__c = pOrM;
        prod.IsActive=true;
        if(applyDML){
            insert prod;
        }
        return prod;
    }

    public static PricebookEntry initializeProductPricebook(Id pbId, Id prodId, Boolean applyDML)
    {
        PricebookEntry pbe = new PricebookEntry();
        pbe.UseStandardPrice = false;
        pbe.Pricebook2Id=pbId;
        pbe.Product2Id=prodId;
        pbe.IsActive=true;
        pbe.UnitPrice=2.0;
        if(applyDML){
            insert pbe;
        }
        return pbe;
    }
  //  public static void createSolutionProductMatrix() {
  //      Solution_Product_Matrix__c spm1 = new Solution_Product_Matrix__c(name = 'spm1', Solution__c = 'OneCareXX', Product__c = 'Financials', Weight__c = 50);
  //      Solution_Product_Matrix__c spm2 = new Solution_Product_Matrix__c(name = 'spm2', Solution__c = 'OneCareXX', Product__c = 'Enterprise Case Receipting', Weight__c = 30);
  //      Solution_Product_Matrix__c spm3 = new Solution_Product_Matrix__c(name = 'spm3', Solution__c = 'OneCareXX', Product__c = 'Student Management', Weight__c = 15);
  //      Solution_Product_Matrix__c spm4 = new Solution_Product_Matrix__c(name = 'spm4', Solution__c = 'OneCareXX', Product__c = 'Property And Rating', Weight__c = 5);
  //      insert spm1;
  //      insert spm2;
  //      insert spm3;
  //      insert spm4;
  //  }

    public static List<Account> createAccounts(integer noOfRecords, Boolean applyDML){
        List<Account> accs = new List<Account>();
        for(integer i=0;i<noOfRecords;i++) {
            Account acc = new Account();
            acc.Name = 'Test Account ' + i;
            acc.Type = 'Prospect';
            acc.Vertical_Market__c = 'Education';
            acc.T1_Industry__c = 'Private Training Provider';
            acc.CountryArea__c = 'Australia';
            acc.Region__c = 'ACT';
            accs.add(acc);
        }
        if(applyDML){
            insert accs;
        }
        return accs;
    }
}