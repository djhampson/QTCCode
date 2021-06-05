/**
 * File Info
 * ----------------------------------
 * @filename       CSFeedItemTriggerHandler.cls
 * @created        24.SEPT.2014
 * @author         Kristian Vegerano
 * @description    Class for FeedItem Triggers Functionalities
 */
public class CSFeedItemTriggerHandler {
    
    /**
     * @description    Handler method for after insert functionalities
     * @author         Kristian Vegerano - 24.SEPT.2014
     */
    static public void onAfterInsert(List<FeedItem> feedItemList) {
        SetNewAttachmentFlag(feedItemList);
        SetNewCommentFlag(feedItemList);
    }

    static public void onBeforeInsert(List<FeedItem> feedItemList) {
           // Cannot be a portal user
            if (UserInfo.getUserType() == 'Standard' || UserInfo.getUserType() == 'PowerPartner') {
                DateTime completionDate = System.now();
                String milestoneType = '';
                List<Id> caseIds = new List<Id>();
                for (FeedItem fi : feedItemList) {
                    if ((fi.ParentId.getSObjectType() == Case.SObjectType) &&
                        (fi.Type == 'TextPost' || fi.Type == 'LinkPost' || fi.Type == 'ContentPost') &&
                        (fi.Visibility == 'AllUsers'))
                        // Do we need to check for case feed objects shared with customer? Yes...
                            caseIds.add(fi.ParentId);
                    
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
                            // consider an outbound post to the contact on the case a valid first response
                            //if ((caseObj.Status == 'In Progress')&&
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

    /**
     * @description    Handler method for after update functionalities
     * @author         Kristian Vegerano - 24.SEPT.2014
     */
    static public void onAfterUpdate(List<FeedItem> feedItemList) {
        SetNewCommentFlag(feedItemList);
    }
    
    /**
     * @description    This method tests case comment creation on case priority change
     * @author         Kristian Vegerano - 24.SEPT.2014
     */
    static public void SetNewCommentFlag(List<FeedItem> feedItemList) {

            list <case> l_cases = new list<case>();
            set<Id> CaseIds = new set<Id>();
            
            //Code suggested by SF to avoid null object error when user is Automated Process, even though this is not a value in the picklist
            if (UserInfo.getuserType() == 'AutomatedProcess'){
                return;
            }
            
            //Determine if the user is a portal user
            User Usr = new User();
            Usr = [SELECT Id, IsPortalEnabled FROM User WHERE Id = : UserInfo.getUserId()];
            
            if (Usr.IsPortalEnabled || Test.isRunningTest()){
                for(FeedItem FedItm : feedItemList){
                    if(FedItm.Type == 'TextPost' || FedItm.Type == 'LinkPost'){
                        CaseIds.add(FedItm.ParentID);
                    }   
                } 
                
                if (!CaseIds.isEmpty()){
                    for (case [] arrCase : [SELECT Id, 
                                                    new_portal_case_comment__c,
                                                    status,
                                                    recordtype.name,
                                                    createddate
                                            FROM case 
                                            WHERE Id IN :caseIds]){       
                        for (Case sCase : arrCase){
                            // 233724 - Only update Case Flag if Case > 10 minutes old
                            if (sCase.status == 'New' && sCase.createddate > System.now().addMinutes(-10)){
                                continue;
                            }
                            else{
                                sCase.new_portal_case_comment__c = true;
                                if ((sCase.status == 'Awaiting Customer' || sCase.status == 'Resolved' || sCase.status == 'With Customer') && sCase.recordtype.name != 'I require Consulting services')
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
    
    /**
     * @description    This method tests case comment creation on case priority change
     * @author         Kristian Vegerano - 24.SEPT.2014
     */
    static public void SetNewAttachmentFlag(List<FeedItem> feedItemList) {

            list <case> l_cases = new list<case>();
            set<Id> CaseIds = new set<Id>();
            
            //Code suggested by SF to avoid null object error when user is Automated Process, even though this is not a value in the picklist
            if (UserInfo.getuserType() == 'AutomatedProcess'){
                return;
            }
            
            //Determine if the user is a portal user
            User Usr = new User();
            Usr = [SELECT Id, IsPortalEnabled FROM User WHERE Id = : UserInfo.getUserId()];
            
            if (Usr.IsPortalEnabled || Test.isRunningTest()){
                for(FeedItem FedItm : feedItemList){
                    if(FedItm.Type == 'ContentPost'){
                        CaseIds.add(FedItm.ParentID);
                    }   
                }
                
                if (!CaseIds.isEmpty()){
                    for (case [] arrCase : [SELECT Id, 
                                                    new_customer_attachment__c,
                                                    status,
                                                    recordtype.name,
                                                    createddate
                                            FROM case 
                                            WHERE Id IN :caseIds]){       
                        for (Case sCase : arrCase){
                            // 233724 - Only update Case Flag if Case > 10 minutes old
                            if (sCase.status == 'New' && sCase.createddate > System.now().addMinutes(-10)){
                                continue;
                            }
                            else{
                                sCase.new_customer_attachment__c = true;
                                if ((sCase.status == 'Awaiting Customer' || sCase.status == 'Resolved' || sCase.status == 'With Customer') && sCase.recordtype.name != 'I require Consulting services')
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
}