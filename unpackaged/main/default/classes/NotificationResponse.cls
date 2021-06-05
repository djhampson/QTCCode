/*******************************************************************************************************
* Class Name      	: NotificationResponse
* Description		: Model for NotificationResponse JSON Payload
* Author          	: Simplus - Abeer Qureshi
* Created On      	: 
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         		        1000				Initial version
******************************************************************************************************/
public with sharing class NotificationResponse {
    public string result {get; set;}
    public string msg {get; set;}
    public string tneid {get; set;}
    public NotificationResponse(){
        result = '';
        msg = '';
        tneid = '';
    }
}