/*********************************************************************************************
* @author         Cludo
* @date           31/07/2018
* @description:   Base trigger handler
* @Version:
**********************************************************************************************/
public virtual class BaseTriggerHandler implements TriggerHandler {

    @TestVisible
    protected Boolean triggerDisabled = false;
	@TestVisible
    private Integer maxRecursion = 1;
	@TestVisible
    protected void allowRecursion() {
        this.allowRecursion(2);
    }
	@TestVisible
    protected void allowRecursion(Integer maxDepth) {
        this.maxRecursion = maxDepth;
    }

    public virtual Boolean isDisabled(){
        return triggerDisabled;
    }

    public virtual String getName(){
        return String.valueOf(this).split(':')[0];
    }

    public virtual Integer getMaxRecursion(){
        return maxRecursion;
    }
	public virtual void beforeInsert(List<SObject> newObjects){
    }
 
    public virtual void afterInsert(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) {
    }
    
    public virtual void beforeUpdate(List<SObject> newObjects, Map<Id, SObject> newObjectsMap, Map<Id, SObject> oldObjectsMap){
    }

    public virtual void afterUpdate(List<SObject> newObjects, Map<Id, SObject> newObjectsMap, Map<Id, SObject> oldObjectsMap) {
    }
   
    public virtual void beforeDelete(Map<Id, SObject> oldObjectsMap){
    }

    public virtual void afterDelete(Map<Id, SObject> oldObjectsMap){
    }

    public virtual void afterUndelete(List<SObject> newObjects, Map<Id, SObject> newObjectsMap){
    }
}