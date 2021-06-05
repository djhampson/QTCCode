/*******************************************************************************************************
* Class Name      	: SM_SplitInvoice
* Description		: Service layer for Split Invoice functionalities
* Author          	: Simplus - Yi Zhang
* Created On      	: 11/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              11/02/2021		1000				Initial version
* Yi Zhang              19/02/2021		2000				Codes for Commitment Rebate changes
* Yi Zhang              22/02/2021		3000				Modified logic to cater for multiple active CIPs per quote
                                                            Split invoices are of custom objects, not OOB
* Yi Zhang              26/02/2021		4000				Populate T1 invoice's Order && PO Number fields
* Yi Zhang              22/03/2021		5000				TOCB-1658 copy unsplit invoice lines into custom invoice objects
* Yi Zhang              08/04/2021		6000				TOCB-1712 cater for multiple invoices per order
* Yi Zhang              24/05/2021		7000				TOCB-1936 Add Commitment Fee to customer invoice plan
******************************************************************************************************/
public class SM_SplitInvoice {
    
    public static final String PLAN_FEE_TYPE_ALL = 'All';
    public static final String PLAN_FEE_TYPE_LICENCE = 'Licence';
    public static final String PLAN_FEE_TYPE_SAAS = 'SaaS Platform';
    public static final String QUOTELINE_FEE_TYPE_ASM = 'ASM';
    public static final String QUOTELINE_FEE_TYPE_AMS = 'AMS';
    public static final String QUOTELINE_FEE_TYPE_LICENSE = 'License';
    public static final String QUOTELINE_FEE_TYPE_CLOUD = 'Cloud';
    public static final String QUOTELINE_CHARGE_TYPE_ONE_TIME = 'One-Time';
    public static final String QUOTELINE_CATEGORY_COMMITMENT_REBATE = 'Commitment Rebate';
    public static final String QUOTELINE_CATEGORY_COMMITMENT_FEE    = 'Commitment Fee';
    public static final List<String> QUOTELINE_FEE_TYPES_ALL = new List<String>{QUOTELINE_FEE_TYPE_ASM, QUOTELINE_FEE_TYPE_LICENSE, QUOTELINE_FEE_TYPE_CLOUD};
    public static final String PLAN_AMOUNT_HIGHER_THAN_QUOTE_AMOUNT_MESSAGE = 'Total amount of the customer invoice plan lines cannot be higher than the total amount on the quote of selected fee type';
    public static final String PLAN_REBATE_AMOUNT_LOWER_THAN_QUOTE_MESSAGE = 'Total commitment rebate of the customer invoice plan lines cannot be fewer than the total commitment rebate on the quote';

    /**
    * @description  Produce a map of ComparisonResult to be consumed by trigger handlers and within the class
    * @author Yi Zhang | 19/02/2021 
    * @param Set<Id> planIds 
    * @return Map<Id, ComparisonResult> 
    **/
    public static Map<Id, ComparisonResult> getPlanQuoteComparisonResultMap(Set<Id> planIds) {
        if(planIds.isEmpty()) return new Map<Id, ComparisonResult>();

        // find Active plans with Amount lines
        List<Customer_Invoice_Plan__c> plans = [
            SELECT Id, Quote__c, Fee_Type__c,  
            (SELECT Id, Amount__c, Commitment_Rebate__c FROM Customer_Invoice_Plan_Lines__r WHERE Type__c = 'Amount')
            FROM Customer_Invoice_Plan__c
            WHERE Id IN :planIds
            AND Active__c = true
        ];
        

        if(plans.isEmpty()) return new Map<Id, ComparisonResult>();

        // find quotes
        List<Id> quoteIds = new List<Id>();
        for(Customer_Invoice_Plan__c plan : plans) {
            quoteIds.add(plan.Quote__c);
        }

        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>([
            SELECT Id, 
            (SELECT Id, Fee_Type__c, SBQQ__CustomerTotal__c, Category__c FROM SBQQ__LineItems__r)
            FROM SBQQ__Quote__c
            WHERE Id IN :quoteIds
        ]);

        Map<Id, ComparisonResult> comparisonMap = new Map<Id, ComparisonResult>();
        for(Customer_Invoice_Plan__c plan : plans) {
            SBQQ__Quote__c quote = quoteMap.get(plan.Quote__c);
            ComparisonResult cr = comparePlanQuote(plan, quote);
            comparisonMap.put(plan.Id, cr);
            comparisonMap.put(quote.Id, cr);
        }
        return comparisonMap;
    }

    /**
    * @description 
    * @author Yi Zhang | 12/02/2021 
    * @param Set<Id> planIds 
    **/
    public static void adjustRemainderAmount(Set<Id> planIds) {
        System.debug('SM.SplitInvoice.adjustRemainderAmount: ' + planIds);
        if(planIds.isEmpty()) return;

        Map<Id, ComparisonResult> comparisonMap = getPlanQuoteComparisonResultMap(planIds);

        adjustRemainderAmount(comparisonMap);
    }

    /**
    * @description  Adjust remainder amount with ComparisonResult Map (avoid same query issued multiple times within one trigger)
    * @author Yi Zhang | 19/02/2021 
    * @param Map<Id, ComparisonResult> comparisonMap 
    **/
    public static void adjustRemainderAmount(Map<Id, ComparisonResult> comparisonMap) {
        System.debug('comparisonMap: ' + comparisonMap);
        if(comparisonMap.isEmpty()) return;

        Map<Id,Customer_Invoice_Plan_Line__c> remainderLineMap = new Map<Id,Customer_Invoice_Plan_Line__c>();
        for(Customer_Invoice_Plan_Line__c line: [
            SELECT Id, Customer_Invoice_Plan__c, Amount__c, Commitment_Rebate__c
            FROM Customer_Invoice_Plan_Line__c
            WHERE Customer_Invoice_Plan__c IN :comparisonMap.keySet()
            AND Type__c = :CustomerInvoicePlanLineTriggerHandler.TYPE_REMAINDER
        ]) {
            ComparisonResult result = comparisonMap.get(line.Customer_Invoice_Plan__c);
            System.debug('line: ' + line);
            System.debug('result: ' + result);
            System.debug('line.Amount__c ' + line.Amount__c);
            
            if(result.planQuoteTotalDiff() <= 0 && result.planQuoteRebateDiff() >= 0) {
                remainderLineMap.put(line.Id, new Customer_Invoice_Plan_Line__c(
                    Id = line.Id, 
                    Amount__c = result.planQuoteTotalDiff() * -1,
                    Commitment_Rebate__c = result.planQuoteRebateDiff() * -1));
            }
        }
        System.debug('remainderLineMap: ' + remainderLineMap);

        if(remainderLineMap.size() > 0) {
            update remainderLineMap.values();
        }
    }


    /**
    * @description 
    * @author Yi Zhang | 12/02/2021 
    * @param List<Customer_Invoice_Plan__c> plans - plans associated with quotes
    **/
    public static void flagQuoteLinesForSplit(List<Customer_Invoice_Plan__c> plans) {
        System.debug('SM.SplitInvoice.flagQuoteLinesForSplit: ' + plans);
        if(plans.isEmpty()) return;

        Map<Id, Customer_Invoice_Plan__c> planMap = new Map<Id,Customer_Invoice_Plan__c>();

        List<Id> quoteIds = new List<Id>();
        for(Customer_Invoice_Plan__c plan : plans) {
            quoteIds.add(plan.Quote__c);
            planMap.put(plan.Quote__c, plan);
        }
        // get quote lines
        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c quoteLine : [
            SELECT Id, Fee_Type__c, Split_Flag__c, SBQQ__ChargeType__c, SBQQ__Quote__c, Category__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c IN :quoteIds
        ]) {
            Customer_Invoice_Plan__c plan = planMap.get(quoteLine.SBQQ__Quote__c);
            
            // update quote line depending on the plan's fee type
            quoteLineMap.put(quoteLine.Id, flagQuoteLine(plan, quoteLine));
        }

        if(quoteLineMap.size() > 0) {
            update quoteLineMap.values();
        }
    }

    /**
    * @description  Main method to be consumed by invoice split batch class
    * @author Yi Zhang | 15/02/2021 
    * @param List<blng__InvoiceLine__c> lines 
    **/
    public static void splitInvoices(List<blng__InvoiceLine__c> lines) {
        System.debug('splitInvoices: ' + lines);
        if(lines.isEmpty()) return;


        Set<Id> quoteIds = new Set<Id>();
        Set<Id> invoiceIds = new Set<Id>();
        Set<Id> planIds = new Set<Id>();
        Set<Id> invoiceIdsWithNotSplitLines = new Set<Id>();
        for(blng__InvoiceLine__c line : lines) {
            quoteIds.add(line.blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quote__c);
            invoiceIds.add(line.blng__Invoice__c);

        }
        
        // re-query invoice lines to avoid missing lines due to batch size
        // regardless whether the line has Split_Flag__c = true or not, query the line (TOCB-1658)
        lines.clear();
        for(blng__InvoiceLine__c line : [SELECT Id, 
        blng__Invoice__c, 
        blng__Invoice__r.Id, 
        blng__Invoice__r.Name,
        Fee_Type__c, 
        Split_Flag__c, 
        blng__OrderProduct__c, 
        blng__OrderProduct__r.Order.Id, 
        blng__OrderProduct__r.Order.Purchase_Order_Number__c, 
        blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quote__c, 
        blng__OrderProduct__r.SBQQ__QuoteLine__r.Category__c
        FROM blng__InvoiceLine__c 
        WHERE blng__Invoice__c IN :invoiceIds 
        AND Split_Done__c = false]) {
            if(line.Split_Flag__c == true) {
                lines.add(line);
            } else {
                invoiceIdsWithNotSplitLines.add(line.blng__Invoice__c);
            }
        }

        
        // quote - invoices && quote - order map to assist T1 Invoice field population
        // TOCB-1712: there might be multiple invoices per order
        Map<String, Map<Id, blng__Invoice__c>> quoteIdInvoiceMap = new Map<String, Map<Id, blng__Invoice__c>>();
        Map<String, Order> quoteIdOrderMap = new Map<String, Order>();
        for(blng__InvoiceLine__c line : lines) {
            String quoteId = line.blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quote__c;
            if(quoteId != null) {
                if(quoteIdInvoiceMap.containsKey(quoteId) == false) {
                    quoteIdInvoiceMap.put(quoteId, new Map<Id, blng__Invoice__c>());
                }
                quoteIdInvoiceMap.get(quoteId).put(line.blng__Invoice__c, line.blng__Invoice__r);
            }

            if(quoteId != null && line.blng__OrderProduct__c != null && quoteIdOrderMap.containsKey(quoteId) == false) {
                quoteIdOrderMap.put(quoteId, line.blng__OrderProduct__r.Order);
            }
        }

        // build a map so that correct order product is linked to manually created invoice line (for due date calculation)
        Map<String, Map<String, String>> quotefeeTypeOrderProductMap = new Map<String, Map<String, String>>();
        for(blng__InvoiceLine__c line : lines) {
            String quoteId = line.blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quote__c;
            if(quotefeeTypeOrderProductMap.containsKey(quoteId) == false) {
                quotefeeTypeOrderProductMap.put(quoteId, new Map<String, String>());
            }
            quotefeeTypeOrderProductMap.get(quoteId).put(line.Fee_Type__c, line.blng__OrderProduct__c);
            // commitment rebate
            if(line.blng__OrderProduct__r.SBQQ__QuoteLine__r.Category__c == QUOTELINE_CATEGORY_COMMITMENT_REBATE) {
                quotefeeTypeOrderProductMap.get(quoteId).put(QUOTELINE_CATEGORY_COMMITMENT_REBATE, line.blng__OrderProduct__c);
            }
            // commitment fee
            if(line.blng__OrderProduct__r.SBQQ__QuoteLine__r.Category__c == QUOTELINE_CATEGORY_COMMITMENT_FEE) {
                quotefeeTypeOrderProductMap.get(quoteId).put(QUOTELINE_CATEGORY_COMMITMENT_FEE, line.blng__OrderProduct__c);
            }
        }

        // get quotes, plans, plan lines, quote lines (to calculate the percentage of each fee type)
        Map<String, List<Customer_Invoice_Plan__c>> planMap = new Map<String, List<Customer_Invoice_Plan__c>>();    // key = quote id
        Map<String, SBQQ__Quote__c> quoteMap = new Map<String, SBQQ__Quote__c>();   // key = quote id
        for(SBQQ__Quote__c quote : [
            SELECT Id, SBQQ__Account__c, 
            (SELECT Id, Fee_Type__c FROM Customer_Invoice_Plans__r WHERE Active__c = true),
            (SELECT Id, Fee_Type__c, SBQQ__CustomerTotal__c, Category__c FROM SBQQ__LineItems__r WHERE Split_Flag__c = true)
            FROM SBQQ__Quote__c
            WHERE Id IN :quoteIds
        ]) {
            if(quote.Customer_Invoice_Plans__r.size() > 0) {
                // planMap.put(quote.Id, quote.Customer_Invoice_Plans__r[0]);
                quoteMap.put(quote.Id, quote);
                // planIds.add(quote.Customer_Invoice_Plans__r[0].Id);
                planIds.addAll((new Map<Id, Customer_Invoice_Plan__c>(quote.Customer_Invoice_Plans__r)).keySet());
            }
        }

        for(Customer_Invoice_Plan__c plan : [
            SELECT Id, Fee_Type__c, Quote__c, Include_Commitment_Fee__c, 
            (SELECT Id, Name, Amount__c, Commitment_Rebate__c, Invoice_Date__c, Purchase_Order_Number__c FROM Customer_Invoice_Plan_Lines__r ORDER BY Processing_Order__c ASC)
            FROM Customer_Invoice_Plan__c
            WHERE Id IN :planIds
        ]) {
            // planMap.put(plan.Quote__c, plan);
            if(planMap.containsKey(plan.Quote__c) == false) {
                planMap.put(plan.Quote__c, new List<Customer_Invoice_Plan__c>());
            }
            planMap.get(plan.Quote__c).add(plan);
        }

        // create invoices & invoice lines
        Map<Integer, T1_Invoice__c> invoiceMap = new Map<Integer, T1_Invoice__c>();
        Map<Integer, List<T1_Invoice_Line__c>> invoiceLineMap = new Map<Integer, List<T1_Invoice_Line__c>>();
        for(SBQQ__Quote__c quote : quoteMap.values()) {
            for(Customer_Invoice_Plan__c plan : planMap.get(quote.Id)) {
                Map<String, String> feeTypeOrderProductMap = quotefeeTypeOrderProductMap.get(quote.Id);
                
                List<Customer_Invoice_Plan_Line__c> planLines = plan.Customer_Invoice_Plan_Lines__r;
                Map<String, Double> distributionMap = getFeeTypeDistribution(quote.SBQQ__LineItems__r, plan);
                // OOB invoice(s)
                for(blng__Invoice__c oobInvoice : quoteIdInvoiceMap.get(quote.Id).values()) {
                    Integer i = 0;
                    Boolean commitmentFeeLineAdded = false;
                    // order of OOB invoice through invoice line - order product - order
                    Order order = quoteIdOrderMap.get(quote.Id);

                    // a invoice pere plan line
                    for(Customer_Invoice_Plan_Line__c planLine : planLines) {
                        Integer key = invoiceMap.size();
                        T1_Invoice__c invoice = new T1_Invoice__c();
                        invoice.Name = oobInvoice.Name + '-' + (++i);
                        invoice.Order__c = order.Id;
                        invoice.InvoiceDate__c = planLine.Invoice_Date__c;
                        invoice.Account__c = quote.SBQQ__Account__c;
                        invoice.Customer_Invoice_Plan__c = plan.Id;
                        invoice.Purchase_Order_Number__c = String.isNotBlank(planLine.Purchase_Order_Number__c) ? planLine.Purchase_Order_Number__c : order.Purchase_Order_Number__c;
                        invoice.Processed__c = false;
                        invoiceMap.put(key, invoice);
                        invoiceLineMap.put(key, new List<T1_Invoice_Line__c>());

                        for(String feeType : distributionMap.keySet()) {
                            T1_Invoice_Line__c invoiceLine = new T1_Invoice_Line__c();
                            invoiceLine.CalculatedQuantity__c = 1;
                            invoiceLine.Quantity__c = 1;
                            invoiceLine.ChargeType__c = QUOTELINE_CHARGE_TYPE_ONE_TIME;
                            invoiceLine.UnitPrice__c = planLine.Amount__c * distributionMap.get(feeType);
                            invoiceLine.Subtotal__c = invoiceLine.UnitPrice__c;
                            invoiceLine.TotalAmount__c = invoiceLine.UnitPrice__c;
                            invoiceLine.OrderProduct__c = feeTypeOrderProductMap.get(feeType);
                            // invoiceLine.Split_Flag__c = false;
                            // invoiceLine.Split_Done__c = true;
                            // use custom object instead, so no flag required
                            invoiceLine.Name = renameFeeType(feeType);
                            invoiceLineMap.get(key).add(invoiceLine);
                        }

                        // commitment rebate line
                        if(planLine.Commitment_Rebate__c != null && planLine.Commitment_Rebate__c < 0) {
                            T1_Invoice_Line__c invoiceLine = new T1_Invoice_Line__c();
                            invoiceLine.CalculatedQuantity__c = 1;
                            invoiceLine.Quantity__c = 1;
                            invoiceLine.ChargeType__c = QUOTELINE_CHARGE_TYPE_ONE_TIME;
                            invoiceLine.UnitPrice__c = planLine.Commitment_Rebate__c;
                            invoiceLine.Subtotal__c = invoiceLine.UnitPrice__c;
                            invoiceLine.TotalAmount__c = invoiceLine.UnitPrice__c;
                            invoiceLine.OrderProduct__c = feeTypeOrderProductMap.get(QUOTELINE_CATEGORY_COMMITMENT_REBATE);
                            // invoiceLine.Split_Flag__c = false;
                            // invoiceLine.Split_Done__c = true;
                            // use custom object instead, so no flag required
                            invoiceLine.Name = QUOTELINE_CATEGORY_COMMITMENT_REBATE;
                            invoiceLineMap.get(key).add(invoiceLine);
                        }

                        // commitment fee line for 1st split invoice only
                        if(plan.Include_Commitment_Fee__c == true && commitmentFeeLineAdded == false) {
                            // loop through quote lines
                            for(SBQQ__QuoteLine__c quoteLine : quote.SBQQ__LineItems__r) {
                                if(quoteLine.Category__c == QUOTELINE_CATEGORY_COMMITMENT_FEE) {
                                    T1_Invoice_Line__c invoiceLine = new T1_Invoice_Line__c();
                                    invoiceLine.CalculatedQuantity__c = 1;
                                    invoiceLine.Quantity__c = 1;
                                    invoiceLine.ChargeType__c = QUOTELINE_CHARGE_TYPE_ONE_TIME;
                                    invoiceLine.UnitPrice__c = quoteLine.SBQQ__CustomerTotal__c;
                                    invoiceLine.Subtotal__c = invoiceLine.UnitPrice__c;
                                    invoiceLine.TotalAmount__c = invoiceLine.UnitPrice__c;
                                    invoiceLine.OrderProduct__c = feeTypeOrderProductMap.get(QUOTELINE_CATEGORY_COMMITMENT_FEE);
                                    invoiceLine.Name = QUOTELINE_CATEGORY_COMMITMENT_FEE;
                                    invoiceLineMap.get(key).add(invoiceLine);
                                    commitmentFeeLineAdded = true;
                                }
                            }
                        }
                    }
                }
            }
        }

        // System.debug('invoiceMap: ' + invoiceMap);
        // System.debug('invoiceLineMap: ' + invoiceLineMap);

        if(invoiceMap.isEmpty()) return;

        try {
            // insert invoices
            insert invoiceMap.values();

            // insert invoice lines
            List<T1_Invoice_Line__c> invoiceLines = new List<T1_Invoice_Line__c>();
            for(Integer key : invoiceMap.keySet()) {
                T1_Invoice__c invoice = invoiceMap.get(key);
                for(T1_Invoice_Line__c line : invoiceLineMap.get(key)) {
                    line.Invoice__c = invoice.Id;
                    invoiceLines.add(line);
                }
            }

            // System.debug('invoiceLines: ' + invoiceLines);
            if(invoiceLines.size() > 0) {
                insert invoiceLines;
            }

            // update invoice lines to split done
            Map<Id, blng__Invoice__c> existingInvoices = new Map<Id, blng__Invoice__c>();
            for(blng__InvoiceLine__c line : lines) {
                line.Split_Done__c = true;
                // existingInvoices.put(line.blng__Invoice__c, new blng__Invoice__c(
                //     Id = line.blng__Invoice__c, 
                //     Customer_Invoice_Plan__c = planMap.get(line.blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quote__c).Id));
            }
            update lines;

            // associate the old invoice with CIP
            // update existingInvoices.values();

            // clone the non split invoice lines & invoice to T1 custom objects
            // depending on which batch runs first after invoice creation, there is chance that
            // clone invoice batch picks up non split lines first, in that case below code
            // won't generate new T1 records as re-query will return no invoice
            SM_CloneInvoice.cloneInvoicesAndLines(new List<Id>(invoiceIdsWithNotSplitLines));
        } catch(Exception e) { insert DM_ApplicationLog.createApplicationLog(e);
            System.debug('unable to complete split invoice: ' + e.getMessage());
        }
    }








    /****************************************************************************
     * Methods primarily used within the class
    ****************************************************************************/

    /**
    * @description 
    * @author Yi Zhang | 15/02/2021 
    * @param String feeType 
    * @return String 
    **/
    public static String renameFeeType(String feeType) {
        if(feeType == QUOTELINE_FEE_TYPE_CLOUD) return PLAN_FEE_TYPE_SAAS;
        if(feeType == QUOTELINE_FEE_TYPE_LICENSE) return PLAN_FEE_TYPE_LICENCE;
        return feeType;
    }


    /**
    * @description 
    * @author Yi Zhang | 15/02/2021 
    * @param List<SBQQ__QuoteLine__c> lines 
    * @param Customer_Invoice_Plan__c plan 
    * @return Map<String, Double> 
    **/
    public static Map<String, Double> getFeeTypeDistribution(List<SBQQ__QuoteLine__c> lines, Customer_Invoice_Plan__c plan) {

        Map<String, Double> amountDistribution = new Map<String, Double>();
        Double total = 0;
        for(SBQQ__QuoteLine__c line : lines) {
            if(quoteLineFeeTypeMatchesPlan(plan.Fee_Type__c, line.Fee_Type__c)) {
                total += (line.SBQQ__CustomerTotal__c == null) ? 0 : line.SBQQ__CustomerTotal__c;
                if(amountDistribution.containsKey(line.Fee_Type__c)) {
                    amountDistribution.put(line.Fee_Type__c, amountDistribution.get(line.Fee_Type__c) + line.SBQQ__CustomerTotal__c);
                } else {
                    amountDistribution.put(line.Fee_Type__c, (line.SBQQ__CustomerTotal__c == null) ? 0 : line.SBQQ__CustomerTotal__c);
                }
            }
        }

        Map<String, Double> percentageDistribution = new Map<String, Double>();
        
        for(String feeType : amountDistribution.keySet()) {
            if(total != 0) {
                percentageDistribution.put(feeType, amountDistribution.get(feeType)/total);
            } else {
                percentageDistribution.put(feeType, 0);
            }
        }
        
        System.debug('percentageDistribution: ' + percentageDistribution);
        return percentageDistribution;
    }

    /**
    * @description Flag / Unflag quote line, start with simple logic
    * @author Yi Zhang | 12/02/2021 
    * @param Customer_Invoice_Plan__c plan 
    * @param SBQQ__QuoteLine__c quoteLine 
    * @return SBQQ__QuoteLine__c 
    **/
    public static SBQQ__QuoteLine__c flagQuoteLine(Customer_Invoice_Plan__c plan, SBQQ__QuoteLine__c quoteLine) {
        // TODO in the future might need to store ChargeType, BillingFrequency, BillingType when flagged and restore them when unflagged
        if(plan.Active__c == true) {
            
            // - plan fee type = All: flag all quote lines with fee type = License, Cloud, ASM
            // - plan fee type = Licence: flag only quote lines with fee type = License
            // - plan fee type = SaaS Platform: flag only quote lines with fee type = Cloud
            // - plan has commitment rebate: flag quote lines with category = commitment rebate 
            // - plan has "Include Commitment Fee" ticked: flag quote lines with fee type = Commitment Fee
            // - ignore line with empty fee type
            if(quoteLineFeeTypeMatchesPlan(plan.Fee_Type__c, quoteLine.Fee_Type__c)
            || (plan.Commitment_Rebate_Sum__c < 0 && quoteLine.Category__c == QUOTELINE_CATEGORY_COMMITMENT_REBATE)
            || (plan.Include_Commitment_Fee__c == true && quoteLine.Category__c == QUOTELINE_CATEGORY_COMMITMENT_FEE) ) {
                quoteLine.Split_Flag__c         = true;
                quoteLine.SBQQ__ChargeType__c   = QUOTELINE_CHARGE_TYPE_ONE_TIME;
                quoteLine.SBQQ__BillingFrequency__c = null;
                quoteLine.SBQQ__BillingType__c = null;
            }
        } else {
            // unflag if plan is deactivated
            if(quoteLineFeeTypeMatchesPlan(plan.Fee_Type__c, quoteLine.Fee_Type__c)
            || (plan.Commitment_Rebate_Sum__c < 0 && quoteLine.Category__c == QUOTELINE_CATEGORY_COMMITMENT_REBATE) ) {
                quoteLine.Split_Flag__c         = false;
            }
        }
        

        return quoteLine;
    }

    /**
    * @description Return a ComparisonResult object which contains many data required for different validations (easy for expansion)
    * @author Yi Zhang | 19/02/2021 
    * @param Customer_Invoice_Plan__c plan - should contain plan lines with Type = Amount
    * @param SBQQ__Quote__c quote - should contain all quote lines 
    * @return ComparisonResult 
    **/
    public static ComparisonResult comparePlanQuote(Customer_Invoice_Plan__c plan, SBQQ__Quote__c quote) {

        Double planLinesTotal = 0;          // add lines with type = Amount. Note that Rollup field is not used as Rollup doesn't update until actual db commit
        Double quoteLinesTotal = 0;         // depending on plan type
        Double planLinesRebateTotal = 0; 
        Double quoteLinesRebateTotal = 0; 

        for(Customer_Invoice_Plan_Line__c line : plan.Customer_Invoice_Plan_Lines__r) {
            planLinesTotal += (line.Amount__c == null) ? 0 : line.Amount__c;
            planLinesRebateTotal += (line.Commitment_Rebate__c == null) ? 0 : line.Commitment_Rebate__c;
        }

        // quote total is dependent on plan fee type:
        // - plan fee type = All: all quote lines with fee type = License, Cloud, ASM
        // - plan fee type = Licence: only quote lines with fee type = License
        // - plan fee type = SaaS Platform: only quote lines with fee type = Cloud
        
        // quote rebate total is dependent on category:
        // - when category = Commitment Rebate
        for(SBQQ__QuoteLine__c line : quote.SBQQ__LineItems__r) {
            if(quoteLineFeeTypeMatchesPlan(plan.Fee_Type__c, line.Fee_Type__c)) {
                quoteLinesTotal += (line.SBQQ__CustomerTotal__c == null) ? 0 : line.SBQQ__CustomerTotal__c;
            }
            if(line.Category__c == QUOTELINE_CATEGORY_COMMITMENT_REBATE) {
                quoteLinesRebateTotal += (line.SBQQ__CustomerTotal__c == null) ? 0 : line.SBQQ__CustomerTotal__c;
            }
        }

        ComparisonResult cr = new ComparisonResult();
        cr.planAmountTotal  = planLinesTotal;
        cr.planRebateTotal  = planLinesRebateTotal;
        cr.quoteAmountTotal = quoteLinesTotal;
        cr.quoteRebateTotal = quoteLinesRebateTotal;

        return cr;
    }

    /**
    * @description 
    * @author Yi Zhang | 16/02/2021 
    * @param String planFeeType 
    * @param String lineFeeType 
    * @return Boolean 
    **/
    static Boolean quoteLineFeeTypeMatchesPlan(String planFeeType, String lineFeeType) {
        // - plan fee type = All: all quote lines with fee type = License, Cloud, ASM
        // - plan fee type = Licence: only quote lines with fee type = License
        // - plan fee type = SaaS Platform: only quote lines with fee type = Cloud
        // - ignore line with empty fee type
        return String.isNotBlank(lineFeeType) && 
        ((planFeeType == PLAN_FEE_TYPE_ALL && QUOTELINE_FEE_TYPES_ALL.contains(lineFeeType))
        || (planFeeType == PLAN_FEE_TYPE_LICENCE && lineFeeType == QUOTELINE_FEE_TYPE_LICENSE)
        || (planFeeType == PLAN_FEE_TYPE_SAAS && lineFeeType == QUOTELINE_FEE_TYPE_CLOUD)
        );
    }


    public class ComparisonResult {
        public Double planAmountTotal;      // positive
        public Double quoteAmountTotal;     // positive
        public Double planRebateTotal;      // negative
        public Double quoteRebateTotal;     // negative

        public Double planQuoteTotalDiff() {
            return this.planAmountTotal - this.quoteAmountTotal;
        }

        public Double planQuoteRebateDiff() {
            return this.planRebateTotal - this.quoteRebateTotal;
        }
    }
}