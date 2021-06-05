/*******************************************************************************************************
* Class Name      	: IOAuthService
* Description		: OAuth Service Interface
* Author          	: Simplus - Abeer Qureshi
* Created On      	: 
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         		        1000				Initial version
******************************************************************************************************/
public interface IOAuthService {
    OAuthResponse getAccessToken(OAuthRequest req);
    void setAccessToken(OAuthResponse ret);
}