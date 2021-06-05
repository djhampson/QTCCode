public class ContDocLinkTriggerHandler {

    static public void onAfterInsert(contentDocumentLink[] newCdls) {

        list <case> l_cases = new list<case>();
        set<Id> caseIds = new set<Id>();
        
        set<Id> cdlIds = new set<Id>(); 
        
        //Determine if the user is a portal user
        User Usr = new User();
        Usr = [SELECT Id, IsPortalEnabled FROM User WHERE Id = : UserInfo.getUserId()];
        
        if (Usr.IsPortalEnabled || Test.isRunningTest()){
            
            String netId = Network.getNetworkId();
            
            //Obtain the Case Id's
            for(contentDocumentLink contDL : newCdls)
            {
                if (String.valueOf(contDL.LinkedEntityId).startsWith('500')){ // it's a Case
                    caseIds.add(contDL.LinkedEntityId);
                    cdlIds.add(contDL.Id); 
                }
                if (String.valueOf(contDL.LinkedEntityId).startsWith('02s')){ // it's an EmailMessage
                    cdlIds.add(contDL.Id);  
                }
            }
            
            if (!caseIds.isEmpty())
            {
                for (Case arrCase : [ select Id, 
                                                new_customer_attachment__c,
                                                status,
                                                recordtype.name,
                                                createddate
                                           from case 
                                          where Id IN :caseIds])
                { 
                    //22/5/19 Remove unnecessary for loop using second Case list
                    // 233724 - Only update Case Flag if Case > 10 minutes old
                    if (arrCase.status == 'New' && arrCase.createddate > System.now().addMinutes(-10)){
                        continue;
                    }
                    else{
                        arrCase.new_customer_attachment__c = true;
                        if ((arrCase.status == 'Awaiting Customer' || arrCase.status == 'Resolved' || arrCase.status == 'With Customer') &&  arrCase.recordtype.name != 'I require Consulting services')
                        {
                            arrCase.status = 'In Progress';
                        }
                        l_cases.add(arrCase);
                    }

                }   
            } 
            if (!l_cases.isEmpty()){
                update l_cases;
            }
            
            // CR 246359 - Stop creation of Community share as users can access via Search and User Profile, not just via Case            
            // CR 246359 - 4/6/19 Reinstated call as the called class now shares with specific user
            if (!cdlIds.isEmpty()){
                ContDocShare.processShare(cdlIds, netId);
            } 

        }

        Try{
            //Only run this if we are a full user
            if (UserInfo.getUserType() == 'Standard'){
                list <contentDocumentLink> l_contDL = new list<contentDocumentLink>();
                String orgId = UserInfo.getOrganizationId();
                // Make all Documents linked to Cases and Email Messages (File attachments) visible by all users
                for(contentDocumentLink contDL : newCdls){
                    if (String.valueOf(contDL.LinkedEntityId).startsWith('500') || String.valueOf(contDL.LinkedEntityId).startsWith('02s')){ // '500' = Case, '02s' = EmailMessage
                        // 22/5/19 Remove inner select to avoid 'Too many sql queries' error
                        //List<contentDocumentLink> checkOrgId = [select id from contentDocumentLink
                        //        where contentDocumentId = :contDL.ContentDocumentId and LinkedEntityId = :orgId limit 1];        
                        //if (checkOrgId.size() == 0){ // does not exist
                            contentDocumentLink cdl = new contentDocumentLink();
                            cdl.ContentDocumentId = contDL.ContentDocumentId;
                            cdl.LinkedEntityId = orgId;
                            cdl.ShareType = contDL.ShareType;
                            cdl.Visibility = contDL.Visibility;
                            l_contDL.add(cdl);
                        //}
                    }
                }
                
                if (l_contDL.size() > 0){
                     insert l_contDL;
                }
            }
        }
        catch(Exception e) {
                if(!e.getMessage().contains('already linked')){
                    T1_Process_Log__c procLog = new T1_Process_Log__c(Process_Name__c = 'ContDocLink AfterInsert',
                        Process_Message__c = e.getMessage());
                    insert procLog;
                }
        }     

    }

    static public void onBeforeInsert(contentDocumentLink[] newCdls) {
        // Make all Documents linked to Cases and Email Messages (File attachments) visible by all users
        for(contentDocumentLink contDL : newCdls){
            if (String.valueOf(contDL.LinkedEntityId).startsWith('500') || String.valueOf(contDL.LinkedEntityId).startsWith('02s')){ // '500' = Case, '02s' = EmailMessage
                if (contDL.Visibility <> 'AllUsers'){
                    contDL.Visibility = 'AllUsers';
                }
            }
        }
    }

 
}