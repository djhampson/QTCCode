/*********************************************************************************************
* @author        CLUDO - armievergara
* @date          21/8/18.
* @description   Use to send request
**********************************************************************************************/
public with sharing class APIGateway {
    public HttpRequest request;

    public APIGateway(){
        request = new HttpRequest();
    }
    /**
    * @description executes HTTP Request
    */
   public HttpResponse execute(String uri, String method, String body){
        request.setMethod(method);
        request.setEndpoint(uri);
        request.setTimeout(120000); 
        if(body != null){
            request.setHeader('Content-Type','application/json');
            request.setHeader('Content-Length', String.valueOf(body.length()));
            request.setBody(body);
        }
        HttpResponse response    = new HttpResponse();
        Http h = new Http();
        response = h.send(request);
        System.debug('Resonse Status Code:' + response.getStatusCode()) ;
        System.debug('Response BODY: ' + response.getBody()) ;
        return response;

    }

    /**
    * @description sets basic authentication for the HttpRequest called by execute method
    */
    public void addBasicAuthentication(string username, string password){
        Blob headerValue            = Blob.valueOf(username + ':' + password);
        String authorizationHeader  = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
    }
}