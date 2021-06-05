global class casePIIPurge implements
   Database.Batchable<sObject>,Database.Stateful{

   public Integer numAttachments=0;
   public Integer numEmail=0;
   public Integer numCases=0;
   public Integer numFiles=0;
   public Integer numComments=0;
   public Integer numPosts=0;
   Integer retentionDays=90; 
          
   global Database.QueryLocator start(Database.BatchableContext BC){

        T1_Control_Settings__c custs = T1_Control_Settings__c.getOrgDefaults();
        if (custs.PII_Content_Retention_Days__c <> NULL){
            retentionDays = Integer.valueOf(custs.PII_Content_Retention_Days__c);
        }

        DateTime thedate = System.now().addDays(retentionDays * -1);
        String thedateS = thedate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String query = 'select id, CaseNumber, Status, ClosedDate, Last_Status_Change__c, (select CreatedDate, NewValue, OldValue from histories where field = \'Status\' order by CreatedDate Desc limit 1) from Case where closeddate < ' + thedateS + ' and Status = \'Closed\' and high_or_extreme_pii_data__c = true';

        if(Test.isRunningTest())
            query = 'select id, CaseNumber, Status, ClosedDate, Last_Status_Change__c, (select CreatedDate, NewValue, OldValue from histories where field = \'Status\' order by CreatedDate Desc limit 1) from Case where Status = \'Closed\' limit 10';

        return Database.getQueryLocator(query);
   } 
   
   global void execute(
                Database.BatchableContext BC, 
                List<sObject> scope){
 
        // ensure triggers, workflow and validation rules are deactivated          
        T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
        s.Bypass_Triggers__c = true;
        s.Bypass_Validation_Rules__c = true;
        s.Bypass_Workflow__c = true;
        s.Customer_Community_URL__c = '';
        s.Employee_Community_URL__c = '';
        s.Internal_URL__c = '';
        s.Closed_Date_for_Archiving_Email__c = null;
        try{
            update s;         
        }catch(exception e){}
                    
        Set<Id> CaseIds = new Set<Id>();
        Set<Id> AttachmentIds = new Set<Id>();
        Set<Id> AttachmentIds2 = new Set<Id>();
        Set<Id> AttachmentIds3 = new Set<Id>();
        Set<Id> ContentDocumentLinkIds = new Set<Id>();
        Set<Id> ContentDocumentIds = new Set<Id>();
        Set<Id> ContDocIdsToDelete = new Set<Id>();
        Set<Id> EmailIds = new Set<Id>();
        Set<Id> TaskIds = new Set<Id>();
        Set<Id> GoogleDocIds = new Set<Id>();

        List<Case> casesToUpd = scope;
        Integer theCount = 0;
                    
        //Build set of case ids
        for (Case updCase : casesToUpd) {
            //system.debug('Case ' + updCase.CaseNumber + ' Status ' + updCase.Status);
            for (CaseHistory caseHistory : updCase.histories) {
                if (caseHistory.NewValue == 'Closed') // ensure the last status change was to Closed
                    CaseIds.add(updCase.Id);
            }
        }    
        
        if (CaseIds.size() == 0) {  
            T1_Process_Log__c procLog = new T1_Process_Log__c(Process_Name__c = 'CasePIIPurge',
                Process_Message__c = 'No Cases to process.');
            insert procLog;
            return;
        } 
                    
        numCases += Integer.valueOf(CaseIds.size()); 
        system.debug('No of CaseIds ' + CaseIds.size());
        String toProcess = 'All';
        String actionType = 'Delete';
 
        if (toProcess == 'All' || toProcess == 'Email')  {   
            //process email, should cascade delete the attachments
            //Try{
                for (EmailMessage email : [Select Id From EmailMessage where parentid in :CaseIds]) {
                    EmailIds.add(email.id);
                }
                system.debug('No of EmailIds ' + EmailIds.size());
                            
                if (EmailIds.size() > 0){
                    list<EmailMessage> emList = [Select id from EmailMessage where Id in :EmailIds];
                    if (actionType == 'Delete'){
                        delete emList;
                        //DataBase.emptyRecycleBin(emList);
                    }
                    system.debug('Email to delete - ' + emList.size());
                }
                numEmail += Integer.valueOf(EmailIds.size());
                
            /*} catch(Exception e) {
                T1_Process_Log__c procLog = new T1_Process_Log__c(Process_Name__c = 'CaseContentPurge',
                    Process_Message__c = e.getMessage().substring(0,254));
                insert procLog;
            }     */
            //process tasks/activity
            //Try{
                for (Task tsk : [Select Id From Task where whatid in :CaseIds and isClosed = True and Type = 'Email' and TaskSubType = 'Email']) {
                    TaskIds.add(tsk.id);
                }
                system.debug('No of TaskIds ' + TaskIds.size());
                            
                if (TaskIds.size() > 0){
                    list<Task> tskList = [Select id from Task where Id in :TaskIds];
                    if (actionType == 'Delete'){
                        delete tskList;
                        //DataBase.emptyRecycleBin(tskList);
                    }
                    system.debug('Tasks to delete - ' + tskList.size());
                }
                //numEmail = Integer.valueOf(TaskIds.size());
                
            /*} catch(Exception e) {
                T1_Process_Log__c procLog = new T1_Process_Log__c(Process_Name__c = 'CaseContentPurge',
                    Process_Message__c = e.getMessage().substring(0,254));
                insert procLog;
            }  */   
        }

        if (toProcess == 'All' || toProcess == 'Attachments')  {        
            //process attachments on Cases
            theCount = 0;
            //Try{
                for (Attachment attach : [Select Id From Attachment where parentid in :CaseIds]) {
                    theCount++;
                    if (theCount < 10000){
                        AttachmentIds.add(attach.id);
                    }
                    if (theCount > 9999 && theCount < 20000){
                        AttachmentIds2.add(attach.id);
                    }                    
                    if (theCount > 19999 && theCount < 30000){
                        AttachmentIds3.add(attach.id);
                    }                    
                }
                system.debug('No of AttachmentIds ' + AttachmentIds.size());
                            
                if (attachmentIds.size() > 0){
                    list<Attachment> attlist = [Select id from Attachment where Id in :AttachmentIds];
                    if (actionType == 'Delete'){
                        delete attList;
                        //DataBase.emptyRecycleBin(attList);
                    }
                    system.debug('Attachments to delete - ' + attList.size());
                    numAttachments += Integer.valueOf(AttachmentIds.size());
                }
                if (attachmentIds2.size() > 0){
                    list<Attachment> attlist2 = [Select id from Attachment where Id in :AttachmentIds2];
                    if (actionType == 'Delete'){
                        delete attList2;
                        //DataBase.emptyRecycleBin(attList2);
                    }
                    system.debug('Attachments to delete - ' + attList2.size());
                    numAttachments += Integer.valueOf(AttachmentIds2.size());
                }
                if (attachmentIds3.size() > 0){
                    list<Attachment> attlist3 = [Select id from Attachment where Id in :AttachmentIds3];
                    if (actionType == 'Delete'){
                        delete attList3;
                        //DataBase.emptyRecycleBin(attList3);
                    }
                    system.debug('Attachments to delete - ' + attList3.size());
                    numAttachments += Integer.valueOf(AttachmentIds3.size());
                }
                
            
            /*} catch(Exception e) {
                T1_Process_Log__c procLog = new T1_Process_Log__c(Process_Name__c = 'CaseContentPurge',
                    Process_Message__c = e.getMessage().substring(0,254));
                insert procLog;
            }   */ 
        }
       
        if (toProcess == 'All' || toProcess == 'Files')  {        
            //process files on Cases
            //Try{
                // process the links between Case and Files
                for (ContentDocumentLink doclink : [Select Id, ContentDocumentId From ContentDocumentLink where LinkedEntityId in :CaseIds]) {
                    ContentDocumentLinkIds.add(doclink.id); // build the list of links to be deleted
                    ContentDocumentIds.add(doclink.ContentDocumentId); //build the list of files involved in links
                }
                system.debug('No of ContentDocumentLinkIds ' + ContentDocumentLinkIds.size());
                            
                if (ContentDocumentLinkIds.size() > 0){
                    list<ContentDocumentLink> docLinklist = [Select id from ContentDocumentLink where Id in :ContentDocumentLinkIds];
                    if (actionType == 'Delete'){
                        delete docLinkList;
                        //DataBase.emptyRecycleBin(docLinkList);
                    }
                    system.debug('Content Document (File) Links to delete - ' + docLinklist.size());
                }
                //now process the files themselves
                for (ContentDocument contentDoc : [Select Id, (select id, linkedentityid from contentdocumentlinks) From ContentDocument where Id in :ContentDocumentIds]) {
                    if (contentDoc.contentdocumentlinks.size() == 0){
                        ContDocIdsToDelete.add(contentDoc.id);
                        continue;
                    }
                    else {
                        for (ContentDocumentLink docLinkDoc : contentDoc.contentdocumentlinks) {
                            if (contentDoc.contentdocumentlinks.size() == 1 && String.valueof(docLinkDoc.linkedentityid).startsWith('005')){
                                ContDocIdsToDelete.add(contentDoc.id);
                                break;
                            }
                        }
                    }
                }
                system.debug('No of ContentDocumentIds ' + ContDocIdsToDelete.size());
                            
                if (ContDocIdsToDelete.size() > 0){
                    list<ContentDocument> contDoclist = [Select id from ContentDocument where Id in :ContDocIdsToDelete];
                    if (actionType == 'Delete'){
                        delete contDoclist;
                        //DataBase.emptyRecycleBin(contDoclist);
                    }
                    system.debug('Content Document (File) to delete - ' + contDoclist.size());
                }                
                
                numFiles += Integer.valueOf(ContentDocumentLinkIds.size());
            
            /*} catch(Exception e) {
                T1_Process_Log__c procLog = new T1_Process_Log__c(Process_Name__c = 'CaseContentPurge',
                    Process_Message__c = e.getMessage().substring(0,254));
                insert procLog;
            }    */
        }

        /*if (toProcess == 'All' || toProcess == 'Comment')  {   
            //process case comments
            //Try{
                for (CaseComment comment : [Select Id From CaseComment where parentid in :CaseIds]) {
                    CommentIds.add(comment.id);
                }
                system.debug('No of CommentIds ' + CommentIds.size());
                            
                if (CommentIds.size() > 0){
                    list<CaseComment> cList = [Select id from CaseComment where Id in :CommentIds];
                    if (actionType == 'Delete'){
                        delete cList;
                        //DataBase.emptyRecycleBin(emList);
                    }
                    system.debug('Comment to delete - ' + cList.size());
                }
                numComments += Integer.valueOf(CommentIds.size());
        } */    
        
   }

   global void finish(Database.BatchableContext BC){
       AsyncApexJob a = 
           [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems //, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =
            :BC.getJobId()];
       
       
       // Send an email to the Apex job's submitter 
       //   notifying of job completion. 
       //   
       /*
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Batch Case Content Purge Status: ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       */
       T1_Process_Log__c procLog = new T1_Process_Log__c(Process_Name__c = 'CasePIIPurge',
           Process_Message__c = 'The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
       insert procLog;

       T1_Process_Log__c procLog2 = new T1_Process_Log__c(Process_Name__c = 'CasePIIPurge',
            Process_Message__c = 'Cases - ' + numCases + ', Email - ' + numEmail + ', Attachments - ' + numAttachments + ', Files - ' + numFiles);
        insert procLog2;

       // Now reset the bypass values        
       T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
       s.Bypass_Triggers__c = false;
       s.Bypass_Validation_Rules__c = false;
       s.Bypass_Workflow__c = false;
       s.Customer_Community_URL__c = '';
       s.Employee_Community_URL__c = '';
       s.Internal_URL__c = '';
       s.Closed_Date_for_Archiving_Email__c = null;
       try{
           update s;         
        }catch(exception e){}
       
   }
}