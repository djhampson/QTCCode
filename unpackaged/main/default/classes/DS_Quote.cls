/*******************************************************************************************************
* @Class Name   : DS_Quote
* @description  : Data Selector class for SBQQ__Quote__c
* @author       : Simplus - Carlos Roy Billones
* @date         : 19/11/2020
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Carlos Roy Billones   19/11/2020      1000        Initial version
* Yi Zhang              12/03/2021      2000        Applied comments
******************************************************************************************************/
public class DS_Quote {

    /**
    * @description  Get Quote object by quote Id
    * @author Carlos Roy Billones | 19/11/2020
    * @param Id quoteId 
    * @return SBQQ__Quote__c 
    **/
    public static SBQQ__Quote__c getQuoteById(Id quoteId){
        // get fields
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('SBQQ__Quote__c').getDescribe().fields.getMap();
        List<String> editableFields = new List<String>();
        
        String qlfields = '';
        
        for(Schema.SObjectField fieldRef : fields.values()) {
            Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();
            if(fieldResult.isUpdateable()) {
                editableFields.add(fieldResult.getname());
                qlfields += fieldResult.getname() + ', ';
            }
        }

        // build query
        String query = 'SELECT Id, ' + qlfields.substring(0,qlfields.length() - 2) + ' FROM SBQQ__Quote__c WHERE Id = :quoteId';
        
        SBQQ__Quote__c quote = Database.query(query);
        System.debug('DS_Quote quote variable in line 20: ' + query);
        return quote;
    }
}