/*******************************************************************************************************
* Class Name      	: OAuthRequest
* Description		: Model for OAuthRequest JSON paylaod
* Author          	: Simplus - Abeer Qureshi
* Created On      	: 
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         		        1000				Initial version
******************************************************************************************************/
public with sharing class OAuthRequest {
    public string client_id {get; set;}
    public string grant_type {get; set;}
    public string client_secret {get; set;}

    public OAuthRequest(){
        client_id = '';
        grant_type = '';
        client_secret = '';
    }   
}