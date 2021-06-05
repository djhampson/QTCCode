/*******************************************************************************************************
* Class Name      	: SM_CloneInvoice
* Description		: Service layer to handle cloning of blng__Invoice__c to T1_Invoice__c (and lines)
* Author          	: Simplus - Yi Zhang
* Created On      	: 19/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              19/02/2021		1000				Initial version
* Yi Zhang              26/02/2021		2000				Populate T1 invoice's Order && PO Number fields
* Yi Zhang              22/03/2021		3000				TOCB-1658 copy unsplit invoice lines into custom invoice objects
******************************************************************************************************/
public class SM_CloneInvoice {
    public static final Integer CLONE_INVOICE_DELAY = 1;
    /**
    * @description  When invoice is created by checking Bill Now on order, schedule a delayed job to clone
    * @author Yi Zhang | 22/02/2021 
    * @param List<blng__Invoice__c> invoices 
    **/
    public static void cloneBillNowInvoices(List<blng__Invoice__c> invoices) {
        // filter invoices with Order (through Bill Now)
        List<String> invoiceIds = new List<String>();
        for(blng__Invoice__c invoice : invoices) {
            if(String.isNotBlank(invoice.blng__Order__c)) {
                invoiceIds.add(invoice.Id);
            }
        }
        if(invoiceIds.isEmpty()) return;

        // schedule a job to carry out cloning 
        // as when invoice is created, invoice line is not ready, need to wait 
        try {
            String jobName = 'SM_CloneInvoice; ' + invoiceIds[0] + '; ' + String.valueOf(DateTime.now());
            SM_CloneInvoiceSchedulable job = new SM_CloneInvoiceSchedulable(invoiceIds);
            String cronString = OrderTriggerHandler.getJobCronString(CLONE_INVOICE_DELAY);
            String jobId = System.schedule(jobName, cronString, job);    
        } catch(Exception e) {
            Application_Log__c log = DM_ApplicationLog.createApplicationLog(e);
            insert log;
        }
    }


    /**
    * @description Variant of core clone function
    * @author Yi Zhang | 22/02/2021 
    * @param List<blng__Invoice__c> invoices 
    **/
    public static void cloneInvoicesAndLines(List<blng__Invoice__c> invoices) {
        List<String> invoiceIds = new List<String>();
        for(blng__Invoice__c invoice : invoices) {
            invoiceIds.add(invoice.Id);
        }
        cloneInvoicesAndLines(invoiceIds);
    }
    
    /**
    * @description  Core function to clone invoices
    * @author Yi Zhang | 22/02/2021 
    * @param List<String> invoiceIds 
    **/
    public static void cloneInvoicesAndLines(List<String> invoiceIds) {
        System.debug('clone invoices and lines for ids: ' + invoiceIds);

        if(invoiceIds.isEmpty()) return;
        // get invoice and invoice lines

        Map<Id, blng__Invoice__c> invoices = new Map<Id, blng__Invoice__c>([
            SELECT Id
            , Name
            , CurrencyIsoCode
            , blng__Account__c
            , Approval_Status__c
            , blng__ARStatus__c
            , blng__BaseCurrency__c
            , blng__BaseCurrencyAmount__c
            , blng__BaseCurrencyFXDate__c
            , blng__BaseCurrencyFXRate__c
            , blng__BillToContact__c
            , blng__CorrectiveAction__c
            , Customer_Invoice_Plan__c
            , blng__DueDate__c
            , blng__InvoiceDate__c
            , blng__InvoicePostedDate__c
            , blng__InvoiceStatus__c
            , blng__Notes__c
            , blng__Order__c
            , Processed__c
            , Ready_to_sync__c
            , blng__TargetDate__c
            , blng__TaxStatus__c
            , blng__UniqueId__c
            , Split_Invoice_Line_Count__c
            , blng__NumberOfInvoiceLines__c
            ,(SELECT Id
            , Name
            , blng__ARStatus__c 
            , blng__AllocatedRevenueAmount__c 
            , blng__Asset__c 
            , blng__BaseCurrencyAmount__c 
            , blng__BaseCurrencyFXDate__c 
            , blng__BaseCurrencyFXRate__c 
            , blng__BaseCurrency__c 
            , blng__BillingFinanceBook__c 
            , blng__BillingFinancePeriod__c 
            , blng__BillingFrequency__c 
            , blng__BillingGLRule__c 
            , blng__BillingGLTreatment__c 
            , blng__BillingRule__c 
            , blng__BillingTransaction__c 
            , blng__BillingTreatment__c 
            , blng__CalculatedQuantity__c 
            , blng__ChargeDate__c 
            , blng__ChargeType__c 
            , blng__ConvertedCreditNoteLine__c 
            , blng__Credits__c 
            , blng__EndDate__c 
            , Fee_Type__c 
            , blng__GroupedQuantity__c 
            , blng__InvoiceLineState__c 
            , blng__InvoiceLineStatus__c 
            , blng__LegalEntityReference__c 
            , blng__LegalEntity__c 
            , blng__NegativeLineConversion__c 
            , New_Business__c 
            , blng__Notes__c 
            , blng__OrderProduct__c 
            , blng__OverrideInitialRevenueEndDate__c 
            , blng__OverrideInitialRevenueStartDate__c 
            , blng__Product__c 
            , blng__Quantity__c 
            , blng__RevenueExpectedAmount__c 
            , blng__RevenueLiabilityAmount__c 
            , blng__RevenueMostLikelyAmount__c 
            , blng__RevenueScheduleStatus__c 
            , Rounded_Amount__c 
            , blng__StartDate__c 
            , blng__Subtotal__c 
            , blng__TaxAmount__c 
            , blng__TaxCity__c 
            , blng__TaxCountry__c 
            , blng__TaxCounty__c 
            , blng__TaxGLRule__c 
            , blng__TaxGLTreatment__c 
            , blng__TaxLocationCode__c 
            , blng__TaxPercentageApplied__c 
            , blng__TaxRule__c 
            , blng__TaxState__c 
            , blng__TaxStatus__c 
            , blng__TaxStreet2__c 
            , blng__TaxStreet__c 
            , blng__TaxTreatment__c 
            , blng__TaxZipCode__c 
            , Third_Party_Type__c 
            , blng__TotalAmount__c 
            , Transaction_Type__c 
            , blng__UniqueId__c 
            , blng__UnitPrice__c 
            , blng__UsageSummary__c
            , CurrencyIsoCode  
            , blng__OrderProduct__r.OrderId
            , blng__OrderProduct__r.Order.Purchase_Order_Number__c
            FROM blng__InvoiceInvoiceLines__r WHERE Split_Flag__c = false)
            FROM blng__Invoice__c
            WHERE Id IN :invoiceIds
            AND Cloned_To_T1_Invoice__c = false
        ]);

        if(invoices.isEmpty()) return;

        Map<Integer, T1_Invoice__c> t1Invoices = new Map<Integer, T1_Invoice__c>();
        Map<Integer, List<T1_Invoice_Line__c>> t1InvoiceLines = new Map<Integer, List<T1_Invoice_Line__c>>();
        List<blng__Invoice__c> invoicesToUpdate = new List<blng__Invoice__c>();
        for(blng__Invoice__c invoice : invoices.values()) {
            // do not clone invoice is all about split, mark them as clone done to avoid them coming to batch again
            // but clone invoice which:
            // - does not require split at all
            // - requires partial split (i.e. some invoice lines has Split Flag = true)
            if(invoice.Split_Invoice_Line_Count__c == 0 || invoice.Split_Invoice_Line_Count__c == null || invoice.Split_Invoice_Line_Count__c < invoice.blng__NumberOfInvoiceLines__c) {
                Integer key = t1Invoices.size() + 1;
                // build T1 invoices
                T1_Invoice__c t1Invoice = cloneInvoice(invoice);
                // if order lookup not populated in OOB invoice, try through invoice line - order product - order
                if(t1Invoice.Order__c == null && invoice.blng__InvoiceInvoiceLines__r.size() > 0) {
                    t1Invoice.Order__c = invoice.blng__InvoiceInvoiceLines__r[0].blng__OrderProduct__r.OrderId;
                }
                // populate T1 invoice's PO Number from invoice line - order product - order's PO number
                if(invoice.blng__InvoiceInvoiceLines__r.size() > 0) {
                    t1Invoice.Purchase_Order_Number__c = invoice.blng__InvoiceInvoiceLines__r[0].blng__OrderProduct__r.Order.Purchase_Order_Number__c;
                }
                t1Invoices.put(key, t1Invoice);
                // build T1 invoice lines
                t1InvoiceLines.put(key, new List<T1_Invoice_Line__c>());
                for(blng__InvoiceLine__c line : invoice.blng__InvoiceInvoiceLines__r) {
                    t1InvoiceLines.get(key).add(cloneInvoiceLine(line));
                }    
            }

            // build invoices to update
            invoicesToUpdate.add(new blng__Invoice__c(Id = invoice.Id, Cloned_To_T1_Invoice__c = true));
        }

        try {
            // insert T1 invoices
            if(t1Invoices.size() > 0) {
                System.debug('t1Invoices: ' + t1Invoices);
                insert t1Invoices.values();

                // insert T1 invoice lines
                // populate line's lookup
                List<T1_Invoice_Line__c> lines = new List<T1_Invoice_Line__c>();
                for(Integer key : t1Invoices.keySet()) {
                    T1_Invoice__c invoice = t1Invoices.get(key);
                    for(T1_Invoice_Line__c line : t1InvoiceLines.get(key)) {
                        line.Invoice__c = invoice.Id;
                        lines.add(line);
                    }
                }
                insert lines;
            }

            // update invoice's clone flag
            update invoicesToUpdate;
        } catch(Exception e) {
            
            System.debug('invoice clone failed: ' + e.getMessage());

            Application_Log__c log = DM_ApplicationLog.createApplicationLog(e);
            insert log;
        }

    }

    /**
    * @description 
    * @author Yi Zhang | 22/02/2021 
    * @param blng__Invoice__c invoice 
    * @return T1_Invoice__c 
    **/
    public static T1_Invoice__c cloneInvoice(blng__Invoice__c invoice) {
        T1_Invoice__c t1Invoice = new T1_Invoice__c();
        t1Invoice.Source_Invoice__c = invoice.Id;
        t1Invoice.Name = invoice.Name;
        t1Invoice.CurrencyIsoCode = invoice.CurrencyIsoCode;
        t1Invoice.Account__c = invoice.blng__Account__c;
        t1Invoice.ARStatus__c = invoice.blng__ARStatus__c;
        t1Invoice.BaseCurrency__c = invoice.blng__BaseCurrency__c;
        t1Invoice.BaseCurrencyAmount__c = invoice.blng__BaseCurrencyAmount__c;
        t1Invoice.BaseCurrencyFXDate__c = invoice.blng__BaseCurrencyFXDate__c;
        t1Invoice.BaseCurrencyFXRate__c = invoice.blng__BaseCurrencyFXRate__c;
        t1Invoice.BillToContact__c = invoice.blng__BillToContact__c;
        t1Invoice.CorrectiveAction__c = invoice.blng__CorrectiveAction__c;
        t1Invoice.Customer_Invoice_Plan__c = invoice.Customer_Invoice_Plan__c;
        t1Invoice.DueDate__c = invoice.blng__DueDate__c;
        t1Invoice.InvoiceDate__c = invoice.blng__InvoiceDate__c;
        t1Invoice.InvoicePostedDate__c = invoice.blng__InvoicePostedDate__c;
        t1Invoice.InvoiceStatus__c = invoice.blng__InvoiceStatus__c;
        t1Invoice.Notes__c = invoice.blng__Notes__c;
        t1Invoice.Order__c = invoice.blng__Order__c;
        t1Invoice.Processed__c = invoice.Processed__c;
        t1Invoice.Ready_to_sync__c = invoice.Ready_to_sync__c;
        t1Invoice.TargetDate__c = invoice.blng__TargetDate__c;
        t1Invoice.TaxStatus__c = invoice.blng__TaxStatus__c;
        t1Invoice.UniqueId__c = invoice.blng__UniqueId__c;
        return t1Invoice;
    }

    /**
    * @description 
    * @author Yi Zhang | 22/02/2021 
    * @param blng__InvoiceLine__c line 
    * @return T1_Invoice_Line__c 
    **/
    public static T1_Invoice_Line__c cloneInvoiceLine(blng__InvoiceLine__c line) {
        T1_Invoice_Line__c t1Line = new T1_Invoice_Line__c();
        t1Line.Name = line.Name;
        t1Line.Source_Invoice_Line__c = line.Id;
        t1Line.CurrencyIsoCode = line.CurrencyIsoCode;
        t1Line.ARStatus__c = line.blng__ARStatus__c;
        t1Line.AllocatedRevenueAmount__c = line.blng__AllocatedRevenueAmount__c;
        t1Line.Asset__c = line.blng__Asset__c;
        t1Line.BaseCurrencyAmount__c = line.blng__BaseCurrencyAmount__c;
        t1Line.BaseCurrencyFXDate__c = line.blng__BaseCurrencyFXDate__c;
        t1Line.BaseCurrencyFXRate__c = line.blng__BaseCurrencyFXRate__c;
        t1Line.BaseCurrency__c = line.blng__BaseCurrency__c;
        t1Line.BillingFinanceBook__c = line.blng__BillingFinanceBook__c;
        t1Line.BillingFinancePeriod__c = line.blng__BillingFinancePeriod__c;
        t1Line.BillingFrequency__c = line.blng__BillingFrequency__c;
        t1Line.BillingGLRule__c = line.blng__BillingGLRule__c;
        t1Line.BillingGLTreatment__c = line.blng__BillingGLTreatment__c;
        t1Line.BillingRule__c = line.blng__BillingRule__c;
        t1Line.BillingTransaction__c = line.blng__BillingTransaction__c;
        t1Line.BillingTreatment__c = line.blng__BillingTreatment__c;
        t1Line.CalculatedQuantity__c = line.blng__CalculatedQuantity__c;
        t1Line.ChargeDate__c = line.blng__ChargeDate__c;
        t1Line.ChargeType__c = line.blng__ChargeType__c;
        t1Line.ConvertedCreditNoteLine__c = line.blng__ConvertedCreditNoteLine__c;
        t1Line.Credits__c = line.blng__Credits__c;  // ?
        t1Line.EndDate__c = line.blng__EndDate__c;
        t1Line.Fee_Type__c = line.Fee_Type__c;
        t1Line.GroupedQuantity__c = line.blng__GroupedQuantity__c;
        t1Line.InvoiceLineState__c = line.blng__InvoiceLineState__c;
        t1Line.InvoiceLineStatus__c = line.blng__InvoiceLineStatus__c;
        t1Line.LegalEntityReference__c = line.blng__LegalEntityReference__c;
        t1Line.LegalEntity__c = line.blng__LegalEntity__c;
        t1Line.NegativeLineConversion__c = line.blng__NegativeLineConversion__c;
        t1Line.New_Business__c = line.New_Business__c;
        t1Line.Notes__c = line.blng__Notes__c;
        t1Line.OrderProduct__c = line.blng__OrderProduct__c;
        t1Line.OverrideInitialRevenueEndDate__c = line.blng__OverrideInitialRevenueEndDate__c;
        t1Line.OverrideInitialRevenueStartDate__c = line.blng__OverrideInitialRevenueStartDate__c;
        t1Line.Product__c = line.blng__Product__c;
        t1Line.Quantity__c = line.blng__Quantity__c;
        t1Line.RevenueExpectedAmount__c = line.blng__RevenueExpectedAmount__c;
        t1Line.RevenueLiabilityAmount__c = line.blng__RevenueLiabilityAmount__c;
        t1Line.RevenueMostLikelyAmount__c = line.blng__RevenueMostLikelyAmount__c;
        t1Line.RevenueScheduleStatus__c = line.blng__RevenueScheduleStatus__c;
        t1Line.Rounded_Amount__c = line.Rounded_Amount__c;
        t1Line.StartDate__c = line.blng__StartDate__c;
        t1Line.Subtotal__c = line.blng__Subtotal__c;
        t1Line.TaxAmount__c = line.blng__TaxAmount__c;
        t1Line.TaxCity__c = line.blng__TaxCity__c;
        t1Line.TaxCountry__c = line.blng__TaxCountry__c;
        t1Line.TaxCounty__c = line.blng__TaxCounty__c;
        t1Line.TaxGLRule__c = line.blng__TaxGLRule__c;
        t1Line.TaxGLTreatment__c = line.blng__TaxGLTreatment__c;
        t1Line.TaxLocationCode__c = line.blng__TaxLocationCode__c;
        t1Line.TaxPercentageApplied__c = line.blng__TaxPercentageApplied__c;
        t1Line.TaxRule__c = line.blng__TaxRule__c;
        t1Line.TaxState__c = line.blng__TaxState__c;
        t1Line.TaxStatus__c = line.blng__TaxStatus__c;
        t1Line.TaxStreet2__c = line.blng__TaxStreet2__c;
        t1Line.TaxStreet__c = line.blng__TaxStreet__c;
        t1Line.TaxTreatment__c = line.blng__TaxTreatment__c;
        t1Line.TaxZipCode__c = line.blng__TaxZipCode__c;
        t1Line.Third_Party_Type__c = line.Third_Party_Type__c;
        t1Line.TotalAmount__c = line.blng__TotalAmount__c;
        t1Line.Transaction_Type__c = line.Transaction_Type__c;
        t1Line.UniqueId__c = line.blng__UniqueId__c;
        t1Line.UnitPrice__c = line.blng__UnitPrice__c;
        t1Line.UsageSummary__c = line.blng__UsageSummary__c;
        return t1Line;
    }
}