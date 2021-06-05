@isTest(seealldata=true)
public class schedCaseContentPurgeTest {

    static testMethod void testMethod1() 
    {
        Test.startTest();
        DateTime earliestDate;    
        for (Case cc : [select ClosedDate from case where status = 'Closed' order by ClosedDate Limit 1])
        {
            earliestDate = datetime.valueof(cc.ClosedDate);
        }    

        Case_Content_Purge_Action__c TestCCPA = new Case_Content_Purge_Action__c(Name = 'Test1',
                                      status__c = 'Unscheduled',
                                      Commencement_Date__c = date.ValueOf(system.Today()),
                                      Items_to_Purge__c = 'All',
                                      action__c = 'Delete',
                                      Closed_Date_From__c = Date.valueof('2014-09-01'),
                                      Closed_Date_To__c = Date.valueof('2014-09-02'));
        insert TestCCPA;
        schedCaseContentPurge q = new schedCaseContentPurge();
        SchedulableContext scq;
        q.execute(scq);
        
        TestCCPA.status__c = 'Scheduled';
        update TestCCPA;
        schedCaseContentPurge q2 = new schedCaseContentPurge();
        SchedulableContext scq2;
        q2.execute(scq2);

        Integer retentionMonths=36;             
        T1_Control_Settings__c custs = T1_Control_Settings__c.getOrgDefaults();
        if (custs.Case_Content_Retention_Months__c <> NULL){
            retentionMonths = Integer.valueOf(custs.Case_Content_Retention_Months__c);
        }
        
        system.debug(custs.Case_Content_Retention_Months__c);
        
        TestCCPA.Closed_Date_From__c = date.ValueOf(earliestDate);
        TestCCPA.Closed_Date_To__c = date.ValueOf(earliestDate).addDays(2);
        update TestCCPA;
        schedCaseContentPurge q3 = new schedCaseContentPurge();
        SchedulableContext scq3;
        q3.execute(scq3); 
        
        // 14/12/2018 - The below code suddenly stopped working in Prod with a Too Many Queries error. The temporary removal was necessary.
        TestCCPA.Closed_Date_To__c = date.valueof(system.today().addMonths(retentionMonths * -1).addDays(-2));
        TestCCPA.Closed_Date_From__c = TestCCPA.Closed_Date_To__c.addDays(-2);
        update TestCCPA;
        schedCaseContentPurge q4 = new schedCaseContentPurge();
        SchedulableContext scq4;
        q4.execute(scq4); 
                
        Test.stopTest();  
    }
 
}