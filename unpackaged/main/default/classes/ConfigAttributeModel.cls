/*******************************************************************************************************
* Class Name      	: ConfigAttributeModel
* Description		: The ConfigAttribute model represents the configuration attribute object in Salesforce CPQ.
* Reference         : https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_configattr_model_5.htm
* Author          	: Simplus - Yi Zhang
* Created On      	: 25/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              25/02/2021		1000				Initial version
******************************************************************************************************/
public class ConfigAttributeModel { 
    public String name; 
    public String targetFieldName; 
    public Decimal displayOrder; 
    public String colmnOrder;
    public Boolean required;
    public Id featureId;
    public String position;
    public Boolean appliedImmediately;
    public Boolean applyToProductOptions;
    public Boolean autoSelect;
    public String[] shownValues;
    public String[] hiddenValues;
    public Boolean hidden;
    public String noSuchFieldName;
    public Id myId;
}