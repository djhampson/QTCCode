/**
 * Created by armievergara on 23/8/18.
 */

@IsTest
private class Opportunity_CIAnywhereControllerTest {
    static testMethod void setRequestTypesTestMethod() {
        Test.startTest();
        List<Opportunity_CIAnywhereController.RequestTypeWrapper> requestTypes = Opportunity_CIAnywhereController.setRequestTypes();
        Test.stopTest();
        System.assertEquals(true,!requestTypes.isEmpty());
    }

    static testMethod void submitToCI_Positive() {
        ID RType = RecordTypeUtil.getRecordTypeIdByName(Opportunity.SObjectType, 'Licence Fee');
        Opportunity opp = TestDataBuilder.createOpportunities(1,true,RType)[0];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200,'CIAnywhereSubmitResponse_Positive'));
        Test.startTest();
        String jobID = Opportunity_CIAnywhereController.submitToCI(opp.Id, 'Ping');
        Test.stopTest();
        System.assertEquals(true, jobID!='');

    }

    static testMethod void submitToCI_NegativeIntegrationException() {
        ID RType = RecordTypeUtil.getRecordTypeIdByName(Opportunity.SObjectType, 'Licence Fee');
        Opportunity opp = TestDataBuilder.createOpportunities(1,true,RType)[0];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400,'CIAnywhereSubmitResponse_Negative'));
        Test.startTest();
        String jobID = Opportunity_CIAnywhereController.submitToCI(opp.Id, 'Ping');
        Test.stopTest();
        System.assertEquals(false, jobID!='');
    }

    static testMethod void submitToCI_NegativeUnhandledExption() {
        ID RType = RecordTypeUtil.getRecordTypeIdByName(Opportunity.SObjectType, 'Licence Fee');
        Opportunity opp = TestDataBuilder.createOpportunities(1,true,RType)[0];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400,'CIAnywhereSubmitResponse_Negative'));
        Test.startTest();
        String jobID = Opportunity_CIAnywhereController.submitToCI(null, 'Ping');
        Test.stopTest();
        System.assertEquals(false, jobID!='');
    }


}