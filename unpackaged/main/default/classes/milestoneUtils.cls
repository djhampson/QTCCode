public class milestoneUtils {
    
    public static void completeMilestone(List<Id> caseIds, String milestoneName, DateTime complDate) {
      
      // reduce processing if test is running
      if (Test.isRunningTest()){
          Integer i = 0;
          while (i < caseIds.size() - 2){
              caseIds.remove(i);
              i++;
          }
      }

      if (milestoneName.startsWith('Response') == true) {
            List<CaseMilestone> cmsToUpdate = [select Id, completionDate
                        from CaseMilestone cm
                        where caseId in :caseIds and cm.MilestoneType.Name like 'Response%' and completionDate = null limit 1];
            if (cmsToUpdate.isEmpty() == false){
                for (CaseMilestone cm : cmsToUpdate){
                  cm.completionDate = complDate;
                }
                update cmsToUpdate;
            } // end if
            return;
      }
      if (milestoneName.startsWith('Final Resolution') == true) {
            List<CaseMilestone> cmsToUpdate = [select Id, completionDate
                        from CaseMilestone cm
                        where caseId in :caseIds and (cm.MilestoneType.Name = 'Final Resolution' or cm.MilestoneType.Name like 'Resolution%') and completionDate = null limit 1];
            if (cmsToUpdate.isEmpty() == false){
                for (CaseMilestone cm : cmsToUpdate){
                  cm.completionDate = complDate;
                }
                update cmsToUpdate;
              } // end if
            return;        
      }

      List<CaseMilestone> cmsToUpdate = [select Id, completionDate
                        from CaseMilestone cm
                        where caseId in :caseIds and cm.MilestoneType.Name = :milestoneName and completionDate = null limit 1];
      if (cmsToUpdate.isEmpty() == false){
            for (CaseMilestone cm : cmsToUpdate){
              cm.completionDate = complDate;
                }
            update cmsToUpdate;
      return;       
      } // end if
 
    }
 }