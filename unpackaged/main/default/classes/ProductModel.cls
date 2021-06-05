/*******************************************************************************************************
* Class Name      	: ProductModel
* Description		: The Product model represents a product data model in Salesforce CPQ
* Reference         : https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_product_model_8.htm
* Author          	: Simplus - Yi Zhang
* Created On      	: 24/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              24/02/2021		1000				Initial version
******************************************************************************************************/
public class ProductModel {
    public Product2 record;
    public Id upgradedAssetId;
    public String currencySymbol;
    public String currencyCode;
    public String[] featureCategories;
    public OptionModel[] options;
    public FeatureModel[] features;
    public ConfigurationModel configuration;
    public ConfigAttributeModel[] configurationAttributes;
    public ConfigAttributeModel[] inheritedConfigurationAttributes;
    public ConstraintModel[] constraints; 
}