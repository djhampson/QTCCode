/*******************************************************************************************************
* Class Name      	: OAuthResponse
* Description		: Model for OAuthResponse JSON paylaod
* Author          	: Simplus - Abeer Qureshi
* Created On      	: 
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         		        1000				Initial version
******************************************************************************************************/
public with sharing class OAuthResponse {
    public string access_token {get; set;}
    public string token_type {get; set;}
    public integer expires_in {get; set;}
    public string refresh_token {get; set;}

    public string error {get; set;}
    public string error_description {get; set;}

    public OAuthResponse(){
        access_token = '';
        token_type = '';
        expires_in = 0;
        refresh_token = '';
        error = '';
        error_description = '';
    }
}