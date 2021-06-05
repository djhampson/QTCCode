/*******************************************************************************************************
* Class Name      	: AnyServiceMockImpl
* Description		: Mocking call-outs for unit tests
* Author          	: Simplus - Abeer Qureshi
* Created On      	: 
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         		        1000				Initial version
******************************************************************************************************/
@isTest
global class AnyServiceMockImpl implements HttpCalloutMock {

    @TestVisible
    public static map<String, Object > getResponse = new map<String, Object >{};

    @TestVisible
    public static map<String, Object > postResponse = new map<String, Object >{};

    @TestVisible
    public static map<String, Object > putResponse = new map<String, Object >{};

/*
    *@description Main method to recieve request and return a mock response
    *@author Abeer Qureshi - Simplus 
    *@param HTTPRequest
    *@return HTTPResponse
*/  
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        if(req.getMethod() == 'GET')
            res.setBody(getRequestMockResponse(req.getEndpoint()));

        if(req.getMethod() == 'POST')
            res.setBody(postRequestMockResponse(req.getEndpoint(), req.getBody()));

        if(req.getMethod() == 'PUT')
            res.setBody(putRequestMockResponse(req.getEndpoint()));


        res.setStatusCode(200);
        return res;
    }

/*
    *@description Finds a mock response based on put endpoint
    *@author Abeer Qureshi - Simplus 
    *@param String endpoint
    *@return String response JSON
*/
    private String putRequestMockResponse(String endpoint){
        for (String key : putResponse.keySet()){
            if (endpoint.contains(key)){
                return JSON.serialize(putResponse.get(key));
            }
        }
        throw new ApplicationException('Invalid request');
    }

/*
    *@description Finds a mock response based on get endpoint
    *@author Abeer Qureshi - Simplus 
    *@param String endpoint
    *@return String response JSON
*/
    private String getRequestMockResponse(String endpoint){
        for (String key : getResponse.keySet()){
            if (endpoint.contains(key)){
                return JSON.serialize(getResponse.get(key));
            }
        }
        throw new ApplicationException('Invalid request');
    }

/*
    *@description Finds a mock response based on post endpoint
    *@author Abeer Qureshi - Simplus 
    *@param String endpoint
    *@param String requestBody
    *@return String response JSON
*/
    private String postRequestMockResponse(String endpoint, String requestBody){

        for (String key : postResponse.keySet()){
            if (endpoint.contains(key)){
                if(postResponse.get(key) instanceof string)
                    return (string)postResponse.get(key);

                return JSON.serialize(postResponse.get(key));
            }
        }

    	throw new ApplicationException('Invalid request');
    }

/*
    *@description Tries to deserialize request body into the request type
    *@author Abeer Qureshi - Simplus 
    *@param String requestBody
    *@param System.Type soType
    *@return Object response of System.Type
*/    
    private Object tryParse(String requestBody, System.Type soType){
    	try { 
    		return JSON.deserialize(requestBody, soType); 
    	} catch (Exception ex) {
    		return null;
    	}
    }

    public class ApplicationException extends Exception {}
}