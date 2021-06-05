/*******************************************************************************************************
* Class Name      	: OrderTriggerHandler
* Description		: Service class for OrderTrigger
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 1-14-2020
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	1-14-2020			Initial version 
******************************************************************************************************/
public class OrderTriggerHandler {
    public FINAL STATIC STRING cronJobPrefix = 'T1_Job';
    
    /*
*@Description: method handler for after Insert
*@params: Trigger.new
*/
    
    public static void doAfterInsert(List<Order> Orders){
        /*System.debug('AFTER INSERT');
        Set<Id> QuoteIds = new Set<Id>();
        Set<Id> CustInvoicePlanIds = new Set<Id>();
        Map<Id,Order> CustInvoicePlanToOrderMap = new Map<Id,Order>();
        Map<Id,Order> QuoteIdToOrderNumMap = new Map<Id,Order>();
        List<Customer_Invoice_Plan__c> CustInvoicePlan = new List<Customer_Invoice_Plan__c>();
        List<Customer_Invoice_Plan_Line__c> CustInvoicePlanLine = new List<Customer_Invoice_Plan_Line__c>();*/
        
        Integer i = 1;
        for(Order orderRec :Orders){
            
            If(orderRec.Auto_Amendment__c){
                String jobName = getJobName(orderRec.Id);
                T1_ActivateOrder job = new T1_ActivateOrder(orderRec);
                String cronString = getJobCronString(i);  //1 minute
                abortPreviousJobs(orderRec.Id);
                System.debug('Processing aborted: ' + jobName);
                String jobId = System.schedule(jobName, cronString, job); 
                i = i + 1; 
            }
            
            /*QuoteIds.add(orderRec.SBQQ__Quote__c); // ADDED
            
            // POPULATE QUOTE TO ORDER NUMBER MAP
            If(QuoteIdToOrderNumMap.get(orderRec.SBQQ__Quote__c) == null){
                QuoteIdToOrderNumMap.put(orderRec.SBQQ__Quote__c,orderRec);
            }*/
        }
        
        // GET ALL THE QUOTE CIP RECORDS THAT LINKS TO THE CUSTOMER INVOICE PLANS
        /*List<Quote_CIP__c> QCIP = [SELECT Id,Quote__c,Customer_Invoice_Plan__c,Fee_Type__c FROM Quote_CIP__c WHERE Quote__c IN: QuoteIds];
        
        if(QCIP.size() > 0){
            // ADD CUSTOMER INVOICE PLAN IDS IN SET
            for(Quote_CIP__c QCIPRec :QCIP){
                CustInvoicePlanIds.add(QCIPRec.Customer_Invoice_Plan__c);
                if(CustInvoicePlanToOrderMap.get(QCIPRec.Customer_Invoice_Plan__c) == null){
                    CustInvoicePlanToOrderMap.put(QCIPRec.Customer_Invoice_Plan__c,QuoteIdToOrderNumMap.get(QCIPRec.Quote__c));
                }
            }
            
            // GET ALL CUSTOMER INVOICE PLANS
            CustInvoicePlan = [SELECT Id,Active__c,Name FROM Customer_Invoice_Plan__c WHERE Id IN: CustInvoicePlanIds];
            
            // GET ALL CUSTOMER INVOICE PLAN LINES
            CustInvoicePlanLine = [SELECT Id,Invoice_Date__c,Customer_Invoice_Plan__r.Active__c,
                                   Name,Customer_Invoice_Plan__c,Processing_Order__c,Amount__c  
                                   FROM Customer_Invoice_Plan_Line__c
                                   WHERE Customer_Invoice_Plan__c IN: CustInvoicePlanIds];
            
            List<blng__InvoicePlan__c> InvoicePlanList = createInvoicePlan(CustInvoicePlan,CustInvoicePlanToOrderMap);
            
            If(InvoicePlanList.size() > 0){
                INSERT InvoicePlanList; 
                
                List<blng__InvoicePlan__c> InvoicePlanNewInserted = [SELECT Id,Order_Id__c FROM blng__InvoicePlan__c WHERE Id IN: InvoicePlanList];
                List<Order> OrderToUpdate = new List<Order>();
                for(blng__InvoicePlan__c InvoicePlanRec:InvoicePlanNewInserted){
                    Order OrderRec = new Order(Id = InvoicePlanRec.Order_Id__c,
                                               Invoice_Plan__c = InvoicePlanRec.Id);
                    OrderToUpdate.add(OrderRec);
                }
                
                If(OrderToUpdate.size() > 0){
                    UPDATE OrderToUpdate; 
                }
                
            } 
            
            List<blng__InvoicePlanLine__c> createInvoicePlanLines = createInvoicePlanLines(CustInvoicePlanLine);
            If(createInvoicePlanLines.size() > 0){
                INSERT createInvoicePlanLines;
            }
            System.debug('Orders: '+ Orders);
            List<blng__BillingRule__c> BillingRuleLst = createBillingRule(Orders);
            If(BillingRuleLst.size() > 0){
                INSERT BillingRuleLst;
                System.debug('Line 97 BillingRuleLst: ' + BillingRuleLst);
                List<blng__BillingTreatment__c> BlngTreatmentLst = createBillingTreatment(BillingRuleLst);
                If(BlngTreatmentLst.size() > 0){
                    INSERT BlngTreatmentLst;
                }
            }
        }*/
    }
    
    
    
    /*
*@Description: METHOD TO CREATE BILLING INVOICE PLAN RECORDS
*@params: N/A
*/  
    
   /* public static List<blng__InvoicePlan__c> createInvoicePlan(List<Customer_Invoice_Plan__c> CustInvoicePlan, Map<Id,Order> CustInvoicePlanToOrderNumMap){
        
        List<blng__InvoicePlan__c> InvoicePlanList = new List<blng__InvoicePlan__c>();
        List<Order> OrderToUpdateList = new List<Order>();
        Set<Id> CIPIds= new Set<Id>();
        
        // LOOP ON ALL CUSTOMER INVOICE PLAN AND GET IDS
        for(Customer_Invoice_Plan__c CustomerInvoicePlanRec :CustInvoicePlan){
            CIPIds.add(CustomerInvoicePlanRec.Id);
        }
        
        // LOOP ON ALL CUSTOMER INVOICE PLAN
        for(Customer_Invoice_Plan__c CustInvPlan:CustInvoicePlan){
            if(CustInvPlan.Active__c){
                blng__InvoicePlan__c InvPlanRec = new blng__InvoicePlan__c(Name = CustInvPlan.Name + ' - ' + CustInvoicePlanToOrderNumMap.get(CustInvPlan.Id).Name_of_Account__c + ' - ' + System.today(),
                                                                           Order_Id__c = CustInvoicePlanToOrderNumMap.get(CustInvPlan.Id).Id,
                                                                           blng__Active__c = CustInvPlan.Active__c,
                                                                           Customer_Invoice_Plan__c = CustInvPlan.Id,
                                                                           blng__BillingScheduleCreation__c = 'Order Product Activation');
                InvoicePlanList.add(InvPlanRec); 
            }
        }
        return InvoicePlanList;
        
    }*/
    
    
    /*
*@Description: METHOD TO CREATE BILLING INVOICE PLAN LINE RECORDS
*@params: LIST OF CUSTOMER INVOICE PLANS
*/  
    /*public static List<blng__InvoicePlanLine__c> createInvoicePlanLines(List<Customer_Invoice_Plan_Line__c> CustInvoicePlanLine){
        Set<Id> CustomerInvPlanIds = new Set<Id>();
        Map<Id,List<Customer_Invoice_Plan_Line__c>> CPlanToCPlanLineMap = new Map<Id,List<Customer_Invoice_Plan_Line__c>>();
        Map<Id,Decimal> CPlanToMaxOrder = new Map<Id,Decimal>();
        Map<Id,Decimal> CPlanTotAmountMap = new Map<Id,Decimal>();
        
        // GET ALL CUSTOMER INVOICE PLANS FROM CUSTOMER INVOICE PLAN LINES        
        for(Customer_Invoice_Plan_Line__c CustInvPlanLine :CustInvoicePlanLine){
            CustomerInvPlanIds.add(CustInvPlanLine.Customer_Invoice_Plan__c);
            If(CPlanToCPlanLineMap.get(CustInvPlanLine.Customer_Invoice_Plan__c) <> null){
                CPlanToCPlanLineMap.get(CustInvPlanLine.Customer_Invoice_Plan__c).add(CustInvPlanLine);
            }else{
                CPlanToCPlanLineMap.put(CustInvPlanLine.Customer_Invoice_Plan__c,new List<Customer_Invoice_Plan_Line__c>{CustInvPlanLine}) ;
            }
        }
        
        for(Id CustInvPlanId:CPlanToCPlanLineMap.keyset()){
            List<Decimal> ProcessingOrderList = new List<Decimal>(); 
            Decimal TotAmount = 0;
            for(Customer_Invoice_Plan_Line__c PlnLines :CPlanToCPlanLineMap.get(CustInvPlanId)){
                ProcessingOrderList.add(PlnLines.Processing_Order__c);
                TotAmount += PlnLines.Amount__c;
            }
            Decimal maxValue = getHighestOrder(ProcessingOrderList);
            
            If(CPlanToMaxOrder.get(CustInvPlanId) == null){
                CPlanToMaxOrder.put(CustInvPlanId,maxValue);
            }
            If(CPlanTotAmountMap.get(CustInvPlanId) == null){
                CPlanTotAmountMap.put(CustInvPlanId,TotAmount);
            }
        }
        
        
        // QUERY NEW BILLING INVOICE PLANS CREATED FROM CUSTOMER INVOICE PLANS 
        List<blng__InvoicePlan__c> InvPlanLst = [SELECT Id,Customer_Invoice_Plan__c FROM blng__InvoicePlan__c WHERE Customer_Invoice_Plan__c IN: CustomerInvPlanIds];  
        
        // CREATE MAP(CUSTOMER INVOICE PLAN,BILLING INVOICE PLAN)
        Map<Id,Id> CustInvPlanToInvPlanMap = new Map<Id,Id>();
        
        // POPULATE MAP(CUSTOMER INVOICE PLAN, BILLING INVOICE PLAN)
        for(blng__InvoicePlan__c InvPlnRec:InvPlanLst){
            If(CustInvPlanToInvPlanMap.get(InvPlnRec.Customer_Invoice_Plan__c) == null){
                CustInvPlanToInvPlanMap.put(InvPlnRec.Customer_Invoice_Plan__c,InvPlnRec.Id);
            }
        }
        
        // BILLING INVOICE PLAN LINE LIST
        List<blng__InvoicePlanLine__c> InvoicePlanList = new List<blng__InvoicePlanLine__c>();
        
        // LOOP ON ALL CUSTOMER INVOICE PLAN LINES
        for(Id CustInvPlanId:CPlanToCPlanLineMap.keyset()){
            Date prevDate;
            Integer OffsetDays = 0;
            for(Customer_Invoice_Plan_Line__c CustInvPlanLine:CPlanToCPlanLineMap.get(CustInvPlanId)){
                if(CustInvPlanLine.Customer_Invoice_Plan__r.Active__c){
                    if(prevDate == null){
                        prevDate = CustInvPlanLine.Invoice_Date__c;
                    }else{
                        OffsetDays = prevDate.daysBetween(CustInvPlanLine.Invoice_Date__c);
                        prevDate =  CustInvPlanLine.Invoice_Date__c;
                    }
                    
                    System.debug(LoggingLevel.ERROR,'OffsetDays ' + OffsetDays);
                    blng__InvoicePlanLine__c InvPlanRec = new blng__InvoicePlanLine__c(Name = CustInvPlanLine.Name,
                                                                                       blng__CommencementDateOffset__c = OffsetDays,
                                                                                       blng__InvoicePlan__c = CustInvPlanToInvPlanMap.get(CustInvPlanLine.Customer_Invoice_Plan__c),
                                                                                       Customer_Invoice_Plan_Line__c = CustInvPlanLine.Id,
                                                                                       blng__Type__c = CPlanToMaxOrder.get(CustInvPlanLine.Customer_Invoice_Plan__c) == CustInvPlanLine.Processing_Order__c ? 'Remainder' : 'Percent',
                                                                                       blng__Percentage__c = CPlanToMaxOrder.get(CustInvPlanLine.Customer_Invoice_Plan__c) == CustInvPlanLine.Processing_Order__c ? 0 : (CustInvPlanLine.Amount__c / CPlanTotAmountMap.get(CustInvPlanLine.Customer_Invoice_Plan__c)) * 100,
                                                                                       blng__CommencementDate__c = 'Order Product Activation',
                                                                                       blng__CommencementDateOffsetUnits__c = 'Days',
                                                                                       blng__ServicePeriodStart__c = 'Order Product Activation',
                                                                                       blng__ServicePeriodEnd__c = 'Order Product End Date',
                                                                                       blng__ProcessingOrder__c = CustInvPlanLine.Processing_Order__c);
                    InvoicePlanList.add(InvPlanRec); 
                }
            }
            prevDate= null;
        }
        return InvoicePlanList;
    }*/
    
    /*
*@Description: METHOD TO GET THE HIGHEST NUMBER WITHIN A LIST
*@params: LIST OF DECIMAL
*/   
    /*public static Decimal getHighestOrder( List<Decimal> ProcessingOrder){
        Decimal maxvalue = ProcessingOrder[0];
        for(integer i =0;i<ProcessingOrder.size();i++){
            if( ProcessingOrder[i] > maxvalue)
                maxvalue = ProcessingOrder[i];             
        }    
        System.debug(System.LoggingLevel.ERROR, 'the max value is'+maxvalue);
        return maxvalue;
    }*/
    
    
    /*
*@Description: METHOD TO CREATE THE BILLING RULE RECORD
*@params: LIST OF ORDERS
*/      
    /*public static List<blng__BillingRule__c> createBillingRule(List<Order> Orders){
        List<blng__BillingRule__c> BillingRuleList = new List<blng__BillingRule__c>();
        blng__BillingRule__c BillingRule = [SELECT Id,Name,blng__InitialBillingTrigger__c,blng__Active__c,
                                            blng__PartialPeriodTreatment__c,blng__GenerateInvoices__c
                                            FROM blng__BillingRule__c WHERE Name LIKE '%TEMPLATE%'];
        
        System.debug('Line 252 BillingRule: '+ BillingRule);
        
        String strBillingRuleName = BillingRule.Name;
        String[] arrStr = strBillingRuleName.split('-');
        
        for(Order OrdRec :Orders){
            blng__BillingRule__c BillingRuleRec = new blng__BillingRule__c(Name = arrStr[1] + ' - ' + arrStr[2] + ' - ' + OrdRec.OrderNumber,
                                                                           Order_Id__c = OrdRec.Id,
                                                                           blng__InitialBillingTrigger__c = BillingRule.blng__InitialBillingTrigger__c,
                                                                           blng__GenerateInvoices__c = BillingRule.blng__GenerateInvoices__c,
                                                                           blng__PartialPeriodTreatment__c = BillingRule.blng__PartialPeriodTreatment__c,
                                                                           blng__Active__c = BillingRule.blng__Active__c);
            BillingRuleList.add(BillingRuleRec);
        }
        return BillingRuleList;
    }*/
    
    /*
*@Description: METHOD TO CREATE THE BILLING TREATMENT RECORD
*@params:LIST OF BILLING RULES
*/     
   /* public static List<blng__BillingTreatment__c> createBillingTreatment(List<blng__BillingRule__c> BillingRules){
        List<blng__BillingTreatment__c> BillingTreatmentList = new List<blng__BillingTreatment__c>();
        blng__BillingTreatment__c BillingTreatment = [SELECT Id,blng__Active__c,Name,blng__BillingFinanceBook__c,
                                                      blng__BillingLegalEntity__c,blng__CancellationRule__c
                                                      FROM blng__BillingTreatment__c WHERE Name LIKE '%TEMPLATE%'];
        
        String strBlngTreatmentName = BillingTreatment.Name;
        String[] arrStr = strBlngTreatmentName.split('-');
        
        for(blng__BillingRule__c BlngRules:BillingRules){
            blng__BillingTreatment__c BlngTreatment = new blng__BillingTreatment__c(Name = arrStr[1],
                                                                                    blng__Active__c = BillingTreatment.blng__Active__c,
                                                                                    blng__BillingFinanceBook__c = BillingTreatment.blng__BillingFinanceBook__c,
                                                                                    blng__CancellationRule__c = BillingTreatment.blng__CancellationRule__c,
                                                                                    blng__BillingLegalEntity__c = BillingTreatment.blng__BillingLegalEntity__c,
                                                                                    blng__BillingRule__c = BlngRules.Id);
            BillingTreatmentList.add(BlngTreatment);
            
        }
        return BillingTreatmentList;
    }*/
    
    
    /*
*@Description: method for getting CRON / JOB name
*@params:String
*/  
    public static String getJobName(String id) {
        Integer randNum = Integer.valueOf((Math.random() * 10000));
        String hashString = String.valueOf(randNum) + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String uniqueStr = EncodingUtil.convertToHex(hash);
        return cronJobPrefix + ';' + id + ';' + String.valueOf(DateTime.now()) + uniqueStr;
    }
    
    
    /*
*@Description: method for getting CRON / JOB name
*@params:String
*/  
    
    public static String getJobCronString(Decimal minutesUntilJobStarts) {
        Integer secondsBetweenJobs = Math.round(minutesUntilJobStarts * 60);
        DateTime currentDateTime = System.now();
        DateTime dateTimeForNextJob = currentDateTime.addSeconds(secondsBetweenJobs);
        Integer seconds = dateTimeForNextJob.second();
        Integer minutes = dateTimeForNextJob.minute();
        Integer hours = dateTimeForNextJob.hour();
        Integer dayOfMonth = dateTimeForNextJob.day();
        Integer month = dateTimeForNextJob.month();
        return seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ?';
    }
    
    
    /*
*@Description: method for to abort based CRON / JOB name
*@params: String 
*/  
    
    public static void abortPreviousJobs(String id) {
        String name = cronJobPrefix + ';' + id + ';%';       
        List<CronJobDetail> det = [SELECT Id FROM CronJobDetail WHERE Name LIKE :name];
        system.debug('det ' + det);
        List<CronTrigger> cronTriggers = [SELECT Id, State, NextFireTime, CronJobDetailId FROM CronTrigger WHERE CronJobDetailId IN (SELECT Id FROM CronJobDetail WHERE Name LIKE :name)];
        system.debug('cronTriggers ' + cronTriggers);
        if (cronTriggers.size() == 0) return;
        for(CronTrigger ct : cronTriggers) {
            system.debug('ct ' + ct);
            System.debug('Aborting job....');
            System.abortJob(ct.Id);
        }
    }
    
}