trigger CS_Set_new_customer_attachment_flag on Attachment (after insert) 
{

    // bypass trigger processing START
    T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
     
    if( s.Bypass_Triggers__c) return; // skip trigger...
    // bypass trigger processing END
 
    list <case> l_cases = new list<case>();
    set<Id> caseIds = new set<Id>();
    
    //Determine if the user is a portal user
    User Usr = new User();
    Usr = [SELECT Id, IsPortalEnabled FROM User WHERE Id = : UserInfo.getUserId()];
    
    if (Usr.IsPortalEnabled || Test.isRunningTest()){
        
        //Obtain the Case Id's
        for(attachment attach : Trigger.new)
        {
            caseIds.add(attach.ParentID);   
        }
        
        if (!caseIds.isEmpty())
        {
            for (case [] arrCase : [ select Id, 
                                            new_customer_attachment__c,
                                            status,
                                            recordtype.name,
                                    		createddate
                                       from case 
                                      where Id IN :caseIds])
            {       
                for (Case sCase : arrCase)
                {
                    // 233724 - Only update Case Flag if Case > 10 minutes old
                    if (sCase.status == 'New' && sCase.createddate > System.now().addMinutes(-10)){
                        continue;
                    }
                    else{
                        sCase.new_customer_attachment__c = true;
                        if ((sCase.status == 'Awaiting Customer' || sCase.status == 'Resolved' || sCase.status == 'With Customer') &&  sCase.recordtype.name != 'I require Consulting services')
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