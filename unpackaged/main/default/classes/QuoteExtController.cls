/*******************************************************************************************************
* Class Name      	: QuoteExtController
* Description		: Controller to support advanced approval functionality on quote
* Author          	: Simplus - Jonathan Nayan
* Created On      	: 27/10/2020
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Jonathan Nayan        27/10/2020		1000				Initial version
******************************************************************************************************/
public with sharing class QuoteExtController {
    private Id quoteId;
    public QuoteExtController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
    }
    public PageReference onSubmit() {
        if (quoteId != null) {
            SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
        }
        return new PageReference('/' + quoteId);
    }
    public PageReference onRecall() {
        if (quoteId != null) {
            SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
        }
        return new PageReference('/' + quoteId);
    }
}