/*******************************************************************************************************
* @Class Name   : DM_ApplicationLog
*
* @description  : SOA/SOC Data Manager (Data Domain) over legacy Application_Log__c
* 
* @group        : A group to display this class under, in the menu hierarchy
* @group-content: A relative path to a static html file that provides content about the group
* 
* @author       : Paul Carmuciano
* @date         : 2017-07-10
* 
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date               Mod ID       Description
* -----------------------------------------------------------------------------------------------------
* Paul Carmuciano       2017-07-10         1000         Initial version
* Theodore Fernandez    2020-12-01         2000         Added new method that accepts custom log type and message
******************************************************************************************************/
public without sharing class DM_ApplicationLog {

    /***
    * @description  : Property to store applicationLogs, can traverse callers reducing dml
    * @author		: Paul Carmuciano
    */
    public static List<Application_Log__c> applicationLogs {
        get {
            if (applicationLogs == null) {
                applicationLogs = new List<Application_Log__c>();
            }
            return applicationLogs;
        }
        set;
    }

    /***
    * @name	        : DM_ApplicationLog
    * @description  : Standard constructor
    * @author		: Paul Carmuciano
    * @param 		: N/A
    * @return	    : Boolean
    */
    public DM_ApplicationLog() {
        //
        return;
    }

    /***
    * @name	        : createApplicationLogSobject
    * @description  : To map the createApplicationLogs to an Sobject
    * @author		: Paul Carmuciano
    * @param 		: String logType - determined by override type TODO map to discrete picklist
    * @param 		: String logMessage - mapped from override
    * @return	    : Application_Log__c sobject record produced
    */
    private static Application_Log__c createApplicationLogSobject(
        String logType
        ,String logMessage
    ) {
        Application_Log__c al = new Application_Log__c();
        al.Log_Type__c = logType;
        al.Message__c = logMessage;
        applicationLogs.add(al);
        //system.debug(LoggingLevel.ERROR, json.serialize(al));
        return al;
    }

    /***
    * @name	        : createApplicationLog
    * @description  : Create from System.Exception
    * @author		: Paul Carmuciano
    * @param 		: Exception e - exception to log
    * @return	    : Application_Log__c sobject record produced
    */
    public static Application_Log__c createApplicationLog(
        Exception e
    ) {
        Application_Log__c al = createApplicationLogSobject(
            e.getTypeName()
            ,e.getMessage() + ' ' + e.getStackTraceString()
        );
        return al;
    }

    /***
    * @name	        : createApplicationLog
    * @description  : Create from System.DmlException
    * @author		: Paul Carmuciano
    * @param 		: DmlException dmle - exception to log
    * @return	    : Application_Log__c sobject record produced
    */
    public static Application_Log__c createApplicationLog(
        DmlException dmle
    ) {
        Application_Log__c al = createApplicationLogSobject(
            dmle.getTypeName()
            ,dmle.getMessage() + ' ' + dmle.getStackTraceString()
        );
        return al;
    }

    /***
    * @name	        : createApplicationLog
    * @description  : Create from Database.Error
    * @author		: Yi
    * @param 		: Database.Error err - exception to log
    * @return	    : Application_Log__c sobject record produced
    */
    public static Application_Log__c createApplicationLog(
        Database.Error err
    ) {
        Application_Log__c al = createApplicationLogSobject(
            'Database.Error'
            ,err.getMessage()
        );
        return al;
    }

    /***
    * @name	        : createApplicationLog
    * @description  : Create Application log with custom message
    * @author		: Theodore Fernandez
    * @param 		: String logType - custom log type
    * 				  String logMessage - custom log message
    * @return	    : Application_Log__c sobject record produced
    */
    public static Application_Log__c createApplicationLog(
        String logType,
        String logMessage
    ) {
        Application_Log__c al = createApplicationLogSobject(
            logType
            ,logMessage
        );
        return al;
    }

}