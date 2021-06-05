public class T1OAuthServiceImpl implements IOAuthService{
    public T1OAuthServiceImpl() {

    }

    public void setAccessToken(OAuthResponse ret){
        T1_OAuth_Token__c settings = T1_OAuth_Token__c.getOrgDefaults();

        if(String.isNotBlank(ret.error))
        {
            settings.error__c = ret.error;
            settings.error_description__c = ret.error_description;
            update settings;
        } else {
            settings.access_token__c = ret.access_token;
            settings.refresh_token__c = ret.refresh_token;
            settings.error__c = null;
            settings.error_description__c = null;
            settings.Expiry__c = System.now().addSeconds(ret.expires_in);
            update settings;
        }
    }

    public OAuthResponse getAccessToken(OAuthRequest req){
        T1_Control_Settings__c CS = T1_Control_Settings__c.getOrgDefaults();
        OAuthResponse ret;
        /**
         *           
         * POST /token HTTP/1.1     
         * Host: server.example.com     
         * Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW     
         * Content-Type: application/x-www-form-urlencoded
             grant_type=client_credentials     
            &client_id=abc
            &client_secret=xYz
        */

        T1_OAuth_Token__c settings = T1_OAuth_Token__c.getOrgDefaults();
        if(settings.Expiry__c > System.now()){
            ret = new OAuthResponse();
            ret.access_token = settings.access_token__c;
            ret.refresh_token = settings.refresh_token__c;
            return ret;
        }

        HttpRequest httpReq = new HttpRequest();

        httpReq.setEndpoint(cs.T1_OAuth_Endpoint__c);
        httpReq.setHeader('Authorization', 'Bearer ' + cs.T1_OAuth_Authorization__c);
        httpReq.setMethod('POST');
        httpReq.setBody(
            //JSON.serialize(req)
            'grant_type='+req.grant_type+'&client_id='+req.client_id+'&client_secret='+req.client_secret
        );

        HttpResponse res = new Http().send(httpReq);

        if( res.getStatusCode() == 200 )
        {
            ret = (OAuthResponse)JSON.deserialize(res.getBody(), OAuthResponse.class);
        } else {
            //TOFIX IMPLEMENT THIS
        }
            return ret;
    }
}