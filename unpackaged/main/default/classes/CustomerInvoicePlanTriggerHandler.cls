/*******************************************************************************************************
* Class Name      	: CustomerInvoicePlanTriggerHandler
* Description		: Trigger handler for sobject Customer_Invoice_Plan__c
* Author          	: Simplus - Yi Zhang
* Created On      	: 11/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              11/02/2021		1000				Initial version
* Yi Zhang              19/02/2021		2000				Codes for Commitment Rebate changes
* Yi Zhang              22/02/2021		3000				Removed one active CIP per quote validation
******************************************************************************************************/
/**
 * Requirements:
 * when activating the CIP, check related quote has only one active CIP and flag related quote lines for split batch job
 * when deactivating the CIP, unflag related quote lines for split batch job
 */
public class CustomerInvoicePlanTriggerHandler {

    public static final String ONE_ACTIVE_CIP_MESSAGE = 'Only one active Customer Invoice Plan can be linked to a quote';

    public static void doBeforeInsert(List<Customer_Invoice_Plan__c> plans) {
        
    }

    public static void doAfterInsert(List<Customer_Invoice_Plan__c> plans) {

        List<Customer_Invoice_Plan__c> activePlans = new List<Customer_Invoice_Plan__c>();
        for(Customer_Invoice_Plan__c plan : plans) {
            if(plan.Active__c == true && plan.Quote__c != null) {
                activePlans.add(plan);
            }
        }

        flagQuoteLinesForSplit(activePlans);
    }

    public static void doBeforeUpdate(Map<Id, Customer_Invoice_Plan__c> oldMap, Map<Id,Customer_Invoice_Plan__c> newMap) {
    }

    public static void doAfterUpdate(Map<Id, Customer_Invoice_Plan__c> oldMap, Map<Id,Customer_Invoice_Plan__c> newMap) {

        List<Customer_Invoice_Plan__c> activePlans = new List<Customer_Invoice_Plan__c>();
        List<Customer_Invoice_Plan__c> updatedPlans = new List<Customer_Invoice_Plan__c>();
        List<Customer_Invoice_Plan__c> changedPlans = new List<Customer_Invoice_Plan__c>();
        for(Customer_Invoice_Plan__c newPlan : newMap.values()) {
            Customer_Invoice_Plan__c oldPlan = oldMap.get(newPlan.Id);
            if(oldPlan.Active__c == false && newPlan.Active__c == true) {
                activePlans.add(newPlan);
            }

            if(newPlan.Active__c == true && (oldPlan.Active__c != newPlan.Active__c || oldPlan.Quote__c != newPlan.Quote__c || oldPlan.Fee_Type__c != newPlan.Fee_Type__c)) {
                updatedPlans.add(newPlan);
            }

            if(oldPlan.Active__c != newPlan.Active__c || oldPlan.Fee_Type__c != newPlan.Fee_Type__c) {
                changedPlans.add(newPlan);
            }
        }

        // adjust remainder
        adjustRemainderAmount(activePlans);

        // plan - quote amount check
        planQuoteAmountCheck(updatedPlans);

        flagQuoteLinesForSplit(changedPlans);
    }

    /**
    * @description 
    * @author Yi Zhang | 12/02/2021 
    * @param List<Customer_Invoice_Plan__c> plans 
    **/
    public static  void flagQuoteLinesForSplit(List<Customer_Invoice_Plan__c> plans) {
        if(plans.isEmpty()) return;

        SM_SplitInvoice.flagQuoteLinesForSplit(plans);
    }

    /**
    * @description 
    * @author Yi Zhang | 12/02/2021 
    * @param List<Customer_Invoice_Plan__c> plans 
    **/
    public static void adjustRemainderAmount(List<Customer_Invoice_Plan__c> plans) {
        if(plans.isEmpty()) return;

        SM_SplitInvoice.adjustRemainderAmount((new Map<Id, Customer_Invoice_Plan__c>(plans)).keySet());
    }

    /**
    * @description 
    * @author Yi Zhang | 11/02/2021 
    * @param List<Customer_Invoice_Plan__c> plans 
    **/
    public static void planQuoteAmountCheck(List<Customer_Invoice_Plan__c> plans) {
        if(plans.isEmpty()) return;

        Map<Id, SM_SplitInvoice.ComparisonResult> comparisonMap = SM_SplitInvoice.getPlanQuoteComparisonResultMap((New Map<Id, Customer_Invoice_Plan__c>(plans)).keySet());

        for(Customer_Invoice_Plan__c plan : plans) {
            SM_SplitInvoice.ComparisonResult result = comparisonMap.get(plan.Id);
            if(result != null && result.planQuoteTotalDiff() > 0) {
                plan.addError(SM_SplitInvoice.PLAN_AMOUNT_HIGHER_THAN_QUOTE_AMOUNT_MESSAGE);
            }
            if(result != null && result.planQuoteRebateDiff() < 0) {
                plan.addError(SM_SplitInvoice.PLAN_REBATE_AMOUNT_LOWER_THAN_QUOTE_MESSAGE);
            }
        }
    }

}