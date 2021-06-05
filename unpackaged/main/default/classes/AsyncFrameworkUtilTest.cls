/*******************************************************************************************************
* @Class Name   : AsyncFrameworkUtilTest
* @description  : Test class for AsyncFrameworkUtil
* @author       : Yi Zhang
* @date         : 03/03/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              03/03/2021      1000        Initial version
* Yi Zhang              18/03/2021		1001		Added method testGetJobCronString
******************************************************************************************************/
@isTest
private class AsyncFrameworkUtilTest {
    @isTest
    static void testException() {
        Test.startTest();
        
        try {
            AsyncFrameworkUtil.cleanUpOneOffJob(null);
        } catch(Exception e) {

        }

        Test.stopTest();
    }

    @isTest
    static void testGetJobCronString() {
        Test.startTest();
        AsyncFrameworkUtil.getJobCronString(1);
        Test.stopTest();
    }
}