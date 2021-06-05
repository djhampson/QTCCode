/*******************************************************************************************************
* Class Name      	: OrderProductTriggerHandler
* Description		: Handler for OrderProductTrigger
* Author          	: Simplus - Carlos Roy Billones
* Created On      	: 09/03/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Carlos Roy Billones   13/01/2021		1000				Initial version
* Yi Zhang              18/02/2021		2000				Sync invoicing dates (TOCB-1361)
* Yi Zhang              01/03/2021		3000				Sync invoicing dates (TOCB-1422)
* Yi Zhang              09/03/2021		4000				Sync invoicing dates logic tweak (TOCB-1557)
******************************************************************************************************/
public class OrderProductTriggerHandler {
    
    private boolean isExecuting = false;
    
    public OrderProductTriggerHandler(boolean isExecuting){
        this.isExecuting = isExecuting;
    }
        
    /*
*@Description: METHOD TO HANDLE ORDER PRODUCT AFTER INSERT LOGIC
*@params: LIST OF CUSTOMER INVOICE PLANS
*@author: Gerald A- Simplus
*/     
    public void OnAfterInsert(List<OrderItem> OrderProducts){
         // EXECUTE BEFORE INSERT LOGIC
        /*Set<Id> OrderIds = new Set<Id>();
        Set<Id> QuoteIds = new Set<Id>();
        List<OrderItem> OrderPrdctLst = new List<OrderItem>();
        List<blng__BillingTreatment__c> BlngTreatmentLstToUpdate = new List<blng__BillingTreatment__c>();
        Map<Id,blng__BillingTreatment__c> OrderIdToBlngTreamentMap = new Map<Id,blng__BillingTreatment__c>();
        Map<Id,Id> OrderIdToBlngTreamentInvoicePlanMap = new Map<Id,id>();
        Map<Id,String> QuoteIdToFeeTypeMap = new Map<Id,String>();
        
        // LOOP ON ALL ORDER PRODUCT RECORDS 
        for(OrderItem OrdItem:OrderProducts){
            System.debug(logginglevel.ERROR,OrdItem.Id);
            System.debug(logginglevel.ERROR,OrdItem.OrderId);
            OrderIds.add(OrdItem.OrderId);
            QuoteIds.add(OrdItem.Quote_Id__c);
        }
        
         // GET ALL INVOICE PLANS WITH THE SAME ORDER ID
        List<blng__InvoicePlan__c> BlngInvoicePlans = [SELECT Id,Order_Id__c 
                                                       FROM blng__InvoicePlan__c 
                                                       WHERE Order_Id__c IN: OrderIds];
        
        // GET ALL CIP WITH THE SAME QUOTE ID
        List<Quote_CIP__c> QCIPLst = [SELECT Id,Quote__c,Fee_Type__c 
                                      FROM Quote_CIP__c 
                                      WHERE Quote__c IN: QuoteIds];
        
        
        // POPULATE MAP<QUOTE ID,FEE TYPE>
        for(Quote_CIP__c QCIP :QCIPLst){
            If(QuoteIdToFeeTypeMap.get(QCIP.Quote__c) == null){
               QuoteIdToFeeTypeMap.put(QCIP.Quote__c,QCIP.Fee_Type__c); 
            }
        }
        
        // POPULATE MAP<ORDER ID, BILLING INVOICE PLAN>
        for(blng__InvoicePlan__c plans:BlngInvoicePlans){
            If(OrderIdToBlngTreamentInvoicePlanMap.get(plans.Order_Id__c) == null){
                OrderIdToBlngTreamentInvoicePlanMap.put(plans.Order_Id__c,plans.Id);
            }
        }
        
        // GET ALL BILLING TREATMENT WITH BILLING RULE AND ORDER ID
        List<blng__BillingTreatment__c> BlngTreatmentLst = [SELECT Id,blng__BillingRule__c,blng__BillingRule__r.Order_Id__c 
                                                            FROM blng__BillingTreatment__c 
                                                            WHERE blng__BillingRule__r.Order_Id__c IN: OrderIds];
        
        for(blng__BillingTreatment__c BlngTreatment:BlngTreatmentLst){
            
            // UPDATE BILLING TREATMENT WITH INVOICE PLAN
            blng__BillingTreatment__c BlngTreatmentRec = new blng__BillingTreatment__c(Id = BlngTreatment.Id,
                                                                                      blng__InvoicePlan__c = OrderIdToBlngTreamentInvoicePlanMap.get(BlngTreatment.blng__BillingRule__r.Order_Id__c));
            
           	BlngTreatmentLstToUpdate.add(BlngTreatmentRec);
            
            // POPULATE MAP<ORDER ID, BILLING TREATMENT>
            if(OrderIdToBlngTreamentMap.get(BlngTreatment.blng__BillingRule__r.Order_Id__c) == null){
                OrderIdToBlngTreamentMap.put(BlngTreatment.blng__BillingRule__r.Order_Id__c,BlngTreatment);
            }
        }
        
        for(OrderItem OrdItem:OrderProducts){
            // UPDATE BILLING RULE AND BILLING TREATMENT ON ORDER PRODUCT
            // CHECK FEE TYPE BASED ON QUOTE ID
            If(QuoteIdToFeeTypeMap.get(OrdItem.Quote_Id__c) == 'All'){
                OrderItem OrdProd = new OrderItem(Id = OrdItem.Id,
                                                  blng__BillingRule__c = OrderIdToBlngTreamentMap.get(OrdItem.OrderId).blng__BillingRule__c,
                                                  blng__BillingTreatment__c = OrderIdToBlngTreamentMap.get(OrdItem.OrderId).Id);
                OrderPrdctLst.add(OrdProd); 
            }else If(QuoteIdToFeeTypeMap.get(OrdItem.Quote_Id__c) == 'License' && OrdItem.Fee_Type__c == 'License'){
                OrderItem OrdProd = new OrderItem(Id = OrdItem.Id,
                                                  blng__BillingRule__c = OrderIdToBlngTreamentMap.get(OrdItem.OrderId).blng__BillingRule__c,
                                                  blng__BillingTreatment__c = OrderIdToBlngTreamentMap.get(OrdItem.OrderId).Id);
                OrderPrdctLst.add(OrdProd); 
            }else If(QuoteIdToFeeTypeMap.get(OrdItem.Quote_Id__c) == 'SaaS Platform' && OrdItem.Fee_Type__c == 'SaaS Platform'){
                OrderItem OrdProd = new OrderItem(Id = OrdItem.Id,
                                                  blng__BillingRule__c = OrderIdToBlngTreamentMap.get(OrdItem.OrderId).blng__BillingRule__c,
                                                  blng__BillingTreatment__c = OrderIdToBlngTreamentMap.get(OrdItem.OrderId).Id);
                OrderPrdctLst.add(OrdProd); 
            }
        }
        
        if(BlngTreatmentLstToUpdate.size() > 0){
            UPDATE BlngTreatmentLstToUpdate;
        }
        
        
        if(OrderPrdctLst.size() > 0){
            UPDATE OrderPrdctLst;
        }*/
        
    }
    
    // ADDED BY GERALD FOR REVENUE AMOUNT CALCULATION
    public static void calculateOrderProductRevenue(Map<Id, OrderItem> OldOrderProductsMap, List<OrderItem> NewOrderProductsList){  
        // MAP<ORDER PRODUCT PARENT ID - REVENUE AMOUNT>
       	Map<String,Id> OrderProductToNegativeLineCheck = new Map<String,Id>();
        Map<String,Id> OrderProductToPositiveLineCheck = new Map<String,Id>();
        Map<Id,List<OrderItem>> OrderToOrderProducts = new Map<Id,List<OrderItem>>();
        
        List<OrderItem> AmendmentOrderProducts = new List<OrderItem>();
        List<OrderItem> NewOrderProducts = new List<OrderItem>();
        
        for(OrderItem OrderProd: NewOrderProductsList){
            If(OldOrderProductsMap.get(OrderProd.Id).SBQQ__Status__c <> OrderProd.SBQQ__Status__c && OrderProd.SBQQ__Status__c == 'Activated'){
                // SORT PRODUCTS ORDER PRODUCTS BY ORDER ID
                If(OrderToOrderProducts.get(OrderProd.OrderId) == null){
                    OrderToOrderProducts.put(OrderProd.OrderId, new List<OrderItem>{OrderProd});
                }else{
                    OrderToOrderProducts.get(OrderProd.OrderId).add(OrderProd);
                }
                
                // SORT NEGATIVE AND POSTIVE LINES BY ORDERID AND PRODUCT ID
                If(OrderProd.SBQQ__OrderedQuantity__c < 0){
                      OrderProductToNegativeLineCheck.put(OrderProd.OrderId+'-'+OrderProd.Product2Id,OrderProd.OrderId); 
                   /*If(OrderProductToNegativeLineCheck.get(OrderProd.OrderId+'-'+OrderProd.Product2Id) == null){
                        OrderProductToNegativeLineCheck.put(OrderProd.OrderId+'-'+OrderProd.Product2Id,new List<OrderItem>{OrderProd}); 
                    }else{
                        OrderProductToNegativeLineCheck.get(OrderProd.OrderId+'-'+OrderProd.Product2Id).add(OrderProd); 
                    }*/
                }else{
                    OrderProductToPositiveLineCheck.put(OrderProd.OrderId+'-'+OrderProd.Product2Id,OrderProd.OrderId); 
                    /*If(OrderProductToPositiveLineCheck.get(OrderProd.OrderId+'-'+OrderProd.Product2Id) == null){
                        OrderProductToPositiveLineCheck.put(OrderProd.OrderId+'-'+OrderProd.Product2Id,new List<OrderItem>{OrderProd}); 
                    }else{
                        OrderProductToPositiveLineCheck.get(OrderProd.OrderId+'-'+OrderProd.Product2Id).add(OrderProd); 
                    }*/
                }
            }
        } 
        
        Set<Id> SortedOrderIdChecker = new Set<Id>();
        If(OrderProductToPositiveLineCheck.size() > 0){
            // SORT HOW REVENUE IS CALCULATED
            for(String OrderIdProductId :OrderProductToPositiveLineCheck.keyset()){
                If(!SortedOrderIdChecker.contains(OrderProductToPositiveLineCheck.get(OrderIdProductId)) ){
                    If(OrderProductToNegativeLineCheck.get(OrderIdProductId) <> null){
                        AmendmentOrderProducts.addAll(OrderToOrderProducts.get(OrderProductToPositiveLineCheck.get(OrderIdProductId)));
                    }else{
                        NewOrderProducts.addAll(OrderToOrderProducts.get(OrderProductToPositiveLineCheck.get(OrderIdProductId)));
                    }
                    SortedOrderIdChecker.add(OrderProductToPositiveLineCheck.get(OrderIdProductId));
                }/*else{
                    If(OrderProductToNegativeLineCheck.get(OrderIdProductId) <> null){
                        AmendmentOrderProducts.addAll(OrderToOrderProducts.get(OrderProductToPositiveLineCheck.get(OrderIdProductId)));
                    }else{
                        NewOrderProducts.addAll(OrderToOrderProducts.get(OrderProductToPositiveLineCheck.get(OrderIdProductId)));
                    }
                    SortedOrderIdChecker.add(OrderProductToPositiveLineCheck.get(OrderIdProductId));
                }*/
            } 
        }else{
            for(String OrderIdProductId :OrderProductToNegativeLineCheck.keyset()){
                If(!SortedOrderIdChecker.contains(OrderProductToNegativeLineCheck.get(OrderIdProductId)) ){
                    AmendmentOrderProducts.addAll(OrderToOrderProducts.get(OrderProductToNegativeLineCheck.get(OrderIdProductId)));
                    SortedOrderIdChecker.add(OrderProductToNegativeLineCheck.get(OrderIdProductId));
                }
            }
        }
        
        System.debug(LoggingLevel.ERROR, '@@  AMENDMENT LINES SIZE ' + AmendmentOrderProducts.size());
        // REVENUE IS TOTAL PRICE
        If(AmendmentOrderProducts.size() > 0){
            System.debug(LoggingLevel.ERROR, '@@ CALCULATING AMENDMENT LINES');
            totalPriceAsRevenueAmount(AmendmentOrderProducts);
        }
       System.debug(LoggingLevel.ERROR, '@@  NEW LINES SIZE ' + NewOrderProducts.size());
        // CALCULATE REVENUE VIA ARPU
        If(NewOrderProducts.size() > 0){
            System.debug(LoggingLevel.ERROR, '@@ CALCULATING NEW LINES');
            calculateRevenueAmount(NewOrderProducts);
        }
    }
    
     // ADDED BY GERALD FOR REVENUE AMOUNT CALCULATION - AMENDMENT
    public static void totalPriceAsRevenueAmount(List<OrderItem> AmendmentOrderProducts){ 
       for(OrderItem OrderProd: AmendmentOrderProducts){
           OrderProd.blng__AllocatedRevenueAmount__c = OrderProd.TotalPrice <> null ? OrderProd.TotalPrice : 0; 
        }  
    }
    
    // ADDED BY GERALD FOR REVENUE AMOUNT CALCULATION
    public static void calculateRevenueAmount(List<OrderItem> NewOrderProducts){  
        
        // MAP<ORDER PRODUCT PARENT ID - REVENUE AMOUNT>
        Map<String,Decimal> RevAdjustParentToTotal = new Map<String,Decimal>();
        // MAP<ORDER PRODUCT PARENT ID - QL GROUP,REVENUE AMOUNT>
        Map<String,Decimal> OrderProdParentToTotal = new Map<String,Decimal>();
        // MAP<ORDER PRODUCT PARENT ID,REVENUE AMOUNT>
        Map<String,Decimal> OrderProdParentToTotalVal = new Map<String,Decimal>();
        // MAP<PRODUCT ID, TOTAL PRICE> TCV
        Map<Id,Decimal> ProductIdToTotPriceMap = new Map<Id,Decimal>();
        // MAP<PRODUCT ID, QUANTITY x MONTH> TOTAL QTY X MONTH
        Map<Id,Decimal> ProductIdToTotQuanMap = new Map<Id,Decimal>();
        // MAP<PRODUCT ID, ARPU> 
        Map<Id,Decimal> ProductIdToARPUMap = new Map<Id,Decimal>();
        // MAP<ORDER ID, QUANTITY x MONTH> 
        Map<Id,Decimal> OrderIdToTotQuanMap = new Map<Id,Decimal>();
        // SET OF QL IDS
        Set<Id> QuoteLineIds = new Set<Id>();
        // SET OF ORDER PRODUCT PARENT IDs
        Set<Id> OrderProductParentIds = new Set<Id>();
        // MAP<STRING, TOTAL OF ALL LICENSE FEE>
        Map<String,Decimal> GroupIdToTotalLicenseMap = new Map<String,Decimal>();
        Map<String,Decimal> OrderIdToTotalLicenseMap = new Map<String,Decimal>();
        Map<String,Decimal> CloudToTotalPriceMap = new Map<String,Decimal>();
        Map<String,Decimal> CloudToTotalQuanMap = new Map<String,Decimal>();
        Map<String,Decimal> ASMToTotalPriceMap = new Map<String,Decimal>();
        
        // GET ALL QL IDS AND ORDER PRODUCT PARENT IDS
        for(OrderItem OrderProd: NewOrderProducts){
            // If(OldOrderProductsMap.get(OrderProd.Id).SBQQ__Status__c <> OrderProd.SBQQ__Status__c && OrderProd.SBQQ__Status__c == 'Activated'){
            QuoteLineIds.add(OrderProd.SBQQ__QuoteLine__c);
            if(OrderProd.Rev_Adj__c){
                OrderProductParentIds.add(OrderProd.SBQQ__RequiredBy__c);
            } 
            // }
        }
        
        Map<Id,SBQQ__QuoteLine__c> QuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id,Term_Months__c,Term_Days__c,
                                                                                  SBQQ__Quantity__c,SBQQ__Group__c,
                                                                                  ASM_Adjustment_Percent__c,
                                                                                  SBQQ__SubscriptionPercent__c,
                                                                                  SBQQ__SubscriptionPricing__c
                                                                                  FROM SBQQ__QuoteLine__c
                                                                                  WHERE ID IN: QuoteLineIds]);      
        // POPULATE MAP VALUES
        for(OrderItem OrderProd: NewOrderProducts){
            // If(OldOrderProductsMap.get(OrderProd.Id).SBQQ__Status__c <> OrderProd.SBQQ__Status__c && OrderProd.SBQQ__Status__c == 'Activated'){
            If(OrderProd.Fee_Type__c == 'License' || OrderProd.Fee_Type__c == 'AMS'){              
                // POPULATE MAP<PRODUCT ID, TOTAL PRICE> = TCV PER LINE
                If(ProductIdToTotPriceMap.get(OrderProd.Product2Id) == null){
                    ProductIdToTotPriceMap.put(OrderProd.Product2Id,OrderProd.TotalPrice);
                }else{
                    Decimal LegacyTotPrice = ProductIdToTotPriceMap.get(OrderProd.Product2Id);
                    Decimal FinalTotPrice = OrderProd.TotalPrice + LegacyTotPrice;
                    ProductIdToTotPriceMap.put(OrderProd.Product2Id,FinalTotPrice); 
                }
                
                // POPULATE MAP<PRODUCT ID, QUANTITY x MONTH> TOTAL QTY X MONTH
                If(ProductIdToTotQuanMap.get(OrderProd.Product2Id) == null){
                    Integer NumMonthsBetween = OrderProd.ServiceDate.daysBetween(OrderProd.EndDate);
                    Decimal LineQty = QuoteLineMap.get(OrderProd.SBQQ__QuoteLine__c).SBQQ__Quantity__c;
                    Decimal TotalLineQty = (NumMonthsBetween + 1) * OrderProd.SBQQ__OrderedQuantity__c; 
                    ProductIdToTotQuanMap.put(OrderProd.Product2Id,TotalLineQty); 
                }else{
                    Integer NumMonthsBetween = OrderProd.ServiceDate.daysBetween(OrderProd.EndDate);
                    Decimal LineQty = QuoteLineMap.get(OrderProd.SBQQ__QuoteLine__c).SBQQ__Quantity__c;
                    Decimal TotalLineQty = (NumMonthsBetween + 1) * OrderProd.SBQQ__OrderedQuantity__c;
                    Decimal LegacyTotQty = ProductIdToTotQuanMap.get(OrderProd.Product2Id);
                    Decimal FinalTotQty = TotalLineQty + LegacyTotQty;
                    ProductIdToTotQuanMap.put(OrderProd.Product2Id,FinalTotQty); 
                }
                
                // POPULATE MAP<ORDER ID, QUANTITY x MONTH> 
                If(OrderIdToTotQuanMap.get(OrderProd.Id) == null){
                    Integer NumMonthsBetween = OrderProd.ServiceDate.daysBetween(OrderProd.EndDate);
                    Decimal LineQty = QuoteLineMap.get(OrderProd.SBQQ__QuoteLine__c).SBQQ__Quantity__c;
                    Decimal TotalLineQty = (NumMonthsBetween + 1) * OrderProd.SBQQ__OrderedQuantity__c;
                    OrderIdToTotQuanMap.put(OrderProd.Id,TotalLineQty); 
                }  
            }
            //}
        }
        
        // CALCULATE ARPU
        for(Id ProdId :ProductIdToTotPriceMap.keySet()){
            Decimal ARPU = 0;
            Decimal TotPrice = ProductIdToTotPriceMap.get(ProdId);
            Decimal TotQuan = ProductIdToTotQuanMap.get(ProdId);
            If(TotQuan <> 0){
                ARPU = TotPrice / TotQuan;  
            }
            If(ProductIdToARPUMap.get(ProdId) == null){
                ProductIdToARPUMap.put(ProdId,ARPU);
            }
        }
        Set<Id> ProcessedOrderProd = new Set<Id>();
        // ASSIGN REVENUE AMOUNT FOR LICENSE PRODUCTS
        for(OrderItem OrderItemRec: NewOrderProducts){
            //If(OldOrderProductsMap.get(OrderItemRec.Id).SBQQ__Status__c <> OrderItemRec.SBQQ__Status__c && OrderItemRec.SBQQ__Status__c == 'Activated'){
            //GET TOTAL PRICE OF PER CLOUD PRODUCTS
            if(OrderItemRec.Fee_Type__c == 'Cloud'){ 
                If(CloudToTotalPriceMap.get(OrderItemRec.Product2Id) == null){
                    CloudToTotalPriceMap.put(OrderItemRec.Product2Id, OrderItemRec.TotalPrice);
                }else{
                    Decimal LegacyVal = CloudToTotalPriceMap.get(OrderItemRec.Product2Id);
                    Decimal TotVal = LegacyVal + OrderItemRec.TotalPrice;
                    CloudToTotalPriceMap.put(OrderItemRec.Product2Id, TotVal);
                }
                If(QuoteLineMap.get(OrderItemRec.SBQQ__QuoteLine__c).SBQQ__SubscriptionPricing__c <> 'Percent Of Total'){
                    If(CloudToTotalQuanMap.get(OrderItemRec.Product2Id) == null){
                        CloudToTotalQuanMap.put(OrderItemRec.Product2Id, QuoteLineMap.get(OrderItemRec.SBQQ__QuoteLine__c).Term_Days__c);
                    }else{
                        Decimal LegacyVal = CloudToTotalQuanMap.get(OrderItemRec.Product2Id);
                        Decimal TotVal = LegacyVal + QuoteLineMap.get(OrderItemRec.SBQQ__QuoteLine__c).Term_Days__c;
                        CloudToTotalQuanMap.put(OrderItemRec.Product2Id, TotVal);
                    }
                }
            }else if(OrderItemRec.Fee_Type__c == 'ASM' && !OrderItemRec.Rev_Adj__c){
                If(ASMToTotalPriceMap.get(OrderItemRec.OrderId + '-' + OrderItemRec.SBQQ__RequiredBy__r.Product2Id + '-' + OrderItemRec.Product2Id) == null){
                    ASMToTotalPriceMap.put(OrderItemRec.OrderId + '-' + OrderItemRec.SBQQ__RequiredBy__r.Product2Id + '-' + OrderItemRec.Product2Id, OrderItemRec.TotalPrice <> null ? OrderItemRec.TotalPrice : 0);
                }else{
                    Decimal LegacyVal = ASMToTotalPriceMap.get(OrderItemRec.OrderId + '-' + OrderItemRec.SBQQ__RequiredBy__r.Product2Id + '-' + OrderItemRec.Product2Id);
                    Decimal NewVal = OrderItemRec.TotalPrice <> null ? OrderItemRec.TotalPrice : 0;
                    Decimal TotVal = LegacyVal + NewVal;
                    ASMToTotalPriceMap.put(OrderItemRec.OrderId + '-' + OrderItemRec.SBQQ__RequiredBy__r.Product2Id + '-' + OrderItemRec.Product2Id, TotVal);
                }
            }
            If(OrderItemRec.Fee_Type__c == 'License' || OrderItemRec.Fee_Type__c == 'AMS' ){ 
                System.debug(LoggingLevel.ERROR, '@@ LICENSE PRODUCT FOUND!');
                System.debug(LoggingLevel.ERROR, '@@ LICENSE PRODUCT NAME! ' + OrderItemRec.Product_Name__c);
                Decimal ARPU = ProductIdToARPUMap.get(OrderItemRec.Product2Id);
                Decimal TotQty = OrderIdToTotQuanMap.get(OrderItemRec.Id);
                Decimal FinalRevenueAmount = ARPU * TotQty;
                If(OrderItemRec.Streamline_Revenue__c){
                    OrderItemRec.blng__AllocatedRevenueAmount__c = FinalRevenueAmount;  
                }else{
                    OrderItemRec.blng__AllocatedRevenueAmount__c = OrderItemRec.TotalPrice;  
                }
                System.debug(LoggingLevel.ERROR, '@@ ARPU! ' + ARPU);
                System.debug(LoggingLevel.ERROR, '@@ REVENUE AMOUNT! ' + FinalRevenueAmount);
                If(!ProcessedOrderProd.contains(OrderItemRec.Id)){
                    // POPULATE MAP<ORDER ID, TOTAL OF ALL LICENSE FEE>
                    If(OrderIdToTotalLicenseMap.get(OrderItemRec.OrderId) == null){ 
                        OrderIdToTotalLicenseMap.put(OrderItemRec.OrderId,FinalRevenueAmount);
                    }else{
                        Decimal LegacyTotal = OrderIdToTotalLicenseMap.get(OrderItemRec.OrderId);
                        Decimal FinalTotal = LegacyTotal + FinalRevenueAmount;
                        OrderIdToTotalLicenseMap.put(OrderItemRec.OrderId,FinalTotal);  
                    }
                    
                    // POPULATE MAP<GROUP, TOTAL OF ALL LICENSE FEE>
                    If(GroupIdToTotalLicenseMap.get(OrderItemRec.ServiceDate + '-' + OrderItemRec.EndDate) == null){ 
                        GroupIdToTotalLicenseMap.put(OrderItemRec.ServiceDate + '-' + OrderItemRec.EndDate,FinalRevenueAmount);
                    }else{
                        Decimal LegacyTotal = GroupIdToTotalLicenseMap.get(OrderItemRec.ServiceDate + '-' + OrderItemRec.EndDate);
                        Decimal FinalTotal = LegacyTotal + FinalRevenueAmount;
                        GroupIdToTotalLicenseMap.put(OrderItemRec.ServiceDate + '-' + OrderItemRec.EndDate,FinalTotal);  
                    }
                    
                    // POPULATE MAP<PARENT ID - QL GROUP,REVENUE AMOUNT>
                    If(OrderProdParentToTotal.get(OrderItemRec.SBQQ__RequiredBy__c + '-' + OrderItemRec.ServiceDate + '-' + OrderItemRec.EndDate) == null){
                        OrderProdParentToTotal.put(OrderItemRec.SBQQ__RequiredBy__c + '-' + OrderItemRec.ServiceDate + '-' + OrderItemRec.EndDate,FinalRevenueAmount);
                    }else{
                        Decimal LegacyTotAmount = OrderProdParentToTotal.get(OrderItemRec.SBQQ__RequiredBy__c + '-' + OrderItemRec.ServiceDate + '-' + OrderItemRec.EndDate);
                        Decimal FinalTotAmount = LegacyTotAmount + FinalRevenueAmount;
                        OrderProdParentToTotal.put(OrderItemRec.SBQQ__RequiredBy__c + '-' + OrderItemRec.ServiceDate + '-' + OrderItemRec.EndDate,FinalTotAmount);
                    }
                    
                     // POPULATE MAP<PARENT ID,REVENUE AMOUNT>
                    If(OrderProdParentToTotalVal.get(OrderItemRec.OrderId + '-' + OrderItemRec.SBQQ__RequiredBy__r.Product2Id) == null){
                        OrderProdParentToTotalVal.put(OrderItemRec.OrderId + '-' + OrderItemRec.SBQQ__RequiredBy__r.Product2Id,FinalRevenueAmount);
                    }else{
                        Decimal LegacyTotAmount = OrderProdParentToTotalVal.get(OrderItemRec.OrderId + '-' + OrderItemRec.SBQQ__RequiredBy__r.Product2Id);
                        Decimal FinalTotAmount = LegacyTotAmount + FinalRevenueAmount;
                        OrderProdParentToTotalVal.put(OrderItemRec.OrderId + '-' + OrderItemRec.SBQQ__RequiredBy__r.Product2Id,FinalTotAmount);
                    }
                    
                    
                    // POPULATE MAP FOR REVENUE ADJUSTMENT SCENARIO
                    If(OrderProductParentIds.contains(OrderItemRec.Id)){
                        If(RevAdjustParentToTotal.get(OrderItemRec.Id) == null){
                            RevAdjustParentToTotal.put(OrderItemRec.Id,FinalRevenueAmount);
                        }
                    } 
                    ProcessedOrderProd.add(OrderItemRec.Id);
                }
            }
            //}
        }
        
        for(OrderItem OrderItemRec: NewOrderProducts){
            //If(OldOrderProductsMap.get(OrderItemRec.Id).SBQQ__Status__c <> OrderItemRec.SBQQ__Status__c && OrderItemRec.SBQQ__Status__c == 'Activated'){
            // SaaS PRODUCTS REVENUE AMOUNT
            if(OrderItemRec.Fee_Type__c == 'Cloud' && QuoteLineMap.get(OrderItemRec.SBQQ__QuoteLine__c).SBQQ__SubscriptionPricing__c == 'Percent Of Total'){ 
                Decimal TotalGroupLicense = GroupIdToTotalLicenseMap.get(OrderItemRec.ServiceDate + '-' + OrderItemRec.EndDate) <> null ? GroupIdToTotalLicenseMap.get(OrderItemRec.ServiceDate + '-' + OrderItemRec.EndDate) :0;
                Decimal TotalOrderLicense = OrderIdToTotalLicenseMap.get(OrderItemRec.OrderId) <> null ? OrderIdToTotalLicenseMap.get(OrderItemRec.OrderId) : 0;
                Decimal TotalCloud = CloudToTotalPriceMap.get(OrderItemRec.Product2Id) <> null ? CloudToTotalPriceMap.get(OrderItemRec.Product2Id) : 0;
                If(TotalGroupLicense <> 0 && TotalOrderLicense <> 0 && OrderItemRec.Streamline_Revenue__c){
                    OrderItemRec.blng__AllocatedRevenueAmount__c = calculatePOTCloudRevenue(TotalCloud, TotalOrderLicense, TotalGroupLicense);
                }else{
                    OrderItemRec.blng__AllocatedRevenueAmount__c = OrderItemRec.TotalPrice;   
                }
                // REVENUE FOR CLOUD AND NOT POT 
            }else if(OrderItemRec.Fee_Type__c == 'Cloud' && QuoteLineMap.get(OrderItemRec.SBQQ__QuoteLine__c).SBQQ__SubscriptionPricing__c != 'Percent Of Total'){ 
                Decimal TotalTerm = CloudToTotalQuanMap.get(OrderItemRec.Product2Id) <> null ? CloudToTotalQuanMap.get(OrderItemRec.Product2Id) : 0;
                Decimal TotalCloud = CloudToTotalPriceMap.get(OrderItemRec.Product2Id) <> null ? CloudToTotalPriceMap.get(OrderItemRec.Product2Id) : 0;
                System.debug(LoggingLevel.ERROR, '@@ TOTAL TERM!' + TotalTerm);
                If(TotalTerm <> 0 && OrderItemRec.Streamline_Revenue__c){
                    OrderItemRec.blng__AllocatedRevenueAmount__c = calculateNonPOTCloudRevenue(TotalCloud, TotalTerm, QuoteLineMap.get(OrderItemRec.SBQQ__QuoteLine__c).Term_Days__c);    
                }else{
                    OrderItemRec.blng__AllocatedRevenueAmount__c = OrderItemRec.TotalPrice;   
                }          
                // REVENUE ADJUSTMENT PRODUCTS REVENUE AMOUNT   
            }else if(OrderItemRec.Rev_Adj__c){
                If(RevAdjustParentToTotal.get(OrderItemRec.SBQQ__RequiredBy__c) <> null && OrderItemRec.Streamline_Revenue__c){
                    Decimal ParentTotalAmount = RevAdjustParentToTotal.get(OrderItemRec.SBQQ__RequiredBy__c);
                    Decimal QLPOT = QuoteLineMap.get(OrderItemRec.SBQQ__QuoteLine__c).SBQQ__SubscriptionPercent__c / 100;
                    Decimal FinalRevenueAmount =  ParentTotalAmount * QLPOT;  
                    OrderItemRec.blng__AllocatedRevenueAmount__c = FinalRevenueAmount;
                }else{
                    OrderItemRec.blng__AllocatedRevenueAmount__c = OrderItemRec.TotalPrice;   
                }
                // ASM PRODUCTS   
            }else if(OrderItemRec.Fee_Type__c == 'ASM' && !OrderItemRec.Rev_Adj__c){
                System.debug(LoggingLevel.ERROR, '@@ ASM PRODUCT FOUND!');
                System.debug(LoggingLevel.ERROR, '@@ ASM PRODUCT NAME! ' + OrderItemRec.Product_Name__c);
                System.debug(LoggingLevel.ERROR, '@@ OrderProdParentToTotal VALUE ' + OrderProdParentToTotal.get(OrderItemRec.SBQQ__RequiredBy__c + '-' + OrderItemRec.ServiceDate + '-' + OrderItemRec.EndDate));
                Decimal TotalLicense = OrderProdParentToTotal.get(OrderItemRec.SBQQ__RequiredBy__c + '-' + OrderItemRec.ServiceDate + '-' + OrderItemRec.EndDate) <> null ? OrderProdParentToTotal.get(OrderItemRec.SBQQ__RequiredBy__c + '-' + OrderItemRec.ServiceDate + '-' + OrderItemRec.EndDate) : 0;
                Decimal TotalParentLicense = OrderProdParentToTotalVal.get(OrderItemRec.OrderId + '-' + OrderItemRec.SBQQ__RequiredBy__r.Product2Id)  <> null ?  OrderProdParentToTotalVal.get(OrderItemRec.OrderId + '-' + OrderItemRec.SBQQ__RequiredBy__r.Product2Id) : 0;
                Decimal TotalASM = ASMToTotalPriceMap.get(OrderItemRec.OrderId + '-' + OrderItemRec.SBQQ__RequiredBy__r.Product2Id + '-' + OrderItemRec.Product2Id) <> null ? ASMToTotalPriceMap.get(OrderItemRec.OrderId + '-' + OrderItemRec.SBQQ__RequiredBy__r.Product2Id + '-' + OrderItemRec.Product2Id) : 0;
                If(TotalLicense <> 0 && TotalParentLicense <> 0 && OrderItemRec.Streamline_Revenue__c){
                    OrderItemRec.blng__AllocatedRevenueAmount__c = calculateASMRevenue(TotalLicense,TotalParentLicense,TotalASM);   
                }else{
                    OrderItemRec.blng__AllocatedRevenueAmount__c = OrderItemRec.TotalPrice;   
                }
            }
            //}   
        }
    }
    
    public void OnAfterUpdate(List<OrderItem> oldObjects, List<OrderItem> updatedObjects, Map<Id, OrderItem> ObjectMap){
        //AFTER UPDATE LOGIC

        List<OrderItem> itemsToSyncInvoicingDates = new List<OrderItem>();
        for(OrderItem oldItem : oldObjects) {
            OrderItem newItem = ObjectMap.get(oldItem.Id);
            if((newItem.SBQQ__ChargeType__c == 'Recurring' && oldItem.blng__NextBillingDate__c != newItem.blng__NextBillingDate__c)
            || (newItem.SBQQ__ChargeType__c == 'Recurring' && oldItem.SBQQ__Status__c != newItem.SBQQ__Status__c && newItem.SBQQ__Status__c == 'Activated')) {
                if(newItem.blng__LastChargeToDate__c != newItem.EndDate) {
                    itemsToSyncInvoicingDates.add(newItem);
                }
            }
        }
        syncInvoicingDates(itemsToSyncInvoicingDates);
    }
    

    /**
    * @description  Sync Invoicing Dates after update (TOCB-1361, TOCB-1422)
    * @author Yi Zhang | 01/03/2021 
    * @param List<OrderItem> orderItems - already filtered, next billing date is updated or activated & charge type = Recurring
    **/
    public static void syncInvoicingDates(List<OrderItem> orderItems) {
        System.debug('syncInvoicingDates: ' + orderItems);
        try {
            if(orderItems.isEmpty()) return;
        
            // re-query order items with additional conditions:
            // - order is activated
            // - order is generated from an amendment quote (TOCB-1361) OR order is of deal type Perpetual on Cloud (TOCB-1422)
            orderItems = new List<OrderItem>([
                SELECT Id
                , ServiceDate
                , EndDate
                , blng__NextBillingDate__c
                , blng__OverrideNextBillingDate__c
                , blng__BillThroughDateOverride__c
                , blng__LastChargeToDate__c
                , SBQQ__BillingFrequency__c
    
                , Order.SBQQ__Quote__r.SBQQSC__MasterServiceContract__r.SBQQSC__Order__c
                , Order.Opportunity.SBQQSC__RenewedServiceContract__r.SBQQSC__Order__c
                , (SELECT Id, blng__InvoiceLineStatus__c FROM blng__OrderProductInvoiceLines__r WHERE blng__InvoiceLineStatus__c = 'Posted' LIMIT 1)
                FROM OrderItem
                WHERE Id IN :orderItems
                AND Order.Status = 'Activated'
                AND (Order.SBQQ__Quote__r.SBQQ__Type__c = 'Amendment' OR Order.Deal_Type__c = :SM_PerpetualOnCloud.PERPETUAL_ON_CLOUD)
            ]);
    
            if(orderItems.isEmpty()) return;
    
            // query original order's order items
            Set<Id> originalOrderIds = new Set<Id>();
            for(OrderItem item : orderItems) {
                // for TOCB-1361, the original order is traversed back via order - quote - master service contract - original order
                if(String.isNotBlank(item.Order.SBQQ__Quote__r.SBQQSC__MasterServiceContract__r.SBQQSC__Order__c)) {
                    originalOrderIds.add(item.Order.SBQQ__Quote__r.SBQQSC__MasterServiceContract__r.SBQQSC__Order__c);
                }
                // for TOCB-1422, the original order is traversed back via order - opportunity - renewed service contract - original order
                if(String.isNotBlank(item.Order.Opportunity.SBQQSC__RenewedServiceContract__r.SBQQSC__Order__c)) {
                    originalOrderIds.add(item.Order.Opportunity.SBQQSC__RenewedServiceContract__r.SBQQSC__Order__c);
                }
            }
            Map<Id, Order> originalOrderMap = new Map<Id, Order>([
                SELECT Id,
                (SELECT Id
                , ServiceDate
                , blng__NextBillingDate__c
                , blng__OverrideNextBillingDate__c
                , blng__BillThroughDateOverride__c
                , blng__LastChargeToDate__c
                , SBQQ__BillingFrequency__c FROM OrderItems WHERE SBQQ__ChargeType__c = 'Recurring' LIMIT 1)
                FROM Order
                WHERE Id IN :originalOrderIds
            ]);
    
            List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
            for(OrderItem item : orderItems) {
                
                // for TOCB-1361, the original order is traversed back via order - quote - master service contract - original order
                Id originalOrderId = item.Order.SBQQ__Quote__r.SBQQSC__MasterServiceContract__r.SBQQSC__Order__c;
                // for TOCB-1422, the original order is traversed back via order - opportunity - renewed service contract - original order
                originalOrderId = String.isBlank(originalOrderId) ? item.Order.Opportunity.SBQQSC__RenewedServiceContract__r.SBQQSC__Order__c : originalOrderId;
    
                if(String.isNotBlank(originalOrderId)) {
                    // if order product has invoice lines generated and posted:
                    // - set new order’s Bill Through Date Override = new order’s Last Charge To Date + x months, if the new date is beyond the end date of the order product, use the end date of the order product as the value for bill through date override
                    if(item.blng__OrderProductInvoiceLines__r.isEmpty() == false) {
                        // Commented out per Jacky's advice on 09/04
                        // This block of code has become obsolete due to new CPQ release
                        /*
                        if(item.blng__LastChargeToDate__c != null) {
                            OrderItem oi = new OrderItem(
                                Id = item.Id, 
                                blng__BillThroughDateOverride__c = item.blng__LastChargeToDate__c.addMonths(translateBillingFrequency(item.SBQQ__BillingFrequency__c))
                            );
                            oi.blng__BillThroughDateOverride__c = (oi.blng__BillThroughDateOverride__c > item.EndDate) ? item.EndDate : oi.blng__BillThroughDateOverride__c;
                            orderItemsToUpdate.add(oi);
                        }
                        */
                    } 
                    /**
                     * if order product does NOT have invoice line generated (and posted):
                        if (new order’s start date > old order’s next billing date) and (new order’s next billing date > old order’s next billing date) then:
                        - set new order’s Override Next Billing Date = old order’s next billing date, 
                        - set new order’s Bill Through Date Override = new order’s Override Next Billing Date + x months, if the new date is beyond the end date of the order product, use the end date of the order product as the value for bill through date override
                        if (new order’s start date < old order’s next billing date) and (new order’s next billing date < old order’s next billing date)
                        - set new order’s Bill Through Date Override = old order’s Last Charge To Date 
                    */
                    else {
                        if(originalOrderMap.get(originalOrderId).OrderItems.size() == 1) {
                            OrderItem originalOrderItem = originalOrderMap.get(originalOrderId).OrderItems[0];
        
                            if(item.ServiceDate > originalOrderItem.blng__NextBillingDate__c && item.blng__NextBillingDate__c > originalOrderItem.blng__NextBillingDate__c) {
                                if(originalOrderItem.blng__NextBillingDate__c != null) {
                                    OrderItem oi = new OrderItem(
                                        Id = item.Id, 
                                        blng__OverrideNextBillingDate__c = originalOrderItem.blng__NextBillingDate__c,
                                        blng__BillThroughDateOverride__c = originalOrderItem.blng__NextBillingDate__c.addMonths(translateBillingFrequency(item.SBQQ__BillingFrequency__c)).addDays(-1)
                                    );
                                    oi.blng__BillThroughDateOverride__c = (oi.blng__BillThroughDateOverride__c > item.EndDate) ? item.EndDate : oi.blng__BillThroughDateOverride__c;
                                    orderItemsToUpdate.add(oi);    
                                }
                            }
                            else if(item.ServiceDate < originalOrderItem.blng__NextBillingDate__c && item.blng__NextBillingDate__c < originalOrderItem.blng__NextBillingDate__c) {
                                orderItemsToUpdate.add(new OrderItem(
                                    Id = item.Id, 
                                    blng__BillThroughDateOverride__c = originalOrderItem.blng__LastChargeToDate__c
                                ));
                            }
                        }
                    }
                }
                
            }
            System.debug('syncInvoicingDates orderItemsToUpdate: ' + orderItemsToUpdate);
            if(orderItemsToUpdate.size() > 0) {
                update orderItemsToUpdate;
            }
        } catch(Exception e) {
            insert DM_ApplicationLog.createApplicationLog(e);
            System.debug(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Yi Zhang | 17/02/2021 
    * @param String billingFrequency 
    * @return Integer 
    **/
    public static Integer translateBillingFrequency(String billingFrequency) {
        switch on billingFrequency {
            when 'Annual'       {return 12;}
            when 'Monthly'      {return 1; }
            when 'Quarterly'    {return 3; }
            when 'Semiannual'   {return 6; }
        }
        return 0;
    }
    
    /**
    * @description: HANDLER FOR BEFORE INSERT EVENT
    * @author: Gerald Arzadon | 12/05/2021 
    * @param: List<OrderItem>
    * @return: N/A 
    **/
    public static void doBeforeInsert(List<OrderItem> newOrderProducts){
        // SET LEGAL ENTITY VALUE
        setLegalEntity(newOrderProducts);
        
        // GET ALL ORDER ID 
        Set<Id> OrderIds = new Set<Id>();
        for(OrderItem oi :newOrderProducts){
            OrderIds.add(oi.OrderId);
        }
        
        If(OrderIds.IsEmpty()) return;
        // GET ORDER RECORDS
        Map<Id, Order> orderMap = new Map<Id,Order>([SELECT Id,Deal_Type__c,Opportunity.Deal_Type__c,Type FROM Order WHERE Id IN: OrderIds]);        
        //SET REVENUE RULES
        setRevRecRule(newOrderProducts,orderMap);
        // SET INVOICE GROUPING
        setInvoiceGroup(newOrderProducts,orderMap);
    }
    
    /**
    * @description: MIGRATED FROM PROCESS BUILDER - SET LEGAL ENTITY VALUE FOR NEWLY CREATED ORDER PRODUCTS - BEFORE INSERT EVENT
    * @author: Gerald Arzadon | 12/05/2021 
    * @param: List<OrderItem>
    * @return: N/A 
    **/
    public static void setLegalEntity(List<OrderItem> newOrderProducts){ 
        Billing_CS__c BCS = Billing_CS__c.getInstance(UserInfo.GetUserID());
        System.debug(LoggingLevel.ERROR, '@@ CHECKING LEGAL ENTITY => ' + BCS.Legal_Entity_ID__c);
        If(BCS.Legal_Entity_ID__c <> null){
            for(OrderItem oi :newOrderProducts){
                oi.blng__LegalEntity__c = BCS.Legal_Entity_ID__c;
            }
        }
    }
    
    /**
    * @description: MIGRATED FROM PROCESS BUILDER - SET INVOICE GROUP VALUE FOR TERM AND SUBSCRIPTION VALUE FOR ORDER PRODUCTS - BEFORE INSERT EVENT
    * @author: Gerald Arzadon | 12/05/2021 
    * @param: List<OrderItem>
    * @return: N/A 
	**/
    public static void setInvoiceGroup(List<OrderItem> newOrderProducts, Map<Id, Order> OrderMap){
        try{
            for(OrderItem oi :newOrderProducts){
                // SET INVOICE GROUPING
                If(orderMap.get(oi.OrderId).Opportunity.Deal_Type__c == 'Perpetual on Cloud' || orderMap.get(oi.OrderId).Opportunity.Deal_Type__c == 'Term' || orderMap.get(oi.OrderId).Deal_Type__c == 'Perpetual on Cloud' || orderMap.get(oi.OrderId).Deal_Type__c == 'Term'){
                    oi.blng__InvoiceGrouping__c = 'Contract Number';
                }
            }
            
        } catch (Exception e) { 
            INSERT DM_ApplicationLog.createApplicationLog(e); 
        }
    }
    
    /**
    * @description: MIGRATED FROM PROCESS BUILDER - SET REVENUE RECOGNITION VALUE FOR NEWLY CREATED ORDER PRODUCTS - BEFORE INSERT EVENT
    * @author: Gerald Arzadon | 12/05/2021 
    * @param: List<OrderItem>
    * @return: N/A 
    **/
    public static void setRevRecRule(List<OrderItem> newOrderProducts,  Map<Id, Order> orderMap){
        try{
            Billing_CS__c BCS = Billing_CS__c.getInstance(UserInfo.GetUserID());
            // CHECK CUSTOM SETTING VALUES
            If(BCS.Legal_Entity_ID__c <> null){
                for(OrderItem oi :newOrderProducts){
                    // CHECK DEAL TYP AND ONLY APPLIES FOR LICENSE PRODUCTS
                    If(oi.Fee_Type__c == 'License' && (orderMap.get(oi.OrderId).Deal_Type__c == 'Perpetual' || orderMap.get(oi.OrderId).Deal_Type__c == 'Term' || orderMap.get(oi.OrderId).Deal_Type__c == 'Subscription')){
                        // FULL REVENUE RECOGNITION RULE
                        if(!oi.Connector_Module__c && BCS.Full_Recognition_RevRec_ID__c <> null){
                            oi.blng__RevenueRecognitionRule__c = BCS.Full_Recognition_RevRec_ID__c;
                       	// 50/50 REVENUE RECOGNITION RULE
                        }else if(oi.Connector_Module__c && BCS.Connector_Full_50_50_Rev_Rec_ID__c <> null && oi.blng__RevenueRecognitionRule__c <> null && oi.blng__RevenueRecognitionRule__c <> null && oi.Revenue_Recognition_Rule_Name__c.contains('50/50')){
                            oi.blng__RevenueRecognitionRule__c = BCS.Connector_Full_50_50_Rev_Rec_ID__c;
                        // 25/25/50 REVENUE RECOGNITION RULE
                        }else if(oi.Connector_Module__c && BCS.Connector_Full_25_25_50_Rev_Rec_ID__c <> null && oi.blng__RevenueRecognitionRule__c <> null && oi.blng__RevenueRecognitionRule__c <> null && oi.Revenue_Recognition_Rule_Name__c.contains('25/25/50')){
                            oi.blng__RevenueRecognitionRule__c = BCS.Connector_Full_25_25_50_Rev_Rec_ID__c;
                        }
                    }
                }
            }
        } catch (Exception e) { 
            INSERT DM_ApplicationLog.createApplicationLog(e); 
        }
    }
    
    /**
    * @description: MIGRATED FROM PROCESS BUILDER - SET AMS UNIT PRICE AND PRORATE MULTIPLIER FOR AMS - BEFORE UPDATE EVENT
    * @author: Gerald Arzadon | 12/05/2021 
    * @param: List<OrderItem>
    * @return: N/A 
    **/
    public static void setAMSUnitPrice(Map<Id,OrderItem> oldOrderProductsMap, List<OrderItem> newOrderProducts){
        System.debug(LoggingLevel.Error,'@@ ASM AUTOMATION IS RUNNING!!');
        try{
            Set<Id> OrderIds = new Set<Id>();
            // GET ALL ORDER ID IF ORDER PRODUCT IS ACTIVATED
            for(OrderItem oi:newOrderProducts){
                if(oldOrderProductsMap.get(oi.Id).SBQQ__Status__c <> oi.SBQQ__Status__c && oi.SBQQ__Status__c == 'Activated'){
                    OrderIds.add(oi.OrderId);
                }
            }
            System.debug(LoggingLevel.Error,'@@ ORDER ID SIZE ' + OrderIds.size());
            System.debug(LoggingLevel.Error,'@@ ORDER ID ' + OrderIds);
            If(OrderIds.IsEmpty()) return;
            
            Map<Id, Order> OrderMap = new Map<Id,Order>([SELECT Id,Deal_Type__c,Opportunity.Deal_Type__c FROM Order WHERE Id IN: OrderIds]);
            System.debug(LoggingLevel.Error,'@@ ORDER MAP SIZE ' + OrderMap.size());
            System.debug(LoggingLevel.Error,'@@ ORDER MAP ' + OrderMap);
            // LOOP ORDER PRODUCTS AND PROCESS
            for(OrderItem oi:newOrderProducts){
                if(oldOrderProductsMap.get(oi.Id).SBQQ__Status__c <> oi.SBQQ__Status__c && oi.SBQQ__Status__c == 'Activated' && (OrderMap.get(oi.OrderId).Deal_Type__c == 'AMS' || OrderMap.get(oi.OrderId).Opportunity.Deal_Type__c == 'AMS')){
                    Decimal finalBillablePrice = 0;
                    Decimal billableUnitPriceval = oi.blng__BillableUnitPrice__c <> null ? oi.blng__BillableUnitPrice__c : 0;
                    if(oi.Term_Months__c <> null && oi.Term_Months__c > 0){
                        // MONTHLY 
                        if(oi.SBQQ__BillingFrequency__c <> null && oi.SBQQ__BillingFrequency__c == 'Monthly'){
                            finalBillablePrice = oi.TotalPrice / oi.Term_Months__c;
                        // ANNUAL
                        }else if(oi.SBQQ__BillingFrequency__c <> null && oi.SBQQ__BillingFrequency__c == 'Annual'){
                             finalBillablePrice = oi.Term_Months__c <> null && oi.Term_Months__c > 12 ? oi.TotalPrice / oi.Term_Months__c * 12 : billableUnitPriceval;
                        // QUARTERLY
                        }else if(oi.SBQQ__BillingFrequency__c <> null && oi.SBQQ__BillingFrequency__c == 'Quarterly'){
                             finalBillablePrice = oi.Term_Months__c <> null && oi.Term_Months__c > 3 ? oi.TotalPrice / oi.Term_Months__c * 3 : billableUnitPriceval;
                        // SEMIANNUAL
                        }else if(oi.SBQQ__BillingFrequency__c <> null && oi.SBQQ__BillingFrequency__c == 'Semiannual'){
                             finalBillablePrice = oi.Term_Months__c <> null && oi.Term_Months__c > 6 ? oi.TotalPrice / oi.Term_Months__c * 6 : billableUnitPriceval;
                        }else{
                            finalBillablePrice = billableUnitPriceval <> null ? billableUnitPriceval : 0;
                        }
                    }else{
                         finalBillablePrice = billableUnitPriceval <> null ? billableUnitPriceval : 0;
                    }
                    // ASSIGN VALUES
                    oi.blng__BillableUnitPrice__c = finalBillablePrice;
                    oi.SBQQ__ProrateMultiplier__c = oi.Term_Months__c > 0 &&  oi.SBQQ__DefaultSubscriptionTerm__c > 0 ? oi.Term_Months__c / oi.SBQQ__DefaultSubscriptionTerm__c : oi.SBQQ__ProrateMultiplier__c;
                }
            }
        } catch (Exception e) { 
            INSERT DM_ApplicationLog.createApplicationLog(e); 
        }
    }
    
    /**
    * @description: CALCULATE ASM ALLOCATED REVENUE
    * @author: Gerald Arzadon | 13/04/2021 
    * @param: Decimal TotalLicense, Decimal TotalParentLicense, Decimal TotalASM
    * @return: Decimal 
    **/
    public static Decimal calculateASMRevenue(Decimal TotalLicense, Decimal TotalParentLicense,Decimal TotalASM){
        Decimal QLPOT = TotalASM / TotalParentLicense;
        Decimal FinalRevenueAmount =  TotalLicense * QLPOT;
        System.debug(LoggingLevel.ERROR, '@@ ASM QLPOT! ' + QLPOT);
        System.debug(LoggingLevel.ERROR, '@@ ASM FinalRevenueAmount! ' + FinalRevenueAmount);
        System.debug(LoggingLevel.ERROR, '@@ ASM TOTAL! ' + TotalASM);
        System.debug(LoggingLevel.ERROR, '@@ ASM LICENSE! ' + TotalLicense);
        System.debug(LoggingLevel.ERROR, '@@ ASM TOTAL PARENT LICENSE! ' + TotalParentLicense);
        return FinalRevenueAmount;
    }
    
     /**
    * @description: CALCULATE SAAS ALLOCATED REVENUE
    * @author: Gerald Arzadon | 13/04/2021 
    * @param: Decimal TotalCloud, Decimal TotalOrderLicense, , Decimal TotalGroupLicense
    * @return: Decimal 
    **/
    public static Decimal calculatePOTCloudRevenue(Decimal TotalCloud, Decimal TotalOrderLicense, Decimal TotalGroupLicense){
        Decimal QLPOT = TotalCloud / TotalOrderLicense;
        Decimal FinalRevenueAmount =  TotalGroupLicense * QLPOT;  
        System.debug(LoggingLevel.ERROR, '@@ TOTAL ORDER LICENSE' + TotalOrderLicense);
        System.debug(LoggingLevel.ERROR, '@@ TOTAL GROUP LICENSE!' + TotalGroupLicense);
        System.debug(LoggingLevel.ERROR, '@@ TOTAL CLOUD! ' + TotalCloud);
        System.debug(LoggingLevel.ERROR, '@@ % ! ' + QLPOT);
        System.debug(LoggingLevel.ERROR, '@@ FINAL CLOUD REVENUE ! ' + FinalRevenueAmount);
        return FinalRevenueAmount;
    }
    
    /**
    * @description CALCULATE NON SAAS ALLOCATED REVENUE
    * @author: Gerald Arzadon | 13/04/2021 
    * @param: Decimal TotalCloud, Decimal TotalTerm, , Decimal TermMonths
    * @return: Decimal 
    **/
    public static Decimal calculateNonPOTCloudRevenue(Decimal TotalCloud, Decimal TotalTerm,  Decimal TermMonths){
        Decimal QLPOT = TotalCloud / TotalTerm;
        Decimal FinalRevenueAmount =  QLPOT * TermMonths;
        System.debug(LoggingLevel.ERROR, '@@ TOTAL CLOUD! ' + TotalCloud);
        System.debug(LoggingLevel.ERROR, '@@ % ! ' + QLPOT);
        System.debug(LoggingLevel.ERROR, '@@ FINAL CLOUD REVENUE ! ' + FinalRevenueAmount);
        return FinalRevenueAmount;
    }
}