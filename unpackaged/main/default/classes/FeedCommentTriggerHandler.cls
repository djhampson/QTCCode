public class FeedCommentTriggerHandler {

    static public void onAfterInsert(List<FeedComment> aComments) {

            list <case> l_cases = new list<case>();
            set<Id> CaseIds = new set<Id>();
            
            //Determine if the user is a portal user
            User Usr = new User();
            Usr = [SELECT Id, IsPortalEnabled FROM User WHERE Id = : UserInfo.getUserId()];
            
            if (Usr.IsPortalEnabled || Test.isRunningTest()){
                for (FeedComment f : aComments){
                    CaseIds.add(f.ParentID);
                } 
                
                if (!CaseIds.isEmpty()){
                    for (case [] arrCase : [SELECT Id, 
                                                    new_portal_case_comment__c,
                                                    status,
                                                    createddate
                                            FROM case 
                                            WHERE Id IN :caseIds for update]){       
                        for (Case sCase : arrCase){
                            // 233724 - Only update Case Flag if Case > 10 minutes old
                            if (sCase.status == 'New' && sCase.createddate > System.now().addMinutes(-10)){
                                continue;
                            }
                            else{
                                sCase.new_portal_case_comment__c = true;
                                if (sCase.status == 'Awaiting Customer' || sCase.status == 'Resolved' || sCase.status == 'With Customer')
                                {
                                    sCase.status = 'In Progress';
                                }
                                l_cases.add(sCase);
                            }
                        }
                    }   
                }   
                if (!l_cases.isEmpty()){
                    update l_cases;
                }
            }
    }

    static public void onBeforeInsert(List<FeedComment> aComments) {

            // Cannot be a portal user
            if (UserInfo.getUserType() == 'Standard' || UserInfo.getUserType() == 'PowerPartner') {
                DateTime completionDate = System.now();
                String milestoneType = '';
                List<Id> caseIds = new List<Id>();
                for (FeedComment fi : aComments) {
                    if (fi.ParentId.getSObjectType() == Case.SObjectType) {
                        List<FeedItem> postIds = [Select p.Id
                            From FeedItem p
                            Where p.Id = :fi.FeedItemId
                            and (p.Type = 'TextPost' or p.Type = 'LinkPost' or p.Type = 'ContentPost') 
                            and p.Visibility = 'AllUsers'];                     
                            
                        if (postIds.IsEmpty() == false){
                            caseIds.add(fi.ParentId);
                        }
                    }
                }
                if (caseIds.isEmpty() == false){
                    List<Case> caseList = [Select c.Id, c.ContactId, c.Contact.Email,
                                        c.OwnerId, c.Status,
                                        c.EntitlementId, c.SlaStartDate,
                                        c.SlaExitDate,
                                        c.First_Response_Complete__c, 
                                        c.New_Customer_Attachment__c,
                                        c.New_Customer_Email__c,
                                        c.New_Portal_Case_Comment__c
                                        From Case c
                                        Where c.Id IN :caseIds];
                    if (caseList.isEmpty() == false){
                        List<Id> updateCases = new List<Id>();
                        List <case> c = new list<case>();
                        for (Case caseObj:caseList) {
                            // consider an Case Feed Comment made by staff member to be a valid first response
                            //if ((caseObj.Status == 'In Progress') &&
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
                            if  ((caseObj.EntitlementId != null)&&
                                (caseObj.SlaStartDate <= completionDate)&&
                                (caseObj.SlaStartDate != null)&&
                                (caseObj.SlaExitDate == null)){
                                    updateCases.add(caseObj.Id);
                                    if (caseObj.First_Response_Complete__c == false)
                                        milestoneType = 'Response';
                                    else
                                        milestoneType = 'Update';
                                }
                        }
                        if (!c.isEmpty()) {
                            update c;
                        }
                        if (updateCases.isEmpty() == false ){
                            if (milestoneType  == 'Response')
                                milestoneUtils.completeMilestone(updateCases, 'Response', completionDate);
                            if (milestoneType  == 'Update')               
                                milestoneUtils.completeMilestone(updateCases, 'Update', completionDate);
                            
                        }
                    }
                }
            }
    }

 
        
}