/*******************************************************************************************************
* Class Name      	: NotificationRequest
* Description		: Model for NotificationRequest JSON Payload
* Author          	: Simplus - Abeer Qureshi
* Created On      	: 
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         		        1000				Initial version
******************************************************************************************************/
public with sharing class NotificationRequest {
    public id requestId {get; set;}
    public List<NotificationModel> Notification {get; set;}

    public NotificationRequest(){
        Notification = new List<NotificationModel>();
    }
}