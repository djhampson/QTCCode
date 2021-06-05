trigger QuoteLineTrigger on SBQQ__QuoteLine__c (After INSERT, after update, after delete) {
    If(Trigger.IsAfter){
        If(Trigger.IsInsert){
            System.debug(logginglevel.ERROR,'RUNNING AFTER INSERT QL TRIGGER: ');
            QuoteLineTriggerHandler.doAfterInsert(Trigger.new);
            QuoteLineTriggerHandler.amountCheckRemainderCalculationQLFlag(Trigger.new); // This should move into doAfterInsert once the method is activated
        } 
        if(Trigger.isUpdate) {
            QuoteLineTriggerHandler.doAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }
        if(Trigger.isDelete) {
            QuoteLineTriggerHandler.doAfterDelete(Trigger.old);
        }
    }
}