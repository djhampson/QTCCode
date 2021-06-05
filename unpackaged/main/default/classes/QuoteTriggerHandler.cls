/*******************************************************************************************************
* Class Name      	: QuoteTriggerHandler
* Description		: Service class for QuoteTrigger
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 12-24-2020
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	12-24-2020			Initial version 
* Yi Zhang              19/03/2021          Added doAfterInsert & autoAmendCloudServiceContracts
******************************************************************************************************/

public class QuoteTriggerHandler {
    // PREVENT RECURSIVE TRIGGER
    private static boolean run = true;
    public static boolean runOnce(){
        system.debug('RUN: ' + run);
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
   
    /*
    * Description		: METHOD TO CREATE ORDER ASYNC USING QUEUEABLE CLASS
    * Author          	: Simplus - Gerald Arzadon | 5-26-2021
    * Params	      	: Map<Id, SBQQ__Quote__c> oldQuotesMap,List<SBQQ__Quote__c> newQuotes
    */
    public static void asyncCreateOrders(Map<Id, SBQQ__Quote__c> oldQuotesMap,List<SBQQ__Quote__c> newQuotes){
        for(SBQQ__Quote__c QuoteRec:newQuotes){
            if(!Test.isRunningTest() && oldQuotesMap.get(QuoteRec.Id).Ordered_Async__c <> QuoteRec.Ordered_Async__c && QuoteRec.Ordered_Async__c && Limits.getQueueableJobs() < 50){
                // T1_AsyncOrderCreation.createOrderFuture(QuoteRec.Id);
                System.enqueueJob(new T1_AsyncOrderCreation(QuoteRec));
                System.debug(System.LoggingLevel.ERROR,'Queueable Jobs => ' + Limits.getQueueableJobs());
            }
        }
    } 
    
    /*
    * Description		: METHOD HANDLER FOR BEFORE UPDATE TRIGGER EVENT
    * Author          	: Simplus - Gerald Arzadon | 2021
    * Params	      	: Map<Id, SBQQ__Quote__c> newQuotesMap
    */
    
    public static void doBeforeUpdate(Map<Id, SBQQ__Quote__c> newQuotesMap){
        // VALIDATION CHECKER - ADDED FEB 23
        for(SBQQ__Quote__c QuoteRec:newQuotesMap.values()){
            if(QuoteRec.Product_Checker__c){
                If(QuoteRec.Validation_Error_Message__c <> null){
                    String errMessage = QuoteRec.Validation_Error_Message__c;
                    System.debug(System.LoggingLevel.ERROR,'errMessage ' + errMessage);
                    If(!Test.isRunningTest()){ 
                        QuoteRec.addError(errMessage);
                    }
                }
            }
        }
        
        
        // query new lines.
        List<SBQQ__QuoteLine__c> newLines = [select id,SBQQ__ProductCode__c,Quote_line_Checker__c,SBQQ__RequiredBy__r.Original_Group_Id__c,SBQQ__ProductOption__c,
                                             Original_Group_Id__c, SBQQ__Group__c, SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in :newQuotesMap.keySet()];
        
        Map<Id,Date> QuoteToStartDateMap = new Map<Id,Date>(); // ADDED 2/1/2021
        
        // if we have new lines,
        if (newLines.size() > 0) {
            // loop through new lines.
            Map<Id, Id> newQuoteIdsMap = new Map<Id, Id>();
            List<Id> originalGroupIds = new List<Id>();
            Map<Id, SBQQ__QuoteLine__c> groupedLinesMap = new Map<Id, SBQQ__QuoteLine__c>();
            for (SBQQ__QuoteLine__c ql : newLines) {
                // if this line has a original group and does not have an actual group,
                if ((ql.Original_Group_Id__c != null || ql.SBQQ__RequiredBy__r.Original_Group_Id__c != null) && ql.SBQQ__Group__c == null) {
                    if (!newQuoteIdsMap.containsKey(ql.SBQQ__Quote__c)) {
                        // add to new quote ids map.
                        newQuoteIdsMap.put(ql.SBQQ__Quote__c, ql.SBQQ__Quote__c);
                    }
                    
                    // add to original group id list.
                    originalGroupIds.add(ql.Original_Group_Id__c);
                    
                    // add to grouped lines list.
                    groupedLinesMap.put(ql.id, ql);
                }
            }
            
            System.debug('originalGroupIds ' +originalGroupIds);
            System.debug('originalGroupIds size ' +originalGroupIds.size());
            System.debug('newQuoteIdsMap ' +newQuoteIdsMap);
            System.debug('groupedLinesMap ' +groupedLinesMap);
            // query for new quotes list.
            if (newQuoteIdsMap.size() > 0) {
            newQuotesMap = new Map<id, SBQQ__Quote__c>([select id, SBQQ__LineItemsGrouped__c,SBQQ__StartDate__c from SBQQ__Quote__c where id in :newQuoteIdsMap.values()]);
            System.debug('newQuotesMap ' +newQuotesMap);
            System.debug('newQuotesMap size ' +newQuotesMap.size());
            // if we have quotes with original group ids but no group set,
            if (newQuotesMap.size() > 0) {
                // get all fields of quote line group.
                Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get('SBQQ__QuoteLineGroup__c').getDescribe().fields.getMap();
                
                // query original groups.
                List<SBQQ__QuoteLineGroup__c> originalGroups = Database.query('select '+string.join(new List<String>(mfields.keySet()), ',')+' from SBQQ__QuoteLineGroup__c where id in :originalGroupIds');
                System.debug('originalGroups ' +originalGroups);
                System.debug('originalGroups size ' +originalGroups.size());
                // if we have original groups,
                if (originalGroups.size() > 0) {
                    // contact Kamino government to commission the creation of a quote line group clone army.
                    List<SBQQ__QuoteLineGroup__c> cloneArmy = new List<SBQQ__QuoteLineGroup__c>();
                    
                    // CLONE QUOTE LINE GROUPS
                    // loop through quotes.
                    for (SBQQ__Quote__c q : newQuotesMap.values()) {
                        // set this quote to have grouped lines.
                        q.SBQQ__LineItemsGrouped__c = true;
                        If(QuoteToStartDateMap.get(q.Id) == null){
                            QuoteToStartDateMap.put(q.Id,q.SBQQ__StartDate__c);
                        }
                        
                        // if we have original group ids,
                        if (originalGroupIds.size() > 0) {
                            // loop through clone army.
                            for (SBQQ__QuoteLineGroup__c og : originalGroups) {
                                SBQQ__QuoteLineGroup__c ng = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.id, SBQQ__Source__c = og.id);
                                for (String fieldName : mfields.keySet()) {
                                    Schema.DescribeFieldResult field = mfields.get(fieldName).getDescribe();
                                    if (field.isUpdateable() && fieldName != 'Id' && fieldName != 'SBQQ__Quote__c' && fieldName != 'SBQQ__Source__c' && og.get(fieldName) != null) {
                                        ng.put(fieldName, og.get(fieldName));
                                    }
                                }
                                cloneArmy.add(ng);
                            }
                        }
                    }
                    // ADDED 2/1/2021
                    for(SBQQ__QuoteLineGroup__c QLGroup:cloneArmy){
                        If(QLGroup.SBQQ__EndDate__c < QuoteToStartDateMap.get(QLGroup.SBQQ__Quote__c)){
                            QLGroup.Target_Amount__c = null;	
                        }
                    }
                    
                    System.debug('cloneArmy ' +cloneArmy);
                    System.debug('cloneArmy size ' +cloneArmy.size());
                    // if we have a clone army,
                    if (cloneArmy.size() > 0) {
                        // insert clone army.
                        insert cloneArmy;
                    }
                    
                    // UPDATE QUOTE LINES
                    
                    // make old group id -> new group id map.
                    Map<Id, Id> newGroupIdByOldGroupIdMap = new Map<Id, Id>();
                    
                    // loop through clone army.
                    for (SBQQ__QuoteLineGroup__c g : cloneArmy) {
                        // add source -> id to the old group id -> new group id map.
                        newGroupIdByOldGroupIdMap.put(g.SBQQ__Source__c, g.id);
                    }
                    System.debug('newGroupIdByOldGroupIdMap ' +newGroupIdByOldGroupIdMap);
                    
                    // if we have grouped lines,
                    if (groupedLinesMap.size() > 0) {
                        // requery grouped lines.
                        groupedLinesMap = new Map<Id, SBQQ__QuoteLine__c>([select id, SBQQ__Group__c,SBQQ__RequiredBy__r.Original_Group_Id__c, Original_Group_Id__c from SBQQ__QuoteLine__c where id in :groupedLinesMap.keySet()]);
                        
                        // loop through grouped lines.
                        for (SBQQ__QuoteLine__c ql : groupedLinesMap.values()) {
                            // update to new group.
                            If(ql.Original_Group_Id__c <> null){
                                ql.SBQQ__Group__c = newGroupIdByOldGroupIdMap.get(ql.Original_Group_Id__c);
                            }else{
                                ql.SBQQ__Group__c = newGroupIdByOldGroupIdMap.get(ql.SBQQ__RequiredBy__r.Original_Group_Id__c);
                            }
                            
                        }
                        
                        // update grouped lines.
                        update groupedLinesMap.values();
                    }
                }
            }
            
        }
    }
}
     
    /**
    * @description - Business Logic for after insert
    * @author Yi Zhang | 19/03/2021 
    * @param List<SBQQ__Quote__c> newList - Trigger.new
    **/
    public static void doAfterInsert(List<SBQQ__Quote__c> newList) {
        autoAmendCloudServiceContracts(newList);
    }

    /**
    * @description - Auto amend cloud service contracts
    * @jira TOCB-1630/TOCB-34
    * @author Yi Zhang | 19/03/2021 
    * @param List<SBQQ__Quote__c> quotes 
    **/
    public static void autoAmendCloudServiceContracts(List<SBQQ__Quote__c> quotes) {
        // find quote with type = 'Amendment'
        List<SBQQ__Quote__c> amendmentQuotes = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : quotes) {
            if(quote.SBQQ__Type__c == 'Amendment') {
                amendmentQuotes.add(quote);
            }
        }
        if(amendmentQuotes.isEmpty()) return;

        // re-query to find quote with master service contract 
        // has a true value in the checkbox field 'Migrated to SaaS Platform', and the master service contract’s deal type = Perpetual
        Map<Id, Id> contractIdquoteIdMap = new Map<Id, Id>();
        for(SBQQ__Quote__c quote : [
            SELECT Id, SBQQSC__MasterServiceContract__c
            FROM SBQQ__Quote__c 
            WHERE SBQQSC__MasterServiceContract__r.Migrated_to_SaaS_Platform__c = true 
            AND SBQQSC__MasterServiceContract__r.Deal_Type__c = 'Perpetual'
            AND Id IN :amendmentQuotes]) {
                contractIdquoteIdMap.put(quote.SBQQSC__MasterServiceContract__c, quote.Id);
            }
        if(contractIdquoteIdMap.isEmpty()) return;

        // find service contract that has 'Linked Perpetual Agreement' field point to the master service contract
        // use async framework to amend contract etc.
        Integer i = 1;
        for(ServiceContract contract : [
            SELECT Id, Linked_Perpetual_Agreement__c 
            FROM ServiceContract 
            WHERE Linked_Perpetual_Agreement__c IN :contractIdquoteIdMap.keySet()]) {
            SM_ContractAmendmentCloudAsync.schedule(contract.Id, contractIdquoteIdMap.get(contract.Linked_Perpetual_Agreement__c), i);
            i++;
        }
    }
}