/**
 * Created by armievergara on 21/8/18.
 */

public with sharing class CIAnywhereAPI {
    public static final String CI_METHOD_URL =  '/Api/WS/v1/ETLProcessCi/CiSubmit';
    public APIGateway apiGateway = new APIGateway();
    public CiAnywhereSetting__c ciAnywhereCustomSettings = CiAnywhereSetting__c.getInstance();

    public CIAnywhereAPI(){
        apiGateway.addBasicAuthentication(ciAnywhereCustomSettings.Username__c, ciAnywhereCustomSettings.Password__c);
    }


    public HttpResponse submit(string processType, string processName, List<CIAnywhere_SubmitDTO.PresetVariableValuesWrapper> variableValues) {
        CIAnywhere_SubmitDTO.Request submitRequest = new CIAnywhere_SubmitDTO.Request();
        submitRequest.ProcessType = processType;
        submitRequest.ProcessName = processName;
        submitRequest.PresetVariableValues = variableValues;
        string requestInJSON = (String) JSON.serializePretty(submitRequest, true);
        System.debug(requestInJSON);
        String uri = ciAnywhereCustomSettings.Host_URL__c + CI_METHOD_URL;
        String encodedURL = EncodingUtil.urlEncode(uri, 'UTF-8');
        return apiGateway.execute(uri, 'POST', requestInJSON);
    }
}