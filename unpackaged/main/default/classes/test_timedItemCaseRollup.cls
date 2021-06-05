@isTest
private class test_timedItemCaseRollup {

  static testMethod void testNewRecords() {

     Account ac = new Account();
            ac.type = 'Customer';
            ac.CountryArea__c = 'Australia';
     		ac.Region__c = 'ACT';
            ac.Vertical_Market__c = 'Education';
            ac.T1_Industry__c = 'Other';
            ac.Name = 'Test Account';
     Insert ac;
    
     Contact con = new Contact();
            con.AccountId = ac.id;
            con.LastName = 'Test Contact';
            con.Title = 'Mr';
            con.Job_Classification__c = 'A';
            con.email = 'abc@123.com';
     Insert con;
            
     Entitlement ent = new Entitlement();
            ent.name = 'Test Entitlement';
            ent.AccountId = ac.id;
            ent.StartDate = Date.Today() - 1;
            ent.EndDate = Date.Today() + 1;
     Insert ent;
                            
    
     Case c = new Case(Subject = 'Test Case with Entitlement ', EntitlementId = ent.Id, AccountId = ac.id, ContactId = con.Id,
                      			Priority = 'Medium', Description = 'A Description', Customer_Product__c = 'Financials (FIN)', Affected_Version__c = 'non-Production', 
                                 Work_around_Details__c = 'A bit of text', CFunctional_Area__c = 'testing', 
                                 Has_it_worked_before__c = 'No', Is_there_a_scalable_work_around__c = 'No', Steps_to_reproduce__c = '12345678910');
     insert c;
    
    // insert timed items
    vftimer__TimedItem__c ti1 = new vftimer__TimedItem__c();
    ti1.vftimer__BillingType__c = 'Fixed Price';
    ti1.vftimer__Case__c = c.id;
    ti1.vftimer__Time__c = 1;
    ti1.vftimer__Description__c = 'Initial Description';
   
    
    vftimer__TimedItem__c ti2 = new vftimer__TimedItem__c();
    ti2.vftimer__BillingType__c = 'Fixed Price';
    ti2.vftimer__Case__c = c.id;
    ti2.vftimer__Time__c = .5;
    
    vftimer__TimedItem__c ti3 = new vftimer__TimedItem__c();
    ti3.vftimer__BillingType__c = 'Fixed Price';
    ti3.vftimer__Case__c = c.id;
    ti3.vftimer__Time__c = .3;
    
    insert new List<vftimer__TimedItem__c>{ti1,ti2, ti3}; 

    System.assertEquals(3,[select count() from vftimer__TimedItem__c where vftimer__Case__c = :c.id]);
    Case case1 = [select Timed_Item_Total__c from Case where id = :c.id];
    
    System.assertEquals(1.8, Case1.Timed_Item_Total__c );
  
    List<vftimer__TimedItem__c> items = [select id, vftimer__Description__c from vftimer__TimedItem__c 
      where vftimer__Case__c = :c.id];
    // change the decription, should trigger update
    items.get(0).vftimer__Description__c = 'Description update';

    update items;
    // assert that the total is correct
    Case case2 = [select Timed_Item_Total__c from Case where id = :c.id];
    
    System.assertEquals(1.8, Case2.Timed_Item_Total__c );
    
    List<vftimer__TimedItem__c> item2 = [select id, vftimer__Description__c from vftimer__TimedItem__c 
      where vftimer__Case__c = :c.id and vftimer__Time__c = 1];
    // delete  should trigger update
    delete item2;
   
    // assert that the total is correct
     Case case3 = [select Timed_Item_Total__c from Case where id = :c.id];
    
    System.assertEquals(.8, Case3.Timed_Item_Total__c );

  }

}