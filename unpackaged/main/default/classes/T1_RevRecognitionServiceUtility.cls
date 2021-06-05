/**
 * @description       : 
 * @author            : sakshi.chauhan@simplus.com
 * @group             : 
 * @last modified on  : 02-19-2021
 * @last modified by  : sakshi.chauhan@simplus.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   02-16-2021   sakshi.chauhan@simplus.com   Initial Version
**/
public with sharing class T1_RevRecognitionServiceUtility { 
    
 
    /*
     * @description: function to return order items based on order ids
     * @returntype: List<OrderItems>
     * @param : OrderIds
     */   
    public static List<OrderItem> selectOrderItemsByOrderId(Set<Id> orderIdsSet){
        return [ SELECT CurrencyIsoCode,blng__RevenueRecognitionRule__c,Product2Id,blng__LegalEntity__c,ServiceDate,EndDate,TotalPrice,blng__AllocatedRevenueAmount__c,OrderId,(SELECT Id FROM blng__OrderProductsRevenueSchedules__r) FROM OrderItem WHERE OrderId IN :orderIdsSet ];
    }

    public static  List<blng__RevenueRecognitionRule__c> returnParentChildRulesHierarchy( Set<Id> parentRuleIds ){
        return [ SELECT blng__Active__c,Full_Revenue_Recognition__c,  ( SELECT Parent_Revenue_Recognition_Rule__c,Financial_End_Date__c ,Financial_Start_Date__c  FROM Revenue_Recognition_Rules__r ORDER BY Financial_Start_Date__c ASC) FROM blng__RevenueRecognitionRule__c WHERE ID= : parentRuleIds ];
    }

    /**
    * @description function to Call Revenue Recognition Service to create Revenue related records
    * @author sakshi.chauhan@simplus.com | 02-19-2021 
    * @param List<blng.RevenueRecognitionInput> recognitionInputs 
    **/
    public static List<blng.RevenueRecognitionResponse> generateRevenueRecognitionRecords( List<blng.RevenueRecognitionInput> recognitionInputs ){
        
        List<blng.RevenueRecognitionResponse> response = blng.RevenueRecognition.recognizeRevenue( recognitionInputs );
        system.debug('Response # '+ response);
        return response;
    }

    
}