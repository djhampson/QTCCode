/*******************************************************************************************************
* Class Name      	: AsyncFrameworkUtil
* Description		: Utility class for async framework
* Author          	: Simplus - Yi Zhang
* Created On      	: 25/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              25/02/2021		1000				Initial version
* Yi Zhang              18/03/2021		1001				Added method getJobCronString
******************************************************************************************************/
public class AsyncFrameworkUtil {
    
    
    /**
    * @description Abort the job of the schedulable context
    * @author Yi Zhang | 25/02/2021 
    * @param SchedulableContext sc 
    **/
    public static void cleanUpOneOffJob(SchedulableContext sc) {
        try {
            System.abortJob(sc.getTriggerId());
        } catch(Exception e) {
            System.debug('failed to abort one-off scheduled job: ' + e.getMessage());
            insert DM_ApplicationLog.createApplicationLog(e);
        }
    }

    /**
    * @description - Get Cron String for job to be executed in X minutes (delay X minutes from current time)
    * @author Yi Zhang | 18/03/2021 
    * @param Decimal delayInMinutes 
    * @return String 
    **/
    public static String getJobCronString(Decimal delayInMinutes) {

        DateTime dateTimeForNextJob = System.now().addSeconds(Math.round(delayInMinutes * 60));
        Integer seconds     = dateTimeForNextJob.second();
        Integer minutes     = dateTimeForNextJob.minute();
        Integer hours       = dateTimeForNextJob.hour();
        Integer dayOfMonth  = dateTimeForNextJob.day();
        Integer month       = dateTimeForNextJob.month();
        return seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ?';
    }
}