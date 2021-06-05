/*******************************************************************************************************
* Trigger Name     	: ServiceContractTrigger
* Description		: Trigger for sobject ServiceContract
* Author          	: Simplus - Abeer Qureshi
* Created On      	: 23/12/2020
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         23/12/2020		1000				Initial version
******************************************************************************************************/
trigger ServiceContractTrigger on ServiceContract (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    ServiceContractTriggerHandler handler = new ServiceContractTriggerHandler();
    
    //Before Update
    if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    
    //After Update
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
    }
    
     //After insert
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug(loggingLevel.ERROR, 'EXECUTING AFTER INSERT!!!!');
        ServiceContractTriggerHandler.LinkPerpetualCloudServiceContracts(Trigger.new);
    }


}