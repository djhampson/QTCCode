/*******************************************************************************************************
* Class Name      	: NotificationService
* Description		: Service layer to send T1 
* Author          	: Simplus - Abeer Qureshi
* Created On      	: 
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         		        1000				Initial version
******************************************************************************************************/

public class NotificationService implements INotificationService{
    private static INotificationService service;

    public NotificationService() {

    }

/*
    *@description Makes api call to send notification to T1
    *@author Abeer Qureshi - Simplus 
    *@param NotificationRequest payload
    *@return 
*/  
    public static NotificationResponse notify(NotificationRequest req){
        return newInstance().notify(req);
    }


/*
    *@description Makes api call to send notification to T1
    *@author Abeer Qureshi - Simplus 
    *@param Serialized NotificationRequest payload
    *@return 
*/  
    @future(Callout=true)
    public static void notifyF(String req)
    {
        newInstance().notify((NotificationRequest)Json.deserialize(req,NotificationRequest.class));
    }

/*
    *@description Creates new instance of service - Singleton pattern
    *@author Abeer Qureshi - Simplus 
    *@param
    *@return 
*/ 
    public static INotificationService newInstance(){
        if(service == null)
            service = new T1NotificationServiceImpl();
        return service;
    }

}