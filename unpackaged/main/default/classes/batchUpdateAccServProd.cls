/**
 * @description       : 
 * @author            : Grant Hamlyn
 * @group             : 
 * @last modified on  : 01-06-2021
 * @last modified by  : Grant Hamlyn
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0                Grant Hamlyn   Initial Version
 * 1.1  19-02-2021    Grant Hamlyn   Minor change for tests
 * 1.2  22-02-2021    Grant Hamlyn   Remove try/catch blocks and improve code coverage
 * 1.3  26-05-2021    Grant Hamlyn   Alter soql query to use the CPQ Migration Status field so as to avoid processing CPQ managed Accounts
 * 1.4  01-06-2021    Grant Hamlyn   Correct spelling mistake in soql string
**/
global class batchUpdateAccServProd implements 
   Database.Batchable<sObject>{

   /*
    execute this class via Developer Console with the following code
        batchUpdateAccServProd c = new batchUpdateAccServProd();
        Database.executeBatch(c);
   */
       
   global Database.QueryLocator start(Database.BatchableContext BC){
       // query hardcoded for ease
      String query = 'SELECT accountid, product2id, product__c FROM Asset where status = \'Active\' and Account.CPQ_Migration_Status__c <> \'Completed\'';
      // append this to queries when custom field is available as per SCE-942
      // and Account.CPQ_Migration _Status__c <> 'Completed' 
      if(Test.isRunningTest())
          query = 'SELECT accountid, product2id, product__c FROM Asset where status = \'Active\' and Account.CPQ_Migration_Status__c <> \'Completed\' order by createddate desc limit 100';
       
      return Database.getQueryLocator(query);
   }
   
   global void execute(
                Database.BatchableContext BC, 
                List<sObject> scope){

        // ensure triggers, workflow and validation rules are deactivated          
        T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
        s.Bypass_Triggers__c = true;
        s.Bypass_Validation_Rules__c = true;
        s.Bypass_Workflow__c = true;
        s.Customer_Community_URL__c = '';
        s.Employee_Community_URL__c = '';
        s.Internal_URL__c = '';
        s.Closed_Date_for_Archiving_Email__c = null;
        upsert s;
          
        List<Account_Service_Product__c> l_asp = new List<Account_Service_Product__c>(); 
        List<Account_Service_Product__c> l_existingasp = [Select AccountId__c, Service_Product_LU__c from Account_Service_Product__c]; 
        List<Asset> assetList = scope;
        
        // build the list of Service Products
        List<Service_Product__c> l_service_product = [Select id, name from Service_Product__c ];
        Map<String, String> service_product_Map = new Map<String, String>();
       
        for (Service_Product__c sp :l_service_product) {
            service_product_Map.put(sp.id, sp.name);
        } 

        // build a list of Products carrying a Service Product
        // build a list of Products where we can find ProductCode using Base Product Code from Module
        List<Product2> l_product = [Select id, productcode, service_product__c from Product2 where product_or_module__c = 'Product' and service_product__c <> null];
        Map<String, String> productService_Map = new Map<String, String>();
        Map<String, String> productCode_Map = new Map<String, String>();
       
        for (Product2 prod2 :l_product) {
            productService_Map.put(prod2.id, prod2.service_product__c);
            productCode_Map.put(prod2.productcode, prod2.id);
        } 
        
         // build a list of Modules with their Product link (base_product_code) 
         List<Product2> l_module = [Select id, base_product_code__c from Product2 where product_or_module__c = 'Module' and base_product_code__c <> null];
         Map<String, String> module_Map = new Map<String, String>();
        
         for (Product2 mp :l_module) {
             module_Map.put(mp.id, mp.base_product_code__c);
        } 

        // build the list of Products and Modules (Product2)
        List<Product2> l_product2 = [Select id, name from Product2 ];
        Map<Id, Product2> product2_Map = new Map<Id, Product2>(l_product2);
    
        // build list of existing Account Service Products so we don't duplicate
        Map<String, String> existingasp = new Map<String, String>();
        for (Account_Service_Product__c l_easp :l_existingasp){
             existingasp.put(String.valueOf(l_easp.AccountId__c) + String.valueOf(l_easp.Service_Product_LU__c), l_easp.Service_Product_LU__c);           
        }
    
        //For all Active Assets on SRS managed Accounts
        for (Asset l_asset : assetList) {
            String sProductId = '';
            String sBaseProductCode = '';
            // get the Product Id
            if (productService_Map.containsKey(l_asset.Product2Id)){ // it's a Product
                sProductId = l_asset.Product2Id; 
            }
            else{
                if (module_Map.containsKey(l_asset.Product2Id)){ // it's a Module
                    sBaseProductCode = module_Map.get(l_asset.Product2Id);
                    if (productCode_Map.containsKey(sBaseProductCode)){
                        sProductId = productCode_Map.get(sBaseProductCode);
                    }
                }

            }
            
            if (!String.IsBlank(sProductId)){ 
                // get the service product for product using the product id
                String servprod = productService_Map.get(sProductId);
                
                if (!String.IsBlank(servProd)){  // didn't find Service Product for this Product
                    //check if this record already exists
                    String checkasp = l_asset.AccountId + servProd;
                    if (!existingasp.containsKey(checkasp)){
                        Account_Service_Product__c asp = new Account_Service_Product__c(
                            AccountId__c = l_asset.AccountId,
                            Service_Product_LU__c = servProd);
                        l_asp.add(asp);
                    }
                }
            }
        }
 
        if (!l_asp.isEmpty()) {
            // now get rid of duplicates
            Set<Account_Service_Product__c> myset = new Set<Account_Service_Product__c>();
            List<Account_Service_Product__c> result = new List<Account_Service_Product__c>();
            myset.addAll(l_asp);
            result.addAll(myset);
                    
            if (!result.isEmpty()) {
                system.debug('Account Service Products inserted ' + result.size());
                T1_Process_Log__c procLogb = new T1_Process_Log__c(Process_Name__c = 'batchUpdateAccServProd',
                    Process_Message__c = 'Account Service Products inserted ' + result.size());
                insert procLogb;
                
                // DML statement
                Database.SaveResult[] srList = Database.insert(result, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.'); 
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }
        
   }

   global void finish(Database.BatchableContext BC){
       AsyncApexJob a = 
           [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =
            :BC.getJobId()];
       
       // Now reset the bypass values        
       T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
       s.Bypass_Triggers__c = false;
       s.Bypass_Validation_Rules__c = false;
       s.Bypass_Workflow__c = false;
       s.Customer_Community_URL__c = '';
       s.Employee_Community_URL__c = '';
       s.Internal_URL__c = '';
       s.Closed_Date_for_Archiving_Email__c = null;
       upsert s;
                                
       // Send an email to the Apex job's submitter 
       //   notifying of job completion. 
       //   
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Batch batchUpdateAccServProd Status: ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }

       
       
}