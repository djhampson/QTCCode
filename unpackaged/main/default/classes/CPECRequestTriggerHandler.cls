/**
     CPECRequestTrigger Handler
 */
public class CPECRequestTriggerHandler {

   static public void onAfterInsert(CPEC_Request__c[] newRecs) {
        createDefaults(newRecs);
    }

    static public void onBeforeInsert(CPEC_Request__c[] newRecs) {

        /* for(CPEC_Request__c newReqs : newRecs){
            if (String.IsBlank(newReqs.Requester__c)){
                newReqs.Requester__c = UserInfo.getUserId();
            }
        } */
    }

    static public void onBeforeUpdate(CPEC_Request__c[] updatedRecs, Map<ID, CPEC_Request__c> oldMap) {
    }
    
    static public void onAfterUpdate(CPEC_Request__c[] updatedRecs, Map<ID, CPEC_Request__c> oldMap) {
    }

    static public void createDefaults(CPEC_Request__c[] newRecs) {
    
        list <CRC_Request_Action__c> l_ReqActions = new list<CRC_Request_Action__c>(); 
        list <CRC_Request_Approval__c> l_ReqApps = new list<CRC_Request_Approval__c>();
        Map<ID,CRC_Request_Action_Settings__c> mapActions = new Map<ID,CRC_Request_Action_Settings__c>(
            [ SELECT Action_Description__c, Applies_to_Request_Type__c, Assigned_To__c
                                                                , Due_in_Days__c, Instructions__c
                                                                 FROM CRC_Request_Action_Settings__c]); 
        Map<ID,CRC_Request_Approval_Settings__c> mapApps = new Map<ID,CRC_Request_Approval_Settings__c>(
            [ SELECT Approval_Level__c, Endorser__c FROM CRC_Request_Approval_Settings__c]); 
 
        for(CPEC_Request__c newReqs : newRecs){
            // Create the default Actions
            for(CRC_Request_Action_Settings__c rASs : mapActions.values()){
                if(rASs.Applies_to_Request_Type__c.contains(newReqs.Request_Type__c)){
                    CRC_Request_Action__c reqAct = new CRC_Request_Action__c();
                    reqAct.Assigned_To__c = rASs.Assigned_To__c;
                    reqAct.Action__c = rASs.Action_Description__c;
                    reqAct.Instructions__c = rASs.Instructions__c;
                    reqAct.CRC_Request__c = newReqs.Id;
                    if (rASs.Due_in_Days__c != null && rASs.Due_in_Days__c > 0){
                        reqAct.Due_Date__c = system.today().addDays(rASs.Due_in_Days__c.intValue());
                    }
                    l_ReqActions.add(reqAct);
                }
 

            }
            if(newReqs.Approval_Level__c.contains('Level 6')){
                CRC_Request_Action__c reqAct = new CRC_Request_Action__c();
                //reqAct.Assigned_To__c = newReqs.Requester__c;
                reqAct.Action__c = 'Gain approval from your RM/RCD';
                reqAct.CRC_Request__c = newReqs.Id;
                l_ReqActions.add(reqAct);
            }

            // Create the default Approvals
            for(CRC_Request_Approval_Settings__c rApps : mapApps.values()){
                if(rApps.Approval_Level__c.contains(newReqs.Approval_Level__c)){
                    CRC_Request_Approval__c reqApp = new CRC_Request_Approval__c();
                    reqApp.Endorser__c = rApps.Endorser__c;
                    reqApp.CRC_Request__c = newReqs.Id;
                    l_ReqApps.add(reqApp);
                }
           }
        } 
  
        if (!l_ReqActions.isEmpty()){
            insert l_ReqActions;
        }   
        if (!l_ReqApps.isEmpty()){
            insert l_ReqApps;
        }
    }
    

}