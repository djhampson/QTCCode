/*******************************************************************************************************
* Class Name      	: QuoteLineModel
* Description		: CPQ Model Class for Quote Line
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 1-13-2020
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	1-13-2020			Initial version 
******************************************************************************************************/
public class QuoteLineModel {
    public SBQQ__QuoteLine__c record;
    public Boolean amountDiscountProrated;
    public Integer parentGroupKey;
    public Integer parentItemKey;
    public Integer key;
    public Boolean upliftable;
    public String configurationType;
    public String configurationEvent;
    public Boolean reconfigurationDisabled;
    public Boolean descriptionLocked;
    public Boolean productQuantityEditable;
    public Decimal productQuantityScale;
    public String dimensionType;
    public Boolean productHasDimensions;
    public Decimal targetCustomerAmount;
    public Decimal targetCustomerTotal;
}