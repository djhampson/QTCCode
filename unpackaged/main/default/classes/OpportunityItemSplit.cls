public class OpportunityItemSplit {
     
     public void deleteItemSplit(Map<Id, Opportunity> oppMap){
 
      Set<Id> oppIds;  
      List<Opportunity> oppValues;
      oppIds = oppMap.keySet();
      oppValues = oppMap.values();
        
     //0. delete ItemSplits where Opportunity__c = oppIds
     List <OpportunityItemSplit__c> OppItemSplits = New List<OpportunityItemSplit__c>();              
     OppItemSplits = [SELECT Id FROM OpportunityItemSplit__c WHERE Opportunity__c =: oppIds]; 
       
      If (OppItemSplits.size()>0) {   
        Try {
     	  Delete OppItemSplits;            
         } Catch (DmlException e) {
           System.debug('An unexpected error has occurred: ' + e.getMessage());
 
         }
       }    
    }      
 
    public void deleteModuleItem(Map<Id, Opportunity> oppMap){
 
      Set<Id> oppIds;  
      List<Opportunity> oppValues;
      oppIds = oppMap.keySet();
      oppValues = oppMap.values();
        
     //0. delete ItemSplits where Opportunity__c = oppIds
     List <OpportunityModuleItem__c> OppModuleItem = New List<OpportunityModuleItem__c>();              
     OppModuleItem = [SELECT Id FROM OpportunityModuleItem__c WHERE Opportunity__c =: oppIds]; 
       
      If (OppModuleItem.size()>0) {   
        Try {
     	  Delete OppModuleItem;            
         } Catch (DmlException e) {
           System.debug('An unexpected error has occurred: ' + e.getMessage());
 
         }
       }    
    }      

    public void deleteGroupedProduct(Map<Id, Opportunity> oppMap){
 
      Set<Id> oppIds;  
      List<Opportunity> oppValues;
      oppIds = oppMap.keySet();
      oppValues = oppMap.values();
        
     //0. delete GroupedProduct where Opportunity__c = oppIds
     List <OpportunityGroupedProduct__c> OppGroupedProduct = New List<OpportunityGroupedProduct__c>();              
     OppGroupedProduct = [SELECT Id FROM OpportunityGroupedProduct__c WHERE Opportunity__c =: oppIds]; 
       
      If (OppGroupedProduct.size()>0) {   
        Try {
     	  Delete OppGroupedProduct;            
         } Catch (DmlException e) {
           System.debug('An unexpected error has occurred: ' + e.getMessage());
 
         }
       }    
    } 

    
   //Insert OpportunityLineItem data into OpportunityItemSplit Object
   // for Opportunity pricebookoverwritten = false 
    public void insertLineItemSplit(Map<Id, Opportunity> oppMap){
      Set<Id> oppIds = oppMap.keySet();   
      List<Opportunity> oppValues = oppMap.values();
        
    //0. Get data from OpportunityLineItem for pricebookoverwritten = false  
    List <OpportunityLineItem> OppLineItems = new List<OpportunityLineItem> ();
    OpportunityItemSplit__c[] ItemSplits = new OpportunityItemSplit__c[]{};



    Map<Id,  List <OpportunityLineItem>> OppLineItemsPerOpp = new Map<Id,  List <OpportunityLineItem>>();
    for(OpportunityLineItem oli:[SELECT Product2.GL_PRODUCT_NAME__C, ID, OPPORTUNITYID, PRODUCT2ID, PRODUCTCODE, Product2.NAME, TOTALPRICE, Product2.CONNECTOR_PERCENT__C, Product2.Connector_GL_Product_Name__c, CURRENCYISOCODE FROM OpportunityLineItem WHERE OPPORTUNITYID in: oppIds and PRICEBOOK_OVERRIDDEN__C = false and TOTALPRICE<>0])    {
        List <OpportunityLineItem> tempOppLineItems = new List<OpportunityLineItem> ();
        if(OppLineItemsPerOpp.containsKey(oli.OPPORTUNITYID)){
            tempOppLineItems = OppLineItemsPerOpp.get(oli.OPPORTUNITYID);
        }
        tempOppLineItems.add(oli);
        OppLineItemsPerOpp.put(oli.OPPORTUNITYID, tempOppLineItems);

    }


    For (Opportunity Lo: oppValues)  {   
      /*
      aug 3, 2018 move to a map outside loop

      OppLineItems = [SELECT Product2.GL_PRODUCT_NAME__C, ID, OPPORTUNITYID, PRODUCT2ID, PRODUCTCODE, Product2.NAME,
                    TOTALPRICE, Product2.CONNECTOR_PERCENT__C, 
                    Product2.Connector_GL_Product_Name__c, CURRENCYISOCODE 
        FROM OpportunityLineItem WHERE OPPORTUNITYID =: Lo.Id and PRICEBOOK_OVERRIDDEN__C = false and TOTALPRICE<>0];
     */
        if(OppLineItemsPerOpp.containsKey(Lo.Id)){
            OppLineItems = OppLineItemsPerOpp.get(Lo.Id);
        }

       //1. Get Dated Conversion Rate 
       Decimal Conversion_Rate = 1;
       If (Lo.CurrencyIsoCode <> 'AUD') {
           Date rateDate =  Date.newInstance(Lo.CloseDate.year(),Lo.CloseDate.month(),1);
           //call class cDatedConversionRate
           Conversion_Rate = cDatedConversionRate.getDatedConversionRate(Lo.CurrencyIsoCode, rateDate);  
    	}   
        
      For (OpportunityLineItem LI: OppLineItems)   { 
    
        Decimal Connector_Pnct = LI.Product2.CONNECTOR_PERCENT__C;
        If (Connector_Pnct == Null) {
            Connector_Pnct = 0 ;
        }
        
       //2. Create a ItemSplit record for original product 
       OpportunityItemSplit__c s1 = new OpportunityItemSplit__c ();
        s1.Indicator__c = 'Product Price';
        s1.Name = LI.Product2.NAME ;  
        s1.Opportunity__c = LI.OPPORTUNITYID; 
        s1.Product2__c=LI.Product2Id;
        s1.ProductCode__c = LI.PRODUCTCODE;
        s1.GL_Product_Name__c = LI.Product2.GL_Product_Name__c;
        s1.Amount__c = LI.TotalPrice * (100 - Connector_Pnct)/100;
        s1.Connector_Percent__c = Connector_Pnct;
        s1.CurrencyIsoCode = LI.CurrencyIsoCode;
        s1.TotalPrice__c = LI.TotalPrice;
        s1.AUD_Amount__c = s1.Amount__c / Conversion_Rate;
 
        ItemSplits.add(s1); 
        
          // 3. Create a ItemSplit record for connector product  
         If (Connector_Pnct <>0) {  
           OpportunityItemSplit__c s2 = new OpportunityItemSplit__c ();
       	   s2.Indicator__c = 'Connector Product Price';
           s2.Name = LI.Product2.NAME ;  
           s2.Opportunity__c = LI.OPPORTUNITYID; 
           s2.Product2__c=LI.Product2Id;
           s2.ProductCode__c = LI.PRODUCTCODE;
           s2.GL_Product_Name__c = LI.Product2.Connector_GL_Product_Name__c;
           s2.Amount__c = LI.TotalPrice * Connector_Pnct/100;
		   s2.Connector_Percent__c = Connector_Pnct;
           s2.CurrencyIsoCode = LI.CurrencyIsoCode;
           s2.TotalPrice__c = LI.TotalPrice;
           s2.AUD_Amount__c = s2.Amount__c / Conversion_Rate;  
             
          ItemSplits.add(s2);        
        
        }   
      }

     }
        
       If (ItemSplits.size()>0) {  
         try { insert ItemSplits;  
          } catch (DmlException e) 
          { System.debug(e.getMessage()); 
          }   
       }       
        
    }
 
 //Insert OpportunityModuleItem data into OpportunityItemSplit Object
 // for Opportunity pricebookoverwritten = true 
    public void insertModuleItemSplit(Map<Id, Opportunity> oppMap){
      Set<Id> oppIds = oppMap.keySet();  
      List<Opportunity> oppValues = oppMap.values();
        
     //0. Get data from OpportunityModuleItem for Opportunity pricebookoverwritten = true  
     List <OpportunityModuleItem__c> OppLineItems = new List<OpportunityModuleItem__c> ();
     OpportunityItemSplit__c[] ItemSplits = new OpportunityItemSplit__c[]{};


    Map<Id,  List <OpportunityModuleItem__c>> OppLineItemsPerOpp = new Map<Id,  List <OpportunityModuleItem__c>>();
    for(OpportunityModuleItem__c oli:[SELECT OPPORTUNITY__r.id, Product2__r.GL_PRODUCT_NAME__C, Opportunity__c, Product2__c, ProductCode__c,NAME, TotalPrice__c, Product2__r.CONNECTOR_PERCENT__C,Product2__r.Connector_GL_Product_Name__c, CURRENCYISOCODE
                                        FROM OpportunityModuleItem__c WHERE OPPORTUNITY__c in: oppIds and TotalPrice__c<>0])    {
        List <OpportunityModuleItem__c> tempOppLineItems = new List<OpportunityModuleItem__c> ();
        if(OppLineItemsPerOpp.containsKey(oli.OPPORTUNITY__r.id)){
            tempOppLineItems = OppLineItemsPerOpp.get(oli.OPPORTUNITY__r.id);
        }
        tempOppLineItems.add(oli);
        OppLineItemsPerOpp.put(oli.OPPORTUNITY__r.id, tempOppLineItems);

    }

    For (Opportunity Lo: oppValues)  {    
        
    /*
    aug 3, 2018 move to a map outside loop
    OppLineItems = [SELECT Product2__r.GL_PRODUCT_NAME__C, Opportunity__c, Product2__c, ProductCode__c,
                     NAME, TotalPrice__c, Product2__r.CONNECTOR_PERCENT__C, 
                    Product2__r.Connector_GL_Product_Name__c, CURRENCYISOCODE 
       FROM OpportunityModuleItem__c WHERE OPPORTUNITY__c =: Lo.Id and TotalPrice__c<>0];
  */
        if(OppLineItemsPerOpp.containsKey(Lo.Id)){
            OppLineItems = OppLineItemsPerOpp.get(Lo.Id);
        }


        //1. Get Dated Conversion Rate 
       Decimal Conversion_Rate = 1;
       If (Lo.CurrencyIsoCode <> 'AUD') {
           Date rateDate =  Date.newInstance(Lo.CloseDate.year(),Lo.CloseDate.month(),1);
           //call class cDatedConversionRate
           Conversion_Rate = cDatedConversionRate.getDatedConversionRate(Lo.CurrencyIsoCode, rateDate);  
    	} 
        
    For (OpportunityModuleItem__c LI: OppLineItems)   { 
        Decimal Connector_Pnct = LI.Product2__r.CONNECTOR_PERCENT__C;
        If (Connector_Pnct == Null) {
            Connector_Pnct = 0 ;
        }
               
       //2. Create a ItemSplit record for original product 
       OpportunityItemSplit__c s1 = new OpportunityItemSplit__c ();
        s1.Indicator__c = 'Product Price';
        s1.Name = LI.NAME ;  
        s1.Opportunity__c = LI.Opportunity__c; 
        s1.Product2__c = LI.Product2__c;
        s1.ProductCode__c = LI.ProductCode__c;
        s1.GL_Product_Name__c = LI.Product2__r.GL_PRODUCT_NAME__C;
        s1.Amount__c = LI.TotalPrice__c * (100-Connector_Pnct)/100;
		s1.Connector_Percent__c = LI.Product2__r.CONNECTOR_PERCENT__C;
        s1.CurrencyIsoCode = LI.CurrencyIsoCode;
        s1.TotalPrice__c = LI.TotalPrice__c;
        s1.AUD_Amount__c = s1.Amount__c / Conversion_Rate;
        
        ItemSplits.add(s1); 
        
          // 3. Create a ItemSplit record for connector product 
         If (Connector_Pnct <>0) {  
           OpportunityItemSplit__c s2 = new OpportunityItemSplit__c ();
       	   s2.Indicator__c = 'Connector Product Price';
           s2.Name = LI.NAME ;  
           s2.Opportunity__c = LI.Opportunity__c; 
           s2.Product2__c=LI.Product2__c;
           s2.ProductCode__c = LI.ProductCode__c;
           s2.GL_Product_Name__c = LI.Product2__r.Connector_GL_Product_Name__c;
           s2.Amount__c = LI.TotalPrice__c * Connector_Pnct/100;
		   s2.Connector_Percent__c = LI.Product2__r.CONNECTOR_PERCENT__C;
           s2.CurrencyIsoCode = LI.CurrencyIsoCode;
           s2.TotalPrice__c = LI.TotalPrice__c;
           s2.AUD_Amount__c = s2.Amount__c / Conversion_Rate;  
             
           ItemSplits.add(s2);        
        }   
      }  
    }      
       If (ItemSplits.size()>0) {  
         try { insert ItemSplits;  
          } catch (DmlException e) 
          { System.debug(e.getMessage()); 
          }   
       }       

}
  
 //Insert OpportunityGroupProduct data Object
    public void insertGroupedProduct(Map<Id, Opportunity> oppMap){
      Set<Id> oppIds;  
      List<Opportunity> oppValues;
      oppIds = oppMap.keySet();
      oppValues = oppMap.values();
	  String targetCurrency = 'AUD';
        
      // 1. Create an object
      OpportunityGroupedProduct__c[] GroupedProduct = new OpportunityGroupedProduct__c[]{};   
      
      // 2. Group data from OpportunityItemSplit
      AggregateResult[] groupedResults = [SELECT Opportunity__c, GL_Product_Name__c,
                                         CurrencyIsoCode, SUM(AUD_Amount__c) AUD_Amount, SUM(Amount__c) Amount
      FROM  OpportunityItemSplit__c Where Opportunity__c =: oppIds 
      GROUP BY Opportunity__c, GL_Product_Name__c, CurrencyIsoCode ] ;
      
        //3. add group data to grouped product
        For (AggregateResult ar : groupedResults) {
            OpportunityGroupedProduct__c gp = new OpportunityGroupedProduct__c();
            gp.Name = (String)(ar.get('GL_Product_Name__c'));
            gp.GL_Product_Name__c = (String)(ar.get('GL_Product_Name__c'));
            gp.Opportunity__c = (ID)ar.get('Opportunity__c');
            gp.CurrencyIsoCode = (String)ar.get('CurrencyIsoCode');
            gp.Amount__c = (Decimal)ar.get('Amount');
            gp.AUD_Amount__c = (Decimal)ar.get('AUD_Amount');
            
            targetCurrency = (String)ar.get('CurrencyIsoCode');
            
            //Get default currency rate
            if(targetCurrency.contains('AUD') == false){
            Decimal conversionRate = [SELECT conversionrate FROM currencytype 
                                       WHERE isocode = :targetCurrency LIMIT 1].conversionRate;
            gp.Amount__c =  gp.Amount__c *   conversionRate; 
            
            }
            
            
            GroupedProduct.add(gp);
        }
        
        //4. insert grouped product
        If (GroupedProduct.size()>0) {  
         try { insert GroupedProduct;  
          } catch (DmlException e) 
          { System.debug(e.getMessage()); 
          }   
       } 
    }
    
}