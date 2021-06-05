trigger AssetTrigger on Asset (before insert) {
    if(Trigger.IsBefore && Trigger.IsInsert){
        AssetTriggerHandler.doBeforeInsert(Trigger.new);
    }
}