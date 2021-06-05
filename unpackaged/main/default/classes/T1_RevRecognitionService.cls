/**
 * @description       : Service Class to process OrderProducts and Generate Revenue Schedule and Transactions where order products dates  fall in two financial books
 * @author            : sakshi.chauhan@simplus.com
 * @group             : 
 * @last modified on  : 02-19-2021
 * @last modified by  : sakshi.chauhan@simplus.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   02-17-2021   sakshi.chauhan@simplus.com   Initial Version
**/
public class T1_RevRecognitionService {
    
    /**
    * @description Master function to generate Revenue Related Records
    * @author sakshi.chauhan@simplus.com | 02-19-2021 
    * @param orderIdSet 
    **/
    @future
    public static void generateRevRecognitionScheduleAndTransactions( Set<Id> orderIdSet ) {
        
        try{
            if( Test.isRunningTest() && T1_RevRecognitionServiceTest.throwExceptionFlag == true){
                throw new T1_RevRecognitionServiceException();
            }
            // generate inputs for Rrevenue Recognition Service
            List<blng.RevenueRecognitionInput> recognitionInputs  = generateRevRecognitionInputsFromOrders( orderIdSet );


            system.debug('######## inputs + '+ recognitionInputs);
            
            List<blng.RevenueRecognitionResponse> response = T1_RevRecognitionServiceUtility.generateRevenueRecognitionRecords( recognitionInputs );
        }
        catch( Exception e ){
            system.debug( 'Exception details ' + e.getCause() + e.getMessage() + e.getStackTraceString());
            Error_Log__c errLog = T1_ErrorLogService.createErrorLog( e, orderIdSet, 'Apex Class',  'T1_RevRecognitionService');
            insert errLog;

        }
    }


    /**
    * @description function to create Revenue Recognition Inputs for order products associated to 'Activated' order
    * @author sakshi.chauhan@simplus.com | 02-19-2021 
    * @param orderIdSet 
    * @return List<blng.RevenueRecognitionInput> 
    **/
    public static List<blng.RevenueRecognitionInput> generateRevRecognitionInputsFromOrders( Set<Id> orderIdSet ){

        List<OrderItem> orderItemList = T1_RevRecognitionServiceUtility.selectOrderItemsByOrderId( orderIdSet );
        system.debug('   size '+ orderItemList.size());

        system.debug('orderItemList '+ orderItemList);
        // map to store order id and corresponding rule id
        Map<Id,Id> orderItemIdRuleIdMap = new Map<Id,Id>();
        Map<Id,OrderItem> orderItemIdOrderItemMap = new Map<Id,OrderItem>();
        for( OrderItem oiVar : orderItemList ) {
            system.debug(' First Loop ' + oiVar.blng__RevenueRecognitionRule__c);
            system.debug(' First Loop ' + oiVar.blng__OrderProductsRevenueSchedules__r.size());
            if( !String.isEmpty(oiVar.blng__RevenueRecognitionRule__c) && oiVar.blng__OrderProductsRevenueSchedules__r.size() == 0 ){
                orderItemIdRuleIdMap.put( oiVar.Id,oiVar.blng__RevenueRecognitionRule__c );
                orderItemIdOrderItemMap.put(oiVar.Id,oiVar);
            }   
        }
        system.debug('**orderItemIdRuleIdMap '+ orderItemIdRuleIdMap);
        system.debug('** orderItemIdOrderItemMap '+ orderItemIdOrderItemMap);

        //map to store parent Rule Id and list of map of child rule Id and record
        Map<Id,Map<Id,blng__RevenueRecognitionRule__c>> rulesHierarchy = new Map<Id,Map<Id,blng__RevenueRecognitionRule__c>>();
        
        Map<Id,blng__RevenueRecognitionRule__c> parentRevRecRuleMap = new Map<Id,blng__RevenueRecognitionRule__c>();
        List<blng__RevenueRecognitionRule__c> parentchildRevRecRule = T1_RevRecognitionServiceUtility.returnParentChildRulesHierarchy( new Set<Id>(orderItemIdRuleIdMap.values()) );

        // create map of parent rule id and child rules list
        for( blng__RevenueRecognitionRule__c revRecRuleObjRec :  parentchildRevRecRule ) {
            // create map of parent rule id and record
            parentRevRecRuleMap.put(revRecRuleObjRec.Id,revRecRuleObjRec);
           
            Map<Id,blng__RevenueRecognitionRule__c> childRuleMap = new Map<Id,blng__RevenueRecognitionRule__c>();
            if( revRecRuleObjRec.Revenue_Recognition_Rules__r.size() > 0 ){
                for( blng__RevenueRecognitionRule__c childRule : revRecRuleObjRec.Revenue_Recognition_Rules__r){
                    childRuleMap.put(childRule.Id,childRule);
                }
                rulesHierarchy.put( revRecRuleObjRec.Id,childRuleMap );
            }
        }
        system.debug('rulesHierarchy '+ rulesHierarchy);

        // list to store inputs Revenue Recognition Service
        blng.RevenueRecognitionInput[] inputs = new List<blng.RevenueRecognitionInput>();
        
        // loop through each order product to create revenue recognition inputs
        for( OrderItem oiVar : orderItemIdOrderItemMap.values() ){
            system.debug( 'orderItemIdRuleIdMap.get(oiVar.Id) ' + orderItemIdRuleIdMap.get(oiVar.Id));
            blng__RevenueRecognitionRule__c parentRule = parentRevRecRuleMap.get( orderItemIdRuleIdMap.get(oiVar.Id) );
            system.debug('parentRule  Inside loop '+ parentRule);
            
            Map<Id,blng__RevenueRecognitionRule__c> orderRulesMap = rulesHierarchy != null?rulesHierarchy.get(parentRule.Id):null;
            system.debug('######  orderRulesMap '+ orderRulesMap);

            if( parentRule.Full_Revenue_Recognition__c == true && orderRulesMap != null){
                system.debug('Inside Full Rev Rec rule)');
                blng__RevenueRecognitionRule__c ruleToCreateRev;
                    for( Id ruleId : orderRulesMap.keyset() ){
                        blng__RevenueRecognitionRule__c ruleVar = orderRulesMap.get(ruleId);
                        if( oiVar.ServiceDate >= ruleVar.Financial_Start_Date__c && oiVar.ServiceDate <= ruleVar.Financial_End_Date__c ){
                            ruleToCreateRev = ruleVar;
                        }
                    }
                    if( ruleToCreateRev != null ){
                        blng.RevenueRecognitionInput revRecInput = generateRevRecInput(oiVar,ruleToCreateRev.Id,oiVar.ServiceDate,oiVar.EndDate,oiVar.blng__AllocatedRevenueAmount__c);
                        inputs.add(revRecInput);
                    }
            }
            else if(orderRulesMap != null){

                if( orderRulesMap.keyset().size() == 2 ){
                    Boolean finSplitRequired = true;
                    for( blng__RevenueRecognitionRule__c ruleVar : orderRulesMap.values() ){
                        if( oiVar.ServiceDate >= ruleVar.Financial_Start_Date__c && oiVar.EndDate <= ruleVar.Financial_End_Date__c){
                            inputs.add( generateRevRecInput(oiVar,ruleVar.Id,oiVar.ServiceDate,oiVar.EndDate,oiVar.blng__AllocatedRevenueAmount__c) );
                            finSplitRequired = false;
                            break;
                        }
                    }
                    if( finSplitRequired == true ){
                        system.debug( '########Financial Split is required ');
                        Date rule1StartDate ,rule1EndDate ,rule2StartDate ,rule2EndDate;
                        blng__RevenueRecognitionRule__c rule1,rule2;
                        
                        List<blng__RevenueRecognitionRule__c> childRulesList =  orderRulesMap.values();
                        if( childRulesList[0].Financial_Start_Date__c < childRulesList[1].Financial_Start_Date__c  ){
                            rule1 = childRulesList[0];
                            rule2 = childRulesList[1];
                        }
                        else{
                            rule1 = childRulesList[1];
                            rule2 = childRulesList[0];
                        }

                        rule1StartDate = oiVar.ServiceDate;
                        rule1EndDate = rule1.Financial_End_Date__c;
                        rule2startDate =  rule2.Financial_Start_Date__c;
                        rule2EndDate = oiVar.EndDate;

                        system.debug('rule1 ' + rule1);
                        system.debug('rule2 ' + rule2);
                        system.debug('rule1EndDate ' + rule1EndDate);
                        system.debug('rule2startDate ' + rule2startDate);
                    
                        // ********************    calculating Financial Split *****************//
                        Decimal rule1Rev,rule2Rev;
                        
                        Integer days = rule1StartDate.daysBetween(rule2EndDate) + 1;
                        system.debug( ' #######Total days'  + days);
                    

                        Integer rule1Days = rule1StartDate.daysBetween(rule1EndDate) + 1;
                        
                        if(rule1Days <> null && days <> null && oiVar.blng__AllocatedRevenueAmount__c <> null){
                            rule1Rev = ((Decimal)rule1Days/days)*oiVar.blng__AllocatedRevenueAmount__c;
                        }else{
                            rule1Rev = 0;
                        }
                        rule2Rev =  (oiVar.blng__AllocatedRevenueAmount__c <> null ? oiVar.blng__AllocatedRevenueAmount__c : 0) - (rule1Rev <> null ? rule1Rev : 0);

                        rule1Rev = rule1Rev.setScale(4);
                        rule2Rev = rule2Rev.setScale(4);
                        
                        system.debug('rule1Rev ' + rule1Rev);
                        system.debug('rule2Rev ' + rule2Rev);

                        blng.RevenueRecognitionInput input1 = generateRevRecInput(oiVar,rule1.Id,rule1StartDate,rule1EndDate,rule1Rev);
                        blng.RevenueRecognitionInput input2 = generateRevRecInput(oiVar,rule2.Id,rule2StartDate,rule2EndDate,rule2Rev);
                        inputs.add(input1);
                        inputs.add(input2);
                    }
                    
                }
                
            }
            
        }
        return inputs;
       
    }

    
    


    /**
    * @description genric function to assign values to Recognition inputs parameters
    * @author sakshi.chauhan@simplus.com | 02-19-2021 
    * @param orderItem 
    * @param recRuleId 
    * @param startDate 
    * @param endDate 
    * @param amount 
    * @return blng.RevenueRecognitionInput 
    **/
    public static blng.RevenueRecognitionInput generateRevRecInput(OrderItem orderItem,Id recRuleId, Date startDate, Date endDate,Decimal amount){
        blng.RevenueRecognitionInput input = new blng.RevenueRecognitionInput();
        input.source = orderItem.Id;
        input.sourceFieldName = 'blng__OrderProduct__c';
        input.revenueAmount = amount;
        input.startDate = startDate;
        input.endDate = endDate;
        input.revenueRecognitionRuleId = recRuleId;
        input.legalEntityId = orderItem.blng__LegalEntity__c;
        input.currencyIsoCode = orderItem.CurrencyIsoCode;
        return input;
    }

    class T1_RevRecognitionServiceException extends Exception{}
}