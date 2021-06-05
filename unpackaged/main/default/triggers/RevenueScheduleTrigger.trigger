/*******************************************************************************************************
* Trigger Name     	: RevenueScheduleTrigger
* Description		: Trigger for sobject blng__RevenueSchedule__c
* Author          	: Simplus - Abeer Qureshi
* Created On      	: 23/12/2020
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         23/12/2020		1000				Initial version
******************************************************************************************************/
trigger RevenueScheduleTrigger on blng__RevenueSchedule__c (after update) {
//blng__RevenueTransactionStatus__c
    NotificationRequest req = new NotificationRequest();
    req.Notification = new List<NotificationModel>();

    for(blng__RevenueSchedule__c s : Trigger.new){

        blng__RevenueSchedule__c os = Trigger.oldMap.get(s.Id);
        
        string statusString = s.Transaction_Update_Timestamp__c != null ? 'Update' : 'Complete';

        if((os.blng__RevenueTransactionStatus__c <> s.blng__RevenueTransactionStatus__c && s.blng__RevenueTransactionStatus__c == 'Complete') ||
          (s.blng__RevenueTransactionStatus__c == 'Complete' && os.Transaction_Update_Timestamp__c <> s.Transaction_Update_Timestamp__c && s.Transaction_Update_Timestamp__c != null)){

        	NotificationModel tmp = new NotificationModel();
            tmp.Notif_ID = StaticUtil.getGUUID();
            tmp.Notif_Type = 'RevenueSchedule';
            tmp.Notif_Obj_ID = s.Id;
            tmp.Notif_Status = statusString;
            tmp.Notif_CreateDate = System.now().format('yyyy-MM-dd HH:mm:ss'); //'2020-10-10 08:30:00'

            req.Notification.add(tmp);
        }
    }

    if(req.Notification.size() > 0)
        NotificationService.notifyF(JSON.serialize(req));

}