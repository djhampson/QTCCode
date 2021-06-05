/*******************************************************************************************************
* Class Name      	: CreditNoteTrigger
* Description		: Trigger for Credit Note object
* Author          	: Simplus - Philip Clark
* Created On      	: 17/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Philip Clark          17/02/2021		1000				Initial version
* Sakshi Chauhan        05/03/2021		2000				Initial version
******************************************************************************************************/
trigger CreditNoteTrigger on blng__CreditNote__c (after update) {

    T1_CreditNoteTriggerHandler.processCreditNoteForRevRecognition( Trigger.oldMap,Trigger.newMap );
    NotificationRequest req = new NotificationRequest();
    req.Notification = new List<NotificationModel>();

    for(blng__CreditNote__c c : Trigger.new){

        blng__CreditNote__c oc = Trigger.oldMap.get(c.Id);

        if(oc.Approval_Status__c <> c.Approval_Status__c && c.Approval_Status__c == 'Approved'){

            NotificationModel tmp = new NotificationModel();
                tmp.Notif_ID = StaticUtil.getGUUID();
                tmp.Notif_Type = 'CreditNote';
                tmp.Notif_Obj_ID = c.Id;
                tmp.Notif_Status = 'Approved';
                tmp.Notif_CreateDate = System.now().format('yyyy-MM-dd HH:mm:ss'); //'2020-10-10 08:30:00'
    
                req.Notification.add(tmp);
            }
    }
	
    system.debug('CreditNoteTrigger: notification log size '+req.Notification.size());
    if(req.Notification.size() > 0)
        NotificationService.notifyF(JSON.serialize(req));

}