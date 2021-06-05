/*******************************************************************************************************
* Class Name      	: ConstraintModel
* Description		: The Constraint model represents the option constraint object in Salesforce CPQ.
* Reference         : https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_constraint_model_7.htm
* Author          	: Simplus - Yi Zhang
* Created On      	: 25/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              25/02/2021		1000				Initial version
******************************************************************************************************/
public class ConstraintModel { 
    public SBQQ__OptionConstraint__c record; 
    public Boolean priorOptionExists; 
}