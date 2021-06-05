@isTest(SeeAllData=True)
public class BatchInitAccountCPQMigrationStatusTest {

 	static testMethod void testMethod1() 
    {
        Account ac = new Account();
        ac.type = 'Customer';
        ac.CountryArea__c = 'Australia';
        ac.Region__c = 'ACT';
        ac.Vertical_Market__c = 'Education';
        ac.T1_Industry__c = 'Other';
        ac.Name = 'Test Account';
        ac.CPQ_Migration_Status__c = null;
        insert ac;

        // ensure triggers, workflow and validation rules are deactivated          
        T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
        s.Bypass_Triggers__c = true;
        s.Bypass_Validation_Rules__c = true;
        s.Bypass_Workflow__c = true;
        s.Customer_Community_URL__c = '';
        s.Employee_Community_URL__c = '';
        s.Internal_URL__c = '';
        s.Closed_Date_for_Archiving_Email__c = null;
        upsert s;

        Test.startTest();
            BatchInitAccountCPQMigrationStatus c = new BatchInitAccountCPQMigrationStatus();
        	Database.executeBatch(c);
        Test.stopTest();
        
        s.Bypass_Triggers__c = false;
        s.Bypass_Validation_Rules__c = false;
        s.Bypass_Workflow__c = false;
        s.Customer_Community_URL__c = '';
        s.Employee_Community_URL__c = '';
        s.Internal_URL__c = '';
        s.Closed_Date_for_Archiving_Email__c = null;
        upsert s;
    } 
}