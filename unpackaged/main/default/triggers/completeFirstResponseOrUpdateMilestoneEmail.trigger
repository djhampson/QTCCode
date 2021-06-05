trigger completeFirstResponseOrUpdateMilestoneEmail on EmailMessage (before insert) {

    // bypass trigger processing START
    T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
    
    if( s.Bypass_Triggers__c) return; // skip trigger...
    // bypass trigger processing END

    try{
        String accountId;
            
        // set IsExternallyVisible 
        for (EmailMessage em : Trigger.new){
            if (em.IsExternallyVisible == false){
                List<Case> caseList = [Select c.Id, c.ContactId, c.Contact.Email, c.AccountId
                            From Case c where c.Id = :em.ParentId and c.Contact.Email <> null limit 1];
                if (caseList.isEmpty()==false){
                    for (Case caseObj:caseList) {
                        // build the list of email domains for Account Contacts
                        Set<String> emDomains = new Set<String>();
                        Integer intIndex = 0;
                        Integer intLength = 0;
                        String sEmailDomain = '';
                        if (caseObj.AccountId != null){
                            List<Contact> contList = [Select c.Email
                            From Contact c where c.AccountId = :caseObj.AccountId and c.Email <> null];
                            if (contList.isEmpty()==false){
                                for (Contact contObj:contList) {
                                    intIndex = contObj.Email.indexOf('@');
                                    intLength = contObj.Email.length();
                                    sEmailDomain = contObj.Email.substring(intIndex, intLength);
                                    system.debug('Email domain = ' + sEmailDomain);
                                    emDomains.add(sEmailDomain);
                                }
                            }
                        }
                        
                        //Now check if any of the addresses contain one of the email domains
                        if (emDomains.Size() > 0){
                            for (String sDom:emDomains){
                                if ((em.toAddress != null && em.toAddress.containsIgnoreCase(sDom)) || 
                                    (em.fromAddress != null && em.fromAddress.containsIgnoreCase(sDom)) ||
                                    (em.ccAddress != null && em.ccAddress.containsIgnoreCase(sDom)) ||
                                    (em.BccAddress != null && em.BccAddress.containsIgnoreCase(sDom))
                                    ){
                                    em.IsExternallyVisible = true;
                                    break;
                                }                    
                            }
                        }
                        
                        /*if ((em.toAddress != null && em.toAddress.containsIgnoreCase(sEmailDomain)) || 
                            (em.fromAddress != null && em.fromAddress.containsIgnoreCase(sEmailDomain)) ||
                            (em.ccAddress != null && em.ccAddress.containsIgnoreCase(sEmailDomain)) ||
                            (em.BccAddress != null && em.BccAddress.containsIgnoreCase(sEmailDomain))
                            ){
                            em.IsExternallyVisible = true;	
                        }*/
                    }
                }
            }
        }
                    
                        
        // Process milestones if necessary
        // Cannot be a portal user
        if (UserInfo.getUserType() == 'Standard' || UserInfo.getUserType() == 'PowerPartner'){
            DateTime completionDate = System.now();
            String milestoneType = '';
            Map<Id, String> emIds = new Map<Id, String>();
            Map<Id, String> emIdsSubject = new Map<Id, String>();
            for (EmailMessage em : Trigger.new){
                if(em.Incoming == false){
                    if (em.CcAddress == null)
                        emIds.put(em.ParentId, em.ToAddress);
                    else
                        emIds.put(em.ParentId, em.ToAddress + ' ' + em.CcAddress);
                    emIdsSubject.put(em.ParentId, em.Subject);
                }
            }
            if (emIds.isEmpty() == false){
                Set <Id> emCaseIds = new Set<Id>();
                emCaseIds = emIds.keySet();
                List<Case> caseList = [Select c.Id, c.ContactId, c.Contact.Email, c.AccountId,
                                c.OwnerId, c.Status,
                                c.EntitlementId,
                                c.SlaStartDate,
                                c.SlaExitDate,
                                c.First_Response_Complete__c, 
                                c.New_Customer_Attachment__c,
                                c.New_Customer_Email__c,
                                c.New_Portal_Case_Comment__c
                            From Case c where c.Id IN :emCaseIds];
                if (caseList.isEmpty()==false){
                    List<Id> updateCases = new List<Id>();
                    List <case> c = new list<case>();
                    for (Case caseObj:caseList) {
                        Boolean isCustomerContact = false;
                        Boolean isCaseContact = false;
                        //Process the Email recipients
                        String toAddress = emIds.get(caseObj.Id);
                        String subject = emIdsSubject.get(caseObj.Id);
                        Set<String> accountSet =new Set<String>();
                        accountSet.add(caseObj.AccountId); 
                        //check if Address contains a Customer Contact
                        For(List<Contact> contacts : [SELECT Name, Email From Contact WHERE AccountId in: accountSet ]){
                            for(Contact contactObj : contacts){
                                if (toAddress != null && contactObj.Email != null && toAddress.containsIgnoreCase(contactObj.Email)){
                                    isCustomerContact = true;
                                }
                            }
                        }
                        // consider an outbound email to the contact on the case a valid first response
                        if (toAddress != null && caseObj.Contact.Email != null && toAddress.containsIgnoreCase(caseObj.Contact.Email))
                            isCaseContact = true;
                        
                        if (isCustomerContact == true || isCaseContact == true){ 
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
                        }
                        if (isCaseContact == true){ 
                            if ((caseObj.EntitlementId != null)&&
                            (caseObj.SlaStartDate <= completionDate)&&
                            (caseObj.SlaStartDate != null)&& 
                            (caseObj.SlaExitDate == null)
                                ){
                                updateCases.add(caseObj.Id);
                                if (caseObj.First_Response_Complete__c == false)
                                    milestoneType = 'Response';
                                else
                                    milestoneType = 'Update';
                                if (subject != null && subject.containsIgnoreCase('Quote for Consulting services')){
                                        milestoneType = 'Provide Quote';
                                    }
                            }
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
                        if (milestoneType  == 'Provide Quote')
                            milestoneUtils.completeMilestone(updateCases, 'Provide Quote', completionDate);
                        
                    }
                }
            }
        }
    }
    catch(Exception e) {
        Integer iLen = e.getMessage().Length();
        String sErr = e.getMessage();
        if(iLen > 254){
            sErr = sErr.left(254);
        }
        T1_Process_Log__c procLog = new T1_Process_Log__c(Process_Name__c = 'completeFirstResponseOrUpdateMilestoneEmail',
            Process_Message__c = sErr);
        insert procLog;
    }   
}