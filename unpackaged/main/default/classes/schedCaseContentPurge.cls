global class schedCaseContentPurge implements Schedulable {
    
   	global void execute(SchedulableContext sc) {
   		
        Integer retentionMonths=60; // defaulting to 5 years
        
        T1_Control_Settings__c s = T1_Control_Settings__c.getOrgDefaults();
        if (s.Case_Content_Retention_Months__c <> NULL){
            retentionMonths = Integer.valueOf(s.Case_Content_Retention_Months__c);
        }
        
        //get the first valid Purge Action by using Limit 1 in soql
      	List<Case_Content_Purge_Action__c> ccpa = [select id, closed_date_from__c, closed_date_to__c, items_to_purge__c, recurring_action__c, action__c from Case_Content_Purge_Action__c
	   			where status__c = 'Scheduled' and commencement_date__c <= TODAY order by commencement_date__c, closed_date_from__c, createddate limit 1];
       
	  	if(ccpa.size() == 0){ // Did not find any scheduled Action
            T1_Process_Log__c procLog = new T1_Process_Log__c(Process_Name__c = 'schedCaseContentPurge',
                Process_Message__c = 'No Content Purge Actions to process.');
            insert procLog;
            system.debug('Nothing to process');
	  		return;
	  	}
	  	
        Boolean recurringAction;
        String ccpaId;
        String toProcess;
        DateTime dateFrom;
        DateTime dateTo;
        String actionType;
        
	  	for (Case_Content_Purge_Action__c d : ccpa) {
            ccpaId = d.Id;
            dateFrom = d.closed_date_from__c;
            dateTo = d.closed_date_to__c;
            toProcess = d.Items_to_Purge__c;
            recurringAction = d.Recurring_Action__c;
            actionType = d.action__c;
        }    
 
        String dateFromS = dateFrom.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String dateToS = dateTo.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String query;
        List<Case> cases;
        cases = [select id from case where status = 'Closed' and closeddate >= :dateFrom and closeddate <= :dateTo order by createddate limit 50000];
        query = 'select id from case where status = \'Closed\' and closeddate >= ' + dateFromS + ' and closeddate <= ' + dateToS + ' order by createddate limit 50000';

        
        if (test.isRunningTest()){
            cases = [select id from case where status = 'Closed' and closeddate >= :dateFrom and closeddate <= :dateTo order by createddate limit 10];
        	query = 'select id from case where status = \'Closed\' and closeddate >= ' + dateFromS + ' and closeddate <= ' + dateToS + ' order by createddate limit 10';
        }
        system.debug(query);
        system.debug(cases.size());
            
        if (cases.size() == 0){
            T1_Process_Log__c procLog = new T1_Process_Log__c(Process_Name__c = 'schedCaseContentPurge',
                Process_Message__c = 'No Cases to process.');
            insert procLog;
            system.debug('No cases to process');
            //complete the Action if nothing to process so it does not get in the way of future processing
            for (Case_Content_Purge_Action__c d : ccpa) {
                if (d.recurring_Action__c == true){
                    //recalc the To date
                    d.Closed_Date_From__c = d.Closed_Date_From__c.addDays(1);
                    d.Closed_Date_To__c = (system.today().addMonths(retentionMonths * -1)).addDays(1);
                    if (d.Closed_Date_From__c <= d.Closed_Date_To__c){
                        d.Closed_Date_From__c = d.Closed_Date_To__c.addDays(-1);
                    }
                }
                else {
                    d.status__c = 'Complete';
                }
            	update d;
        	}
            return;
        }
  			
        for (Case_Content_Purge_Action__c d : ccpa) {
        	d.status__c = 'In Progress';
            update d;
        }
        
        if (cases.size() > 0){
            CaseContentPurge a = new CaseContentPurge();
            a.query = query;
            a.ccpaId = ccpaId;
            a.toProcess = toProcess;
            a.recurringAction = recurringAction;
            a.actionType = actionType;
            database.executebatch(a);
        }
        
        
   	}
}