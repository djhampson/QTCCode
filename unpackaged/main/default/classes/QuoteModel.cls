/*******************************************************************************************************
* Class Name      	: QuoteModel
* Description		: CPQ Model Class for Quote
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 1-13-2020
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	1-13-2020			Initial version 
******************************************************************************************************/
public class QuoteModel {
    public SBQQ__Quote__c record;
    public QuoteLineModel[] lineItems;
    public QuoteLineGroupModel[] lineItemGroups;
    public Integer nextKey;
    public Boolean applyAdditionalDiscountLast;
    public Boolean applyPartnerDiscountFirst;
    public Boolean channelDiscountsOffList;
    public Decimal customerTotal;
    public Decimal netTotal;
    public Decimal netNonSegmentTotal;
}