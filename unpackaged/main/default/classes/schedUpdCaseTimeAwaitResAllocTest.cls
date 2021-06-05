@isTest(SeeAllData=True)
public class schedUpdCaseTimeAwaitResAllocTest {

 	static testMethod void testMethod1() 
    {
    	Test.startTest();
	    	schedUpdCaseTimeAwaitResAlloc q = new schedUpdCaseTimeAwaitResAlloc();
			SchedulableContext scq;
			q.execute(scq);
		Test.stopTest();  
    }
 
}