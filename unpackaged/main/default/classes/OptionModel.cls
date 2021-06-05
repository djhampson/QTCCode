/*******************************************************************************************************
* Class Name      	: OptionModel
* Description		: The Option model represents a product option data model in Salesforce CPQ.
* Reference         : https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_option_model_3.htm
* Author          	: Simplus - Yi Zhang
* Created On      	: 25/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              25/02/2021		1000				Initial version
******************************************************************************************************/
public class OptionModel { 
    public SBQQ__ProductOption__c record; 
    public Map<String,String> externalConfigurationData; 
    public Boolean configurable; 
    public Boolean configurationRequired; 
    public Boolean quantityEditable; 
    public Boolean priceEditable; 
    public Decimal productQuantityScale; 
    public Boolean priorOptionExists; 
    public Set<Id> dependentIds; 
    public Map<String,Set<Id>> controllingGroups; 
    public Map<String,Set<Id>> exclusionGroups; 
    public String reconfigureDimensionWarning; 
    public Boolean hasDimension; 
    public Boolean isUpgrade; 
    public String dynamicOptionKey; 
}