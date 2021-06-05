/**
 * Created by armievergara on 23/8/18.
 */

@IsTest
private class CIAnywhere_SubmitDTOTest {
    static testMethod void requestObject() {
        string expectedStringValue = 'test';
        CIAnywhere_SubmitDTO.Request requestObj = new  CIAnywhere_SubmitDTO.Request();
        requestObj.ProcessType = expectedStringValue;
        requestObj.ProcessName = expectedStringValue;
        requestObj.PresetVariableValues.add(new  CIAnywhere_SubmitDTO.PresetVariableValuesWrapper('TestVar','TestValue'));

        System.assertEquals(expectedStringValue, requestObj.ProcessType);
        System.assertEquals(expectedStringValue, requestObj.ProcessName);
        System.assertEquals(1, requestObj.PresetVariableValues.size());
    }

    static testMethod void responseObject() {
        string expectedStringValue = 'test';
        CIAnywhere_SubmitDTO.Response responseObj = new  CIAnywhere_SubmitDTO.Response();
        responseObj.ProcessType = expectedStringValue;
        responseObj.ProcessName = expectedStringValue;

        System.assertEquals(expectedStringValue, responseObj.ProcessType);
        System.assertEquals(expectedStringValue, responseObj.ProcessName);
    }


}