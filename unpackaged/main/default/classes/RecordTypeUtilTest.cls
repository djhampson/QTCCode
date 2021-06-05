@isTest
private class RecordTypeUtilTest {

    @isTest static void getRecordTypeIdByNameTest() {
        RecordType opportunityRecordType = [select Id, Name, SobjectType from RecordType where SobjectType = 'Opportunity' and Name = 'Licence Fee'];

        Test.startTest();
        Id returnedRecTypeId = RecordTypeUtil.getRecordTypeIdByName(Opportunity.SObjectType, opportunityRecordType.Name);
        Test.stopTest();

        System.assertEquals(opportunityRecordType.Id, returnedRecTypeId);
    }
    
    @isTest static void getRecordTypeIdByNameNegativeTest() {
        Test.startTest();
        Id returnedRecTypeId = RecordTypeUtil.getRecordTypeIdByName(Opportunity.SObjectType, 'NegativeName');
        Test.stopTest();

        System.assertEquals(null, returnedRecTypeId);
    }

    @isTest static void getRecordTypeNameByIdTest() {
        RecordType opportunityRecordType = [select Id, Name, SobjectType from RecordType where SobjectType = 'Opportunity' and Name = 'Licence Fee'];

        Test.startTest();
        String returnedRecTypeName = RecordTypeUtil.getRecordTypeNameById(Opportunity.SObjectType, opportunityRecordType.Id);
        Test.stopTest();

        System.assertEquals(opportunityRecordType.Name, returnedRecTypeName);
    }
    @isTest static void getRecordTypeNameById_NegativeTest() {
        RecordType opportunityRecordType = [select Id, Name, SobjectType from RecordType where SobjectType = 'Opportunity' and Name = 'Licence Fee'];

        Test.startTest();
        String returnedRecTypeName = RecordTypeUtil.getRecordTypeNameById(Account.SObjectType, opportunityRecordType.Id);
        Test.stopTest();

        System.assertEquals(null, returnedRecTypeName);
    }

    @isTest static void getRecordTypeByNameTest() {
        RecordType opportunityRecordType = [select Id, Name, SobjectType from RecordType where SobjectType = 'Opportunity' and Name = 'Licence Fee'];

        Test.startTest();
        Schema.RecordTypeInfo returnedRecType = RecordTypeUtil.getRecordTypeByName(Opportunity.SObjectType, opportunityRecordType.Name);
        Test.stopTest();

        System.assertEquals(opportunityRecordType.Name, returnedRecType.getName());
    }

    @isTest static void getRecordTypeByIdTest() {
        RecordType opportunityRecordType = [select Id, Name, SobjectType from RecordType where SobjectType = 'Opportunity' and Name = 'Licence Fee'];

        Test.startTest();
        Schema.RecordTypeInfo returnedRecType = RecordTypeUtil.getRecordTypeById(Opportunity.SObjectType, opportunityRecordType.Id);
        Test.stopTest();

        System.assertEquals(opportunityRecordType.Id, returnedRecType.getRecordTypeId());
    }
    
    @isTest static void getRecordTypeByIdNegativeTest() {
        RecordType opportunityRecordType = [select Id, Name, SobjectType from RecordType where SobjectType = 'Opportunity' and Name = 'Licence Fee'];

        Test.startTest();
        Schema.RecordTypeInfo returnedRecType = RecordTypeUtil.getRecordTypeById(Account.SObjectType, opportunityRecordType.Id);
        Test.stopTest();

        System.assertEquals(null, returnedRecType);
    }

}