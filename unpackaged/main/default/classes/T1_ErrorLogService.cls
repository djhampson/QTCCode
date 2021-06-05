/**
 * @description       : Error log service class to store methods for error logging
 * @author            : sakshi.chauhan@simplus.com
 * @group             : 
 * @last modified on  : 02-19-2021
 * @last modified by  : sakshi.chauhan@simplus.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   02-19-2021   sakshi.chauhan@simplus.com   Initial Version
**/
public  class T1_ErrorLogService {
    

    /**
    * @description method to create error log
    * @author sakshi.chauhan@simplus.com | 02-19-2021 
    * @param e 
    * @param recordIdSet 
    * @param source 
    * @param sourceName 
    **/
    public static Error_Log__c createErrorLog( Exception e ,Set<Id> recordIdSet, String source, String sourceName) {
        Error_Log__c errLogEntry = new Error_Log__c();
        errLogEntry.Error_Record__c = String.join(new List<Id>(recordIdSet), ',') ;
        errLogEntry.Error_Source__c = source;
        errLogEntry.Error_Source_Name__c = sourceName;
        errLogEntry.Type__c = e.getTypeName();
        errLogEntry.StackTraceString__c = e.getStackTraceString();
        errLogEntry.User__c = UserInfo.getFirstName() + ' '  + UserInfo.getLastName();
        return errLogEntry;
    }

    // @Description : query error logs based on record id that triggered the error
    public static List<Error_Log__c> queryErrorLogs( Set<Id> recordIdSet ){
        return [ SELECT Error_Record__c,Error_Source__c,Error_Source_Name__c,Type__c,User__c FROM  Error_Log__c WHERE Error_Record__c IN :recordIdSet ];
    }
}