@isTest
public class TestConsultingSurveyResponse {

   public static void CreateSurveyResponseOpportunity() {
        // Create test record
        Survey_Response_Opportunity__c s = new Survey_Response_Opportunity__c (Name='T1 Consulting Survey');
        insert s; 
        s.Experience_Rating__c = 5;
        s.Comment__c = 'Excellent Service';
        s.Improvement__c = 'Communications';
       update s;
       
           Survey_Response_Opportunity__c updatedS = [SELECT Name,Experience_Rating__c,Comment__c FROM
            Survey_Response_Opportunity__c WHERE Id = : s.Id];
            System.assertEquals('T1 Consulting Survey', updatedS.Name);      
            System.assertEquals(5, updatedS.Experience_Rating__c);
        	System.assertEquals('Excellent Service', updatedS.Comment__c);
   }
    
}