trigger ConsultingSurveyResponseTrigger on Survey_Response_Opportunity__c (after insert) {

   Map<Id, Survey_Response_Opportunity__c>  oppMap = new Map<Id, Survey_Response_Opportunity__c>();
   Map<Id, Survey_Response_Opportunity__c> oppOldMap = Trigger.oldMap;    

    if ( Trigger.isAfter) 
     {   for(Survey_Response_Opportunity__c o : Trigger.new)    {        
          oppMap.put(o.id, o);  
         
          if(oppMap.size() > 0) { 
    
              CR_Resources sp = new CR_Resources();
              sp.InsertResources(oppMap); 
              
          }
      }
   }
}