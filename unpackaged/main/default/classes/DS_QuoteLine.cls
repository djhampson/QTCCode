/*******************************************************************************************************
* @Class Name   : DS_QuoteLine
* @description  : Data Selector class for SBQQ__QuoteLine__c
* @author       : Simplus - Carlos Roy Billones
* @date         : 19/11/2020
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Carlos Roy Billones   19/11/2020      1000        Initial version
* Yi Zhang              12/03/2021      2000        Applied comments
******************************************************************************************************/
public class DS_QuoteLine {

    /**
    * @description - Get list of quote lines based on quote id
    * @author Carlos Roy Billones | 19/11/2020
    * @param Id quoteId 
    * @return List<SBQQ__QuoteLine__c> 
    **/
    public static List<SBQQ__QuoteLine__c> getQuoteLineByQuoteId(Id quoteId){
        // get fields
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();
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
        String query = 'SELECT Id, ' + qlfields.substring(0,qlfields.length() - 2) + ', SBQQ__Quote__c, SBQQ__ProductCode__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId ORDER BY SBQQ__Number__c ASC';
        
        List<SBQQ__QuoteLine__c> quoteLines = Database.query(query);
        return quoteLines;
    }
    
    /**
    * @description - Clone quote lines to quote line groups, each group has a set of cloned quote lines
    * @author Carlos Roy Billones | 19/11/2020
    * @param List<SBQQ__QuoteLineGroup__c> quotelinegroups 
    * @param List<SBQQ__QuoteLine__c> quoteLines 
    * @return List<SBQQ__QuoteLine__c> 
    **/
    public static List<SBQQ__QuoteLine__c> getClonedQuoteLines(List<SBQQ__QuoteLineGroup__c> quotelinegroups, List<SBQQ__QuoteLine__c> quoteLines){
        List<SBQQ__QuoteLine__c> newquotelines = new List<SBQQ__QuoteLine__c>();
        integer originalQLCount = quoteLines.size() + 1;
        for(SBQQ__QuoteLineGroup__c newqlg : quotelinegroups){
            for(SBQQ__QuoteLine__c ql : quoteLines){
                // If(ql.Fee_Type__c == 'ASM' || ql.Fee_Type__c == 'License' || ql.Fee_Type__c == 'Cloud' ) {
                    SBQQ__QuoteLine__c newql = new SBQQ__QuoteLine__c();
                    newql = ql.clone(false,true,false,false);
                    newql.SBQQ__Group__c = newqlg.Id; 
                    newql.SBQQ__Discount__c = 0;
                    newql.SBQQ__Number__c = originalQLCount;
                    newquotelines.add(newql);
                    originalQLCount++;
               // }
            }
        }
        return newquotelines;
    }
}