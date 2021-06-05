/*******************************************************************************************************
* Class Name      	: SM_AutoOrderSchedulable
* Description		: One-off schedulable to update quote's fields (e.g. Auto_Amendment__c, Start/End Date). Can avoid SOQL 101 & Apex CPU Timeout error
* Author          	: Simplus - Yi Zhang
* Created On      	: 23/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              23/02/2021		1000				Initial version
******************************************************************************************************/
public class SM_AutoOrderSchedulable implements Schedulable {
    Set<String> quoteIds;
    Map<Id, Date> contractIdStartDateMap;
    Map<Id, Date> contractIdEndDateMap;
    
    /**
    * @description Constructor
    * @author Yi Zhang | 23/02/2021 
    * @param Set<String> quoteIds 
    * @param Map<Id Date> contractIdStartDateMap    key = quote's MSC
    * @param Map<Id Date> contractIdEndDateMap      key = quote's MSC
    **/
    public SM_AutoOrderSchedulable(Set<String> quoteIds, Map<Id, Date> contractIdStartDateMap, Map<Id, Date> contractIdEndDateMap) {
        this.quoteIds = quoteIds;
        this.contractIdStartDateMap = (contractIdStartDateMap != null) ? contractIdStartDateMap : new Map<Id, Date>();
        this.contractIdEndDateMap = (contractIdEndDateMap != null) ? contractIdEndDateMap : new Map<Id, Date>();
    }
    
    /**
    * @description Standard execute method for schedulable class
    * @author Yi Zhang | 23/02/2021 
    * @param SchedulableContext sc 
    **/
    public void execute(SchedulableContext sc) {
        
        SM_PerpetualOnCloud.orderAmendmentQuotes(quoteIds, contractIdStartDateMap, contractIdEndDateMap);

        AsyncFrameworkUtil.cleanUpOneOffJob(sc);
    }
}