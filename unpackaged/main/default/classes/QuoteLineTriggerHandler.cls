/*******************************************************************************************************
* Class Name      	: QuoteLineTriggerHandler
* Description		: Service class for QuoteLineTrigger
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 2-5-2021
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	2-5-2021			Initial version 
* Yi Zhang              15/02/2021          Added logic for quote/plan amount validation, remainder calculation & QL flagging
* Yi Zhang              19/02/2021          Codes for Commitment Rebate changes
* Yi Zhang              24/05/2021          Codes for Commitment Fee changes
******************************************************************************************************/
public class QuoteLineTriggerHandler {
    
    public static void doAfterUpdate(Map<Id, SBQQ__QuoteLine__c> oldMap, Map<Id, SBQQ__QuoteLine__c> newMap) {
        // when QL's customer total is changed
        // - calculate remainder / run amount validation against the related quote
        // - flag the quote line when needed
        List<SBQQ__QuoteLine__c> changedLines = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c newLine : newMap.values()) {
            SBQQ__QuoteLine__c oldLine = oldMap.get(newLine.Id);
            if(newLine.SBQQ__CustomerTotal__c != oldLine.SBQQ__CustomerTotal__c) {
                changedLines.add(newLine);
            }
        }
        amountCheckRemainderCalculationQLFlag(changedLines);
    }

    public static void doAfterDelete(List<SBQQ__QuoteLine__c> oldList) {
        // when QL's deleted
        // - calculate remainder / run amount validation against the related quote
        amountCheckRemainderCalculationQLFlag(oldList);
    }

    /**
    * @description  If QL's quote is associated with an active CIP, then carry out:
    *               - amount check
    *               - remainder calculation
    *               - QL flagging
    * @author Yi Zhang | 15/02/2021 
    * @param List<SBQQ__QuoteLine__c> lines 
    **/
    public static void amountCheckRemainderCalculationQLFlag(List<SBQQ__QuoteLine__c> lines) {
        if(lines.isEmpty()) return;

        Set<Id> quoteIds = new Set<Id>();
        for(SBQQ__QuoteLine__c line : lines) {
            quoteIds.add(line.SBQQ__Quote__c);
        }
        // get active CIPs
        List<Customer_Invoice_Plan__c> plans = [SELECT Id, Quote__c, Fee_Type__c, Active__c, Commitment_Rebate_Sum__c, Include_Commitment_Fee__c FROM Customer_Invoice_Plan__c WHERE Active__c = true AND Quote__c IN :quoteIds];
        Map<Id, SM_SplitInvoice.ComparisonResult> comparisonMap = SM_SplitInvoice.getPlanQuoteComparisonResultMap(new Map<Id, Customer_Invoice_Plan__c>(plans).keySet());
        
        if(comparisonMap.isEmpty()) return;

        // plan - quote amount check
        for(SBQQ__QuoteLine__c line : lines) {
            SM_SplitInvoice.ComparisonResult result = comparisonMap.get(line.SBQQ__Quote__c);
            if(result != null && result.planQuoteTotalDiff() > 0) {
                line.addError(SM_SplitInvoice.PLAN_AMOUNT_HIGHER_THAN_QUOTE_AMOUNT_MESSAGE);
            }
            if(result != null && result.planQuoteRebateDiff() < 0) {
                line.addError(SM_SplitInvoice.PLAN_REBATE_AMOUNT_LOWER_THAN_QUOTE_MESSAGE);
            }
        }

        // adjust reaminder amount
        SM_SplitInvoice.adjustRemainderAmount(comparisonMap);

        // flag quote lines
        SM_SplitInvoice.flagQuoteLinesForSplit(plans);
    }
    
    // HANDLE AFTER INSERT SCENARIO
    public static void doAfterInsert(List<SBQQ__QuoteLine__c> newQuoteLinesList){

        System.debug(logginglevel.ERROR, 'QL AFTER INSERT');
        Boolean AddOptionsChecker = FALSE;
        List<SBQQ__ProductOption__c> ProductOptions;
        Map<Id,Set<Id>> QuoteToQuoteLineListMap= new Map<Id,Set<Id>>();
        Map<Id,SBQQ__QuoteLine__c> QuoteToEDISCLineMap= new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,List<SBQQ__QuoteLine__c>> OriginalEDISCQLMap= new Map<Id,List<SBQQ__QuoteLine__c>>();
        Map<Id,Id> AmendmentQuoteToOriginalQuoteMap= new Map<Id,Id>();
        Set<Id> QuoteIds = new Set<Id>();
        Set<Id> OriginalQuoteIds = new Set<Id>();
            
        // LOOP ON QL
        for(SBQQ__QuoteLine__c QuoteLineRec : newQuoteLinesList){
            QuoteIds.add(QuoteLineRec.SBQQ__Quote__c);
            // QL WITH ELIGIBLE DISCOUNT AS A PRODUCT
            System.debug(logginglevel.ERROR, '@@ QUOTE LINE CHECKER ' + QuoteLineRec.Quote_line_Checker__c);
            System.debug(logginglevel.ERROR, '@@ QUOTE LINE PRODUCT CODE ' + QuoteLineRec.SBQQ__ProductCode__c);
            
            if(QuoteLineRec.Quote_line_Checker__c && QuoteLineRec.SBQQ__ProductCode__c == 'EDISC'){
                AddOptionsChecker = TRUE;
                QuoteToEDISCLineMap.put(QuoteLineRec.SBQQ__Quote__c,QuoteLineRec);
                OriginalQuoteIds.add(QuoteLineRec.Original_Quote__c);
                // POPULATE MAP AMENDMENT QUOTE AND ORIGINAL QUOTE
                If(AmendmentQuoteToOriginalQuoteMap.get(QuoteLineRec.SBQQ__Quote__c) == null ){
                    AmendmentQuoteToOriginalQuoteMap.put(QuoteLineRec.SBQQ__Quote__c,QuoteLineRec.Original_Quote__c);
                }
            }
        }
        
        // EXECUTE LOGIC IF ADD OPTIONS IS TRUE
        If(AddOptionsChecker){
            
            // GET ALL QUOTE LINE FIELDS
            Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();

            // GET ALL PRODUCT OPTIONS UNDER ELIGIBLE DISCOUNTS
            ProductOptions = [SELECT Id,SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Discount_Type__c,
                              SBQQ__Feature__c,SBQQ__ProductCode__c
                              FROM SBQQ__ProductOption__c 
                              WHERE SBQQ__ConfiguredSKU__r.ProductCode = 'EDISC'];
            
            // COLLECTION OF PRODUCT CODES
            Set<String> TargetProdCodes = new Set<String>();
            for(SBQQ__ProductOption__c ProdOptions: ProductOptions){
                TargetProdCodes.add(ProdOptions.SBQQ__ProductCode__c);
            }
            
            // GET ALL QL FROM THE ORIGINAL QUOTE
            List<SBQQ__QuoteLine__c> OriginalQLines = DATABASE.QUERY('SELECT ' + String.join(new List<String>(mfields.keySet()),',') + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :OriginalQuoteIds');
            
            // POPULATE MAP OF ORIGINAL QUOTE AND LIST OF QL
            for(SBQQ__QuoteLine__c QLine : OriginalQLines){
                If(TargetProdCodes.contains(QLine.SBQQ__ProductCode__c)){
                    If(OriginalEDISCQLMap.get(QLine.SBQQ__Quote__c) <> null){
                        OriginalEDISCQLMap.get(QLine.SBQQ__Quote__c).add(QLine);
                    }else{
                        OriginalEDISCQLMap.put(QLine.SBQQ__Quote__c,new List<SBQQ__QuoteLine__c>{QLine});
                    }  
                }
            }
            
            System.debug(logginglevel.ERROR, 'QUOTE ID SIZE ' + QuoteIds.size());
            System.debug(logginglevel.ERROR, 'QuoteToEDISCLineMap ' + QuoteToEDISCLineMap);
            
            // LOOP ON QL
            for(SBQQ__QuoteLine__c QuoteLineRec : newQuoteLinesList){
                // GET EXISTING PRODUCT OPTIONS OF ELIGIBLE DISCOUNT PER QUOTE
                If(QuoteToEDISCLineMap.get(QuoteLineRec.SBQQ__Quote__c) <> null){
                    System.debug('YES');
                    System.debug('REQUIRED BY PARENT ID ' + QuoteToEDISCLineMap.get(QuoteLineRec.SBQQ__Quote__c).Id);
                    System.debug('QL PRODUCT CODE ' + QuoteLineRec.SBQQ__ProductCode__c);
                    System.debug('QL Id ' + QuoteLineRec.Id);
                    // CHECK IF PRODUCT CODE IS A TARGET OPTION
                    If(TargetProdCodes.contains(QuoteLineRec.SBQQ__ProductCode__c)){
                        If(QuoteToQuoteLineListMap.get(QuoteLineRec.SBQQ__Quote__c) <> null){
                            QuoteToQuoteLineListMap.get(QuoteLineRec.SBQQ__Quote__c).add(QuoteLineRec.SBQQ__ProductOption__c);
                        }else{
                            QuoteToQuoteLineListMap.put(QuoteLineRec.SBQQ__Quote__c,new Set<Id>{QuoteLineRec.SBQQ__ProductOption__c});
                        } 
                    }  
                }
            }
            System.debug('QuoteToQuoteLineListMap ' + QuoteToQuoteLineListMap);
            System.debug(logginglevel.ERROR,'AddOptionsChecker ' + AddOptionsChecker);
            
            // LIST OF NEW LINE TO INSERT
            List<SBQQ__QuoteLine__c> ToInsertQlines = new List<SBQQ__QuoteLine__c>();
            
            for(Id QuoteId : QuoteToQuoteLineListMap.keySet()){
                for(SBQQ__ProductOption__c ProdOptions : ProductOptions){
                    // GET ALL EXISTING PRODUCT OPTION
                    Set<Id> ExistingProdOptIds = QuoteToQuoteLineListMap.get(QuoteId);
                    // CHECK IF PRODUCT OPTION IS NOT EXISTING ON THE AMENDMENT LINES
                    If(!ExistingProdOptIds.contains(ProdOptions.Id)){
                        SBQQ__QuoteLine__c QLRec = new SBQQ__QuoteLine__c(SBQQ__Quote__c = QuoteId,
                                                                          SBQQ__Quantity__c = 0,
                                                                          SBQQ__Number__c = QuoteToEDISCLineMap.get(QuoteId).SBQQ__Number__c + 1,
                                                                          SBQQ__RequiredBy__c = QuoteToEDISCLineMap.get(QuoteId).Id);
                        If(QuoteToEDISCLineMap.get(QuoteId).SBQQ__Group__c <> null){
                           // QLRec.put('SBQQ__Group__c', QuoteToEDISCLineMap.get(QuoteId).SBQQ__Group__c); 
                        }
                        // ORIGINAL QUOTE ID
                        Id OriginalQuoteId = AmendmentQuoteToOriginalQuoteMap.get(QuoteId);
                        // GET ALL QUOTE LINES FROM THE ORIGINAL ID
                        for(SBQQ__QuoteLine__c OrigQLine: OriginalEDISCQLMap.get(OriginalQuoteId)){
                            If(OrigQLine.SBQQ__ProductOption__c == ProdOptions.Id){
                                // LOOP ON ALL OTHER FIELDS
                                for (String fieldName : mfields.keySet()) {
                                    // CHECK IF FIELD CAN BE UPDATED
                                    Schema.DescribeFieldResult field = mfields.get(fieldName).getDescribe();
                                    if (field.isUpdateable() && OrigQLine.get(fieldName) <> null && fieldName <> 'SBQQ__Quote__c' && fieldName <> 'SBQQ__Group__c'
                                        && fieldName <> 'SBQQ__Quantity__c' && fieldName <> 'SBQQ__Number__c' && fieldName <> 'SBQQ__RequiredBy__c'){
                                            // COPY FIELD VALUE
                                          QLRec.put(fieldName, OrigQLine.get(fieldName)); 
                                    }
                                }   
                            } 
                        }
                        // ADD NEW LINE TO THE LIST
                        ToInsertQlines.add(QLRec);
                    }
                }
            }
            
            System.debug(logginglevel.ERROR, 'ToInsertQlines size ' + ToInsertQlines.size());
            
            // INSERT QL NEW LINES
            If(ToInsertQlines.size() > 0){
                INSERT ToInsertQlines;
            }
        }
    }

}