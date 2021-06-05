public class T1_CreditNoteTriggerHandler {
    public static final String POSTED_STATUS = 'Posted';

    public static void processCreditNoteForRevREcognition( Map<Id,blng__CreditNote__c> oldMap,  Map<Id,blng__CreditNote__c> newMap){
        Set<Id> creditNotesId = new Set<Id>();
        for( blng__CreditNote__c creditNoteVar : newMap.values() ){
            if( creditNoteVar.blng__Status__c == POSTED_STATUS && oldMap.get(creditNoteVar.Id).blng__Status__c  != creditNoteVar.blng__Status__c ){
                creditNotesId.add(creditNoteVar.Id);
            }
        }
        T1_CreditNoteLineService.processCreditNoteLinesForRevRecognitionFuture( creditNotesId );
    }
}