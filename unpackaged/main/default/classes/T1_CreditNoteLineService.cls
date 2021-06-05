public class T1_CreditNoteLineService {
    
    @future
    public static void processCreditNoteLinesForRevRecognitionFuture(Set<Id> creditNotesId ){

        processCreditNoteLinesForRevRec(creditNotesId);
        
    }

    public static void processCreditNoteLinesForRevRec( Set<Id> creditNotesId ){
        try{
            if( Test.isRunningTest() && T1_CreditNoteLineServiceTest.throwExceptionFlag == true){
                throw new T1_CreditNoteLineServiceException();
            }
            // generate inputs for Rrevenue Recognition Service
            List<blng.RevenueRecognitionInput> recognitionInputs  = generateRevRecognitionInputsFromCNLineItems( creditNotesId );

            system.debug('inputs + '+ recognitionInputs.size());
            system.debug('inputs + '+ recognitionInputs);
            
            List<blng.RevenueRecognitionResponse> response = T1_RevRecognitionServiceUtility.generateRevenueRecognitionRecords( recognitionInputs );
        }
        catch( Exception e ){
            system.debug( 'Exception details ' + e.getCause() + e.getMessage() + e.getStackTraceString());
            Error_Log__c errLog = T1_ErrorLogService.createErrorLog( e, creditNotesId, 'Apex Class',  'T1_CreditNoteLineService');
            insert errLog;

        }
    }
    public static List<blng.RevenueRecognitionInput> generateRevRecognitionInputsFromCNLineItems( Set<Id> creditNotesId ){
        List<blng__CreditNoteLine__c> creditNoteLines = getCreditNoteLinesByCNId( creditNotesId );
        Map<Id,Id> cnLineRuleMap = new Map<Id,Id>();
        Map<Id,blng__CreditNoteLine__c> cnLineItemMap = new Map<Id,blng__CreditNoteLine__c>();
        if( creditNoteLines != null ){
            for(blng__CreditNoteLine__c cnLine : creditNoteLines){
                if( cnLine.blng__Product__r.blng__RevenueRecognitionRule__c != null && cnLine.blng__RevenueSchedules__r.size() == 0){
                    cnLineRuleMap.put(cnLine.Id,cnLine.blng__Product__r.blng__RevenueRecognitionRule__c);
                    cnLineItemMap.put(cnLine.Id,cnLine);
                }

            }
        }


        List<blng__RevenueRecognitionRule__c> parentchildRevRecRuleList =  T1_RevRecognitionServiceUtility.returnParentChildRulesHierarchy( new Set<ID>(cnLineRuleMap.values()) );
        system.debug('@@@@@@@@@@ parentchildRevRecRuleList '+ parentchildRevRecRuleList);

        //map to store parent Rule Id and list of map of child rule Id and record
        Map<Id,Map<Id,blng__RevenueRecognitionRule__c>> rulesHierarchy = new Map<Id,Map<Id,blng__RevenueRecognitionRule__c>>();
        // map to store parent rule and its record
        Map<Id,blng__RevenueRecognitionRule__c> parentRevRecRuleMap = new Map<Id,blng__RevenueRecognitionRule__c>();

        for( blng__RevenueRecognitionRule__c revRecRuleObjRec :  parentchildRevRecRuleList ) {
            parentRevRecRuleMap.put(revRecRuleObjRec.Id,revRecRuleObjRec);
            Map<Id,blng__RevenueRecognitionRule__c> childRuleMap = new Map<Id,blng__RevenueRecognitionRule__c>();
            if( revRecRuleObjRec.Revenue_Recognition_Rules__r.size() > 0 ){
                for( blng__RevenueRecognitionRule__c childRule : revRecRuleObjRec.Revenue_Recognition_Rules__r){
                    childRuleMap.put(childRule.Id,childRule);
                }
            }
            rulesHierarchy.put( revRecRuleObjRec.Id,childRuleMap );
        }
        system.debug('rulesHierarchy '+ rulesHierarchy);


        // list to store inputs Revenue Recognition Service
        blng.RevenueRecognitionInput[] inputs = new List<blng.RevenueRecognitionInput>();


        // create map of Credit NoteLineItem and corresponding  rules list
        for(blng__CreditNoteLine__c cnLine : cnLineItemMap.values() ){
            blng__RevenueRecognitionRule__c parentRule = parentRevRecRuleMap.get( cnLineRuleMap.get(cnLine.Id) );
            Map<Id,blng__RevenueRecognitionRule__c> childRulesMap = rulesHierarchy.get(parentRule.Id);
            system.debug('#########childRulesMap '+ childRulesMap);
            if( parentRule.Full_Revenue_Recognition__c == true && childRulesMap != null){
                system.debug('Inside Full REv Rec rule)');
                blng__RevenueRecognitionRule__c ruleToCreateRev;
                for(  blng__RevenueRecognitionRule__c ruleVar : childRulesMap.values() ){
                    
                    if( cnLine.blng__StartDate__c >= ruleVar.Financial_Start_Date__c && cnLine.blng__StartDate__c <= ruleVar.Financial_End_Date__c ){
                        ruleToCreateRev = ruleVar;
                    }
                }
                if( ruleToCreateRev != null ){
                    blng.RevenueRecognitionInput revRecInput = generateRevRecInput(cnLine,ruleToCreateRev.Id,cnLine.blng__StartDate__c,cnLine.blng__EndDate__c,cnLine.blng__TotalAmount__c);
                    inputs.add(revRecInput);
                }
            }else if(childRulesMap != null){
                
                if(childRulesMap.keyset().size() == 2 ){

                    system.debug('$$$$$$$ Inside Master Rule ');

                    Boolean finSplitRequired = true;
                    for( blng__RevenueRecognitionRule__c ruleVar : childRulesMap.values() ){
                        if( cnLine.blng__StartDate__c >= ruleVar.Financial_Start_Date__c && cnLine.blng__EndDate__c <= ruleVar.Financial_End_Date__c){
                            inputs.add( generateRevRecInput(cnLine,ruleVar.Id,cnLine.blng__StartDate__c,cnLine.blng__EndDate__c,cnLine.blng__TotalAmount__c) );
                            finSplitRequired = false;
                            break;
                        }
                    }
                    if( finSplitRequired == true ){
                        Date rule1StartDate ,rule1EndDate ,rule2StartDate ,rule2EndDate;
                        blng__RevenueRecognitionRule__c rule1,rule2;
                        
                        List<blng__RevenueRecognitionRule__c> childRulesList =  childRulesMap.values();
                        if( childRulesList[0].Financial_Start_Date__c < childRulesList[1].Financial_Start_Date__c  ){
                            rule1 = childRulesList[0];
                            rule2 = childRulesList[1];
                        }
                        else{
                            rule1 = childRulesList[1];
                            rule2 = childRulesList[0];
                        }
                        system.debug('rule1 ' + rule1);
                        system.debug('rule2 ' + rule2);
                        rule1StartDate = cnLine.blng__StartDate__c;
                        rule1EndDate = rule1.Financial_End_Date__c;
                        rule2startDate =  rule2.Financial_Start_Date__c;
                        rule2EndDate = cnLine.blng__EndDate__c;

                        // ********************    calculating Financial Split *****************//
                        Decimal rule1Rev,rule2Rev;
                        
                        Integer days = rule1StartDate.daysBetween(rule2EndDate) + 1;
                        system.debug( ' #######Total days'  + days);
                    

                        Integer rule1Days = rule1StartDate.daysBetween(rule1EndDate) + 1;
                        rule1Rev = ((Decimal)rule1Days/days)*cnLine.blng__TotalAmount__c;
                        rule2Rev =  cnLine.blng__TotalAmount__c - rule1Rev;

                        rule1Rev = rule1Rev.setScale(4);
                        rule2Rev = rule2Rev.setScale(4);
                        
                        system.debug('rule1Rev ' + rule1Rev);
                        system.debug('rule2Rev ' + rule2Rev);

                        blng.RevenueRecognitionInput input1 = generateRevRecInput(cnLine,rule1.Id,rule1StartDate,rule1EndDate,rule1Rev);
                        blng.RevenueRecognitionInput input2 = generateRevRecInput(cnLine,rule2.Id,rule2StartDate,rule2EndDate,rule2Rev);
                        inputs.add(input1);
                        inputs.add(input2);
                    }
                }
            }
        }
        return inputs;

    }

    public static List<blng__CreditNoteLine__c> getCreditNoteLinesByCNId( Set<Id> creditNotesId ){
        return [ SELECT blng__TotalAmount__c,CurrencyIsoCode,blng__LegalEntity__c,blng__StartDate__c,blng__EndDate__c,blng__Product__c, blng__Product__r.blng__RevenueRecognitionRule__c,blng__CreditNote__c,(SELECT Name FROM blng__RevenueSchedules__r) FROM blng__CreditNoteLine__c WHERE blng__CreditNote__c IN :creditNotesId ];
    }

    public static blng.RevenueRecognitionInput generateRevRecInput(blng__CreditNoteLine__c cnLineItem,Id recRuleId, Date startDate, Date endDate,Decimal amount){
        blng.RevenueRecognitionInput input = new blng.RevenueRecognitionInput();
        input.source = cnLineItem.Id;
        input.sourceFieldName = 'blng__CreditNoteLine__c';
        input.revenueAmount = amount;
        input.startDate = startDate;
        input.endDate = endDate;
        input.revenueRecognitionRuleId = recRuleId;
        input.legalEntityId = cnLineItem.blng__LegalEntity__c;
        input.currencyIsoCode = cnLineItem.CurrencyIsoCode;
        return input;
    }

    class T1_CreditNoteLineServiceException extends Exception{}
}