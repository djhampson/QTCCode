trigger BUPBeforeTrigger on OrderItem (before insert) {
    for (OrderItem oi : Trigger.new) {
        oi.blng__BillableUnitPrice__c = null;
    }
}