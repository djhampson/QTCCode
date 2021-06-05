@isTest(SeeAllData=True)
public class BatchUpdateCaseTypeTest2 {

 	static testMethod void testMethod1() 
    {
        Test.startTest();
            BatchUpdateCaseType c = new BatchUpdateCaseType();
        	Database.executeBatch(c);
        Test.stopTest();
 
    } 
}