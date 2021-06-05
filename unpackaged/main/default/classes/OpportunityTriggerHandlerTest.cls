@isTest(SeeAllData=true)
public  class OpportunityTriggerHandlerTest 
{

    static List<PricebookEntry> createPriceBookRecords(){
        // Create a new product
        Product2 p1= TestDataBuilder.initializeProduct('Financials', 'Financials', 'Product',true);
        Product2 p2= TestDataBuilder.initializeProduct('Enterprise Cash Receipting', 'Enterprise Cash Receipting', 'Product',true);
        Product2 p3= TestDataBuilder.initializeProduct('Student Management', 'Student Management', 'Product',true);
        Product2 p4= TestDataBuilder.initializeProduct('Property', 'Property', 'Product',true);

        Pricebook2 pb = [select id from Pricebook2 where isStandard=true limit 1];
        //Pricebook2 pb = new Pricebook2(name='PriceBook', IsActive=true, Description='Test');
        //insert pb;

        // Create a pricebook entry
        PricebookEntry pbe1 = TestDataBuilder.initializeProductPricebook(pb.id, p1.id,true);
        PricebookEntry pbe2 = TestDataBuilder.initializeProductPricebook(pb.id, p2.id,true);
        PricebookEntry pbe3 = TestDataBuilder.initializeProductPricebook(pb.id, p3.id,true);
        PricebookEntry pbe4 = TestDataBuilder.initializeProductPricebook(pb.id, p4.id,true);
        List<PricebookEntry> pricebooks = new List<PricebookEntry>();
        pricebooks.add(pbe1);
        pricebooks.add(pbe2);
        pricebooks.add(pbe3);
        pricebooks.add(pbe4);
        return pricebooks;
    }
    static User getSysAdmin(){
        Profile p = [select id from profile where name='System Administrator' limit 1];
        User u = new User(alias = 'sysadmin', email='sysadmin@technologyonecorp.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_AU', profileid = p.Id,
                timezonesidkey='Australia/Brisbane', username='sysadmin@technologyonecorp.com');
        return  u;
    }
    static Opportunity setOpp(Opportunity o, Account acc){
        o.Name = 'Opportunity Test 1';
        o.AccountId = acc.Id;
        o.CurrencyIsoCode = 'AUD';
        o.CloseDate = date.today();
        o.Solution__c = 'OneEducation';
        o.Overview__c = 'ABCD';
        o.type='Existing Business';
        o.ConsultingS_Required__c='No';
        o.No_Consulting_Reason__c= 'Uplift/Add User';
        o.Licence_Model__c ='Perpetual';
        o.LeadSource = 'Web';
        o.Win_Price_Customer_Budget__c=10000;
        return o;
    }

 
    static testmethod void opportunityTestsWhenSolutionExistsT1() {
        Account acc= TestDataBuilder.createAccounts(1, true)[0];
        ID RType = RecordTypeUtil.getRecordTypeIdByName(Opportunity.SObjectType, 'Licence Fee');
        Opportunity o = TestDataBuilder.createOpportunities(1, false, RType)[0];
        setOpp(o,acc);
        insert o;

        List<PricebookEntry> entries = createPriceBookRecords();
        System.runas(getSysAdmin())
        {
            System.debug('Starting Test');
                    
            //add line
            OpportunityLineItem line1 = new OpportunityLineItem(opportunityId=o.id, quantity=1, UnitPrice=100, PricebookEntryId=entries[0].id);
            insert line1;
            
            OpportunityLineItem line1t = [Select id, opportunityid, quantity, unitPrice from OpportunityLineItem 
                                            where id =: line1.id];
            Opportunity ot = [Select id, amount from Opportunity
                                where id =: line1t.opportunityid];                                  
            
            System.assertEquals(1,line1t.quantity);
            System.assertEquals(100, line1t.unitPrice);
            System.assertEquals(100, ot.amount);
        }
    }

    static testmethod void opportunityTestsWhenSolutionExistsT2() {
        Account acc= TestDataBuilder.createAccounts(1, true)[0];
        ID RType = RecordTypeUtil.getRecordTypeIdByName(Opportunity.SObjectType, 'Licence Fee');
        Opportunity o = TestDataBuilder.createOpportunities(1, false, RType)[0];
        setOpp(o,acc);
        insert o;

        List<PricebookEntry> entries = createPriceBookRecords();
        System.runas(getSysAdmin())
        {
            System.debug('Starting Test');
                    
            //add lines
            OpportunityLineItem line1 = new OpportunityLineItem(opportunityId=o.id, quantity=2, UnitPrice=100, PricebookEntryId=entries[0].id);
            OpportunityLineItem line2 = new OpportunityLineItem(opportunityId=o.id, quantity=1, UnitPrice=100, PricebookEntryId=entries[1].id);
    
            List<OpportunityLineItem> lines = new List<OpportunityLineItem>();
            lines.add(line1);
            lines.add(line2);
            insert lines;
            
            List<OpportunityLineItem> linesT = [Select id, opportunityid, quantity, unitPrice from OpportunityLineItem 
                                            where opportunityid =: o.id
                                            order by unitPrice desc];                       
            Opportunity ot = [Select id, amount from Opportunity
                                where id =: o.id];  
        
            System.assertEquals(2,linesT.size());
            System.assertEquals(100, linesT.get(0).unitPrice);
            System.assertEquals(100, linesT.get(1).unitPrice);
            System.assertEquals(300, ot.amount);
        }
    }
    
    static testmethod void opportunityTestsWhenSolutionExistsT3(){
        Account acc= TestDataBuilder.createAccounts(1, true)[0];

        ID RType = RecordTypeUtil.getRecordTypeIdByName(Opportunity.SObjectType, 'Licence Fee');
        Opportunity o = TestDataBuilder.createOpportunities(1, false, RType)[0];
        setOpp(o,acc);
        insert o;

        List<PricebookEntry> entries = createPriceBookRecords();

            //add lines
        OpportunityLineItem line1 = new OpportunityLineItem(opportunityId=o.id, quantity=1, UnitPrice=200, PricebookEntryId=entries[0].id);
        OpportunityLineItem line2 = new OpportunityLineItem(opportunityId=o.id, quantity=1, UnitPrice=100, PricebookEntryId=entries[1].id);
        OpportunityLineItem line3 = new OpportunityLineItem(opportunityId=o.id, quantity=1, UnitPrice=100, PricebookEntryId=entries[2].id);
        OpportunityLineItem line4 = new OpportunityLineItem(opportunityId=o.id, quantity=1, UnitPrice=100, PricebookEntryId=entries[3].id);
    
        List<OpportunityLineItem> lines = new List<OpportunityLineItem>();
        lines.add(line1);
        lines.add(line2);
        lines.add(line3);
        lines.add(line4);
        insert lines;
                
        System.runas(getSysAdmin())
        {
            System.debug('Starting Test');
                            
            List<OpportunityLineItem> linesT = [Select id, opportunityid, quantity, unitPrice from OpportunityLineItem 
                                            where opportunityid =: o.id
                                            order by unitPrice desc];                       
            Opportunity ot = [Select id, amount from Opportunity
                                where id =: o.id];  
        
            System.assertEquals(4,linesT.size());
            System.assertEquals(200, linesT.get(0).unitPrice);
            System.assertEquals(100, linesT.get(1).unitPrice);
            System.assertEquals(100, linesT.get(2).unitPrice);
            System.assertEquals(100, linesT.get(3).unitPrice);
            System.assertEquals(500, ot.amount);
            
        }
    }   
    
    static testmethod void opportunityTestsWhenSolutionExistsT5(){
        Account acc= TestDataBuilder.createAccounts(1, true)[0];

        ID RType = RecordTypeUtil.getRecordTypeIdByName(Opportunity.SObjectType, 'Licence Fee');
        Opportunity o = TestDataBuilder.createOpportunities(1, false, RType)[0];
        setOpp(o,acc);
        insert o;

        List<PricebookEntry> entries = createPriceBookRecords();
            
            //add lines
        OpportunityLineItem line1 = new OpportunityLineItem(opportunityId=o.id, quantity=2, UnitPrice=100, PricebookEntryId=entries[0].id);
        OpportunityLineItem line2 = new OpportunityLineItem(opportunityId=o.id, quantity=1, UnitPrice=100, PricebookEntryId=entries[1].id);
        OpportunityLineItem line3 = new OpportunityLineItem(opportunityId=o.id, quantity=1, UnitPrice=100, PricebookEntryId=entries[2].id);
        OpportunityLineItem line4 = new OpportunityLineItem(opportunityId=o.id, quantity=1, UnitPrice=100, PricebookEntryId=entries[3].id);
    
        List<OpportunityLineItem> lines = new List<OpportunityLineItem>();
        lines.add(line1);
        lines.add(line2);
        lines.add(line3);
        lines.add(line4);
        insert lines;


        System.Test.startTest();

        //delete line 1
        delete line1;

        //do checks
        List<OpportunityLineItem> updatedLines = [ Select id, opportunityid, quantity, unitPrice from OpportunityLineItem
                                        where opportunityid =: line1.OpportunityId];

        System.assertEquals(3,updatedLines.size());
        System.Test.stopTest();

    }

    static testmethod void opportunityTestsWhenBreakdownCheckboxUnticked(){
        Account acc= TestDataBuilder.createAccounts(1, true)[0];

        ID RType = RecordTypeUtil.getRecordTypeIdByName(Opportunity.SObjectType, 'Licence Fee');
        Opportunity o = TestDataBuilder.createOpportunities(1, false, RType)[0];
        setOpp(o,acc);
        insert o;

        List<PricebookEntry> entries = createPriceBookRecords();
        System.runas(getSysAdmin())
        {
            System.debug('Starting Test');
                    
            //add line
            OpportunityLineItem line1 = new OpportunityLineItem(opportunityId=o.id, quantity=2, UnitPrice=100, PricebookEntryId=entries[0].id);
            insert line1;
            
            OpportunityLineItem line1t = [Select id, opportunityid, quantity, unitPrice from OpportunityLineItem 
                                            where id =: line1.id];
            Opportunity ot = [Select id, amount from Opportunity
                                where id =: line1t.opportunityid];                                  
            
            System.assertEquals(200,ot.amount);
        }
    }

    static testmethod void opportunityTestsWhenSPMDoesNotExist(){
        Account acc= TestDataBuilder.createAccounts(1, true)[0];

        ID RType = RecordTypeUtil.getRecordTypeIdByName(Opportunity.SObjectType, 'Licence Fee');
        Opportunity o = TestDataBuilder.createOpportunities(1, false, RType)[0];
        setOpp(o,acc);
        insert o;

        List<PricebookEntry> entries = createPriceBookRecords();
        System.runas(getSysAdmin())
        {
            System.debug('Starting Test');
                    
            //add line
            OpportunityLineItem line1 = new OpportunityLineItem(opportunityId=o.id, quantity=2, UnitPrice=100, PricebookEntryId=entries[0].id);
            insert line1;
            
            OpportunityLineItem line1t = [Select id, opportunityid, quantity, unitPrice from OpportunityLineItem 
                                            where id =: line1.id];
            Opportunity ot = [Select id, amount from Opportunity
                                where id =: line1t.opportunityid];                                  
            
            System.assertEquals(200,ot.amount);
        }
    }
    
    static testmethod void opportunityTestsWhenOppNotSellingSolution(){
        Account acc= TestDataBuilder.createAccounts(1, true)[0];
        ID RType = RecordTypeUtil.getRecordTypeIdByName(Opportunity.SObjectType, 'Licence Fee');
        Opportunity o = TestDataBuilder.createOpportunities(1, false, RType)[0];
        setOpp(o,acc);
        o.Solution__c = '';
        insert o;

        List<PricebookEntry> entries = createPriceBookRecords();
        System.runas(getSysAdmin())
        {
            System.debug('Starting Test');
                    
            //add line
            OpportunityLineItem line1 = new OpportunityLineItem(opportunityId=o.id, quantity=2, UnitPrice=100, PricebookEntryId=entries[0].id);
            insert line1;
            
            OpportunityLineItem line1t = [Select id, opportunityid, quantity, unitPrice from OpportunityLineItem 
                                            where id =: line1.id];
            Opportunity ot = [Select id, amount from Opportunity
                                where id =: line1t.opportunityid];                                  
            
        }
    }   
    static testmethod void opportunityTestsWhenDealValueisNull(){
        Account acc= TestDataBuilder.createAccounts(1, true)[0];
        ID RType = RecordTypeUtil.getRecordTypeIdByName(Opportunity.SObjectType, 'Licence Fee');
        Opportunity o = TestDataBuilder.createOpportunities(1, false, RType)[0];
        setOpp(o,acc);
        insert o;

        List<PricebookEntry> entries = createPriceBookRecords();
        System.runas(getSysAdmin())
        {
            System.debug('Starting Test');
                    
            //add line
            OpportunityLineItem line1 = new OpportunityLineItem(opportunityId=o.id, quantity=2, UnitPrice=100, PricebookEntryId=entries[0].id);
            insert line1;
            
            OpportunityLineItem line1t = [Select id, opportunityid, quantity, unitPrice from OpportunityLineItem 
                                            where id =: line1.id];
            Opportunity ot = [Select id, amount from Opportunity
                                where id =: line1t.opportunityid];                                             
            System.assertEquals(2,line1t.quantity);
            System.assertEquals(100,line1t.unitPrice);
            System.assertEquals(200,ot.amount);                    
        }
    }
}