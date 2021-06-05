@isTest(SeeAllData=true)
public class OpportunityItemSplitTest {

     public static Product2 pr( String name, String family, String productcode, String pOrM)
     {
        Product2 prod = new Product2();
        prod.Name = name;
        prod.Family = family;       
        prod.CurrencyIsoCode = 'AUD';
        prod.Product_or_Module__c = pOrM;
        prod.Connector_Percent__c = 50; 
        prod.GL_Product_Code__c = productcode;
        prod.GL_Product_Name__c = name;
        prod.Connector_GL_Product_Name__c= 'BI';
        prod.IsActive=true;
        return prod;
    }
    
    public static PricebookEntry pbEntry(Id pbId, Id prodId)
    {
        PricebookEntry pbe = new PricebookEntry();
        pbe.UseStandardPrice = false;
        pbe.Pricebook2Id=pbId; 
        pbe.Product2Id=prodId;
        pbe.IsActive=true;
        pbe.UnitPrice=0.0;
        return pbe;
    }
    
    static testMethod void OppItemSplitTest1() {
 
        // Create a test account 
        Account acc= new Account(name= 'Test Account');
        acc.type = 'Customer';
        acc.CountryArea__c = 'Australia';
        acc.Vertical_Market__c = 'Education';
        acc.T1_Industry__c = 'Other Education';
        acc.Region__c = 'Queensland';
        acc.CurrencyIsoCode = 'AUD';
        insert acc;

        // Create a test opportunity 
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = OpportunityRecordTypeInfo .get('Licence Fee').getRecordTypeId();
                
        Opportunity o = new Opportunity();
        o.RecordTypeId = rtid;
        o.Name = 'Opportunity Test';
        o.AccountId = acc.Id;
        o.StageName = '1 - Discovery';
        o.CurrencyIsoCode = 'AUD';
        o.CloseDate = date.today();
        o.Solution__c = 'OneEducation';
        o.Overview__c = 'ABCD'; 
        o.type='Existing Business'; 
        o.ConsultingS_Required__c='No';
        o.No_Consulting_Reason__c= 'Uplift/Add User';
        o.Licence_Model__c ='Perpetual';   
        o.LeadSource = 'Web';
        o.Win_Price_Customer_Budget__c=10000;
        insert o;
 
        Map<Id, Opportunity>  oppMap = new Map<Id, Opportunity>(); 
        Set<Id> oppIds;  
        List<Opportunity> oppValues;
        
        oppMap.put(o.id, o);  
        oppIds = oppMap.keySet();
        oppValues = oppMap.values();
              
        // Create a new product
        Product2 p= pr('Financials', 'Financials','FINANCE', 'Product');  
        insert p;
        
        // Create a new pricebook
        Pricebook2 pb = [select id from Pricebook2 where isStandard=true limit 1];
        PricebookEntry pbe1 = pbEntry(pb.id, p.id);
        insert pbe1;
        
         //add OpportunityLineItem
         OpportunityLineItem line1 = new OpportunityLineItem(opportunityId=o.id, quantity=1, UnitPrice=75000, PricebookEntryId=pbe1.id);
         insert line1;
       
            
         OpportunityLineItem line1t = [Select id, opportunityid, quantity, unitPrice from OpportunityLineItem 
                                            where id =: line1.id Limit 1];
         Opportunity ot = [Select id, amount from Opportunity
                             where id =: line1t.opportunityid];                                  
            
         System.assertEquals(line1t.quantity, 1);
         System.assertEquals(line1t.unitPrice, 75000);
         System.assertEquals(ot.amount, 75000);
   
        //Create a new OppModuleItem
        OpportunityModuleItem__c m = new OpportunityModuleItem__c (Opportunity__c = o.id, Product2__c = p.id,
                                                                   Name='TechnologyOne Financials');
        insert m;
        
        m.Quantity__c = 1; 
        m.ProductCode__c = p.GL_Product_Code__c;
        m.CurrencyIsoCode = 'AUD';
        m.TotalPrice__c = 75000;
        m.UnitPrice__c = 75000;
        
        update m;
        
        OpportunityModuleItem__c updatedM = [SELECT Name, Quantity__c,ProductCode__c, TotalPrice__c,UnitPrice__c FROM
                  OpportunityModuleItem__c WHERE Id = : m.Id];
            System.assertEquals('TechnologyOne Financials', updatedM.Name);      
            System.assertEquals('FINANCE', updatedM.ProductCode__c);
        	System.assertEquals(75000, 	updatedM.TotalPrice__c);
            System.assertEquals(75000, 	updatedM.UnitPrice__c);
            System.assertEquals(1, 	updatedM.Quantity__c);  
        
        //Create a new OppItemSplit for original product
        Decimal Conversion_Rate = 1;
        OpportunityItemSplit__c s = new OpportunityItemSplit__c (Opportunity__c = o.id, Product2__c = p.id, Name='TechnologyOne Financials');
        insert s;
        s.Indicator__c = 'Product Price';      
        s.ProductCode__c = p.GL_Product_Code__c;
        s.GL_Product_Name__c = p.GL_Product_Name__c;
		s.Connector_Percent__c = p.Connector_Percent__c;
        s.CurrencyIsoCode = o.CurrencyIsoCode; 
        s.TotalPrice__c = 75000;
        s.Amount__c = s.TotalPrice__c *(100 - s.Connector_Percent__c)/100;
        s.AUD_Amount__c = s.Amount__c/Conversion_Rate;
        
        update s;
        OpportunityItemSplit__c updatedS = [SELECT Name,GL_Product_Name__c,TotalPrice__c,AUD_Amount__c, 
                                            Amount__c,Connector_Percent__c,ProductCode__c  
                                            FROM OpportunityItemSplit__c WHERE Id = : s.Id];
            System.assertEquals('TechnologyOne Financials', updatedS.Name);      
            System.assertEquals('Financials', updatedS.GL_Product_Name__c);
        	System.assertEquals(75000, 	updatedS.TotalPrice__c);
            System.assertEquals(37500, 	updatedS.AUD_Amount__c);
            System.assertEquals(37500, 	updatedS.Amount__c);  
            System.assertEquals(50, 	updatedS.Connector_Percent__c); 
            System.assertEquals('FINANCE', 	updatedS.ProductCode__c);  
        
         //Create a new OppItemSplit for connector product
        OpportunityItemSplit__c c = new OpportunityItemSplit__c (Opportunity__c = o.id, Product2__c = p.id, Name=s.name);
        insert c;
        c.Indicator__c = 'Connector Product Price';      
        c.ProductCode__c = p.GL_Product_Code__c;
        c.GL_Product_Name__c = p.Connector_GL_Product_Name__c;
		c.Connector_Percent__c = p.Connector_Percent__c;
           If (s.Connector_Percent__c == Null) {
               s.Connector_Percent__c = 0 ;
           }
        c.CurrencyIsoCode = o.CurrencyIsoCode; 
        c.TotalPrice__c = 75000;
        c.Amount__c = s.TotalPrice__c *c.Connector_Percent__c/100;
        c.AUD_Amount__c = c.Amount__c/Conversion_Rate;
        
        update c;
        OpportunityItemSplit__c updatedC = [SELECT Name,GL_Product_Name__c,TotalPrice__c,AUD_Amount__c, 
                                            Amount__c,Connector_Percent__c,ProductCode__c  
                                            FROM OpportunityItemSplit__c WHERE Id = : c.Id];
            System.assertEquals('TechnologyOne Financials', updatedC.Name);      
            System.assertEquals('BI', updatedC.GL_Product_Name__c);
        	System.assertEquals(75000, 	updatedS.TotalPrice__c);
            System.assertEquals(37500, 	updatedS.AUD_Amount__c);
            System.assertEquals(37500, 	updatedS.Amount__c);  
            System.assertEquals(50, 	updatedS.Connector_Percent__c); 
            System.assertEquals('FINANCE', 	updatedS.ProductCode__c);  
        
         // Create a OppGroupProduct record
         String targetCurrency = 'AUD';   
         OpportunityGroupedProduct__c[] GroupedProduct = new OpportunityGroupedProduct__c[]{};   
         AggregateResult[] groupedResults = [SELECT Opportunity__c, GL_Product_Name__c,
                                         CurrencyIsoCode, SUM(AUD_Amount__c) AUD_Amount, SUM(Amount__c) Amount
                          FROM  OpportunityItemSplit__c Where Opportunity__c =: oppIds 
                          GROUP BY Opportunity__c, GL_Product_Name__c, CurrencyIsoCode ] ;
        
         For (AggregateResult ar : groupedResults) {
            OpportunityGroupedProduct__c gp = new OpportunityGroupedProduct__c();
     
            gp.Name = (String)(ar.get('GL_Product_Name__c'));
            gp.GL_Product_Name__c = (String)(ar.get('GL_Product_Name__c'));
            gp.Opportunity__c = (ID)ar.get('Opportunity__c');
            gp.CurrencyIsoCode = (String)ar.get('CurrencyIsoCode');
            gp.Amount__c = (Decimal)ar.get('Amount');
            gp.AUD_Amount__c = (Decimal)ar.get('AUD_Amount');
            
            targetCurrency = (String)ar.get('CurrencyIsoCode');
                    gp.Amount__c =  gp.Amount__c *  1; 
           GroupedProduct.add(gp);
          }
        
         If (GroupedProduct.size()>0) {  
           try { insert GroupedProduct;  
               } catch (DmlException e) 
               { System.debug(e.getMessage()); 
               }   
           } 
        
           List <OpportunityGroupedProduct__c> OppGroupedProduct = New List<OpportunityGroupedProduct__c>();              
           OppGroupedProduct = [SELECT Id, Name, GL_Product_Name__c, Amount__c, AUD_Amount__c 
                                FROM OpportunityGroupedProduct__c WHERE Opportunity__c =: oppIds]; 
 
            System.assertEquals('Financials', OppGroupedProduct[0].Name);
        	System.assertEquals('Financials', OppGroupedProduct[0].GL_Product_Name__c);
            System.assertEquals(37500, 	OppGroupedProduct[0].AUD_Amount__c);
            System.assertEquals(37500, 	OppGroupedProduct[0].Amount__c);  
  
            System.assertEquals('BI', OppGroupedProduct[1].Name);
        	System.assertEquals('BI', OppGroupedProduct[1].GL_Product_Name__c);
            System.assertEquals(37500, 	OppGroupedProduct[1].AUD_Amount__c);
            System.assertEquals(37500, 	OppGroupedProduct[1].Amount__c);  
            
 
          OpportunityItemSplit tsp = new OpportunityItemSplit(); 
        
           tsp.insertLineItemSplit(oppMap);
           tsp.insertGroupedProduct(oppMap); 
           
           o.PRICEBOOK_OVERRIDDEN__C = true;
           update o;
           tsp.deleteItemSplit(oppMap);
           tsp.deleteGroupedProduct(oppMap); 
        
           tsp.insertModuleItemSplit(oppMap);
           tsp.insertGroupedProduct(oppMap); 
        
           tsp.deleteItemSplit(oppMap);
           tsp.deleteGroupedProduct(oppMap); 
           tsp.deleteModuleItem(oppMap);           
   }
}