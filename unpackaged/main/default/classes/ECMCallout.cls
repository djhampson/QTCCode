public class ECMCallout {

    @future (callout=true)
    public static void createCustomerIndex(String sName, String sId, String sUrl, String sParams) {
        try{
            List<String> sParamList = sParams.split(',');
            String sJsonRequestBody = '{"IndexNumber": ' + sParamList.get(0) + ',"LevelNumber": ' + sParamList.get(1) + ',"IndexLevelEntryId": 0,"ParentKeyData": "","RecordEntryData": "{UserText:[\\"' + sName +'\\",\\"\\",\\"\\",\\"' + sId + '\\"],UserNumber:[],UserInteger:[],UserDate:[]}","RowVer": 0,"AuditEcmUserId": 0}';
                
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();

            request.setEndpoint('callout:ECM_Callout/WebServiceSave');
            request.setHeader('Content-Type','application/json'); 
            request.setMethod('POST');
            request.setBody(sJsonRequestBody);
            request.setCompressed(false);
             
            response = http.send(request);
            if (response.getStatusCode() == 200) {
                System.debug('Response-' + response);
            }
        }
        catch(System.CalloutException e){
            T1_Process_Log__c procLog = new T1_Process_Log__c(Process_Name__c = 'ECMCallout.createCustomerIndex',
                                      Process_Message__c = e.getMessage());
            insert procLog;
            System.debug('Error-' + e.getMessage());   
        }
    }
}