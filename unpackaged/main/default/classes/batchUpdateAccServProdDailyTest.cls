/**
 * @description       : 
 * @author            : Grant Hamlyn
 * @group             : 
 * @last modified on  : 19-02-2021
 * @last modified by  : Grant Hamlyn
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   19-02-2021   Grant Hamlyn   Initial Version
**/
@isTest(SeeAllData=True)
public inherited sharing class batchUpdateAccServProdDailyTest {
         static testMethod void testMethod1() 
        {

            Id modId1 = null;
            Id modId2 = null;

            // get a couple of Modules
            List<Product2> lProduct2 = [SELECT id FROM Product2 where product_or_module__c = 'Module'];
            for (Product2 l_Product2 : lProduct2) {
                if (modId1 == null){
                    modId1 = l_Product2.Id;
                    continue;
                }
                if(modId2 == null){
                    modId2 = l_Product2.Id;
                    continue;
                }
                break;
            }
            Account ac = new Account();
            ac.type = 'Customer';
            ac.CountryArea__c = 'Australia';
            ac.Region__c = 'ACT';
            ac.Vertical_Market__c = 'Education';
            ac.T1_Industry__c = 'Other';
            ac.Name = 'Test Account for batchUpdateAccServProdDaily';
            
            insert ac;
            
            Asset ass = new Asset();
            ass.AccountId = ac.Id;
            ass.Product__c = 'TechnologyOne Financials';
            ass.status = 'Active';
            ass.Name = 'Test Asset for batchUpdateAccServProdDaily 1';
            ass.Product2Id = modId1;
            insert ass;

            Asset ass2 = new Asset();
            ass2.AccountId = ac.Id;
            ass2.Product__c = 'TechnologyOne Something else';
            ass2.status = 'Active';
            ass2.Name = 'Test Account for batchUpdateAccServProdDaily 2';
            ass2.Product2Id = modId2;
            insert ass2;
    
            // insert Account Service Product record
            Account_Service_Product__c asp = new Account_Service_Product__c();
            asp.AccountId__c = ac.Id;
            insert asp;
                        
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
    
            Test.startTest();
                batchUpdateAccServProdDaily c = new batchUpdateAccServProdDaily();
                Database.executeBatch(c);
            Test.stopTest();
            
            s.Bypass_Triggers__c = false;
            s.Bypass_Validation_Rules__c = false;
            s.Bypass_Workflow__c = false;
            s.Customer_Community_URL__c = '';
            s.Employee_Community_URL__c = '';
            s.Internal_URL__c = '';
            s.Closed_Date_for_Archiving_Email__c = null;
            upsert s;
        } 
    }