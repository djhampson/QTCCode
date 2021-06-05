@isTest(SeeAllData=True)
public class TestCaseLoopPrevent {
    static testmethod void LoopTest(){
        try{
            
            
            Case newcase1 = new Case(SuppliedEmail = 'raffertyalbert@gmail.com', subject = 'Out of office');
            insert newCase1;   
            Case newcase2 = new Case(SuppliedEmail = 'raffertyalbert@gmail.com', subject = 'Out of office');
            insert newCase2;   
            Case newcase3 = new Case(SuppliedEmail = 'raffertyalbert@gmail.com', subject = 'Out of office');
            insert newCase3;   
            
            Case newcase4 = new Case(SuppliedEmail = 'raffertyalbert@gmail.com', subject = 'Test');
            insert newCase4;   
            Case newcase5 = new Case(SuppliedEmail = 'raffertyalbert@gmail.com', subject = 'Test');
            insert newCase5;   
            Case newcase6 = new Case(SuppliedEmail = 'raffertyalbert@gmail.com', subject = 'Test');
            insert newCase6; 
            Case newcase7 = new Case(SuppliedEmail = 'raffertyalbert@gmail.com', subject = 'Test');
            insert newCase7; 

        }
        catch(Exception e) {
        }
    }  
 
}