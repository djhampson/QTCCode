/*******************************************************************************************************
* Class Name      	: SM_UpdateContractsSchedulable
* Description		: One-off schedulable to update service contract's fields. Can avoid SOQL 101 & Apex CPU Timeout error
* Author          	: Simplus - Yi Zhang
* Created On      	: 23/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              23/02/2021		1000				Initial version
******************************************************************************************************/
public class SM_UpdateContractsSchedulable implements Schedulable {
    private Set<Id> contractIds;
    private String fieldName;
    private Object fieldValue;
    
    public SM_UpdateContractsSchedulable(Set<Id> contractIds, String fieldName, Object fieldValue) {
        this.contractIds = contractIds; 
        this.fieldName   = fieldName;
        this.fieldValue  = fieldValue;
    }
    /**
    * @description Standard execute method for schedulable class
    * @author Yi Zhang | 23/02/2021 
    * @param SchedulableContext sc 
    **/
    public void execute(SchedulableContext sc) {
        
        SM_PerpetualOnCloud.updateContracts(contractIds, fieldName, fieldValue);

        AsyncFrameworkUtil.cleanUpOneOffJob(sc);
    }
}