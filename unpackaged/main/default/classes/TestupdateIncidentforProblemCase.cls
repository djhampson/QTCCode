@isTest
public class TestupdateIncidentforProblemCase {
/*    
    public static testmethod void testRelatedCases() {
        Id problemRecordTypeID = [Select Id from RecordType where sObjectType = 'Case' and DeveloperName ='Problem'].Id;
        System.debug(problemRecordTypeID);

        Id incidentRecordTypeID = [Select Id from RecordType where sObjectType = 'Case' and DeveloperName ='Incident'].Id;
        System.debug(problemRecordTypeID);
        
        Account ac = new Account();
        ac.type = 'Customer';
        ac.CountryArea__c = 'Australia';
        ac.Vertical_Market__c = 'Education';
        ac.T1_Industry__c = 'Other';
        ac.Name = 'Test Account';
        insert ac;
        
        Contact con = new Contact();
        con.AccountId = ac.id;
        con.LastName = 'Test Contact';
        insert con;
        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true];
        
        Case c = new Case();
        c.AccountId = ac.id;
        c.ContactId = con.id;
        c.RecordTypeId = problemRecordTypeID;
        c.CurrencyIsoCode = 'AUD';
        c.BusinessHoursId = bhs.id;
        c.Status = 'New';
        insert c;
        
        List<Case> children = new List<Case>();
        for (integer i = 0; i < 3; i++) {
            Case child = new case();
            child.AccountId = ac.id;
            child.ContactId = con.id;
            child.CurrencyIsoCode = 'AUD';
            child.BusinessHoursId = bhs.id;
            child.Problem_Cases__c = c.id;
            child.Status = 'New';
            children.add(child);
        }
        insert children;
        
        // insert new incident
        Case c2 = new Case();
        c2.AccountId = ac.id;
        c2.ContactId = con.id;
        c2.RecordTypeId = incidentRecordTypeID;
        c2.CurrencyIsoCode = 'AUD';
        c2.BusinessHoursId = bhs.id;
        //c2.Created_From_Case__C = c.id;
        c2.Status = 'New';
        insert c2;

        // insert new problem for incident
        Case c3 = new Case();
        c3.AccountId = ac.id;
        c3.ContactId = con.id;
        c3.RecordTypeId = problemRecordTypeID;
        c3.CurrencyIsoCode = 'AUD';
        c3.BusinessHoursId = bhs.id;
        c3.Created_From_Case__C = c2.id;
        c3.Status = 'New';
        insert c3;
                
        c = [select id, Number_of_Related_Cases__c from Case where id = :c.id];
        System.assertEquals(3, c.Number_of_Related_Cases__c);
        
        children[0].Problem_Cases__c = null;
        update children[0];
        c = [select id, Number_of_Related_Cases__c from Case where id = :c.id];
        System.assertEquals(2, c.Number_of_Related_Cases__c);
        
        delete children[2];
        c = [select id, Number_of_Related_Cases__c from Case where id = :c.id];
        System.assertEquals(1, c.Number_of_Related_Cases__c);

        delete children[1];
        c = [select id, Number_of_Related_Cases__c from Case where id = :c.id];
        System.assertEquals(0, c.Number_of_Related_Cases__c);
    }
    */
}