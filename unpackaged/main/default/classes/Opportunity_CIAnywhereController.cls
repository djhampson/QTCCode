/******************************************************************************************************
* @author        CLUDO - armievergara
* @date          21/8/18
* @description   server side controller class used by Lightning bundle OpportunituCIAnywhere component
*******************************************************************************************************/
public with sharing class Opportunity_CIAnywhereController {

    public static final String CI_PROCESSTYPE =  '$ETL';
    public static final String CI_SFREQUEST_PROCESSNAME =  'SF_REQUEST_REPORT';

    public class RequestTypeWrapper{
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String description;
        public RequestTypeWrapper(string val, string description){
            this.value = val;
            this.description = description;
        }
    }
    /********************************************************************************************
       @Description : Sets available request type to be generated
        TO ADD - add RequestTypeWrapper object to the list with the following parameter
        new RequestTypeWrapper([VALUE],[DESCRIPTION - dropdown label])
    *******************************************************************************************/
    @AuraEnabled
    public static List<RequestTypeWrapper> setRequestTypes(){
        List<RequestTypeWrapper> requestTypes = new List<RequestTypeWrapper>();
        requestTypes.add(new RequestTypeWrapper('Synopsis','Generate Synopsis'));
        requestTypes.add(new RequestTypeWrapper('Quote','Generate Quote'));
        requestTypes.add(new RequestTypeWrapper('Product Split','Generate Product Split'));
        /*
        UNCOMMENT TO MAKE THE REQUEST TYPES AVAILABLE
        requestTypes.add(new RequestTypeWrapper('Ping','Sends a test email message only'));
        //requestTypes.add(new RequestTypeWrapper('Consulting Service Request','Generate Consulting Service Request'));
        //requestTypes.add(new RequestTypeWrapper('Consulting Activity Report','Generate Consulting Activity Report'));
        //requestTypes.add(new RequestTypeWrapper('SaaS Synopsis','Generate SaaS Synopsis'));
        //requestTypes.add(new RequestTypeWrapper('SaaS Quote','Generate SaaS Quote'));
        */
        return requestTypes;
    }

    /********************************************************************************************
      @Description : method that calls the webservice
      @inputs:
      @param: opportunityID -
      @param: reportType
      @outputs: jobID
    *******************************************************************************************/
    @AuraEnabled
    public static String submitToCI(string opportunityID, string reportType){
        String jobID = '';
        try {System.debug(opportunityID);
            //Opportunity opp = [Select Name from Opportunity where id=:opportunityID];
            List<CIAnywhere_SubmitDTO.PresetVariableValuesWrapper> variableValues = new List<CIAnywhere_SubmitDTO.PresetVariableValuesWrapper>();
            variableValues.add(new CIAnywhere_SubmitDTO.PresetVariableValuesWrapper('EMAIL', UserInfo.getUserEmail()));
            variableValues.add(new CIAnywhere_SubmitDTO.PresetVariableValuesWrapper('SF_ID', opportunityID));
            variableValues.add(new CIAnywhere_SubmitDTO.PresetVariableValuesWrapper('REQTYPE', reportType));
            CIAnywhereAPI cianywhere = new CIAnywhereAPI();
            HttpResponse response = cianywhere.submit(CI_PROCESSTYPE, CI_SFREQUEST_PROCESSNAME, variableValues);
            if (response.getStatusCode() < 400) {
                CIAnywhere_SubmitDTO.Response responseBody = (CIAnywhere_SubmitDTO.Response) JSON.deserialize(response.getBody(), CIAnywhere_SubmitDTO.Response.class);
                if (responseBody.DpJobId != null) {
                    jobID = responseBody.DpJobId;
                }
            }
        }catch (Exception ex){
            System.debug('Error:'+ ex.getMessage());
        }
        return jobID;
    }






}