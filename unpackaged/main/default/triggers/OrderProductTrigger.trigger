trigger OrderProductTrigger on OrderItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    OrderProductTriggerHandler handler = new OrderProductTriggerHandler(false);
    //After Insert
    if(Trigger.isInsert && Trigger.isAfter){
       handler.OnAfterInsert(Trigger.new);
    }
    //Before Update
    else if(Trigger.isUpdate && Trigger.isBefore){
        OrderProductTriggerHandler.calculateOrderProductRevenue(Trigger.oldMap, Trigger.new);
        OrderProductTriggerHandler.setAMSUnitPrice(Trigger.oldMap, Trigger.new);
    }
    //Before Insert
    else if(Trigger.isInsert && Trigger.isBefore){
      OrderProductTriggerHandler.doBeforeInsert(Trigger.new);
    }
    //After Update
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    } 
}