/*******************************************************************************************************
* Class Name      	: T1_ProductAdder
* Description		: Apex to call CPQ Read Product API
* Reference         : https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_read_product.htm
* Author          	: Simplus - Yi Zhang
* Created On      	: 24/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              24/02/2021		1000				Initial version
******************************************************************************************************/
public with sharing class T1_ProductReader { 
    
    public static ProductModel read(Id productId, Id pricebookId, String currencyCode) {
        ProductReaderContext ctx = new ProductReaderContext(pricebookId, currencyCode);
        String productJSON = SBQQ.ServiceRouter.load('SBQQ.ProductAPI.ProductLoader', productId, JSON.serialize(ctx));
        return (ProductModel) JSON.deserialize(productJSON, ProductModel.class);
    }
    
    private class ProductReaderContext {
        private Id pricebookId;
        private String currencyCode;
        
        private ProductReaderContext(Id pricebookId, String currencyCode) {
            this.pricebookId = pricebookId;
            this.currencyCode = currencyCode;
        }
    } 
}