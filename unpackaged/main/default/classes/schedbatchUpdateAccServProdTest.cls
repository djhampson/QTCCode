@isTest(SeeAllData=True)
public class schedbatchUpdateAccServProdTest {

   static testMethod void testMethod1() 
    {
      Test.startTest();
        schedbatchUpdateAccServProd q = new schedbatchUpdateAccServProd();
      SchedulableContext scq;
      q.execute(scq);
    Test.stopTest();  
    }
 
}