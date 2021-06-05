public class t1EditController {
    @AuraEnabled
    public static Case getCase(Id recordId){
        Case mycase = [SELECT Id, Status, RecordTypeId, RecordType.Name, CaseNumber, Subject FROM Case WHERE id=:recordId];
        return myCase;
    }
 
    @AuraEnabled
    public static boolean returnnothing(){
        
        return true;
    }
    
    @AuraEnabled
    public static String getBaseURL(){
        string baseURL = URL.getSalesforceBaseUrl().toString();
        return (baseURL);
    }

}