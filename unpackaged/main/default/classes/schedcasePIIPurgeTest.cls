@isTest(SeeAllData=True)
public class schedcasePIIPurgeTest {

   static testMethod void testMethod1() 
    {
      	Test.startTest();
      	schedCasePIIPurge q = new schedCasePIIPurge();
      	SchedulableContext scq;
      	q.execute(scq);
    	Test.stopTest();  
    }
 
}