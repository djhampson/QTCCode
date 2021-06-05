/*******************************************************************************************************
* @Class Name   : T1_RenewalServiceBatchSchedulableTest
* @description  : Test class for T1_RenewalServiceBatchSchedulable
* @author       : Carlos Roy Billones
* @date         : 09/03/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Carlos Roy Billones   09/03/2021      1000        Initial version
* Yi Zhang              12/03/2021      2000        Applied comments
******************************************************************************************************/
@isTest
private class T1_RenewalServiceBatchSchedulableTest {
    @isTest
    static void executeTest(){
        Test.startTest();
        T1_RenewalServiceBatchSchedulable batchSch = new T1_RenewalServiceBatchSchedulable();
        String sch='0 5 2 * * ?';
        //System.schedule(String jobName, String cronExp, APEX_OBJECT schedulable);
        System.schedule('Batch Schedule', sch , batchSch);
        Test.stopTest();
    }
}