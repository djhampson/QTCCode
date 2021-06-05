/*
DEscription: Case Entitlement service class to process cases and generate their servie packs entitlement as per the account on case
*/

public class T1_CaseEntitlementService {
    
    // product category for which entitlements need to be generated
    public static final Set<String>  CONTRACT_LINEITEM_SERVICE_CATEGORY = new Set<String>{'Support Fee'};
    public static final Map<Id,Schema.RecordTypeInfo> caseRecordTypeIdNameMap = getCaseRecordTypeMap();
    
    /* DEcription: Future Method to process  the cases called by Case Trigger handler
    * return type: void
    * param: set of case Ids
    ****************/
    @future
    public static void processCasesforCreatingEntitlements( Set<Id> caseIds ){
        
        // query case priority,customer product and record Type
        List<Case> caseList = queryCaseById( caseIds );  // Query 1
        createEntitlements(caseList, caseIds);                        

    }
    
    public static void createEntitlements( List<Case> caseList ,Set<Id> caseIds ){
        //  storemap of Case Id and  customer product name
        Map<Id,String> caseIdcustProductNameMap = new Map<Id,String>();

        // create Map of case Id and account Id
        Map<Id,Id> caseIdAccountIdMap = new Map<Id,Id>();

        if( caseList.size() > 0 ){
            for( Case caseLoopVar: caseList){
                caseIdcustProductNameMap.put( caseLoopVar.Id, caseLoopVar.Customer_Product__c );
                caseIdAccountIdMap.put( caseLoopVar.Id, caseLoopVar.AccountId );
            }
        }

        // create map of service product and Sales Product Names
        Map<String,Set<String>> serviceProdSalesProductMap = new Map<String,Set<String>>();

        // set to store list of sales product names
        Set<String> salesProductNameSet = new Set<String>();

        for( Product_Mapping__c prodMapVar : getProductMappingByServiceProduct( new Set<String>(caseIdcustProductNameMap.values())) ){              // query 2
            salesProductNameSet.add( prodMapVar.Sales_Product__c );
            if(  !serviceProdSalesProductMap.keyset().contains( prodMapVar.Service_Product__c ) ){
                serviceProdSalesProductMap.put(prodMapVar.Service_Product__c,new Set<String>{prodMapVar.Sales_Product__c});
            }
            else{
                Set<String> salesProductList = serviceProdSalesProductMap.get(prodMapVar.Service_Product__c);
                salesProductList.add( prodMapVar.Sales_Product__c );
                serviceProdSalesProductMap.put(prodMapVar.Service_Product__c,salesProductList);
            }
        }

        system.debug('serviceProdSalesProductMap ' + serviceProdSalesProductMap);

        // create Map of Case Id and corresponding sales product
        Map<Id,Set<String>> caseIdSalesProductsMap = new Map<Id,Set<String>>();
        try{ 
            for( Case caseLoopVar: caseList){
                for( String servProdVar : serviceProdSalesProductMap.keyset() ){
                    if( caseLoopVar.Customer_Product__c == servProdVar){
                        caseIdSalesProductsMap.put(caseLoopVar.Id,serviceProdSalesProductMap.get(servProdVar));
                    }
                }
            }
            system.debug( 'caseIdSalesProductsMap ' + caseIdSalesProductsMap);
        }
        catch( Exception e){
            String message = ' No Sales Product mapping exists for case product';
            system.debug( 'Exception details ' + e.getCause() + e.getMessage()+ ' ' + message + ' '+ e.getStackTraceString());
            Error_Log__c errLog = T1_ErrorLogService.createErrorLog( e, caseIds, 'Apex Class',  'T1_CaseEntitlementService');
            insert errLog;
        }

        // add shared accounts id to set and create Map of target and source account
        Map<Id,Set<Id>> targetSourceAccountIdMap = new Map<Id,Set<Id>>();
        for( Shared_Entitlements__c sharedEntitlmentVar : getSourceAccountIds( new Set<Id>(caseIdAccountIdMap.values()) ) ){        // query 3
            if( sharedEntitlmentVar != null ){
             
                if( !targetSourceAccountIdMap.keyset().contains( sharedEntitlmentVar.Target_Account__c ) ){
                    targetSourceAccountIdMap.put( sharedEntitlmentVar.Target_Account__c, new Set<Id>{sharedEntitlmentVar.Source_Account__c} );
                }
                else{
                    Set<Id> sourceAccountIds = targetSourceAccountIdMap.get( sharedEntitlmentVar.Target_Account__c);
                    sourceAccountIds.add( sharedEntitlmentVar.Source_Account__c );
                    targetSourceAccountIdMap.put(sharedEntitlmentVar.Target_Account__c,sourceAccountIds );
                }
            }
        }
        
        // create set of account ids related to case 
        Set<Id> accountIdSet = new Set<Id>( caseIdAccountIdMap.values() );
        // add all account ids to set which are shared to above accounts
        if( targetSourceAccountIdMap.keyset().size() > 0 ){
            for( Id idVar: targetSourceAccountIdMap.keyset() ){
                accountIdSet.addAll(  targetSourceAccountIdMap.get(idVar)  );
            }
            
        }
        // query Service Contract for all those account Ids along with contract line items and create Map
        List<ServiceContract> serviceContractsList = getServiceContractByAccountId( accountIdSet, salesProductNameSet );        // query 4
        
        // Map of Account and corresponding service contracts
        Map<Id,List<ServiceContract>> accountServiceContractMap = new Map<Id,List<ServiceContract>>();
        for( ServiceContract scVar :  serviceContractsList){
           system.debug(' Inside Service Contracts Loop ' + scVar.AccountId);
            if( !accountServiceContractMap.keyset().contains( scVar.AccountId ) ){
                system.debug('Inside account map does not have service contract ');
                accountServiceContractMap.put( scVar.AccountId , new List<ServiceContract>{ scVar } );
            }
            else{
                List<ServiceContract> scList = accountServiceContractMap.get( scVar.AccountId );
                scList.add( scVar );
                accountServiceContractMap.put( scVar.AccountId , scList );
            }
            system.debug('accountServiceContractMap '+ accountServiceContractMap);
           
        }
        system.debug('accountServiceContractMap after loop *****'+ accountServiceContractMap);
        // Map of Case and corresponding service contracts
        Map<Id,List<ServiceContract>> caseServiceContractMap = new Map<Id,List<ServiceContract>>();
        for( Case caseVar: caseList ){

            system.debug('Case CreatedDate '+ caseVar );
            Id accountId = caseIdAccountIdMap.get( caseVar.Id );
            //  get source accounts for the case account if any
            Set<Id> sourceAccntIds = targetSourceAccountIdMap.get(accountId);
            if( sourceAccntIds == null ) sourceAccntIds = new Set<Id>();
            sourceAccntIds.add( accountId );
            system.debug('sourceAccntIds ' + sourceAccntIds);
            // loop through each account and theit service contracts
            Integer i =0;
            for(Id accountIdVar: sourceAccntIds){
                system.debug('accountIdVar '+ accountIdVar);
                i++;
                // get all service contracts for all accounts
                List<ServiceContract> serviceContracts = accountServiceContractMap.get(accountIdVar);
                system.debug('serviceContracts for account '+ accountIdVar + ' are ' + serviceContracts);
                // system.debug( serviceContracts.size() );
                if( serviceContracts != null ){
                    for(ServiceContract serviceContractVar : serviceContracts){
                        system.debug( 'Inside ServiceContract loop Contract Line Items for Service COntract ' + serviceContractVar.Name);
                        system.debug(serviceContractVar.ContractLineItems);
                        
                        if( caseVar.CreatedDate >= serviceContractVar.StartDate && caseVar.CreatedDate <= serviceContractVar.EndDate ){
                            if( !caseServiceContractMap.keyset().contains(caseVar.Id) ){
                                caseServiceContractMap.put( caseVar.Id, new List<ServiceContract>{ serviceContractVar });
                            }
                            else{
                                List<ServiceContract> serviceContractListForCase = caseServiceContractMap.get( caseVar.Id );
                                serviceContractListForCase.add( serviceContractVar );
                                caseServiceContractMap.put( caseVar.Id, serviceContractListForCase );
                            }
                            
                        }
                    }
                }
            }
        }
        system.debug('caseServiceContractMap ' + caseServiceContractMap);
        List<Case_Entitlements__c> caseEntitlements = new List<Case_Entitlements__c>();
        try{
            // create Map of case and each entitlements
           
            for(Case caseVar : caseList ){
                String caseRecordType = caseRecordTypeIdNameMap.get(caseVar.RecordTypeId).getName();
                Set<String> caseSalesProductNames  = caseIdSalesProductsMap.get(caseVar.Id);
                system.debug('caseRecordType ' + caseRecordType );
                for( ServiceContract serviceContractVar : caseServiceContractMap.get(caseVar.Id) ){
                    
                    // generate map of Contract line item corresponding to Id for sales product corresponding to Service Product on case
                    Map<Id,ContractLineItem> caseMasterProductContractLineItems = new Map<Id,ContractLineItem>();
                    Map<Id,ContractLineItem> validContractLineItemsMap = new Map<Id,ContractLineItem>();
                    for(ContractLineItem lineItemVar : serviceContractVar.ContractLineItems){
                        if( caseVar.CreatedDate >= lineItemVar.SBQQSC__SubscriptionStartDate__c && caseVar.CreatedDate <= lineItemVar.End_Terminated_Date__c && caseSalesProductNames.contains( lineItemVar.SBQQSC__ProductName__c) ){
                            
                            caseMasterProductContractLineItems.put( lineItemVar.Id,lineItemVar );
                            validContractLineItemsMap.put( lineItemVar.Id,lineItemVar );
                        }
                            
                    }
                    // if  case sales product matches contract line item's product  , the add their service packs
                    if( caseMasterProductContractLineItems.keyset().size() > 0 ){
                        for(ContractLineItem lineItemVar : serviceContractVar.ContractLineItems){
                            if( caseMasterProductContractLineItems.keyset().contains(lineItemVar.SBQQSC__RequiredById__c) ){
                                validContractLineItemsMap.put(lineItemVar.Id,lineItemVar);
                            }
                        }
                        for(ContractLineItem lineItemVar : serviceContractVar.ContractLineItems){
                            if( validContractLineItemsMap.keyset().contains(lineItemVar.SBQQSC__RequiredById__c) ){
                                validContractLineItemsMap.put(lineItemVar.Id,lineItemVar);
                            } 
                        }
                        system.debug('validContractLineItemsMap '+ validContractLineItemsMap);
                        system.debug('validContractLineItemsMap size() ' + validContractLineItemsMap.size() );
                        Integer i=0;
                        for(Id lineItemId : validContractLineItemsMap.keyset() ){
                            ContractLineItem lineItemVar = validContractLineItemsMap.get( lineItemId );
                            system.debug('Line Items ' + i + ' ' + lineItemVar);
                            i++;
                            if( CONTRACT_LINEITEM_SERVICE_CATEGORY.contains(lineItemVar.Category__c) && !String.isEmpty(lineItemVar.Entitlement_Case_Type__c) && !String.isEmpty(lineItemVar.Entitlement_Priority__c) ){
                                if( !caseMasterProductContractLineItems.keyset().contains(lineItemVar.SBQQSC__RequiredById__c) &&  (lineItemVar.Entitlement_Case_Type__c == 'All' || lineItemVar.Entitlement_Case_Type__c.contains(caseRecordType) )  &&  (lineItemVar.Entitlement_Priority__c == 'All' || lineItemVar.Entitlement_Priority__c.contains(caseVar.Priority)) ){
                                    Case_Entitlements__c caseEntitleMent = new Case_Entitlements__c(Case__c=caseVar.Id,Contract_Line_Item__c=lineItemVar.Id);
                                    caseEntitlements.add(caseEntitleMent);
                                }
                            }
                        
                        }
                    }
                }
            }
        }
        catch( Exception e){
            system.debug('It is just Data issue ' + e.getCause() + ' ' + e.getMessage() );
            system.debug('It is just Data issue ' + e.getCause() + ' ' + e.getStackTraceString() );
        }
        system.debug('caseEntitlements '+ caseEntitlements);
        if( caseEntitlements.size() > 0){
            try{ 
                insert caseEntitlements;
            }
            catch( Exception e){
               
                system.debug( 'Exception details ' + e.getCause() + e.getMessage() + ' '+ e.getStackTraceString());
                Error_Log__c errLog = T1_ErrorLogService.createErrorLog( e, caseIds, 'Apex Class',  'T1_CaseEntitlementService');
                insert errLog;
            }
    
        }
    }

    public static Map<Id,Schema.RecordTypeInfo> getCaseRecordTypeMap( ){
        return Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById();
    }

    public static List<ServiceContract> getServiceContractByAccountId( Set<Id> accountIds, Set<String> salesProductNameSet ){
        return [ SELECT Name,AccountId,StartDate,EndDate,(SELECT SBQQSC__ProductName__c,SBQQSC__RequiredById__c,SBQQSC__SubscriptionStartDate__c,End_Terminated_Date__c,Category__c,Entitlement_Case_Type__c,Entitlement_Priority__c FROM ContractLineItems WHERE Category__c = :CONTRACT_LINEITEM_SERVICE_CATEGORY OR SBQQSC__ProductName__c IN :salesProductNameSet) FROM ServiceContract WHERE AccountId IN :accountIds ];
    }


    public static List<Shared_Entitlements__c> getSourceAccountIds( Set<Id> accountIds ){
        return [ SELECT Active__c,Source_Account__c,Target_Account__c FROM Shared_Entitlements__c WHERE Target_Account__c IN :accountIds AND Active__c = true ];
    } 

    

    public static List<Product_Mapping__c> getProductMappingByServiceProduct( Set<String> productNames ){
        return [ SELECT Sales_Product__c,Service_Product__c FROM Product_Mapping__c WHERE Service_Product__c IN :productNames ];
    }

    

    public static List<Case> queryCaseById( set<Id> caseIds ){
        return [ SELECT AccountId,RecordTypeId,Case_Record_Type_Name__c,CreatedDate,Customer_Product__c,Priority FROM Case WHERE ID IN :caseIds ];
    }

    public static List<Case_Entitlements__c> getCaseEntitlementsByCaseId( set<Id> caseIds ){
        return [ SELECT Case__c FROM Case_Entitlements__c WHERE Case__c IN :caseIds ];
    }

}