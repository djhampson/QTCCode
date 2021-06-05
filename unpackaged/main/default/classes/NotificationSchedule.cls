/*******************************************************************************************************
* Class Name      	: NotificationSchedule
* Description		: Notification Retry mechanism 
* Author          	: Simplus - Abeer Qureshi
* Created On      	: 
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         		        1000				Initial version
******************************************************************************************************/

global class NotificationSchedule implements Schedulable {

	@testVisible
	public static String CRON_EXP = '0 0 0 3 9 ? 2022';
	@testVisible
	private static Integer MINUTES					= 1; //Run every 1-2 Minutes
	private List<Id> notificationIds;

	public NotificationSchedule(){
        
	}

/*
    *@description Query failed notifications and resends them to T1 notifications endpoint
    *@author Abeer Qureshi - Simplus 
    *@param String Schedule cron job id
    *@return 
*/ 
    private static void sendNotifications(String cronId)
	{
		//Integration monitoring
		//CronTrigger ct = (CronTrigger)Util.Single([SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id =: cronId]);
        T1_Control_Settings__c CS = T1_Control_Settings__c.getOrgDefaults();
        

        DateTime lastModifiedOffset = System.now().addMinutes(Integer.valueOf(-cs.T1_Retry_Frequency__c));

        List<Notification_Log__c> toSend = [
            SELECT 
                Request_Payload__c
            FROM 
                Notification_Log__c 
            WHERE 
                Is_Success__c = false AND 
                Attempts__c < :cs.T1_Max_Attempts__c AND
                LastModifiedDate <: lastModifiedOffset 
            ORDER BY LastModifiedDate asc
            //LIMIT 50
            ];

        NotificationRequest req = new NotificationRequest();
        req.Notification = new List<NotificationModel>();

        if(toSend.size() > 0){
            Integer i = 0;
            for(Notification_Log__c l : toSend)
            {
                if (i >= cs.T1_Max_Notifications__c || i >= 50 )
                    break;
                req = (NotificationRequest)JSON.deserialize(l.Request_Payload__c, NotificationRequest.class);
                req.requestId = l.Id;
                NotificationService.notifyF(JSON.serialize(req));
                i++;
            }
        }

        try{
            NotificationSchedule s = new NotificationSchedule();

            //if last batch then reschedule based on frequency else queue schedule again for 1 min
            if(toSend.size() < cs.T1_Max_Notifications__c){
                //override
                MINUTES = Integer.valueOf(cs.T1_Retry_Frequency__c);
            }

            System.schedule('NotificationSchedule Job Scheduled For ' + System.now().addMinutes(MINUTES), getCronExp(MINUTES), s);
            System.debug(LoggingLevel.INFO, 'NotificationSchedule Job Scheduled For ' + System.now().addMinutes(MINUTES));
        } catch(System.AsyncException e){
            //Ignore as one is already scheduled.
        }

		//End previous job
		System.abortJob(cronId);
	}

    /*
    *@description Schedule interface execute method
    *@author Abeer Qureshi - Simplus 
    *@param SchedulableContext 
    *@return 
*/ 
	global void execute(SchedulableContext sc)
	{
		NotificationSchedule.sendNotifications(sc.getTriggerId());
	}

        /*
    *@description Returns cron expression for the schedule
    *@author Abeer Qureshi - Simplus 
    *@param Integer minutes 
    *@return 
*/ 
	public static String getCronExp(Integer minutes)
	{
        Datetime nr = System.now().addMinutes(minutes);

		//Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
		return '0 ' + nr.minute() + ' ' + nr.hour() + ' ' + nr.date().day() + ' ' + nr.month()+ ' ?';
	}

}