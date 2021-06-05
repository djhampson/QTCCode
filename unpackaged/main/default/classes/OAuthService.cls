/*******************************************************************************************************
* Class Name      	: OAuthService
* Description		: Service layer to handle T1 OAuth requirement
* Author          	: Simplus - Abeer Qureshi
* Created On      	: 
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         		        1000				Initial version
******************************************************************************************************/
public abstract class OAuthService {
    
    private static IOAuthService service;

/*
    *@description Set access token on custom settings
    *@author Abeer Qureshi - Simplus 
    *@param OAuthResponse payload
    *@return 
*/  
    public static void setAccessToken(OAuthResponse ret){
        newInstance().setAccessToken(ret);
    }

/*
    *@description Makes api call gets oauth access token from T1 service
    *@author Abeer Qureshi - Simplus 
    *@param OAuthRequest payload
    *@return 
*/  
    public static OAuthResponse getAccessToken(OAuthRequest req){
        return newInstance().getAccessToken(req);
    }

/*
    *@description Creates new instance of service - Singleton pattern
    *@author Abeer Qureshi - Simplus 
    *@param
    *@return 
*/  
    public static IOAuthService newInstance(){
        if(service == null)
            service = new T1OAuthServiceImpl();
        return service;
    }
}