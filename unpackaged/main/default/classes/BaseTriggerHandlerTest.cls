@isTest
private class BaseTriggerHandlerTest {
	static testMethod void callBehavior() 
    {	
        //BaseTriggerHandler is implemented by other classes.
        BaseTriggerHandler c = new BaseTriggerHandler();
        c.beforeUpdate(new List<SObject>(),new  Map<Id, SObject>(),new  Map<Id, SObject>());
        c.beforeInsert(new List<SObject>());
        c.beforeDelete(new Map<Id, SObject>());
        c.afterInsert(new List<SObject>(),new  Map<Id, SObject>());
        c.afterUpdate(new List<SObject>(),new  Map<Id, SObject>(),new Map<Id, SObject>());
        c.afterDelete(new Map<Id, SObject>());
        c.afterUndelete(new List<SObject>(),new Map<Id, SObject>());
        c.isDisabled();
    	c.getName();
		c.getMaxRecursion();
        c.allowRecursion(); 
        c.allowRecursion(2); 
        System.assertEquals(2,c.maxRecursion);
    }
    
}