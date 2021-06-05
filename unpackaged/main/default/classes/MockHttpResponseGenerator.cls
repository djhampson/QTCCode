/*********************************************************************************************
* @author         Cludo - armievergara
* @date           22/8/18.
* @description:   implementation for the HttpCalloutMock interface to specify the response sent in the respond method
                  which the Apex runtime calls to send a response for a callout.
* @Version:
**********************************************************************************************/


public with sharing class MockHttpResponseGenerator implements HttpCalloutMock {
    protected Integer code;
    protected String body;
    public MockHttpResponseGenerator(Integer code, String resourceName) {
        StaticResource res = [SELECT Id, Body FROM StaticResource WHERE Name = :resourceName] ;

        this.body = res.body.toString();
        System.debug(this.body);
        this.code = code;
    }
   public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(this.body);
        res.setStatus(code==200?'OK':'Error');
        res.setStatusCode(this.code);
        return res;
    }

}