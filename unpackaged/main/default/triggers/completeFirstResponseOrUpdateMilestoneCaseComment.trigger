trigger completeFirstResponseOrUpdateMilestoneCaseComment on CaseComment (before insert) {

     // bypass trigger processing START
     T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
     
     if( s.Bypass_Triggers__c) return; // skip trigger...
     // bypass trigger processing END
    
        // Cannot be a portal user
        if (UserInfo.getUserType() == 'Standard' || UserInfo.getUserType() == 'PowerPartner') {
            DateTime completionDate = System.now();
            String milestoneType = '';
            List<Id> caseIds = new List<Id>();
            for (CaseComment cc : Trigger.new){
                // Only public comments qualify
                if(cc.IsPublished == true){
                    caseIds.add(cc.ParentId);
                }
            }
            if (caseIds.isEmpty() == false){
                List<Case> caseList = [Select c.Id, c.ContactId, c.Contact.Email,
                                c.OwnerId, c.Status,
                                c.EntitlementId,
                                c.SlaStartDate,
                                c.SlaExitDate,
                                c.First_Response_Complete__c, 
                                c.New_Customer_Attachment__c,
                                c.New_Customer_Email__c,
                                c.New_Portal_Case_Comment__c
                            From Case c
                            Where c.Id IN :caseIds];
                //List<Id> CaseMilestone = new List<Id>();
                //List<CaseMilestone> cmsCompleted = [select Id, completionDate
                //           from CaseMilestone cm
                //           where caseId in :caseIds and cm.MilestoneType.Name like 'Response%' and completionDate != null limit 1];
                if (caseList.isEmpty() == false){
                    List<Id> updateCases = new List<Id>();
                    List <case> c = new list<case>();
                    for (Case caseObj:caseList) {
                        // consider a public Case comment by a staff member as a valid first response
                        //if ((caseObj.Status == 'In Progress')  &&
                        //
                        // clear flags due to outbound email, if necessary
                        if (caseObj.New_Customer_Attachment__c == true || caseObj.New_Customer_Email__c == true || caseObj.New_Portal_Case_Comment__c == true ){
                            c.add(new Case(id = caseObj.id, 
                                        New_Customer_Attachment__c = false,
                                        New_Customer_Email__c = false,
                                        New_Portal_Case_Comment__c = false,
                                        Last_Customer_Contact__c = System.now()));
                        }
                        else {
                            c.add(new Case(id = caseObj.id, 
                                        Last_Customer_Contact__c = System.now()));
                        }
                        if ((caseObj.EntitlementId != null)&&
                            (caseObj.SlaStartDate <= completionDate)&&
                            (caseObj.SlaStartDate != null)&&
                            (caseObj.SlaExitDate == null)){
                            updateCases.add(caseObj.Id);
                            if (caseObj.First_Response_Complete__c == false){
                                milestoneType = 'Response';
                            }
                            else{
                                milestoneType = 'Update';
                            }
                        }
                    }
                    if (!c.isEmpty()) {
                        update c;
                    }
                    if (updateCases.isEmpty() == false ){
                        if (milestoneType  == 'Response'){
                            milestoneUtils.completeMilestone(updateCases, 'Response', completionDate);
                        }
                        if (milestoneType  == 'Update'){               
                            milestoneUtils.completeMilestone(updateCases, 'Update', completionDate);
                        }
                    }
                }
            }
        }
}