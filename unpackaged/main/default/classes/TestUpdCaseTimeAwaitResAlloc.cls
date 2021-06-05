/**
 * Test class for TestUpdCaseTimeAwaitResAlloc
 */
@isTest(SeeAllData=True)
public class TestUpdCaseTimeAwaitResAlloc {

    static testMethod void myUnitTest() {
    	
        try{
            RecordType rectype = [Select Id from RecordType where name = 'I require Consulting services'];
            Account testAccount = new Account(Name = 'TestAccount',
                                      CountryArea__c = 'Australia',
                                      Type = 'Customer',
                                      T1_Industry__c = 'State Government',
                                      Vertical_Market__c = 'Education');
            insert testAccount;
            Case case1 = new Case (AccountId = testAccount.id, recordtypeid = rectype.Id, SuppliedEmail = 'raffertyalbert@gmail.com', subject = 'Test', Status='Awaiting Resource Allocation');
            Insert case1;
            Case case2 = new Case (AccountId = testAccount.id, recordtypeid = rectype.Id, SuppliedEmail = 'raffertyalbert@gmail.com', subject = 'Test again', Status='Awaiting Resource Allocation');
            Insert case2;
            case2.Status = 'Scheduled';
            update case2;
            Test.StartTest();
            UpdCaseTimeAwaitResAlloc s = new UpdCaseTimeAwaitResAlloc();
            Database.executeBatch(s);
            Test.StopTest();
            //System.AssertEquals(database.countquery('SELECT COUNT()'+' FROM Case'), 132);
        }
        catch(Exception e) {
        }
    }
}