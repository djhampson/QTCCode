/*******************************************************************************************************
* Trigger Name     	: T1_InvoiceTrigger
* Description		: Trigger for sobject T1_Invoice__c
* Author          	: Simplus
* Created On      	: 02/03/2020
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Philip Clark          02/03/2020		1000				Initial version
******************************************************************************************************/
trigger T1_InvoiceTrigger on T1_Invoice__c (after update) {

    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            NotificationRequest req = new NotificationRequest();
            req.Notification = new List<NotificationModel>();
        
            for(T1_Invoice__c i : Trigger.new){
        
                T1_Invoice__c oi = Trigger.oldMap.get(i.Id);
        
                if((oi.InvoiceStatus__c <> i.InvoiceStatus__c || oi.Finance_Reviewed__c <> i.Finance_Reviewed__c) 
                   		&& i.InvoiceStatus__c == 'Posted' && i.Finance_Reviewed__c == TRUE){
        
                    NotificationModel tmp = new NotificationModel();
                    tmp.Notif_ID = StaticUtil.getGUUID();
                    tmp.Notif_Type = 'T1_Invoice';
                    tmp.Notif_Obj_ID = i.Id;
                    tmp.Notif_Status = 'Posted';
                    tmp.Notif_CreateDate = System.now().format('yyyy-MM-dd HH:mm:ss'); //'2020-10-10 08:30:00'
        
                    req.Notification.add(tmp);
                }
        
            }
        
            if(req.Notification.size() > 0)
                NotificationService.notifyF(JSON.serialize(req));
        }
    }
}