public class Jira_Dev_IssueTriggerHandler {

    static public void onAfterInsert(Jira_Dev_Issue__c[] newJDIs) {
        updateCaseDevStatus(newJDIs);
        completeMilestones(newJDIs);
    }

    static public void onAfterUpdate(Jira_Dev_Issue__c[] updatedJDIs, Map<ID, Jira_Dev_Issue__c> oldMap) {
        updateCaseDevStatus(updatedJDIs);
    }

    static public void onAfterDelete(Jira_Dev_Issue__c[] updatedJDIs) {
        updateCaseDevStatus(updatedJDIs);
    }

    static public void updateCaseDevStatus(Jira_Dev_Issue__c[] newJDIs) {
    
            // get the list of Status values and their sequence
            Map<String, Integer> devStat = new Map<String, Integer>();
            for (Jira_Dev_Status__c jds : [Select Name, Sequence__c From Jira_Dev_Status__c ]){
                devStat.put(jds.name, Integer.valueof(jds.Sequence__c));
            }

            // get the list of Project Prefixes
            Map<String, String> devPP = new Map<String, String>();
            for (Jira_Dev_Project_Prefix__c jdpp : [Select Name From Jira_Dev_Project_Prefix__c ]){
                devPP.put(jdpp.name, jdpp.name);
            }

            String newcaseDevStatus = '';
            String currentcaseDevStatus = '';

            //build the list of affected Cases
            list <case> lcases = new list<case>(); // to be updated
            set<Id> caseIds = new set<Id>(); // list of Case Id's related to updated Jira Dev Issues
            for(Jira_Dev_Issue__c jdi : newJDIs){
                    caseIds.add(jdi.case__c); 
            }

            if (caseIds.isEmpty()){
                return;
            }

            for (case [] arrCase : [SELECT Id, 
                                            Development_Status__c 
                                FROM case 
                                    WHERE Status <> 'Resolved' and Status <> 'Closed' and Id IN :caseIds]){      // an array of Cases based on the ID's to be updated 
                for (Case sCase : arrCase){ // Update the field for the Case to be updated and add it to the Update List
                    currentcaseDevStatus = sCase.Development_Status__c;
                    //process each related Jira Dev Issue
                    list<String> devStatuses = new list<String>();
                    newcaseDevStatus = '';
                    Integer iCount = 0; 
                    Integer intIndex = 0;
                    String sPrefix = '';
                    
                    for (Jira_Dev_Issue__c jdi2 : [select name, issue_type__c, fix_version__c, status__c, resolution__c from jira_dev_issue__c
                                                where case__c = :sCase.Id])
                    {
                        // See if this issue is within one of the desired Projects
                        intIndex = 0;
                        sPrefix = '';
                        intIndex = jdi2.name.indexOf('-');
                        
                        if (intIndex <= 0){
                            continue;    
                        }
                        sPrefix = jdi2.name.left(intIndex + 1);
                        if (sPrefix == ''){
                            continue;
                        }
                        if (!devPP.containsKey(sPrefix)){
                            continue;
                        }
                        
                        iCount ++;
                        //determine the new status
                        if((jdi2.issue_type__c == 'Support Triage' || jdi2.issue_type__c == 'R&D Triage' || jdi2.issue_type__c == 'Question')
                            && jdi2.Status__c == 'Closed'){
                            newcaseDevStatus = 'Completed';
                        }
                        else if(jdi2.resolution__c == 'Cancelled'){
                            newcaseDevStatus = 'Completed';
                        }
                        else if(jdi2.issue_type__c == 'Support Triage'){
                            newcaseDevStatus = 'Under Review';
                        }
                        else if(jdi2.issue_type__c == 'R&D Triage'){
                            newcaseDevStatus = 'Under Investigation';
                        }
                        else if(jdi2.status__c == 'Closed' || jdi2.status__c == 'Release Merge' || jdi2.status__c == 'Release QA'){
                            newcaseDevStatus = 'Awaiting Release';
                        }
                        else if(jdi2.fix_version__c > '' || jdi2.status__c == 'Development Complete' || jdi2.status__c == 'ITQA'){
                            newcaseDevStatus = 'Planned for Release';
                        }
                        else if(jdi2.issue_type__c == 'Bug' || jdi2.issue_type__c == 'User Story' ){
                            newcaseDevStatus = 'Requires a Software Change';
                        }
                        else if(jdi2.issue_type__c == 'Question'){
                            newcaseDevStatus = 'Requires Research';
                        }
                    
                        if (newcaseDevStatus > ''){
                            Integer intSeq = devStat.Get(newcaseDevStatus);
                            devStatuses.add(string.valueOf(intSeq) + ' ' + newcaseDevStatus);
                        }
                    }

                    if (iCount == 0){
                        sCase.Development_Status__c = '';
                        lcases.add(sCase);
                    }

                    // now get the earliest status in the list
                    if (!devStatuses.isEmpty()){
                        devStatuses.sort();
                        String finalStatus = devStatuses[0]; // get the first string
                        String theStatus = finalStatus.substring(finalStatus.indexof(' ')+1); // get rid of the sequence
                        if (theStatus <> currentcaseDevStatus){
                            sCase.Development_Status__c = theStatus;
                            lcases.add(sCase);
                        }
                    }
                }
            }  
    
            if (!lcases.isEmpty()){
                update lcases;
            }
    }
    static public void completeMilestones(Jira_Dev_Issue__c[] newJDIs) {
            // Cannot be a portal user
            if (UserInfo.getUserType() == 'Standard' || UserInfo.getUserType() == 'PowerPartner') {
                DateTime completionDate = System.now();
                String milestoneType = '';
                List<Id> caseIds = new List<Id>();
                for (Jira_Dev_Issue__c jdi : newJDIs) {
                    caseIds.add(jdi.case__c);
                }
                if (caseIds.isEmpty() == false){
                    List<Case> caseList = [Select c.Id, c.Status, c.EntitlementId, c.SlaStartDate, c.SlaExitDate
                        From Case c
                        Where c.Id IN :caseIds];
                    if (caseList.isEmpty() == false){
                        List<Id> updateCases = new List<Id>();
                        for (Case caseObj:caseList) {
                            if  ((caseObj.EntitlementId != null)&&
                                (caseObj.SlaStartDate <= completionDate)&&
                                (caseObj.SlaStartDate != null)&&
                                (caseObj.SlaExitDate == null)&&
                                (caseObj.Status != 'Resolved') && //only update if Case is still open
                                (caseObj.Status != 'Closed')){
                                updateCases.add(caseObj.Id);
                                milestoneType = 'Update';
                            }
                        }

                        if (updateCases.isEmpty() == false ){
                            if (milestoneType  == 'Update')               
                                milestoneUtils.completeMilestone(updateCases, 'Update', completionDate);
                            
                        }
                    }
                }
            }
    }
}