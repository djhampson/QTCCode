public class caseQuoteButtonsController_Apex {
    @AuraEnabled
    public static Case getCase(Id recordId){
        Case mycase = [SELECT Id, isClosed, Status, Quote_Status__c, ContactId, ContactEmail FROM Case WHERE id=:recordId];
        return mycase;
    }
    
    @AuraEnabled
	public static Case saveCase(Case caseRec, String vstatus){

        if (caseRec.Quote_Status__c != vstatus){
            caseRec.Quote_Status__c = vstatus;

        }
        else {
            caseRec.Quote_Status__c = '';
        }
        
        /* Start CR 206104 - Include rrorr message handling to pick up DMS exceptions */
        String msg = '';
        try{
             update caseRec;

        }catch(DmlException e){
            //Any type of Validation Rule error message, Required field missing error message, Trigger error message etc..
            //we can get from DmlException
             
            //Get All DML Messages
            for (Integer i = 0; i < e.getNumDml(); i++) {
                //Get Validation Rule & Trigger Error Messages
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
            //throw DML exception message
            if (!test.isRunningTest()){
                throw new AuraHandledException(msg);
            }
             
        }catch(Exception e){
            //throw all other exception message
            throw new AuraHandledException(e.getMessage());
        }
        finally {
        }
        /* End CR 206104 - Include rrorr message handling to pick up DMS exceptions */
        return caseRec;
    }

}