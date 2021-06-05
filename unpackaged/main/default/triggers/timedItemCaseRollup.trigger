trigger timedItemCaseRollup on vftimer__TimedItem__c (after insert, after update, after delete, after undelete) {

        Map<Id,Case> updateCases = new Map<Id,Case>();
        Set<Id> updateCaseIds = new Set<Id>();
        
        // If we are inserting, updating, or undeleting, use the new ID values
        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete)
            for(vftimer__TimedItem__c timedItem:Trigger.new)
                updateCaseIds.add(timedItem.vftimer__Case__c);
                
        // If we are updating, some cases might change, so include that as well as deletes
        if(Trigger.isUpdate || Trigger.isDelete)
            for(vftimer__TimedItem__c timedItem:Trigger.old)
                updateCaseIds.add(timedItem.vftimer__Case__c);
                
        // Do not create a record for null field
        updateCaseIds.remove(null);
        
        // Create in-memory copies for all cases that will be affected
        for(Id caseId:updateCaseIds)
            updateCases.put(caseId,new Case(id=caseId,Timed_Item_Total__c=0,Total_Billable_Time__c=0)); // sce-207 added total billable time field
        
        // Run an optimized query that looks for all cases that meet the criteria
        for(vftimer__TimedItem__c timedItem:[select id, vftimer__Time__c, vftimer__Case__c from vftimer__TimedItem__c 
                                                where vftimer__Case__c in :updateCaseIds order by vftimer__Case__c])
            updateCases.get(timedItem.vftimer__Case__c).Timed_Item_Total__c += timedItem.vftimer__Time__c;
        // sce-207 ->
        // Now build the billable total based on work type
        for(vftimer__TimedItem__c timedItem:[select id, vftimer__Time__c, vftimer__Case__c from vftimer__TimedItem__c 
                                                where vftimer__Case__c in :updateCaseIds and (not vftimer__WorkType__c like '%non-billable%') order by vftimer__Case__c])
            updateCases.get(timedItem.vftimer__Case__c).Total_Billable_Time__c += timedItem.vftimer__Time__c;
        // sce-207 <-
     
        // Update all the cases with new values.
        Database.update(updateCases.values());

}