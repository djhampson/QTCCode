/*******************************************************************************************************
* Class Name      	: SM_PerpetualOnCloud
* Description		: Service layer for functions related to Perpetual On Cloud Service Contract
* Author          	: Simplus - Yi Zhang
* Created On      	: 25/02/2021
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              25/02/2021		1000				Initial version
******************************************************************************************************/
public class SM_PerpetualOnCloud {
    
    public static final String NEW_PRODUCT_NAME = 'No ASM (migrated to Perpetual on Cloud)';
    public static final String PERPETUAL_ON_CLOUD = 'Perpetual on Cloud';
    public static final List<String> PRODUCTCODE_SERVICE_PACK = new List<String>{'SPS', 'SPNS'};
    /**
    * @description 
    * @author Yi Zhang | 25/02/2021 
    * @param List<ServiceContract> serviceContracts 
    **/
    public static void amendOriginalContractsEtc(List<ServiceContract> serviceContracts) {
        try {
            Set<Id> originalServiceContractIds = new Set<Id>();
            Map<Id, ServiceContract> serviceContractsInProgress = new Map<Id, ServiceContract>();
            Map<Id, Date> contractIdStartDateMap = new Map<Id, Date>();
            Map<Id, Date> contractIdEndDateMap = new Map<Id, Date>();
            
            // get original contracts 
            // traverse from CLI -> QL -> SBQQSC__RenewedContractLine__c -> SC to locate the original contract
            for(ServiceContract sc : serviceContracts){
                System.debug('in scope sc: ' + JSON.serialize(sc));
                
                for(ContractLineItem line: sc.ContractLineItems){

                    if(line.SBQQSC__QuoteLine__r?.SBQQSC__RenewedContractLine__r.ServiceContractId != null){
                        Id originalServiceContractId = line.SBQQSC__QuoteLine__r.SBQQSC__RenewedContractLine__r.ServiceContractId;
                        originalServiceContractIds.add(originalServiceContractId); 
                        contractIdStartDateMap.put(originalServiceContractId, line.ServiceContract.StartDate); 
                    }
                }
                
                serviceContractsInProgress.put(sc.Id, new ServiceContract(Id = sc.Id, Perpetual_On_Cloud_Status__c = 'In progress'));

            }

            // prepare product map of No ASM (migrated to Perpetual on Cloud), to be added to amendment quotes
            Map<String, ProductModel> noASMProductMap = new Map<String, ProductModel>();
            for(PricebookEntry pbe : [SELECT Id, Product2Id, CurrencyIsoCode, Pricebook2Id FROM PricebookEntry WHERE IsActive = true AND Product2.IsActive = true AND Product2.Name = :NEW_PRODUCT_NAME ]) {
                noASMProductMap.put(
                    pbe.CurrencyIsoCode + pbe.Pricebook2Id, 
                    T1_ProductReader.read(pbe.Product2Id, pbe.Pricebook2Id, pbe.CurrencyIsoCode));
            }

            // System.debug('noASMProductMap: ' + noASMProductMap);

            // amend original contracts using CPQ API
            Set<String> quoteIds = new Set<String>();
            Set<String> productIds = new Set<String>();
            List<QuoteModel> quotes = new List<QuoteModel>();
            for(Id serviceContractId : originalServiceContractIds){
                
                QuoteModel quote = T1_ContractAmender.load(serviceContractId);
                quotes.add(quote);

                for(QuoteLineModel qlm : quote.lineItems) {
                    productIds.add(qlm.record.SBQQ__Product__c);
                }
            }

            // prepare a product map to help amending line quantity for Service Pack Quote Lines
            Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT Id, ProductCode FROM Product2 WHERE Id IN :productIds]);

            for(QuoteModel quote : quotes) {

                Boolean quoteLinesAmended = false;

                // amend line quantity for Service Pack Quote Lines
                // unfortunately this approach is unstable as sometimes qlm.record is null
                // has to use alternative below
                for(QuoteLineModel qlm : quote.lineItems) {
                    System.debug('qlm.record: ' + qlm.record);
                    Id productId = (Id) qlm.record.SBQQ__Product__c;
                    if(productMap.containsKey(productId) && PRODUCTCODE_SERVICE_PACK.contains(productMap.get(productId).ProductCode)) {
                        qlm.record.SBQQ__Quantity__c = 0;
                        quoteLinesAmended = true;
                    }
                }
                
                // use CPQ API to add No ASM (migrated to Perpetual on Cloud) product
                String key = quote.record.CurrencyIsoCode + (Id)quote.record.SBQQ__PricebookId__c;
                if(noASMProductMap.containsKey(key)) {
                    quote = T1_ProductAdder.add(quote, new List<ProductModel>{noASMProductMap.get(key)}, 0);
                    quoteLinesAmended = true;
                }
                
                // use CPQ API to save quote
                if(quoteLinesAmended) {
                    quote = (QuoteModel) JSON.deserialize(SBQQ.ServiceRouter.save('SBQQ.QuoteAPI.QuoteSaver', JSON.serialize(quote)), QuoteModel.class);
                }

                quoteIds.add(quote.record.Id);
            }
            
            // change contracts in scope to in progress
            if(serviceContractsInProgress.size() > 0){
                update serviceContractsInProgress.values();
            }
            
            // async to update amendment quote's start date and auto order
            Integer i = 1;
            System.schedule(
                OrderTriggerHandler.getJobName('Perpetual On Cloud Amendment Quotes Auto Order'), 
                OrderTriggerHandler.getJobCronString(i),   //1 minute
                new SM_AutoOrderSchedulable(quoteIds, contractIdStartDateMap, contractIdEndDateMap)); 
            
            // async  to update contract xx_status__c field
            Integer t = 2;
            System.schedule(
                OrderTriggerHandler.getJobName('Perpetual On Cloud Contracts Status Update'), 
                OrderTriggerHandler.getJobCronString(i),   //1 minute
                new SM_UpdateContractsSchedulable(serviceContractsInProgress.keySet(), 'Perpetual_On_Cloud_Status__c', 'Processed')); 
            
        } catch(Exception e) {
            System.debug('failed to run perpetual on cloud batch: ' + e.getMessage());
            insert DM_ApplicationLog.createApplicationLog(e);
        }
    }

    /**
    * @description 
    * @author Yi Zhang | 25/02/2021 
    * @param Set<Id> contractIds 
    * @param String fieldName 
    * @param Object fieldValue 
    **/
    public static void updateContracts(Set<Id> contractIds, String fieldName, Object fieldValue) {
        try {
            List<ServiceContract> contractsToUpdate = new List<ServiceContract>();
            for(Id contractId : contractIds){
                ServiceContract serviceContract = new ServiceContract(Id = ContractId);  
                serviceContract.put(fieldName, fieldValue);
                contractsToUpdate.add(serviceContract);
            }
            
            If(contractsToUpdate.size() > 0){
                update contractsToUpdate;
            }
            
        } catch (Exception e) {
            System.debug('failed to update service contracts: ' + e.getMessage());
            insert DM_ApplicationLog.createApplicationLog(e);
        }
    }

    /**
    * @description 
    * @author Yi Zhang | 25/02/2021 
    * @param Set<String> quoteIds 
    * @param Map<Id Date> contractIdStartDateMap 
    * @param Map<Id Date> contractIdEndDateMap 
    **/
    public static void orderAmendmentQuotes(Set<String> quoteIds, Map<Id, Date> contractIdStartDateMap, Map<Id, Date> contractIdEndDateMap) {
        System.debug('quoteIds: ' + quoteIds);
        try {
            List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
            
            for(SBQQ__Quote__c  quote : [SELECT Id, SBQQSC__MasterServiceContract__c FROM SBQQ__Quote__c WHERE Id IN:quoteIds]){
                
                SBQQ__Quote__c q = new SBQQ__Quote__c(Id = quote.Id, Auto_Amendment__c = true, SBQQ__Ordered__c = true);

                // start & end dates conditional
                if(contractIdStartDateMap.containsKey(quote.SBQQSC__MasterServiceContract__c)) {
                    q.SBQQ__StartDate__c = contractIdStartDateMap.get(quote.SBQQSC__MasterServiceContract__c);
                }
                
                if(contractIdEndDateMap.containsKey(quote.SBQQSC__MasterServiceContract__c)) {
                    q.SBQQ__EndDate__c = contractIdEndDateMap.get(quote.SBQQSC__MasterServiceContract__c);
                }

                quotesToUpdate.add(q);
            }
            
            if(quotesToUpdate.size() > 0){
                update quotesToUpdate;
            }
            
        } catch (Exception e) {   
            System.debug('failed to order amendment quotes: ' + e.getMessage());
            insert DM_ApplicationLog.createApplicationLog(e);
        } 
    }
}