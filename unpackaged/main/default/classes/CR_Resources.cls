public class CR_Resources {

    public void InsertResources (Map<Id, Survey_Response_Opportunity__c> oppMap){
 
    Set<Id> SurveyIds;  
    List<Survey_Response_Opportunity__c> SurveyValues;
    SurveyIds = oppMap.keySet();
    SurveyValues = oppMap.values();
    
    Id SvId =  SurveyValues.get(0).Id  ;                  
   	Id oppId =  SurveyValues.get(0).Opportunity_Number__c  ;
        
    String ResourceNames ='';
   
      If (oppId !=Null) {
      AggregateResult[]   CR = [Select Resource__r.Name ResourceName From Service_Only_Consulting_Request__c
              Where Opportunity__c =: oppId 
              Group by Resource__r.Name];
        For (AggregateResult I: CR) {
           ResourceNames = (String)(I.get('ResourceName'))  + '; ' + ResourceNames ;
        }
 	    
        Survey_Response_Opportunity__c SR;
        
        try {
            SR = [Select Resources__c from Survey_Response_Opportunity__c where id =: SvId Limit 1];
            SR.Resources__c = ResourceNames; 
            Update SR;
           
        } catch(DmlException e) {
           System.debug('An unexpected error has occurred: ' + e.getMessage());
        }  
      }        
   }     
}