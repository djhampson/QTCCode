/**
 * @description       : Test class for BatchBulkAccServProdCPQ
 * @author            : Edo Manik
 * @group             : 
 * @last modified on  : 24-03-2021
 * @last modified by  : Grant Hamlyn
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   16-03-2021   Edo Manik      Initial Version
 * 1.1   24-03-2021   Grant Hamlyn   Alterations
**/
@isTest(SeeAllData=True)
public class BatchBulkAccServProdCPQTest {

 	/**
 	* @description 
 	* @author Grant Hamlyn | 24-03-2021 
 	* @return testMethod 
 	**/
 	static testMethod void testMethod1() 
    {
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
            BatchBulkAccServProdCPQ c = new BatchBulkAccServProdCPQ();
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