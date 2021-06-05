// DISABLE TRIGGER due to case 11040743 logged with Salesforce: System.LimitException: Too many SOQL queries
trigger updateIncidentforProblemCase on Case (after insert) {
/* 
*     // This trigger will update the Problem Case ID back onto the Incident Case that it stemmed fom
*     List<Case> childrenToUpdate = new List<Case>();
*     for(Case p:trigger.new) {
*         // Only process Problem carrying a value in its Problem Case field
*         if(p.Created_From_Case__C != null && p.type == 'Problem') {
*              for(Case ch : [SELECT Id, Problem_Cases__C, description FROM Case WHERE Id = :p.Created_From_Case__C]) {
*                 ch.Problem_Cases__C = p.id;
*                 childrenToUpdate.add(ch);
*             }
*         }       
*     }
*    
*     if(childrenToUpdate.size() > 0) {         
*         try{
*             update childrenToUpdate;
*         }
*         catch(Exception e) {
*         }
*    }
*/
}