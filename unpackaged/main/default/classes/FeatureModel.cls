/*******************************************************************************************************
* Class Name      	: FeatureModel
* Description		: The Feature model represents a product feature data model in Salesforce CPQ.
* Reference         : https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_feature_model_4.htm
* Author          	: Simplus - Yi Zhang
* Created On      	: 25/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              25/02/2021		1000				Initial version
******************************************************************************************************/
public class FeatureModel { 
    public SBQQ__ProductFeature__c record; 
    public String instructionsText; 
    public Boolean containsUpgrades; 
}