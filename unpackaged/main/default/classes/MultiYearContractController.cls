/*******************************************************************************************************
* @Class Name   : MultiYearContractController
* @description  : Controller for VF Page Expand_to_Groups
* @author       : Simplus - Carlos Roy Billones
* @date         : 04/11/2020
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Carlos Roy Billones   04/11/2020      1000        Initial version
* Yi Zhang              12/03/2021      2000        Applied comments & added conditions to DMLs
******************************************************************************************************/
public class MultiYearContractController {
    private final SBQQ__Quote__c quote;
    @TestVisible public static String incentiveTypeval {get;set;}
    @TestVisible public static Integer yearsval {get;set;}
    @TestVisible public static Integer monthsval {get;set;}
    public SBQQ__QuoteLineGroup__c QLGroup { get; private set; }
    
    /**
    * @description - Provide incentive type options
    * @author Carlos Roy Billones | 04/11/2020
    * @return List<SelectOption> 
    **/
    public static List<SelectOption> getIncentiveType() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectOption('Free Period', 'Free Period'));
        options.add(new selectOption('Billing Holiday', 'Billing Holiday'));
        return options;
	}
    
    /**
    * @description - Provide month options
    * @author Carlos Roy Billones | 04/11/2020
    * @return List<SelectOption> 
    **/
    public static List<SelectOption> getMonths() {
     List<SelectOption> options = new List<SelectOption>();
     options.add(new selectOption('', 'None'));
     options.add(new selectOption('1', '1 Months'));
     options.add(new selectOption('2', '2 Months'));
     options.add(new selectOption('3', '3 Months'));
     options.add(new selectOption('4', '4 Months'));
     options.add(new selectOption('5', '5 Months'));
     options.add(new selectOption('6', '6 Months'));
     options.add(new selectOption('7', '7 Months'));
     options.add(new selectOption('8', '8 Months'));
     options.add(new selectOption('9', '9 Months'));
     options.add(new selectOption('10', '10 Months'));
     options.add(new selectOption('11', '11 Months'));
     options.add(new selectOption('12', '12 Months'));
    
     return options;
	}
    
    /**
    * @description - Provide year options
    * @author Carlos Roy Billones | 04/11/2020
    * @return List<SelectOption> 
    **/
    public static List<SelectOption> getYears() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectOption('1', '1 Year'));
        options.add(new selectOption('2', '2 Years'));
        options.add(new selectOption('3', '3 Years'));
        options.add(new selectOption('4', '4 Years'));
        options.add(new selectOption('5', '5 Years'));
        options.add(new selectOption('6', '6 Years'));
        options.add(new selectOption('7', '7 Years'));
        options.add(new selectOption('8', '8 Years'));
        
        return options;
    }
    
    /**
    * @description - Constructor
    * @author Carlos Roy Billones | 04/11/2020
    **/
    public MultiYearContractController(){
        quote = [SELECT Id, SBQQ__LineItemsGrouped__c, (SELECT Id,  SBQQ__ProductName__c, SBQQ__Product__c, SBQQ__ListPrice__c, SBQQ__Quantity__c, SBQQ__ProductCode__c, SBQQ__RequiredBy__c,SBQQ__Number__c FROM SBQQ__LineItems__r ORDER BY SBQQ__Number__c ASC) FROM SBQQ__Quote__c WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
    }
    
    /**
    * @description 
    * @author Carlos Roy Billones | 04/11/2020 
    * @return SBQQ__Quote__c 
    **/
    public SBQQ__Quote__c getQuote(){
        return quote;
    }
    
    /**
    * @description - Orchestator to call different methods based on user input
    * @author Carlos Roy Billones | 04/11/2020 
    * @return PageReference 
    **/
    public PageReference applyquote(){
        
        if(incentiveTypeval == 'Free Period' && monthsval != null){
            System.debug('Free Period');
        	return applyFreePeriod();    
        }
        else if(incentiveTypeval == 'Billing Holiday' && monthsval != null)
        {
            System.debug('Billing Holiday');
            return applyBillingHoliday();
        }
        else{
            System.debug('Standard');
            return applyStandardQuote();
        }
        
    }
    
    /**
    * @description - Actions when Incentive Type = 'Free Period'
    * @author Carlos Roy Billones | 04/11/2020 
    * @return PageReference 
    **/
    public static PageReference applyFreePeriod(){
        
        List<SBQQ__QuoteLineGroup__c> yeargroup_list = new List<SBQQ__QuoteLineGroup__c>();
        List<SBQQ__QuoteLine__c> original_quotelines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> productlines = new List<SBQQ__QuoteLine__c>();
        
        Map<Id,Map<Id,Id>> qlgSourceCloneMap = new Map<Id,Map<Id,Id>>();
        
        if(monthsval == null){
            monthsval = 0;
        }
        
        integer remainingbillablemonths = 12 - monthsval;
        
        date previousEndDate;
        
        SBQQ__Quote__c quote = DS_Quote.getQuoteById(ApexPages.currentPage().getParameters().get('Id')); 
        quote.SBQQ__LineItemsGrouped__c = true;
        quote.Streamline_Revenue__c = true;        
        
        // create free period quote line group
        SBQQ__QuoteLineGroup__c freePeriod = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = quote.Id,
                                                                         Period_Type__c = incentiveTypeval,
                                                                         Name = incentiveTypeval,
                                                                         SBQQ__StartDate__c = quote.SBQQ__StartDate__c,
                                                                         Interval_in_Months__c = monthsval);
        
        if(monthsval == 0){
            freePeriod.SBQQ__EndDate__c = freePeriod.SBQQ__StartDate__c.addYears(1).addDays(-1);
        }
        else{
            freePeriod.SBQQ__EndDate__c = freePeriod.SBQQ__StartDate__c.addMonths(monthsval).addDays(-1);
        }
        
        insert freePeriod;

        // move existing quote lines into free period group and apply 100% discount
        for(SBQQ__QuoteLine__c quoteLine : DS_QuoteLine.getQuoteLineByQuoteId(quote.Id)){
            quoteLine.SBQQ__Group__c = freePeriod.Id;
            quoteLine.SBQQ__Discount__c = 100;
            original_quotelines.add(quoteLine);
        }
        
        if(original_quotelines.size() > 0) {
            upsert original_quotelines;
        }
        
        // create quote line groups for other periods
        for(integer i = 1; i <= yearsval; i++){
            SBQQ__QuoteLineGroup__c yeargroup = new SBQQ__QuoteLineGroup__c();
			yeargroup.SBQQ__Quote__c = quote.Id;
            yeargroup.Name = 'Year ' + i;
            yeargroup.SBQQ__Number__c = i;
            yeargroup.Period_Type__c = 'Standard';
            
            if(i == 1){
                yeargroup.SBQQ__StartDate__c = freePeriod.SBQQ__EndDate__c.addDays(1);
                yeargroup.SBQQ__EndDate__c = yeargroup.SBQQ__StartDate__c.addMonths(remainingbillablemonths).addDays(-1);
                previousEndDate = yeargroup.SBQQ__EndDate__c;
            }
            else{
                yeargroup.SBQQ__StartDate__c = previousEndDate.addDays(1);
                yeargroup.SBQQ__EndDate__c = yeargroup.SBQQ__StartDate__c.addYears(1).addDays(-1);
                previousEndDate = yeargroup.SBQQ__EndDate__c;
            }
            yeargroup_list.add(yeargroup);
            
        }
        
        update quote;

        if(yeargroup_list.size() > 0) {
            upsert yeargroup_list;
        }
        
        Map<Id,SBQQ__QuoteLine__c> discountbundleMap = new Map<Id,SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> discountbundleList = createDiscountGroup(quote, original_quotelines, quote.SBQQ__StartDate__c, previousEndDate);
        
        for(SBQQ__QuoteLine__c ql :discountbundleList){
            discountbundleMap.put(ql.Id,ql);
        }
        
        for(SBQQ__QuoteLine__c ql :original_quotelines){
            if(!discountbundleMap.containsKey(ql.Id)){
                productlines.add(ql);
            }
        }
        
        // cloning quote lines for each group
        List<SBQQ__QuoteLine__c> clone_quotelines = DS_QuoteLine.getClonedQuoteLines(yeargroup_list, productlines);
        
        if(clone_quotelines.size() > 0) {
            upsert clone_quotelines;
        }
        
        // establish the relationship for cloned quote lines based on the source quote lines
        for(SBQQ__QuoteLine__c ql : clone_quotelines){
            if(qlgSourceCloneMap.containskey(ql.SBQQ__Group__c)){
                Map<Id,Id> sourceclonemap = qlgSourceCloneMap.get(ql.SBQQ__Group__c);
                sourceclonemap.put(ql.getCloneSourceId(), ql.Id);
            }
            else{
                Map<Id,Id> sourceclonemap = new Map<Id,Id>();
                sourceclonemap.put(ql.getCloneSourceId(), ql.Id);
                qlgSourceCloneMap.put(ql.SBQQ__Group__c,sourceclonemap);
            }
        }
        
        for(SBQQ__QuoteLine__c ql : clone_quotelines){
            if(qlgSourceCloneMap.containskey(ql.SBQQ__Group__c)){
                Map<Id,Id> sourceclonemap = qlgSourceCloneMap.get(ql.SBQQ__Group__c);
                if(ql.SBQQ__RequiredBy__c != null && sourceclonemap.containskey(ql.SBQQ__RequiredBy__c)){
                    ql.SBQQ__RequiredBy__c = sourceclonemap.get(ql.SBQQ__RequiredBy__c);
                }
            }
        }
        
        if(clone_quotelines.size() > 0) {
            update clone_quotelines;
        }
        
        PageReference pr = new PageReference('/apex/sbqq__sb?scontrolCaching=1&id=' + quote.Id);
        pr.setRedirect(true);
        return pr;
    }
    
    /**
    * @description - Actions when Incentive Type = 'Billing Holiday'
    * @author Carlos Roy Billones | 04/11/2020 
    * @return PageReference 
    **/
    public static PageReference applyBillingHoliday(){
        
        List<SBQQ__QuoteLineGroup__c> yeargroup_list = new List<SBQQ__QuoteLineGroup__c>();
        List<SBQQ__QuoteLine__c> original_quotelines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> productlines = new List<SBQQ__QuoteLine__c>();
        
        Map<Id,Map<Id,Id>> qlgSourceCloneMap = new Map<Id,Map<Id,Id>>();
        if(monthsval == null){
            monthsval = 0;
        }
        
        integer remainingbillablemonths = 12 - monthsval;
        date previousEndDate;
        
        SBQQ__Quote__c quote = DS_Quote.getQuoteById(ApexPages.currentPage().getParameters().get('Id')); 
        quote.SBQQ__LineItemsGrouped__c = true;        
        quote.Streamline_Revenue__c = true;   
        
        // create billing holiday quote line group
        SBQQ__QuoteLineGroup__c billingHoliday = new SBQQ__QuoteLineGroup__c();
        billingHoliday.SBQQ__Quote__c = quote.Id;
        billingHoliday.Period_Type__c = incentiveTypeval;
        billingHoliday.Name = incentiveTypeval;
        billingHoliday.SBQQ__StartDate__c = quote.SBQQ__StartDate__c;
        billingHoliday.Interval_in_Months__c = monthsval;
        Date BHEndDate = quote.SBQQ__StartDate__c.addMonths(monthsval).addDays(-1);
        System.debug(LoggingLevel.ERROR,'BILLING HOLIDAY END DATE IS => ' + BHEndDate);
        billingHoliday.SBQQ__EndDate__c = BHEndDate;
        
        if(monthsval == 0){
            billingHoliday.SBQQ__EndDate__c = quote.SBQQ__StartDate__c.addMonths(12).addDays(-1);
        }
        
        previousEndDate = billingHoliday.SBQQ__EndDate__c;
        insert billingHoliday;
        
        // move existing quote lines into billing holiday group and apply 100% discount
        for(SBQQ__QuoteLine__c quoteLine : DS_QuoteLine.getQuoteLineByQuoteId(quote.Id)){
            quoteLine.SBQQ__Group__c = billingHoliday.Id;
            quoteLine.SBQQ__Discount__c = 100;
            original_quotelines.add(quoteLine);
        }
        
        if(original_quotelines.size() > 0) {
            upsert original_quotelines;
        }
        
        // create quote line groups for other periods
        for(integer i = 1; i <= yearsval; i++){
            SBQQ__QuoteLineGroup__c yeargroup = new SBQQ__QuoteLineGroup__c();
			yeargroup.SBQQ__Quote__c = quote.Id;
            yeargroup.Name = 'Year ' + i;
            yeargroup.SBQQ__Number__c = i;
            yeargroup.Period_Type__c = 'Standard';
            yeargroup.SBQQ__StartDate__c = previousEndDate.addDays(1);
            yeargroup.SBQQ__EndDate__c = yeargroup.SBQQ__StartDate__c.addYears(1).addDays(-1);
            previousEndDate = yeargroup.SBQQ__EndDate__c;
            yeargroup_list.add(yeargroup);
            
        }
        
        update quote;

        if(yeargroup_list.size() > 0) {
            upsert yeargroup_list;
        }
        
        Map<Id,SBQQ__QuoteLine__c> discountbundleMap = new Map<Id,SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> discountbundleList = createDiscountGroup(quote, original_quotelines, quote.SBQQ__StartDate__c, previousEndDate);
        for(SBQQ__QuoteLine__c ql :discountbundleList){
            discountbundleMap.put(ql.Id,ql);
        }
        
        for(SBQQ__QuoteLine__c ql :original_quotelines){
            if(!discountbundleMap.containsKey(ql.Id)){
                productlines.add(ql);
            }
        }
        
        // cloning quote lines for each group
        List<SBQQ__QuoteLine__c> clone_quotelines = DS_QuoteLine.getClonedQuoteLines(yeargroup_list, productlines);
        
        if(clone_quotelines.size() > 0) {
            upsert clone_quotelines;
        }
        
        // establish the relationship for cloned quote lines based on the source quote lines
        for(SBQQ__QuoteLine__c ql : clone_quotelines){
            if(qlgSourceCloneMap.containskey(ql.SBQQ__Group__c)){
                Map<Id,Id> sourceclonemap = qlgSourceCloneMap.get(ql.SBQQ__Group__c);
                sourceclonemap.put(ql.getCloneSourceId(), ql.Id);
            }
            else{
                Map<Id,Id> sourceclonemap = new Map<Id,Id>();
                sourceclonemap.put(ql.getCloneSourceId(), ql.Id);
                qlgSourceCloneMap.put(ql.SBQQ__Group__c,sourceclonemap);
            }
        }
        
        // establish the relationship for cloned quote lines based on the source quote lines
        for(SBQQ__QuoteLine__c ql : clone_quotelines){
            if(qlgSourceCloneMap.containskey(ql.SBQQ__Group__c)){
                Map<Id,Id> sourceclonemap = qlgSourceCloneMap.get(ql.SBQQ__Group__c);
                if(ql.SBQQ__RequiredBy__c != null && sourceclonemap.containskey(ql.SBQQ__RequiredBy__c)){
                    ql.SBQQ__RequiredBy__c = sourceclonemap.get(ql.SBQQ__RequiredBy__c);
                }
            }
        }
        
        if(clone_quotelines.size() > 0) {
            update clone_quotelines;
        }
        
        PageReference pr = new PageReference('/apex/sbqq__sb?scontrolCaching=1&id=' + quote.Id);
        pr.setRedirect(true);
        return pr;
    }
    
    /**
    * @description - Actions when no Incentive Type selected
    * @author Carlos Roy Billones | 04/11/2020 
    * @return PageReference 
    **/
    public static PageReference applyStandardQuote(){
        List<SBQQ__QuoteLineGroup__c> yeargroup_list = new List<SBQQ__QuoteLineGroup__c>();
        List<SBQQ__QuoteLine__c> original_quotelines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> productlines = new List<SBQQ__QuoteLine__c>();
        Map<Id,Map<Id,Id>> qlgSourceCloneMap = new Map<Id,Map<Id,Id>>();
        
        if(monthsval == null)
        {
            monthsval = 0;
        }
        
        integer remainingbillablemonths = 12 - monthsval;
        date previousEndDate;
        
        SBQQ__Quote__c quote = DS_Quote.getQuoteById(ApexPages.currentPage().getParameters().get('Id')); 
        quote.SBQQ__LineItemsGrouped__c = true;
        quote.Streamline_Revenue__c = true;   
        
        // create 1st year quote line group
        SBQQ__QuoteLineGroup__c year_1 = new SBQQ__QuoteLineGroup__c();
        year_1.SBQQ__Quote__c = quote.Id;
        year_1.Period_Type__c = 'Standard';
        year_1.Name = 'Year 1';
        year_1.SBQQ__Number__c = 1;
        year_1.SBQQ__StartDate__c = quote.SBQQ__StartDate__c;
        year_1.SBQQ__EndDate__c = year_1.SBQQ__StartDate__c.addYears(1).addDays(-1);
        previousEndDate = year_1.SBQQ__EndDate__c;
        insert year_1;
        
        // move existing quote lines into 1st year group
        for(SBQQ__QuoteLine__c ql : DS_QuoteLine.getQuoteLineByQuoteId(quote.Id)){
            ql.SBQQ__Group__c = year_1.Id;
            original_quotelines.add(ql);
        }
        
        if(original_quotelines.size() > 0) {
            upsert original_quotelines;
        }
        
        // create quote line groups for other periods
        for(integer i = 2; i <= yearsval; i++){
            SBQQ__QuoteLineGroup__c yeargroup = new SBQQ__QuoteLineGroup__c();
			yeargroup.SBQQ__Quote__c = quote.Id;
            yeargroup.Name = 'Year ' + i;
            yeargroup.SBQQ__Number__c = i;
            yeargroup.Period_Type__c = 'Standard';
            yeargroup.SBQQ__StartDate__c = previousEndDate.addDays(1);
            yeargroup.SBQQ__EndDate__c = yeargroup.SBQQ__StartDate__c.addYears(1).addDays(-1);
            previousEndDate = yeargroup.SBQQ__EndDate__c;
            
            yeargroup_list.add(yeargroup);
            
        }
        update quote;
        if(yeargroup_list.size() > 0) {
            upsert yeargroup_list;
        }
        
        Map<Id,SBQQ__QuoteLine__c> discountbundleMap = new Map<Id,SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> discountbundleList = createDiscountGroup(quote, original_quotelines, quote.SBQQ__StartDate__c, previousEndDate);
        
        for(SBQQ__QuoteLine__c ql :discountbundleList){
            discountbundleMap.put(ql.Id,ql);
        }
        
        for(SBQQ__QuoteLine__c ql :original_quotelines){
            if(!discountbundleMap.containsKey(ql.Id)){
                productlines.add(ql);
            }
        }
        
        // cloning quote lines for each group
        List<SBQQ__QuoteLine__c> clone_quotelines = DS_QuoteLine.getClonedQuoteLines(yeargroup_list, productlines);
        
        if(clone_quotelines.size() > 0) {
            upsert clone_quotelines;
        }
        
        // establish the relationship for cloned quote lines based on the source quote lines
        for(SBQQ__QuoteLine__c ql : clone_quotelines){
            if(qlgSourceCloneMap.containskey(ql.SBQQ__Group__c)){
                Map<Id,Id> sourceclonemap = qlgSourceCloneMap.get(ql.SBQQ__Group__c);
                sourceclonemap.put(ql.getCloneSourceId(), ql.Id);
            }
            else{
                Map<Id,Id> sourceclonemap = new Map<Id,Id>();
                sourceclonemap.put(ql.getCloneSourceId(), ql.Id);
                qlgSourceCloneMap.put(ql.SBQQ__Group__c,sourceclonemap);
            }
        }
        
        for(SBQQ__QuoteLine__c ql : clone_quotelines){
            if(qlgSourceCloneMap.containskey(ql.SBQQ__Group__c)){
                Map<Id,Id> sourceclonemap = qlgSourceCloneMap.get(ql.SBQQ__Group__c);
                if(ql.SBQQ__RequiredBy__c != null && sourceclonemap.containskey(ql.SBQQ__RequiredBy__c)){
                    ql.SBQQ__RequiredBy__c = sourceclonemap.get(ql.SBQQ__RequiredBy__c);
                }
            }
        }
        
        if(clone_quotelines.size() > 0) {
            update clone_quotelines;
        }
        
        PageReference pr = new PageReference('/apex/sbqq__sb?scontrolCaching=1&id=' + quote.Id);
        pr.setRedirect(true);
        return pr;
    }
    
    /**
    * @description - Create discount quote line groups
    * @author Carlos Roy Billones | 04/11/2020 
    * @param SBQQ__Quote__c quote 
    * @param List<SBQQ__QuoteLine__c> quoteline 
    * @param Date startDate 
    * @param Date endDate 
    * @return List<SBQQ__QuoteLine__c> 
    **/
    public static List<SBQQ__QuoteLine__c> createDiscountGroup(SBQQ__Quote__c quote, List<SBQQ__QuoteLine__c> quoteline, Date startDate, Date endDate){
        
        List<SBQQ__QuoteLine__c> ediscbundle = new List<SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> ediscbundleMap = new Map<Id, SBQQ__QuoteLine__c>();
        SBQQ__QuoteLineGroup__c discountGroup = new SBQQ__QuoteLineGroup__c(Name = 'Discount', 
                                                                            SBQQ__Quote__c = quote.Id, 
                                                                            Period_Type__c = 'Standard', 
                                                                            SBQQ__StartDate__c = startDate, 
                                                                            SBQQ__EndDate__c = endDate);
        insert discountGroup;
        
        for(SBQQ__QuoteLine__c ql :quoteline){
            if(ql.SBQQ__ProductCode__c == 'EDISC' && ql.SBQQ__Quote__c == quote.Id){
            	ql.SBQQ__Group__c = discountGroup.id;
                ediscbundle.add(ql);
                ediscbundleMap.put(ql.Id,ql);
            }
            
            if(ql.SBQQ__ProductCode__c == 'Commitment Fee' && ql.SBQQ__Quote__c == quote.Id){
            	ql.SBQQ__Group__c = discountGroup.id; 
                ediscbundle.add(ql);
                ediscbundleMap.put(ql.Id,ql);
            }
        }
        
        for(SBQQ__QuoteLine__c ql :quoteline){
            
            
            if(ql.SBQQ__RequiredBy__c != null && ediscbundleMap.containsKey(ql.SBQQ__RequiredBy__c)){
                ql.SBQQ__Group__c = discountGroup.id;
                ediscbundle.add(ql);
            }
            
        }
        
        if(ediscbundle.size() > 0){
        	update ediscbundle;    
        }
        
        return ediscbundle;
        
    }
}