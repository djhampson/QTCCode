/*******************************************************************************************************
* Class Name      	: NotificationServiceTest
* Description		: Notification Service test coverage
* Author          	: Simplus - Abeer Qureshi
* Created On      	: 
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         		        1000				Initial version
******************************************************************************************************/
@isTest 
public with sharing class NotificationServiceTest {
    
    @testSetup static void setup() {
        insert new T1_Control_Settings__c(
            T1_OAuth_Endpoint__c =  'https://test.notification.url/oauth',
            Notification_URL__c = 'https://test.notification.url/notify',
            T1_Timeout_milliseconds__c = 10*1000,
            T1_Max_Attempts__c = 8,
            T1_Retry_Frequency__c = -120
        );

        insert new T1_OAuth_Token__c();
    }

    @isTest static void notifyPass(){
        NotificationRequest req = new NotificationRequest();
        req.Notification = new List<NotificationModel>();

        NotificationModel tmp = new NotificationModel();
        tmp.Notif_ID = StaticUtil.getGUUID();
        tmp.Notif_Type = 'Invoice';
        tmp.Notif_Obj_ID = 'Invoice ID';
        tmp.Notif_Status = 'Posted';
        tmp.Notif_CreateDate = System.now().format('yyyy-mm-dd HH:MM:SS'); //'2020-10-10 08:30:00'

        req.Notification.add(tmp);

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
            '	<res_msg>string</res_msg>' +
            '</QTCnotres>'
        );

        Test.setMock(HttpCalloutMock.class, new AnyServiceMockImpl());

        Test.startTest();
        NotificationService.notify(req);
        NotificationService.notifyF(Json.serialize(req));
        Test.stopTest();

    }

    @isTest static void notifyFail(){
        NotificationRequest req = new NotificationRequest();
        req.Notification = new List<NotificationModel>();

        NotificationModel tmp = new NotificationModel();
        tmp.Notif_ID = StaticUtil.getGUUID();
        tmp.Notif_Type = 'Invoice';
        tmp.Notif_Obj_ID = 'Invoice ID';
        tmp.Notif_Status = 'Posted';
        tmp.Notif_CreateDate = System.now().format('yyyy-mm-dd HH:MM:SS'); //'2020-10-10 08:30:00'

        req.Notification.add(tmp);

        Map<String,Object> r1 = (Map<String,Object>)JSON.deserializeUntyped('{        "error": "test error",        "error_description": "test error description"}');

        AnyServiceMockImpl.postResponse.put(
            '/oauth',
            r1
        );

        AnyServiceMockImpl.postResponse.put(
            '/notify',
            '<?xml version="1.0" encoding="UTF-8"?>' +
            '<QTCnotres>' +
            '	<res_result>Success</res_result>' +
            '	<res_msg>string</res_msg>' +
            '</QTCnotres>'
        );

        Test.setMock(HttpCalloutMock.class, new AnyServiceMockImpl());

        Test.startTest();
        NotificationService.notify(req);
        NotificationService.notifyF(Json.serialize(req));
        Test.stopTest();

    }

    @isTest static void modelCoverage(){
        T1_OAuth_Token__c t1ot = [select Id, expiry__c from T1_OAuth_Token__c limit 1];
        t1ot.expiry__c = System.now().addDays(1);
        update t1ot;
        new NotificationModel();
        new NotificationRequest();
        new NotificationResponse();
        OAuthRequest req = new OAuthRequest();
        OAuthResponse resp = new OAuthResponse();
        StaticUtil.Single([select id from User limit 1]);
        StaticUtil.getGUUID();
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
            '	<res_msg>string</res_msg>' +
            '</QTCnotres>'
        );

        Test.setMock(HttpCalloutMock.class, new AnyServiceMockImpl());
        T1_Control_Settings__c CS = T1_Control_Settings__c.getOrgDefaults();
        req.grant_type = 'client_credentials';
        req.client_id = cs.T1_OAuth_Client_Id__c;
        req.client_secret = cs.T1_OAuth_Client_Secret__c; 
        test.startTest();
        resp = OAuthService.getAccessToken(req);
        test.stopTest();
        //OAuthService.setAccessToken((OAuthResponse) JSON.deserialize('{        "access_token": "2YotnFZFEjr1zCsicMWpAA",        "token_type": "example",        "expires_in": 3600,        "refresh_token": "tGzv3JOkF0XG5Qx2TlKWIA"    }', OAuthResponse.class));
    }

    @isTest static void notificationScheduleCoverage(){
        
        NotificationRequest req = new NotificationRequest();
        req.Notification = new List<NotificationModel>();

        NotificationModel tmp = new NotificationModel();
        tmp.Notif_ID = StaticUtil.getGUUID();
        tmp.Notif_Type = 'Invoice';
        tmp.Notif_Obj_ID = 'Invoice ID';
        tmp.Notif_Status = 'Posted';
        tmp.Notif_CreateDate = System.now().format('yyyy-mm-dd HH:MM:SS'); //'2020-10-10 08:30:00'

        req.Notification.add(tmp);

        Notification_Log__c notifLog = new Notification_Log__c(
            Request_Payload__c = JSON.serialize(req),
            Is_Success__c = false,
            Attempts__c = 0
        );
        
        insert notifLog;
        Test.setCreatedDate(notifLog.Id, System.today().addDays(-2));
        Test.startTest();
        List<Notification_Log__c> toSend = [
            SELECT 
            Request_Payload__c,Is_Success__c,Attempts__c,LastModifiedDate
            FROM 
            Notification_Log__c
        ];
        System.debug(LoggingLevel.ERROR,'toSend => ' + toSend);
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
            '	<res_msg>string</res_msg>' +
            '</QTCnotres>'
        );

       
        Test.setMock(HttpCalloutMock.class, new AnyServiceMockImpl());
        NotificationSchedule.MINUTES = 120;
        NotificationSchedule s = new NotificationSchedule();
        System.schedule('NotificationSchedule Job Scheduled For ' + System.now().addMinutes(120), NotificationSchedule.getCronExp(120), s);

        Test.stopTest();
    }

    @isTest static void revenueScheduleTestCoverage(){
            String masterRuleName = 'Test Rev Rec Master rule';
            Date finBook1StartDate = Date.newInstance( Date.today().year(),1,1 );
            Date finBook1EndDate = Date.newInstance( Date.today().year()+4,12,31 );
            Date finBook2StartDate = Date.newInstance( Date.today().year()+5,1,1 );
            Date finBook2EndDate = Date.newInstance( Date.today().year()+9,12,31 );

            // create Revenue Recognition Rule Hierarchy for generating Revenue Schedules and transaction for 10 year Order
            List<blng__FinanceBook__c> financeBooks = new List<blng__FinanceBook__c>();
            financeBooks.add( TestUtility.createFinanceBook( 'Test Rev Book1','Monthly','Revenue') );
            financeBooks.add( TestUtility.createFinanceBook( 'Test Rev Book2','Monthly','Revenue') );
            insert financeBooks;

            // create legal entity
            blng__LegalEntity__c legalEntity = TestUtility.createLegalEntity();
            insert legalEntity;

            // create Revenue Distribution Method
            blng__RevenueDistributionMethod__c revDistributedMethod = TestUtility.createRevenueDistributionMethod();
            insert revDistributedMethod;

            // insert GL Rule
            blng__GLRule__c glRule = TestUtility.createGLRule();
            insert glRule;

            // create Master Revenue Recognitionn Rule
            blng__RevenueRecognitionRule__c masterRevScheduleCreateRule = TestUtility.createRevRecRule (masterRuleName,true,null,null,null);
            insert masterRevScheduleCreateRule;

            // crete Child Revc Rec Rules with FinancialPeriods information
            List<blng__RevenueRecognitionRule__c> childRuleList = new List<blng__RevenueRecognitionRule__c>();
            Date finStartDate = finBook1StartDate;
            Date finEndDate = finBook1EndDate;
            childRuleList.add( TestUtility.createRevRecRule ('Test Rev Rec Rule 1',true,masterRevScheduleCreateRule.Id,finStartDate,finEndDate ) );
            finStartDate = finBook2StartDate;
            finEndDate  = finBook2EndDate;
            childRuleList.add( TestUtility.createRevRecRule ('Test Rev Rec Rule 2',true,masterRevScheduleCreateRule.Id,finStartDate,finEndDate) );

            // create 'No Revenue' rule
            childRuleList.add( TestUtility.createRevRecRule ('No Revenue',true,null,null,null) );
            insert childRuleList;

            // insert Rule treatments for 2 child rules
            List<blng__RevenueRecognitionTreatment__c> treatmentList = new List<blng__RevenueRecognitionTreatment__c>();
            treatmentList.add( TestUtility.createRevRecognitionTreatment('Test Rev Rec Treatment 1',childRuleList[0].ID,financeBooks[0].Id,legalEntity.Id,revDistributedMethod.Id,glRule.Id) );
            treatmentList.add( TestUtility.createRevRecognitionTreatment('Test Rev Rec Treatment 2',childRuleList[1].ID,financeBooks[1].Id,legalEntity.Id,revDistributedMethod.Id,glRule.Id) );
            insert treatmentList;

            // insert Billing Rule
            blng__BillingRule__c  billRule = TestUtility.createBillingRule();
            insert billRule;

            //insert Tax Rule
            blng__TaxRule__c taxRule = TestUtility.createTaxRule();
            insert taxRule;

        blng__RevenueSchedule__c rs =  new blng__RevenueSchedule__c(
            blng__RevenueRecognitionTreatment__c = treatmentList[0].id,
            blng__TotalRevenueAmount__c = 100,
            blng__RevenueStartDate__c = System.today()+5,
            blng__RevenueEndDate__c = System.today()+35
            );

        insert rs;

        rs.blng__RevenueTransactionStatus__c = 'Complete';

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
            '	<res_msg>string</res_msg>' +
            '</QTCnotres>'
        );

        Test.setMock(HttpCalloutMock.class, new AnyServiceMockImpl());

        Test.startTest();
        update rs;
        Test.stopTest();
    }
    //NotificationServiceTest

}