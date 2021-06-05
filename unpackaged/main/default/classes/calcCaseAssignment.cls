public with sharing class calcCaseAssignment {
    @future
    public static void calcAssignment(List<Id> caseIds) {
        List<Case> casesToUpdate = new List<Case>();

        for (Case cCase : [
            select Id
                from Case
                where Id in :caseIds]) {
            casesToUpdate.add(cCase);
        }

        if (!casesToUpdate.isEmpty()){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            if(!Test.isRunningTest())
                Database.update(casesToUpdate, dmo);
        }   
    }
}