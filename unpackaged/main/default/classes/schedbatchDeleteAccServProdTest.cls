@isTest(SeeAllData=True)
public class schedbatchDeleteAccServProdTest {

   static testMethod void testMethod1() 
    {
      	Test.startTest();
      	schedbatchDeleteAccServProd q = new schedbatchDeleteAccServProd();
      	SchedulableContext scq;
      	q.execute(scq);
    	Test.stopTest();  
    }
 
}