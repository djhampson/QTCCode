/*******************************************************************************************************
* @Class Name   : T1_InvoiceTrigger_Test
* @description  : Test class for T1_InvoiceTrigger
* @author       : Philip Clark
* @date         : 10/03/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Philip Clark          10/03/2021      1000        Initial version
******************************************************************************************************/
@isTest
public class T1_InvoiceTrigger_Test {


    @isTest
    public static void testT1InvoiceNotificationService(){
        
        // create Notification Service test data
        insert new T1_Control_Settings__c(
            T1_OAuth_Endpoint__c =  'https://test.notification.url/oauth',
            Notification_URL__c = 'https://test.notification.url/notify',
            T1_Max_Attempts__c = 8,
            T1_Retry_Frequency__c = 120
        );

        insert new T1_OAuth_Token__c();
        
        // create Account
        Account testAccount = TestUtility.createAccount('Test Account');
        insert testAccount;
        // create T1 Invoice
        T1_Invoice__c t1i = TestUtility.createT1Invoice(testAccount.Id);
        insert t1i;
        
        Map<String,Object> r1 = (Map<String,Object>)JSON.deserializeUntyped('{        "access_token": "2YotnFZFEjr1zCsicMWpAA",        "token_type": "example",        "expires_in": 3600,        "refresh_token": "tGzv3JOkF0XG5Qx2TlKWIA"    }');

        AnyServiceMockImpl.postResponse.put(
            '/oauth',
            r1
        );

        AnyServiceMockImpl.postResponse.put(
            '/notify',
            '<?xml version="1.0" encoding="UTF-8"?>' +
            '<QTCnotres>' +
            '	<res_result>Success</res_result>' +
            '	<res_msg></res_msg>' +
            '	<tne_id>870c59fd-ebf7-f4b3-8b66-c8057f8f3dac</tne_id>' +
            '</QTCnotres>'
        );

        Test.setMock(HttpCalloutMock.class, new AnyServiceMockImpl());
        
        Test.startTest();
        t1i.ApprovalStatus__c = 'Approved';
        t1i.InvoiceStatus__c = 'Posted';
        t1i.Finance_Reviewed__c = TRUE;
        update t1i;
        Test.stopTest();
        
        list<Notification_Log__c> nl = [select Id, TNE_ID__c from Notification_Log__c];
        system.AssertEquals(1,nl.size());
        system.AssertEquals('870c59fd-ebf7-f4b3-8b66-c8057f8f3dac',nl[0].TNE_ID__c);

    }


}