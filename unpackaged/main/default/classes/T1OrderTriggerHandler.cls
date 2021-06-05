/**
 * @description       : T1OrderTriggerHandler
 * @author            : Alfredo Edo
 * @group             : 
 * @last modified on  : 28-04-2021
 * @last modified by  : Alfredo Edo
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   28-04-2021   Alfredo Edo              Initial Version
**/
public class T1OrderTriggerHandler {

    static public void onAfterInsert(Order[] newOrders) {
        
        set<Id> OrderIds = new set<Id>();
        set<Id> SBQQQuoteIds = new set<Id>();
        set<Id> OpportunityIds = new set<Id>();
        set<Id> ServiceContractIds = new set<Id>();
        set<Id> ContractLineItemIds = new set<Id>();
        
        Map<Id, List<id>> orderQuoteMap = new Map<Id, List<id>>();
        Map<Id, List<id>> quoteOpportunityMap = new Map<Id, List<id>>(); 
        Map<Id, List<id>> opportunityServContractMap = new Map<Id, List<id>>();
        Map<Id, List<ContractLineItem>> servContractLineMap = new Map<Id, List<ContractLineItem>>();
        Map<string, List<SBQQ__QuoteLine__c>> quoteLineMap = new Map<string, List<SBQQ__QuoteLine__c>>();

        for(Order newOrder : newOrders){
            OrderIds.add(newOrder.ID);
            SBQQQuoteIds.add(newOrder.SBQQ__Quote__c);
            //Map order with quote
            if (orderQuoteMap.containsKey(newOrder.ID)) {
                orderQuoteMap.get(newOrder.ID).add(newOrder.SBQQ__Quote__c);
            }
            else {
                orderQuoteMap.put(newOrder.ID, new List<id>{ newOrder.SBQQ__Quote__c });
            }
        }
        
        
        if (OrderIds.IsEmpty()){
            System.debug('No Order to be process' );
            return;
        }
        System.debug('number of order  ' + OrderIds.size());
        
        //Get related quote which have type renewal
        List<SBQQ__Quote__c> l_quotes = [SELECT ID, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id IN :SBQQQuoteIds AND SBQQ__Type__c = 'Renewal' ];
        for(SBQQ__Quote__c l_quote : l_quotes){                 
            OpportunityIds.add(l_quote.SBQQ__Opportunity2__c);
            //map quote with opportunity
            if (quoteOpportunityMap.containsKey(l_quote.ID)) {
                quoteOpportunityMap.get(l_quote.ID).add(l_quote.SBQQ__Opportunity2__c);
            }
            else {
                quoteOpportunityMap.put(l_quote.ID, new List<id>{ l_quote.SBQQ__Opportunity2__c });
            }
        }
        
        if (OpportunityIds.IsEmpty()){
            return;
        }
        System.debug('number of OpportunityIds  ' + OpportunityIds.size());
   
        List<Opportunity> l_opportunities = [SELECT ID, SBQQSC__RenewedServiceContract__c FROM Opportunity WHERE Id IN :OpportunityIds];
        for(Opportunity l_opportunity : l_opportunities){                 
            ServiceContractIds.add(l_opportunity.SBQQSC__RenewedServiceContract__c);
            //map opportunity with service contract
            if (opportunityServContractMap.containsKey(l_opportunity.ID)) {
                opportunityServContractMap.get(l_opportunity.ID).add(l_opportunity.SBQQSC__RenewedServiceContract__c);
            }
            else {
                opportunityServContractMap.put(l_opportunity.ID, new List<id>{ l_opportunity.SBQQSC__RenewedServiceContract__c });
            }
        }
        
        if (ServiceContractIds.IsEmpty()){
            return;
        }   
        System.debug('number of ServiceContractIds  ' + ServiceContractIds.size());

        List<ContractLineItem> ctrLineList = [SELECT Id, SBQQSC__ProductName__c, SBQQSC__RenewalQuantity__c, SBQQSC__Quantity__c, ServiceContractId FROM ContractLineItem WHERE ServiceContractId IN :ServiceContractIds]; 
        for(ContractLineItem ctrLine : ctrLineList){                 
            ContractLineItemIds.add(ctrLine.Id);
            //map service contract with contract line item
            if (servContractLineMap.containsKey(ctrLine.ServiceContractId)) {
                servContractLineMap.get(ctrLine.ServiceContractId).add(ctrLine);
            }
            else {
                servContractLineMap.put(ctrLine.ServiceContractId, new List<ContractLineItem>{ ctrLine });
            }
        }
        
        if (ContractLineItemIds.IsEmpty()){
            return;
        }
        System.debug('number of ContractLineItemIds  ' + ContractLineItemIds.size());
                     
        List<SBQQ__QuoteLine__c> qLineList = [SELECT Id,SBQQ__ProductName__c, SBQQ__Quantity__c, SBQQ__Quote__c, SBQQSC__RenewedContractLine__c 
                                              FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c IN :SBQQQuoteIds and SBQQSC__RenewedContractLine__c IN :ContractLineItemIds ];                                
        for(SBQQ__QuoteLine__c qLine : qLineList){
            //map quote + contractline with contract line
            if (quoteLineMap.containsKey(qLine.SBQQ__Quote__c + ':' + qLine.SBQQSC__RenewedContractLine__c)) {
                quoteLineMap.get(qLine.SBQQ__Quote__c + ':' + qLine.SBQQSC__RenewedContractLine__c).add(qLine);
            }
            else {
                quoteLineMap.put(qLine.SBQQ__Quote__c + ':' + qLine.SBQQSC__RenewedContractLine__c, new List<SBQQ__QuoteLine__c>{ qLine });
            }
        }
        System.debug('number of qLineList  ' + qLineList.size());

        //list of order to be updated
        list <Order> CheckOrders = [SELECT ID, RenewalReductions__c FROM Order WHERE Id IN :OrderIds]; 
        list <Order> UpdateOrders = new list <Order>();     
        for(Order l_order : CheckOrders){
            
            if (orderQuoteMap.containsKey(l_order.id)) {
                List<id> quoteIds = orderQuoteMap.get(l_order.id);
                for (Id quoteId :quoteIds){
                    if (quoteOpportunityMap.containsKey(quoteId)){
                        List<id> oppIds = quoteOpportunityMap.get(quoteId);
                        for (Id oppId :oppIds){
                            if (opportunityServContractMap.containsKey(oppId)){
                                List<id> servContractIds = opportunityServContractMap.get(oppId);
                                for (Id servContractId :servContractIds){
                                    if (servContractLineMap.containsKey(servContractId)){
                                        List<ContractLineItem> orderContractLines = servContractLineMap.get(servContractId);
                                    	for (ContractLineItem orderContractLine :orderContractLines){
                                            
                                            //Check if module available or has been removed
                                            if (quoteLineMap.containsKey(quoteId + ':' + orderContractLine.id)){
                                                List<SBQQ__QuoteLine__c> orderQuoteLines = quoteLineMap.get(quoteId + ':' + orderContractLine.id);
                                                System.debug('orderQuoteLines:   ' + orderQuoteLines.size());
                                                for (SBQQ__QuoteLine__c orderQuoteLine :orderQuoteLines){
                                                      
                                                    if (orderContractLine.SBQQSC__RenewalQuantity__c == null){
                                                        if (orderQuoteLine.SBQQ__Quantity__c < orderContractLine.SBQQSC__Quantity__c){
                                                            double l_diff = orderContractLine.SBQQSC__Quantity__c - orderQuoteLine.SBQQ__Quantity__c;
                                                            if ( l_order.RenewalReductions__c == null){
                                                               l_order.RenewalReductions__c = orderContractLine.SBQQSC__ProductName__c + ' has been reduced by ' + l_diff + 
                                                                   ' from ' + orderContractLine.SBQQSC__Quantity__c + ' To '+ orderQuoteLine.SBQQ__Quantity__c +'. ';  
 
                                                            }
                                                            else{
                                                              l_order.RenewalReductions__c = l_order.RenewalReductions__c + orderContractLine.SBQQSC__ProductName__c + ' has been reduced by ' + l_diff + 
                                                                  ' from ' + orderContractLine.SBQQSC__Quantity__c + ' To '+ orderQuoteLine.SBQQ__Quantity__c +'. ';   
  
                                                            }
                                                        }                                                                               
                                                    }
                                                    else{
                                                        if (orderQuoteLine.SBQQ__Quantity__c < orderContractLine.SBQQSC__RenewalQuantity__c){
                                                            double l_diff = orderContractLine.SBQQSC__RenewalQuantity__c - orderQuoteLine.SBQQ__Quantity__c;
                                                            if ( l_order.RenewalReductions__c == null){
                                                               l_order.RenewalReductions__c = orderContractLine.SBQQSC__ProductName__c + ' has been reduced by ' + l_diff + 
                                                                   ' from ' + orderContractLine.SBQQSC__RenewalQuantity__c + ' To '+ orderQuoteLine.SBQQ__Quantity__c +'. ';
 
                                                            }
                                                            else{
                                                              l_order.RenewalReductions__c = l_order.RenewalReductions__c + orderContractLine.SBQQSC__ProductName__c + ' has been reduced by ' + l_diff + 
                                                                  ' from ' + orderContractLine.SBQQSC__RenewalQuantity__c + ' To '+ orderQuoteLine.SBQQ__Quantity__c +'. ';  
  
                                                            } 
                                                        }                                        
                            						}                                                     
                                                }                                                
                                            }
                                            else {
                                                // modules have been removed
                                                if ( l_order.RenewalReductions__c == null){
                                                    l_order.RenewalReductions__c = orderContractLine.SBQQSC__ProductName__c + ' has been removed. ';
                                                }
                                                else {
                                                    l_order.RenewalReductions__c = l_order.RenewalReductions__c + orderContractLine.SBQQSC__ProductName__c + ' has been removed. ';
                                                }
                                            }
                                    	}
                                    }
                                }
                            }                            
                        }
                    }
                } 
            }
            if (l_order.RenewalReductions__c <> null){
                UpdateOrders.add(l_order);
                System.debug('renewalreduction text:   ' + l_order.RenewalReductions__c);
            }
            
        } 
        system.debug('UpdatedOrder count:   ' + UpdateOrders.size());
            update UpdateOrders;     
    }
}