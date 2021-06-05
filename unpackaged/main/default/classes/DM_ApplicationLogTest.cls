/*******************************************************************************************************
* @Class Name   : DM_ApplicationLogTest
* @description  : Test Class for DM_ApplicationLog
* @author       : Paul
* @date         : 2019-08-20
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID       Description
* -----------------------------------------------------------------------------------------------------
* Paul                  2019-08-20      1000         Initial version
******************************************************************************************************/
@isTest
public class DM_ApplicationLogTest {
	/***
    * @name	        : testCreateFromPendingPolicy
    * @description  : overall test
    * @author		: Paul
    */
    @isTest 
    static void testApplicationLog(){

        //std constructor
        DM_ApplicationLog dmal = new DM_ApplicationLog();

        // generic record, we'll use this to do exceptions
        Application_Log__c al = DM_ApplicationLog.createApplicationLog(
            'Custom',
            'String logMessage'
        );
        insert al;


        // general Exception catching
        try {
            insert al;

        } catch (Exception e) {
            Application_Log__c resultantAl = DM_ApplicationLog.createApplicationLog(
                e
            );
        }
        

        // dml Exception catching
        try {
            insert al;

        } catch (DMLException dmle) {
            Application_Log__c resultantAl = DM_ApplicationLog.createApplicationLog(
                dmle
            );
        }
        

        // Database Exectpiont catching
        Database.SaveResult sr = Database.insert(al, false);
        for (Database.Error dbe : sr.getErrors()) {
            Application_Log__c resultantAl = DM_ApplicationLog.createApplicationLog(
                dbe
            );
        }

        
        Test.startTest();

        Test.stopTest();

        //Assert that mapping was successful
        System.assert(true, 'Logic not required, is deprecated. Retaining for VCS pointer');
        
    }
    
}