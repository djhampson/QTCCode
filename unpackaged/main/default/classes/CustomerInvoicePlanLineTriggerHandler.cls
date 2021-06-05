/*******************************************************************************************************
* Class Name      	: CustomerInvoicePlanLineTriggerHandler
* Description		: Trigger handler for sobject Customer_Invoice_Plan_Line__c
* Author          	: Simplus - Yi Zhang
* Created On      	: 11/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              11/02/2021		1000				Initial version
* Yi Zhang              19/02/2021		2000				Codes for Commitment Rebate changes
******************************************************************************************************/
public class CustomerInvoicePlanLineTriggerHandler {

    public static final String TYPE_AMOUNT = 'Amount';
    public static final String TYPE_REMAINDER = 'Remainder';

    public static void doBeforeInsert(List<Customer_Invoice_Plan_Line__c> lines) {   

        List<Customer_Invoice_Plan_Line__c> remainderLines = new List<Customer_Invoice_Plan_Line__c>();
        for(Customer_Invoice_Plan_Line__c line : lines) {
            if(line.Type__c == TYPE_REMAINDER) {
                remainderLines.add(line);
            }
        }
        populateRemainderAmount(remainderLines);
    }

    public static void doAfterInsert(List<Customer_Invoice_Plan_Line__c> lines) {

        // plan - quote amount check
        planQuoteAmountCheck(lines);

        List<Customer_Invoice_Plan_Line__c> linesAffectRemainderAmount = new List<Customer_Invoice_Plan_Line__c>();
        for(Customer_Invoice_Plan_Line__c line : lines) {
            if(line.Type__c == TYPE_AMOUNT) {
                linesAffectRemainderAmount.add(line);
            }
        }
        adjustRemainderAmount(linesAffectRemainderAmount);
    }

    public static void doBeforeUpdate(Map<Id, Customer_Invoice_Plan_Line__c> oldMap, Map<Id,Customer_Invoice_Plan_Line__c> newMap) {
    }
    
    public static void doAfterUpdate(Map<Id, Customer_Invoice_Plan_Line__c> oldMap, Map<Id,Customer_Invoice_Plan_Line__c> newMap) {


        List<Customer_Invoice_Plan_Line__c> lines = new List<Customer_Invoice_Plan_Line__c>();
        List<Customer_Invoice_Plan_Line__c> linesAffectRemainderAmount = new List<Customer_Invoice_Plan_Line__c>();
        for(Customer_Invoice_Plan_Line__c newLine : newMap.values()) {
            Customer_Invoice_Plan_Line__c oldLine = oldMap.get(newLine.Id);
            // changes in type, amount, commitment rebate
            if(oldLine.Type__c != newLine.Type__c || oldLine.Amount__c != newLine.Amount__c || oldLine.Commitment_Rebate__c != newLine.Commitment_Rebate__c) {
                lines.add(newLine);
            }

            // when line is updated to remainder, populate the amount
            // when amount line is updated, adjust the remainder line
            if((oldLine.Type__c != newLine.Type__c && newLine.Type__c == TYPE_REMAINDER)
            || (oldLine.Type__c == TYPE_AMOUNT && newLine.Type__c == TYPE_AMOUNT && oldLine.Amount__c != newLine.Amount__c)) {
                linesAffectRemainderAmount.add(newLine);
            }
        }
        // plan - quote amount check
        planQuoteAmountCheck(lines);

        adjustRemainderAmount(linesAffectRemainderAmount);

    }

    public static void doAfterDelete(List<Customer_Invoice_Plan_Line__c> lines) {
        
        // when amount line is deleted, adjust the remainder line
        List<Customer_Invoice_Plan_Line__c> linesAffectRemainderAmount = new List<Customer_Invoice_Plan_Line__c>();
        for(Customer_Invoice_Plan_Line__c line : lines) {
            if(line.Type__c == TYPE_AMOUNT) {
                linesAffectRemainderAmount.add(line);
            }
        }
        adjustRemainderAmount(linesAffectRemainderAmount);
    }








    /**
    * @description Populate Remainder line's amount as well as commitment rebate (optional)
    * @author Yi Zhang | 19/02/2021 
    * @param List<Customer_Invoice_Plan_Line__c> lines - Remainder Lines
    **/
    public static void populateRemainderAmount(List<Customer_Invoice_Plan_Line__c> lines) {
        if(lines.isEmpty()) return;
        
        Set<Id> planIds = new Set<Id>();
        for(Customer_Invoice_Plan_Line__c line : lines) {
            planIds.add(line.Customer_Invoice_Plan__c);
        }

        Map<Id, SM_SplitInvoice.ComparisonResult> comparisonMap = SM_SplitInvoice.getPlanQuoteComparisonResultMap(planIds);

        for(Customer_Invoice_Plan_Line__c line : lines) {
            line.Amount__c = null;
            line.Commitment_Rebate__c = null;
            SM_SplitInvoice.ComparisonResult result = comparisonMap.get(line.Customer_Invoice_Plan__c);
            if(result != null && result.planQuoteTotalDiff() < 0) {
                line.Amount__c = result.planQuoteTotalDiff() * -1;
            }
            if(result != null && result.planQuoteRebateDiff() > 0) {
                line.Commitment_Rebate__c = result.planQuoteTotalDiff() * -1;
            }
        }
    }

    /**
    * @description Adjust reaminder line's amount (if any)
    * @author Yi Zhang | 12/02/2021 
    * @param List<Customer_Invoice_Plan_Line__c> lines - Amount Lines
    **/
    public static void adjustRemainderAmount(List<Customer_Invoice_Plan_Line__c> lines) {
        if(lines.isEmpty()) return;

        Set<Id> planIds = new Set<Id>();
        for(Customer_Invoice_Plan_Line__c line : lines) {
            planIds.add(line.Customer_Invoice_Plan__c);
        }

        SM_SplitInvoice.adjustRemainderAmount(planIds);
    }


    /**
    * @description 
    * @author Yi Zhang | 11/02/2021 
    * @param List<Customer_Invoice_Plan_Line__c> lines 
    **/
    public static void planQuoteAmountCheck(List<Customer_Invoice_Plan_Line__c> lines) {
        if(lines.isEmpty()) return;

        Set<Id> planIds = new Set<Id>();
        for(Customer_Invoice_Plan_Line__c line : lines) {
            planIds.add(line.Customer_Invoice_Plan__c);
        }

        Map<Id, SM_SplitInvoice.ComparisonResult> comparisonMap = SM_SplitInvoice.getPlanQuoteComparisonResultMap(planIds);

        for(Customer_Invoice_Plan_Line__c line : lines) {
            SM_SplitInvoice.ComparisonResult result = comparisonMap.get(line.Customer_Invoice_Plan__c);
            if(result != null && result.planQuoteTotalDiff() > 0) {
                line.addError(SM_SplitInvoice.PLAN_AMOUNT_HIGHER_THAN_QUOTE_AMOUNT_MESSAGE);
            }
            if(result != null && result.planQuoteRebateDiff() < 0) {
                line.addError(SM_SplitInvoice.PLAN_REBATE_AMOUNT_LOWER_THAN_QUOTE_MESSAGE);
            }
        }
    }
}