public class CaseMilestoneUtils {

    @future
    public static void copyTargetDate(List<Id> caseIds) {

            List<Case> casesToUpdate = new List<Case>();

            for (CaseMilestone milestone : [
                select CaseId,
                    MilestoneType.Name,
                    TargetDate
                from CaseMilestone
                where CaseId in :caseIds and
                    MilestoneType.Name = 'Final Resolution'
            ]) {
                casesToUpdate.add(new Case(
                    Id = milestone.CaseId,
                    Final_Resolution_Target__c = milestone.TargetDate
                ));
            }

            if (!casesToUpdate.isEmpty()) {
                update casesToUpdate;
            }
        
            List<Case> casesToUpdate2 = new List<Case>();

            for (CaseMilestone milestone : [
                select CaseId,
                    MilestoneType.Name,
                    TargetDate
                from CaseMilestone
                where CaseId in :caseIds and
                    MilestoneType.Name = 'Interim Resolution'
            ]) {
                casesToUpdate2.add(new Case(
                    Id = milestone.CaseId,
                    Interim_Resolution_Target__c = milestone.TargetDate
                ));
            }

            if (!casesToUpdate2.isEmpty()) {
                update casesToUpdate2;
            }
    }

    @future
    public static void setExitEntitlement(List<Id> caseIds, Boolean setTo) {
            List<Case> casesToUpdate = new List<Case>();

            for (Case c: [
                select Id,
                    Exit_Entitlement_Process__c
                    from Case
                where Id in :caseIds
            ]) {
                if (c.Exit_Entitlement_Process__c <> setTo){
                    casesToUpdate.add(new Case(
                        Id = c.Id,
                        Exit_Entitlement_Process__c = setTo
                    ));
                }
            }

            if (!casesToUpdate.isEmpty()) {
                update casesToUpdate;
            }
        
    
    }
}