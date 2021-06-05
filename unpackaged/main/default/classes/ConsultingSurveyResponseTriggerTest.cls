@isTest
public class ConsultingSurveyResponseTriggerTest {

   public static testmethod void testConsultingSurveyResponseTrigger() {
       //Create an account    
        Account acc= new Account(name= 'TechnologyOne');
        acc.type = 'Customer';
        acc.CountryArea__c = 'Australia';
        acc.Vertical_Market__c = 'Education';
        acc.T1_Industry__c = 'Other Education';
        acc.Region__c = 'Queensland';
        acc.CurrencyIsoCode = 'AUD';
        insert acc;

       //Create an Opportunity
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = OpportunityRecordTypeInfo .get('Services Only / Consulting request').getRecordTypeId();  
            
        Opportunity o = new Opportunity();
        o.RecordTypeId = rtid;
        o.Name = 'Opportunity Test 1';
        o.AccountId = acc.Id;
        o.StageName = 'Stage 8 - Preferred Vendor';
        o.CurrencyIsoCode = 'AUD';
        o.CloseDate = date.today()+30;
        
        o.Overview__c = 'ABCD'; o.type='New Business';   
        o.LeadSource = 'Web';
        o.Win_Price_Customer_Budget__c=10000;
        insert o;
       
       //Create a Contact 
        Schema.DescribeSObjectResult cSchema = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> ContactRecordTypeInfo = cSchema.getRecordTypeInfosByName(); 
        Id cId = ContactRecordTypeInfo.get('Technology One Employee').getRecordTypeId();  
   
       Contact c = new Contact(firstname='Consulting', lastname='Management') ;
       c.AccountId = acc.id;
       c.Employee_Classification__c = 'Other';
       c.Title = 'Consultant';
       c.RecordTypeId = cId;
	   insert c; 	
             
       //Create a Consulting Request
       Service_Only_Consulting_Request__c sc = new Service_Only_Consulting_Request__c();
       sc.Resource__c = c.Id;
       sc.No_Days__c = 2;
       sc.Rate_Day__c = 1880;
       sc.Opportunity__c = o.Id;
       insert sc;
                    
       System.Test.startTest();       
       // Create a Survey_Response_Opportunity record
        Survey_Response_Opportunity__c s = new Survey_Response_Opportunity__c (Name='T1 Consulting Survey');
        s.Opportunity_Number__c = o.Id;
        s.Experience_Rating__c = 5;
        s.Comment__c = 'Excellent Service';
        s.Improvement__c = 'Communications';
        insert s;
           Survey_Response_Opportunity__c updatedS = [SELECT Name,Experience_Rating__c,Comment__c FROM
           Survey_Response_Opportunity__c WHERE Id = : s.Id];
           System.assertEquals('T1 Consulting Survey', updatedS.Name);      
           System.assertEquals(5, updatedS.Experience_Rating__c);
           System.assertEquals('Excellent Service', updatedS.Comment__c);
    
       System.Test.stopTest();
   }
    
}