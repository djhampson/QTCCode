@isTest(SeeAllData=True)
public class schedbatchUpdateAccServProdDailyTest {

   static testMethod void testMethod1() 
    {
        Test.startTest();
        schedbatchUpdateAccServProdDaily q = new schedbatchUpdateAccServProdDaily();
        SchedulableContext scq;
        q.execute(scq);
        Test.stopTest();  
    }
 
}