/*******************************************************************************************************
* Class Name      	: SM_CloneInvoiceSchedulable
* Description		: Schedulable class to asynchronously clone invoices (& lines) in Trigger context 
* Author          	: Simplus - Yi Zhang
* Created On      	: 22/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              22/02/2021		1000				Initial version
******************************************************************************************************/
global class SM_CloneInvoiceSchedulable implements Schedulable {
    
    global List<String> invoiceIds;

    /**
    * @description Constructor, initialise with a list of invoice ids
    * @author Yi Zhang | 22/02/2021 
    * @param List<String> ids 
    **/
    global SM_CloneInvoiceSchedulable(List<String> ids) {
        this.invoiceIds = ids;
    }

    /**
    * @description Standard execute method for schedulable class
    * @author Yi Zhang | 22/02/2021 
    * @param SchedulableContext sc 
    **/
    global void execute(SchedulableContext sc) {
        // clone invoices
        SM_CloneInvoice.cloneInvoicesAndLines(invoiceIds);
        
        // expand this to split invoice as well
        // pass all invoice lines to split invoice method
        SM_SplitInvoice.splitInvoices([SELECT Id, blng__Invoice__c, blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quote__c
        FROM blng__InvoiceLine__c 
        WHERE blng__Invoice__c IN :invoiceIds
        AND Split_Flag__c = true
        AND Split_Done__c = false
        ]);

        AsyncFrameworkUtil.cleanUpOneOffJob(sc);

    }
}