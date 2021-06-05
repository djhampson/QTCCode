/*******************************************************************************************************
* Class Name      	: T1NotificationServiceImpl
* Description		: Implementation for T1 notifications 
* Author          	: Simplus - Abeer Qureshi
* Created On      	: 
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         		        1000				Initial version
******************************************************************************************************/
public class T1NotificationServiceImpl implements INotificationService {

    public class NotImplementedException extends Exception{}

    public T1NotificationServiceImpl() {

    }

    public static void notifyF(String req)
    {
        throw new NotImplementedException();
    }

/*
    *@description Makes api call to send notification to T1
    *@author Abeer Qureshi - Simplus 
    *@param NotificationRequest payload
    *@return 
*/ 
    public NotificationResponse notify(NotificationRequest req){
        T1_Control_Settings__c CS = T1_Control_Settings__c.getOrgDefaults();
        NotificationResponse ret = new NotificationResponse();

        HttpRequest httpReq = new HttpRequest();

        httpReq.setEndpoint(cs.Notification_URL__c);
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setMethod('POST');
        if(CS.T1_Timeout_milliseconds__c != null)
        	httpReq.setTimeout(integer.valueOf(CS.T1_Timeout_milliseconds__c));
        httpReq.setBody(
            JSON.serialize(req)
        );


        T1_OAuth_Token__c settings = T1_OAuth_Token__c.getOrgDefaults();

        OAuthResponse oauthres;

        if(settings.Expiry__c > System.now()){
            httpReq.setHeader('Authorization', 'Bearer ' + settings.access_token__c);
        } else {
            oauthres = getAccessToken();
        }
        
        HttpResponse res;
        
        try {
        	res = new Http().send(httpReq);
        } catch(System.CalloutException e) {
            System.debug(LoggingLevel.Info, 'CalloutException');
            System.debug(LoggingLevel.Info, e.getMessage());
            ret.msg = e.getMessage();
            logRequest(req, ret, null);
            return ret;
        }

        if( res.getStatusCode() == 200 )
        {
            DOM.Document doc = res.getBodyDocument();
            
            for(Dom.XmlNode fluxChildNode: doc.getRootElement().getChildElements()) 
            {
                
                if(fluxChildNode.getName() == 'res_result') {
                    ret.result = fluxChildNode.getText().trim();
                }
                if(fluxChildNode.getName() == 'res_msg') {
                    ret.msg = fluxChildNode.getText().trim();
                }
                if(fluxChildNode.getName() == 'tne_id') {
                    ret.tneid = fluxChildNode.getText().trim();
                }
            }
            
        } else {
            ret = new NotificationResponse();
        }
        
        System.debug(LoggingLevel.Info, 'Response');
        System.debug(LoggingLevel.Info, ret);
        
        if(oauthres != null){
            OAuthService.setAccessToken(oauthres);
        }
        
        logRequest(req, ret, res);
        
        return ret;
    }

/*
    *@description Makes api call to get access token from T1
    *@author Abeer Qureshi - Simplus 
    *@param 
    *@return 
*/ 
    private OAuthResponse getAccessToken()
    {
        T1_Control_Settings__c CS = T1_Control_Settings__c.getOrgDefaults();

        OAuthRequest req = new OAuthRequest();
        req.grant_type = 'client_credentials';
        req.client_id = cs.T1_OAuth_Client_Id__c;
        req.client_secret = cs.T1_OAuth_Client_Secret__c;        

        return OAuthService.newInstance().getAccessToken(req);
    }

/*
    *@description logs request in notification log
    *@author Abeer Qureshi - Simplus 
    *@param NotificationRequest to log request paylaod 
    *@param NotificationResponse to log response payload
    *@param HttpResponse to log http response code and error message
    *@return 
*/     
    private void logRequest(NotificationRequest req, NotificationResponse res, HttpResponse httpRes){
        Notification_Log__c l;

        if(req.requestId <> null)
            l = (Notification_Log__c)StaticUtil.Single([select Attempts__c from Notification_Log__c where id =: req.requestId]);
		
        upsert new Notification_Log__c(
            Id = req.requestId,
            Request_Payload__c = JSON.serializePretty(req),
            Response_Payload__c = JSON.serializePretty(res),
            Is_Success__c = (res.result != null && res.result.toLowerCase().contains('success') ? true : false),
            Http_Status__c = (httpRes != null ? String.valueOf(httpRes.getStatusCode()) : ''),
            Http_Error__C = (httpRes != null && httpRes.getStatusCode() != 200 ? httpRes.getBody() : ''),
            TNE_ID__c = res.tneid,
            Attempts__c = (l <> null) ? l.Attempts__c + 1 : 1,
            Response_Time__c = System.now()
        );
    }

}