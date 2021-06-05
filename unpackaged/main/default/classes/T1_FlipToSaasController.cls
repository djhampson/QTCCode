/*******************************************************************************************************
* Class Name      	: T1_FlipToSaasController
* Description		: CONTROLLER FOR FLIP TO SAAS LIGHTNING COMPONENT
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 2-15-2020
* Modification Log	: 
* -----------------------------------------------------------------------------------------------------
* Developer				Date					Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	2-15-2020				Initial version 
******************************************************************************************************/
public class T1_FlipToSaasController {
    
    @AuraEnabled
    public static List<ServiceContractListWrapper> getServiceContracts(Id OppId){
        List<ServiceContractListWrapper> ServContListWrapper = new List<ServiceContractListWrapper>();
        Opportunity OppRec = [SELECT AccountId,Start_Date__c FROM Opportunity WHERE Id =: OppId];
        List<ServiceContract> ServContList = [SELECT Id,ContractNumber,Deal_Type__c,StartDate,EndDate 
                                              FROM ServiceContract 
                                              WHERE Deal_Type__c = 'Perpetual' 
                                              AND AccountId =:OppRec.AccountId
                                              AND StartDate <= :OppRec.Start_Date__c
                                              AND EndDate >= :OppRec.Start_Date__c];
        
        for(ServiceContract ServCont:ServContList){
            ServContListWrapper.add(new ServiceContractListWrapper(false,ServCont));
        }
        return ServContListWrapper;
    }
    
    @AuraEnabled
    public static List<ServiceContractListWrapper> getRecordsBydates(Id OppId, Date EffectiveDate){
        List<ServiceContractListWrapper> ServContListWrapper = new List<ServiceContractListWrapper>();
        Opportunity OppRec = [SELECT AccountId FROM Opportunity WHERE Id =: OppId];
        List<ServiceContract> ServContList = [SELECT Id,ContractNumber,Deal_Type__c,StartDate,EndDate 
                                              FROM ServiceContract 
                                              WHERE Deal_Type__c = 'Perpetual' 
                                              AND AccountId =:OppRec.AccountId 
                                              AND StartDate <= :EffectiveDate 
                                              AND EndDate >= :EffectiveDate ];
        
        for(ServiceContract ServCont:ServContList){
            ServContListWrapper.add(new ServiceContractListWrapper(false,ServCont));
        }
        return ServContListWrapper;
    }

    
    @AuraEnabled 
    public static void createLines(List<ServiceContract> ServContList, Id OppId){
        System.debug('Service Contracts ' + ServContList); 
        System.debug('Opportunity Id ' + OppId);
        
        Opportunity OppRec = [SELECT AccountId,Start_Date__c,Pricebook2Id FROM Opportunity WHERE Id =: OppId];
        Map<Id,List<ContractLineItem>> ContractToLinesMap = new Map<Id,List<ContractLineItem>>();
        Map<Id,SBQQ__ProductOption__c> SkuToProdOptionMap = new Map<Id,SBQQ__ProductOption__c>();
        Map<String,SBQQ__ProductOption__c> POTToProdOptionMap = new Map<String,SBQQ__ProductOption__c>();
        Map<Id,SBQQ__QuoteLine__c> AssetIdToQLIdMap = new Map<Id,SBQQ__QuoteLine__c>();
        Map<String,SBQQ__ProductOption__c> ConfiguredSKUOptionalSKUToPO = new Map<String,SBQQ__ProductOption__c>();
        
        Set<Id> AssetIds = new Set<Id>();
        Set<Id> SPFPProdOptIds = new Set<Id>();
        Set<Id> TopAssetIds = new Set<Id>();
        Set<Id> EDISCIds = new Set<Id>();
        Set<Id> ProductOptionSKU = new Set<Id>();
        Set<Id> AssetsIdsForAmendment = new Set<Id>();
        
        List<SBQQ__QuoteLine__c> TopLevelQuoteLineToInsert = new List<SBQQ__QuoteLine__c>();    
        List<SBQQ__QuoteLine__c> OriginalAssetQuoteLineToInsert = new List<SBQQ__QuoteLine__c>();   
        List<SBQQ__QuoteLine__c> LastLevelAssetQuoteLineToInsert = new List<SBQQ__QuoteLine__c>(); 
        List<SBQQ__QuoteLine__c> ContractLineQuoteLineToInsert = new List<SBQQ__QuoteLine__c>(); 
        
        // GET ALL PRODUCT OPTIONS AVAILABLE FOR SERVICE PACK FIXED PRICE    
        List<SBQQ__ProductOption__c> ProdOptionsList = [SELECT Id,SBQQ__OptionalSKU__r.ProductCode,SBQQ__OptionalSKU__c,SBQQ__ConfiguredSKU__c,SBQQ__Feature__c FROM SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__r.ProductCode IN ('SPFP','SPS','SPNS') ];
        
        // GET ALL PRODUCT OPTION IDS
        for(SBQQ__ProductOption__c ProdOption:ProdOptionsList){
            If(ProdOption.SBQQ__OptionalSKU__r.ProductCode == 'SPFP'){
                SPFPProdOptIds.add(ProdOption.SBQQ__ConfiguredSKU__c);
                If(SkuToProdOptionMap.get(ProdOption.SBQQ__ConfiguredSKU__c) == null){
                    SkuToProdOptionMap.put(ProdOption.SBQQ__ConfiguredSKU__c,ProdOption);
                } 
            }else{
                If(POTToProdOptionMap.get(ProdOption.SBQQ__OptionalSKU__r.ProductCode + '-' + ProdOption.SBQQ__ConfiguredSKU__c) == null){
                    POTToProdOptionMap.put(ProdOption.SBQQ__OptionalSKU__r.ProductCode + '-' + ProdOption.SBQQ__ConfiguredSKU__c,ProdOption);
                } 
            }
        }
        // GET ALL CONTRACT LINE FIELDS
        Map<String,Schema.SObjectField> cfields = Schema.getGlobalDescribe().get('ContractLineItem').getDescribe().fields.getMap();
        
        // GET ALL CONTRACT LINES FROM SELECTED CONTRACT IN THE UI
        List<ContractLineItem> ContractLines = Database.query('SELECT SBQQSC__Product__r.ProductCode,'+string.join(new List<String>(cfields.keySet()), ',')+' FROM ContractLineItem WHERE ServiceContractId IN :ServContList');
        
        System.debug('LINE SIZE ' + ContractLines.size());
        If(ContractLines.size() > 0){
            // LOOP ON ALL LINES AND POPULATE MAP
            for(ContractLineItem ContLineRec :ContractLines){
                If(ContLineRec.SBQQSC__Product__r.ProductCode == 'EDISC'){ 
                   EDISCIds.add(ContLineRec.Id); 
                }
                If(ContractToLinesMap.get(ContLineRec.ServiceContractId) <> null){
                    ContractToLinesMap.get(ContLineRec.ServiceContractId).add(ContLineRec);
                }else{
                    ContractToLinesMap.put(ContLineRec.ServiceContractId, new List<ContractLineItem>{ContLineRec}); 
                }
            }
            
            // CREATE AND INSERT A NEW QUOTE
            SBQQ__Quote__c newQuote = new SBQQ__Quote__c(SBQQ__Account__c = OppRec.AccountId,
                                                         SBQQ__Opportunity2__c = OppId,
                                                         SBQQ__Primary__c = TRUE,
                                                         SBQQ__PriceBook__c = OppRec.Pricebook2Id,
                                                         Transaction_Type__c = 'Flip to SaaS',
                                                         SBQQ__StartDate__c = OppRec.Start_Date__c,
                                                         SBQQ__EndDate__c = OppRec.Start_Date__c.addYears(1).addDays(-1),
                                                         End_Date__c = OppRec.Start_Date__c.addYears(1).addDays(-1));
            INSERT newQuote;
            
            // GET ASSET ID RECORDS IF ANY
            for(Id ContId: ContractToLinesMap.keySet()){
                for(ContractLineItem ContLines: ContractToLinesMap.get(ContId)){
                    If((ContLines.SBQQSC__Product__r.ProductCode == 'SPS' || ContLines.SBQQSC__Product__r.ProductCode == 'SPNS') && ContLines.SBQQSC__RequiredById__c <> null){
                        System.debug('ASSET ID REQUIRED BY ' + ContLines.SBQQSC__RequiredById__c);
                        System.debug('CONTRACT LINE ID ' + ContLines.Id);
                        AssetIds.add(ContLines.SBQQSC__RequiredById__c);
                    }
                }
            }
            System.debug('ASSET IDS ' + AssetIds.size());
            System.debug('ASSET ' + AssetIds);
            // GET ALL ASSET FIELDS
            Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get('Asset').getDescribe().fields.getMap();
            
            If(AssetIds.size() > 0){                
                // QUERY ALL ASSET RECORDS BASED ON THE ASSET IDS
                list<Asset> OriginalAssets = Database.query('SELECT SBQQ__ProductOption__r.Flip_to_Product_Option__c, Product2.Flip_to_Product__c, '+string.join(new List<String>(mfields.keySet()), ',')+' FROM Asset WHERE Id IN :AssetIds');
                
                // LOOP TRHOUGH ORIGINAL ASSETS AND CHECK IF THERE ARE STILL TOP / PARENT ASSETS
                for(Asset AssetRec: OriginalAssets){
                     if(AssetRec.SBQQ__RequiredByAsset__c <> null){
                        AssetsIdsForAmendment.add(AssetRec.SBQQ__RequiredByAsset__c);
                    }
                    TopAssetIds.add(AssetRec.SBQQ__RequiredByAsset__c);
                    AssetsIdsForAmendment.add(AssetRec.Id); 
                }
                
                // QUERY 3RD LEVEL ASSETS
                list<Asset> LastLevelAssets = Database.query('SELECT SBQQ__ProductOption__r.Flip_to_Product_Option__c, Product2.Flip_to_Product__c, '+string.join(new List<String>(mfields.keySet()), ',')+' FROM Asset WHERE SBQQ__RequiredByAsset__c IN :AssetIds');
                
                
                // QUERY PARENT ASSETS
                list<Asset> TopLevelAssets = Database.query('SELECT Product2.Flip_to_Product__c, '+string.join(new List<String>(mfields.keySet()), ',')+' FROM Asset WHERE Id IN :TopAssetIds');

                list<Asset> getAllAmendmentAssets = Database.query('SELECT '+string.join(new List<String>(mfields.keySet()), ',')+' FROM Asset WHERE SBQQ__RevisedAsset__c IN :AssetsIdsForAmendment OR SBQQ__RevisedAsset__c IN :LastLevelAssets');
                Map<Id,Decimal> OriginalAssetToAmendmentTotQuanMap = new Map<Id,Decimal>();
                
                // LOOP ON ALL AMENDMENT ASSETS AND CREATE A QL RECORD 
                for(Asset AssetRec :getAllAmendmentAssets){
                    If(OriginalAssetToAmendmentTotQuanMap.get(AssetRec.SBQQ__RevisedAsset__c) == null){
                        OriginalAssetToAmendmentTotQuanMap.put(AssetRec.SBQQ__RevisedAsset__c,AssetRec.Quantity);
                    }else{
                        Decimal LegacyVal =  OriginalAssetToAmendmentTotQuanMap.get(AssetRec.SBQQ__RevisedAsset__c) <> null ? OriginalAssetToAmendmentTotQuanMap.get(AssetRec.SBQQ__RevisedAsset__c) : 0;
                        Decimal NewVal =  AssetRec.Quantity <> null ? AssetRec.Quantity : 0;
                        Decimal TotVal =  LegacyVal + NewVal;
                        OriginalAssetToAmendmentTotQuanMap.put(AssetRec.SBQQ__RevisedAsset__c,TotVal);
                    }
                }
                
                 // LOOP ON ALL TOP LEVEL ASSETS AND CREATE A QL RECORD
                for(Asset AssetRec :TopLevelAssets){
                    SBQQ__QuoteLine__c QLRec = creatTopAsset(AssetRec,newQuote.Id, newQuote.SBQQ__PriceBook__c,OriginalAssetToAmendmentTotQuanMap);
                    TopLevelQuoteLineToInsert.add(QLRec);
                    ProductOptionSKU.add(AssetRec.Product2.Flip_to_Product__c);
                }
                
                // GET PRODUCTS FOR PO PROCESSING
                for(Asset AssetRec :OriginalAssets){
                    ProductOptionSKU.add(AssetRec.Product2.Flip_to_Product__c);
                }
                
                for(Asset AssetRec :LastLevelAssets){
                    ProductOptionSKU.add(AssetRec.Product2.Flip_to_Product__c);
                }
                
                ConfiguredSKUOptionalSKUToPO = getAllOptions(ProductOptionSKU);
                    
                System.debug('QL FROM TOP ASSETS ' + TopLevelQuoteLineToInsert);
                System.debug('QL FROM TOP ASSETS SIZE() ' + TopLevelQuoteLineToInsert.size());
                // INSERT TOP LEVEL ASSETS
                If(TopLevelQuoteLineToInsert.size() > 0){
                    INSERT TopLevelQuoteLineToInsert;
                    
                    // GET ALL ID NEWLY INSERTED QL AND POPULATE MAP
                    for(SBQQ__QuoteLine__c QLRec: TopLevelQuoteLineToInsert){
                        if(AssetIdToQLIdMap.get(QLRec.Flipped_from_Asset__c) == null){
                            AssetIdToQLIdMap.put(QLRec.Flipped_from_Asset__c,QLRec); 
                        }
                    }
                }
                
                // LOOP ON ALL ORIGINAL ASSETS AND CREATE A QL RECORD
                for(Asset AssetRec :OriginalAssets){
                    If(AssetIdToQLIdMap.get(AssetRec.SBQQ__RequiredByAsset__c) <> null){
                        SBQQ__QuoteLine__c QLRec = creatOriginalAsset(AssetRec,ConfiguredSKUOptionalSKUToPO, AssetIdToQLIdMap.get(AssetRec.SBQQ__RequiredByAsset__c), newQuote.Id, newQuote.SBQQ__PriceBook__c, OriginalAssetToAmendmentTotQuanMap);
                        OriginalAssetQuoteLineToInsert.add(QLRec); 
                    }else{
                         SBQQ__QuoteLine__c QLRec = creatOriginalAsset(AssetRec,ConfiguredSKUOptionalSKUToPO, null, newQuote.Id, newQuote.SBQQ__PriceBook__c, OriginalAssetToAmendmentTotQuanMap);
                        OriginalAssetQuoteLineToInsert.add(QLRec);
                    }
                }
                
                System.debug('QL FROM ORIGINAL ASSETS ' + OriginalAssetQuoteLineToInsert);
                System.debug('QL FROM ORIGINAL ASSETS SIZE() ' + OriginalAssetQuoteLineToInsert.size());
                // INSERT ORIGINAL ASSETS
                If(OriginalAssetQuoteLineToInsert.size() > 0){
                    INSERT OriginalAssetQuoteLineToInsert;
                    
                    // GET ALL ID NEWLY INSERTED QL AND POPULATE MAP
                    for(SBQQ__QuoteLine__c QLRec: OriginalAssetQuoteLineToInsert){
                        if(AssetIdToQLIdMap.get(QLRec.Flipped_from_Asset__c) == null){
                            AssetIdToQLIdMap.put(QLRec.Flipped_from_Asset__c,QLRec); 
                        }
                    }
                }
                
                
                System.debug('LAST LEVEL ASSETS - QUERY RESULTS ' + LastLevelAssets);
                System.debug('LAST LEVEL ASSETS - QUERY RESULTS SIZE() ' + LastLevelAssets.size());
                // LOOP ON ALL 3RD LEVEL ASSETS AND CREATE A QL RECORD
                for(Asset AssetRec :LastLevelAssets){
                    If(AssetIdToQLIdMap.get(AssetRec.SBQQ__RequiredByAsset__c) <> null){
                        SBQQ__QuoteLine__c QLRec = creatLastLevelAsset(AssetRec,ConfiguredSKUOptionalSKUToPO,AssetIdToQLIdMap.get(AssetRec.SBQQ__RequiredByAsset__c),newQuote.Id, newQuote.SBQQ__PriceBook__c, OriginalAssetToAmendmentTotQuanMap);
                        LastLevelAssetQuoteLineToInsert.add(QLRec); 
                    }else{
                        SBQQ__QuoteLine__c QLRec = creatLastLevelAsset(AssetRec,ConfiguredSKUOptionalSKUToPO,null,newQuote.Id, newQuote.SBQQ__PriceBook__c, OriginalAssetToAmendmentTotQuanMap);
                        LastLevelAssetQuoteLineToInsert.add(QLRec);
                    }
                }
                
                System.debug('QL FROM LAST LEVEL ASSETS ' + LastLevelAssetQuoteLineToInsert);
                System.debug('QL FROM LAST LEVEL ASSETS SIZE() ' + LastLevelAssetQuoteLineToInsert.size());
                // INSERT LAST LEVEL ASSETS
                If(LastLevelAssetQuoteLineToInsert.size() > 0){
                    INSERT LastLevelAssetQuoteLineToInsert;
                    
                    // GET ALL ID NEWLY INSERTED QL AND POPULATE MAP
                    for(SBQQ__QuoteLine__c QLRec: LastLevelAssetQuoteLineToInsert){
                        if(AssetIdToQLIdMap.get(QLRec.Flipped_from_Asset__c) == null){
                            AssetIdToQLIdMap.put(QLRec.Flipped_from_Asset__c,QLRec); 
                        }
                    }
                }
            }
            Map<Id,Set<Id>> ProductToASMLines = new Map<Id,Set<Id>>();
            // LOOP FOR INSERTING QL FROM CONTRACT LINES
            for(Id ContId: ContractToLinesMap.keySet()){
                for(ContractLineItem ContLines: ContractToLinesMap.get(ContId)){
                    String ContLineRequiredById = ContLines.SBQQSC__RequiredById__c;
                    If(ContLineRequiredById <> null && ContLineRequiredById.substring(0,3) <> '811' && ContLines.SBQQSC__Product__r.ProductCode <> 'EDISC' && ContLines.SBQQSC__Quantity__c > 0){ 
                        System.debug('@@@ PRODUCT =>' + ContLines.Id);
                        System.debug('@@@ REQUIRED BY IS NOT 811! ');
                        If(ContLines.SBQQSC__Quantity__c <> 0){
                            SBQQ__QuoteLine__c QLRec = new SBQQ__QuoteLine__c(SBQQ__Quote__c = newQuote.Id,
                                                                              SBQQ__RequiredBy__c = AssetIdToQLIdMap.get(ContLineRequiredById).Id,
                                                                              Flipped_from_Contract_Line__c = ContLines.Id,
                                                                              SBQQ__Quantity__c = ContLines.Quantity,
                                                                              SBQQ__Product__c = ContLines.Product2Id,
                                                                              SBQQ__Bundle__c = ContLines.SBQQSC__Bundle__c,
                                                                              SBQQ__Bundled__c = ContLines.SBQQSC__Bundled__c,
                                                                              SBQQ__BundledQuantity__c = ContLines.SBQQSC__BundledQuantity__c,
                                                                              SBQQ__ComponentDiscountedByPackage__c = ContLines.SBQQSC__ComponentDiscountedByPackage__c,
                                                                              SBQQ__ComponentSubscriptionScope__c = ContLines.SBQQSC__ComponentSubscriptionScope__c,
                                                                              SBQQ__DiscountSchedule__c = ContLines.SBQQSC__DiscountSchedule__c,
                                                                              SBQQ__DiscountScheduleType__c = ContLines.SBQQSC__DiscountScheduleType__c,
                                                                              SBQQ__OptionDiscount__c = ContLines.SBQQSC__OptionDiscount__c,
                                                                              SBQQ__OptionDiscountAmount__c = ContLines.SBQQSC__OptionDiscountAmount__c,
                                                                              SBQQ__OptionLevel__c = ContLines.SBQQSC__OptionLevel__c,
                                                                              SBQQ__OptionType__c = ContLines.SBQQSC__OptionType__c,
                                                                              SBQQ__ProductSubscriptionType__c = ContLines.SBQQSC__ProductSubscriptionType__c,
                                                                              SBQQ__SubscriptionPricing__c = ContLines.SBQQSC__SubscriptionPricing__c,
                                                                              SBQQ__SubscriptionType__c = ContLines.SBQQSC__SubscriptionType__c,
                                                                              SBQQ__PricingMethod__c = ContLines.SBQQSC__PricingMethod__c,
                                                                              SBQQ__UnitCost__c = ContLines.SBQQSC__UnitCost__c);
                            If(POTToProdOptionMap.get(ContLines.SBQQSC__Product__r.ProductCode+'-'+AssetIdToQLIdMap.get(ContLineRequiredById).SBQQ__Product__c) <> null){
                                QLRec.SBQQ__ProductOption__c = POTToProdOptionMap.get(ContLines.SBQQSC__Product__r.ProductCode+'-'+AssetIdToQLIdMap.get(ContLineRequiredById).SBQQ__Product__c).Id;
                                QLRec.SBQQ__DynamicOptionId__c = POTToProdOptionMap.get(ContLines.SBQQSC__Product__r.ProductCode+'-'+AssetIdToQLIdMap.get(ContLineRequiredById).SBQQ__Product__c).SBQQ__Feature__c;
                            }
                            ContractLineQuoteLineToInsert.add(QLRec);
                        }
                    }
                }
            }
            
            System.debug('QL FROM CONTRACT LINES ' + ContractLineQuoteLineToInsert);
            System.debug('QL FROM CONTRACT LINES SIZE ' + ContractLineQuoteLineToInsert.size());
            // INSERT QL FROM CONTRACT LINES
            If(ContractLineQuoteLineToInsert.size() > 0){
                INSERT ContractLineQuoteLineToInsert;
                
                Map<Id,Id> ContractLinesToQLMap= new Map<Id,Id>();
                
                // POPULATE MAP
                for(SBQQ__QuoteLine__c QL :ContractLineQuoteLineToInsert){
                    If(ContractLinesToQLMap.get(QL.Flipped_from_Contract_Line__c) == null){
                        ContractLinesToQLMap.put(QL.Flipped_from_Contract_Line__c,QL.Id);
                    }
                }
                
                // INSERT QL WITH CONTRACT LINE DEPENDENCIES
                List<SBQQ__QuoteLine__c> ContractLineQuoteLineChildToInsert = new List<SBQQ__QuoteLine__c>();
                for(Id ContId: ContractToLinesMap.keySet()){
                    for(ContractLineItem ContLines: ContractToLinesMap.get(ContId)){
                        if(ContLines.SBQQSC__RequiredById__c <> null){
                            String ContLineRequiredById = ContLines.SBQQSC__RequiredById__c;
                            If(ContLineRequiredById.substring(0,3) == '811' && !EDISCIds.contains(ContLineRequiredById) && ContractLinesToQLMap.get(ContLines.SBQQSC__RequiredById__c) != null && ContLines.SBQQSC__Quantity__c > 0){
                                SBQQ__QuoteLine__c QLRec = creatQLFromContracLine(ContLines, ContractLinesToQLMap.get(ContLines.SBQQSC__RequiredById__c), newQuote.Id, newQuote.SBQQ__PriceBook__c);
                                ContractLineQuoteLineChildToInsert.add(QLRec); 
                            }  
                        }
                    }
                }
                System.debug('QL FROM CONTRACT LINES DEPENDENT' + ContractLineQuoteLineToInsert);
                System.debug('QL FROM CONTRACT LINES DEPENDENT SIZE ' + ContractLineQuoteLineToInsert.size());
                If(ContractLineQuoteLineChildToInsert.size() > 0){
                    INSERT ContractLineQuoteLineChildToInsert;
                }
                
                List<SBQQ__QuoteLine__c> ASMLineList= new List<SBQQ__QuoteLine__c>();
                // INSERT ASM FIXED PRODUCT
                List<SBQQ__QuoteLine__c> NewInsertedQL = [SELECT Id,SBQQ__Product__c,SBQQ__ProductOption__c,SBQQ__ProductOption__r.SBQQ__OptionalSKU__c 
                                                          FROM SBQQ__QuoteLine__c 
                                                          WHERE SBQQ__Quote__c = :newQuote.Id]; 
                
                for(SBQQ__QuoteLine__c QL: NewInsertedQL){
                    If(SPFPProdOptIds.contains(QL.SBQQ__Product__c)){
                        SBQQ__QuoteLine__c QLRec = new SBQQ__QuoteLine__c(SBQQ__Quote__c = newQuote.Id,
                                                                          SBQQ__ProductOption__c = SkuToProdOptionMap.get(QL.SBQQ__Product__c).Id, 
                                                                          SBQQ__RequiredBy__c = QL.Id,
                                                                          SBQQ__DynamicOptionId__c = SkuToProdOptionMap.get(QL.SBQQ__Product__c).SBQQ__Feature__c,
                                                                          SBQQ__Quantity__c = 1,
                                                                          SBQQ__PricebookEntryId__c = newQuote.SBQQ__PriceBook__c,
                                                                          SBQQ__Product__c = SkuToProdOptionMap.get(QL.SBQQ__Product__c).SBQQ__OptionalSKU__c);
                        ASMLineList.add(QLRec); 
                    }
                }
                
                // INSERT ASM FIXED PRODUCT
                If(ASMLineList.size() > 0){
                    INSERT ASMLineList;
                }
                
            }
        }       
    }
    
    public static Map<String,SBQQ__ProductOption__c> getAllOptions(Set<Id> ProductOptionSKU){
        System.debug('--@@ ProductOptionSKU ' + ProductOptionSKU);
        Map<String,SBQQ__ProductOption__c> ConfiguredSKUOptionalSKUToPO = new Map<String,SBQQ__ProductOption__c>();
        List<SBQQ__ProductOption__c> ProdOptions = [SELECT Id,SBQQ__Feature__c,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c 
                                                    FROM SBQQ__ProductOption__c
                                                    WHERE SBQQ__ConfiguredSKU__c IN: ProductOptionSKU 
                                                    OR SBQQ__OptionalSKU__c IN: ProductOptionSKU];
        for(SBQQ__ProductOption__c ProdOpt :ProdOptions){
            If(ConfiguredSKUOptionalSKUToPO.get(ProdOpt.SBQQ__ConfiguredSKU__c + '-' + ProdOpt.SBQQ__OptionalSKU__c) == null){
                ConfiguredSKUOptionalSKUToPO.put(ProdOpt.SBQQ__ConfiguredSKU__c + '-' + ProdOpt.SBQQ__OptionalSKU__c,ProdOpt);
            }
        }
        
        return ConfiguredSKUOptionalSKUToPO;
    }
    
    public static SBQQ__QuoteLine__c creatLastLevelAsset(Asset AssetRec, Map<String,SBQQ__ProductOption__c> getAllOptions, SBQQ__QuoteLine__c RequiredBy, Id QuoteId, Id PricebookEntryId, Map<Id,Decimal> OriginalAssetToAmendmentTotQuanMap){
        Decimal AmendmentQty = OriginalAssetToAmendmentTotQuanMap.get(AssetRec.Id) <> null ? OriginalAssetToAmendmentTotQuanMap.get(AssetRec.Id) : 0;
        Decimal FinalQty = AmendmentQty + AssetRec.Quantity;
        SBQQ__QuoteLine__c QLRec;
        If(RequiredBy <> null){
            System.debug('--@@ getAllOptions ' + getAllOptions);
            System.debug('--@@ key => ' + RequiredBy.SBQQ__Product__c + '-' + AssetRec.Product2.Flip_to_Product__c);
            QLRec = new SBQQ__QuoteLine__c(SBQQ__Quote__c = QuoteId,
                                           SBQQ__PricebookEntryId__c = PricebookEntryId,
                                           SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                           Flipped_from_Asset__c = AssetRec.Id,
                                           SBQQ__RequiredBy__c = RequiredBy.Id,
                                           SBQQ__Quantity__c = FinalQty,
                                           Flipped_Qty__c = FinalQty,
                                           SBQQ__Product__c = AssetRec.Product2.Flip_to_Product__c,
                                           SBQQ__Bundle__c = AssetRec.SBQQ__Bundle__c,
                                           SBQQ__Bundled__c = AssetRec.SBQQ__Bundled__c,
                                           SBQQ__BundledQuantity__c = AssetRec.SBQQ__BundledQuantity__c,
                                           SBQQ__ComponentDiscountedByPackage__c = AssetRec.SBQQ__ComponentDiscountedByPackage__c,
                                           SBQQ__DiscountSchedule__c = AssetRec.SBQQ__DiscountSchedule__c,
                                           SBQQ__DiscountScheduleType__c = AssetRec.SBQQ__DiscountScheduleType__c,
                                           SBQQ__OptionDiscount__c = AssetRec.SBQQ__OptionDiscount__c,
                                           SBQQ__OptionDiscountAmount__c = AssetRec.SBQQ__OptionDiscountAmount__c,
                                           SBQQ__OptionLevel__c = AssetRec.SBQQ__OptionLevel__c,
                                           SBQQ__OptionType__c = AssetRec.SBQQ__OptionType__c,
                                           SBQQ__OriginalUnitCost__c = AssetRec.SBQQ__OriginalUnitCost__c,
                                           SBQQ__PricingMethod__c = AssetRec.SBQQ__PricingMethod__c,
                                           SBQQ__UnitCost__c = AssetRec.SBQQ__UnitCost__c);
            If(getAllOptions.get(RequiredBy.SBQQ__Product__c + '-' + AssetRec.Product2.Flip_to_Product__c) <> null){
                QLRec.SBQQ__ProductOption__c = getAllOptions.get(RequiredBy.SBQQ__Product__c + '-' + AssetRec.Product2.Flip_to_Product__c).Id;
                QLRec.SBQQ__DynamicOptionId__c = getAllOptions.get(RequiredBy.SBQQ__Product__c + '-' + AssetRec.Product2.Flip_to_Product__c).SBQQ__Feature__c;
            }
        }else{
            QLRec = new SBQQ__QuoteLine__c(SBQQ__Quote__c = QuoteId,
                                           SBQQ__PricebookEntryId__c = PricebookEntryId,
                                           SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                           Flipped_from_Asset__c = AssetRec.Id,
                                           SBQQ__Quantity__c = FinalQty,
                                           Flipped_Qty__c = FinalQty,
                                           SBQQ__Product__c = AssetRec.Product2.Flip_to_Product__c,
                                           SBQQ__Bundle__c = AssetRec.SBQQ__Bundle__c,
                                           SBQQ__Bundled__c = AssetRec.SBQQ__Bundled__c,
                                           SBQQ__BundledQuantity__c = AssetRec.SBQQ__BundledQuantity__c,
                                           SBQQ__ComponentDiscountedByPackage__c = AssetRec.SBQQ__ComponentDiscountedByPackage__c,
                                           SBQQ__DiscountSchedule__c = AssetRec.SBQQ__DiscountSchedule__c,
                                           SBQQ__DiscountScheduleType__c = AssetRec.SBQQ__DiscountScheduleType__c,
                                           SBQQ__DynamicOptionId__c = AssetRec.SBQQ__DynamicOptionId__c,
                                           SBQQ__OptionDiscount__c = AssetRec.SBQQ__OptionDiscount__c,
                                           SBQQ__OptionDiscountAmount__c = AssetRec.SBQQ__OptionDiscountAmount__c,
                                           SBQQ__OptionLevel__c = AssetRec.SBQQ__OptionLevel__c,
                                           SBQQ__OptionType__c = AssetRec.SBQQ__OptionType__c,
                                           SBQQ__OriginalUnitCost__c = AssetRec.SBQQ__OriginalUnitCost__c,
                                           SBQQ__PricingMethod__c = AssetRec.SBQQ__PricingMethod__c,
                                           SBQQ__UnitCost__c = AssetRec.SBQQ__UnitCost__c);  
        }
        return QLRec;
    }
    
    public static SBQQ__QuoteLine__c creatOriginalAsset(Asset AssetRec, Map<String,SBQQ__ProductOption__c> getAllOptions,SBQQ__QuoteLine__c RequiredBy, Id QuoteId, Id PricebookEntryId, Map<Id,Decimal> OriginalAssetToAmendmentTotQuanMap){
        Decimal AmendmentQty = OriginalAssetToAmendmentTotQuanMap.get(AssetRec.Id) <> null ? OriginalAssetToAmendmentTotQuanMap.get(AssetRec.Id) : 0;
        Decimal FinalQty = AmendmentQty + AssetRec.Quantity;
        SBQQ__QuoteLine__c QLRec;
        If(RequiredBy <> null){
            QLRec = new SBQQ__QuoteLine__c(SBQQ__Quote__c = QuoteId,
                                           SBQQ__PricebookEntryId__c = PricebookEntryId,
                                           SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                           Flipped_from_Asset__c = AssetRec.Id,
                                           SBQQ__RequiredBy__c = RequiredBy.Id,
                                           SBQQ__Quantity__c = FinalQty,
                                           Flipped_Qty__c = FinalQty,
                                           SBQQ__Product__c = AssetRec.Product2.Flip_to_Product__c,                                                                      
                                           SBQQ__Bundle__c = AssetRec.SBQQ__Bundle__c,
                                           SBQQ__Bundled__c = AssetRec.SBQQ__Bundled__c,
                                           SBQQ__BundledQuantity__c = AssetRec.SBQQ__BundledQuantity__c,
                                           SBQQ__ComponentDiscountedByPackage__c = AssetRec.SBQQ__ComponentDiscountedByPackage__c,
                                           SBQQ__DiscountSchedule__c = AssetRec.SBQQ__DiscountSchedule__c,
                                           SBQQ__DiscountScheduleType__c = AssetRec.SBQQ__DiscountScheduleType__c,
                                           SBQQ__OptionDiscount__c = AssetRec.SBQQ__OptionDiscount__c,
                                           SBQQ__OptionDiscountAmount__c = AssetRec.SBQQ__OptionDiscountAmount__c,
                                           SBQQ__OptionLevel__c = AssetRec.SBQQ__OptionLevel__c,
                                           SBQQ__OptionType__c = AssetRec.SBQQ__OptionType__c,
                                           SBQQ__OriginalUnitCost__c = AssetRec.SBQQ__OriginalUnitCost__c,
                                           SBQQ__PricingMethod__c = AssetRec.SBQQ__PricingMethod__c,
                                           SBQQ__UnitCost__c = AssetRec.SBQQ__UnitCost__c);
            If(getAllOptions.get(RequiredBy.SBQQ__Product__c + '-' + AssetRec.Product2.Flip_to_Product__c) <> null){
                QLRec.SBQQ__ProductOption__c = getAllOptions.get(RequiredBy.SBQQ__Product__c + '-' + AssetRec.Product2.Flip_to_Product__c).Id;
                QLRec.SBQQ__DynamicOptionId__c = getAllOptions.get(RequiredBy.SBQQ__Product__c + '-' + AssetRec.Product2.Flip_to_Product__c).SBQQ__Feature__c;
            }
        }else{
            QLRec = new SBQQ__QuoteLine__c(SBQQ__Quote__c = QuoteId,
                                           SBQQ__PricebookEntryId__c = PricebookEntryId,
                                           SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                           Flipped_from_Asset__c = AssetRec.Id,
                                           SBQQ__Quantity__c = FinalQty,
                                           Flipped_Qty__c = FinalQty,
                                           SBQQ__Product__c = AssetRec.Product2.Flip_to_Product__c,
                                           SBQQ__Bundle__c = AssetRec.SBQQ__Bundle__c,
                                           SBQQ__Bundled__c = AssetRec.SBQQ__Bundled__c,
                                           SBQQ__BundledQuantity__c = AssetRec.SBQQ__BundledQuantity__c,
                                           SBQQ__ComponentDiscountedByPackage__c = AssetRec.SBQQ__ComponentDiscountedByPackage__c,
                                           SBQQ__DiscountSchedule__c = AssetRec.SBQQ__DiscountSchedule__c,
                                           SBQQ__DiscountScheduleType__c = AssetRec.SBQQ__DiscountScheduleType__c,
                                           SBQQ__DynamicOptionId__c = AssetRec.SBQQ__DynamicOptionId__c,
                                           SBQQ__OptionDiscount__c = AssetRec.SBQQ__OptionDiscount__c,
                                           SBQQ__OptionDiscountAmount__c = AssetRec.SBQQ__OptionDiscountAmount__c,
                                           SBQQ__OptionLevel__c = AssetRec.SBQQ__OptionLevel__c,
                                           SBQQ__OptionType__c = AssetRec.SBQQ__OptionType__c,
                                           SBQQ__OriginalUnitCost__c = AssetRec.SBQQ__OriginalUnitCost__c,
                                           SBQQ__PricingMethod__c = AssetRec.SBQQ__PricingMethod__c,
                                           SBQQ__UnitCost__c = AssetRec.SBQQ__UnitCost__c);  
        }
        return QLRec;
    }
    
    public static SBQQ__QuoteLine__c creatTopAsset(Asset AssetRec, Id QuoteId, Id PricebookEntryId, Map<Id,Decimal> OriginalAssetToAmendmentTotQuanMap){
        Decimal AmendmentQty = OriginalAssetToAmendmentTotQuanMap.get(AssetRec.Id) <> null ? OriginalAssetToAmendmentTotQuanMap.get(AssetRec.Id) : 0;
        Decimal FinalQty = AmendmentQty + AssetRec.Quantity;
        SBQQ__QuoteLine__c QLRec = new SBQQ__QuoteLine__c(SBQQ__Product__c = AssetRec.Product2.Flip_to_Product__c,
                                                          SBQQ__Quantity__c = FinalQty,
                                                          Flipped_Qty__c = FinalQty,
                                                          SBQQ__Bundle__c = AssetRec.SBQQ__Bundle__c,
                                                          SBQQ__Bundled__c = AssetRec.SBQQ__Bundled__c,
                                                          SBQQ__BundledQuantity__c = AssetRec.SBQQ__BundledQuantity__c,
                                                          SBQQ__ComponentDiscountedByPackage__c = AssetRec.SBQQ__ComponentDiscountedByPackage__c,
                                                          SBQQ__DiscountSchedule__c = AssetRec.SBQQ__DiscountSchedule__c,
                                                          SBQQ__DiscountScheduleType__c = AssetRec.SBQQ__DiscountScheduleType__c,
                                                          SBQQ__DynamicOptionId__c = AssetRec.SBQQ__DynamicOptionId__c,
                                                          SBQQ__OptionDiscount__c = AssetRec.SBQQ__OptionDiscount__c,
                                                          SBQQ__OptionDiscountAmount__c = AssetRec.SBQQ__OptionDiscountAmount__c,
                                                          SBQQ__OptionLevel__c = AssetRec.SBQQ__OptionLevel__c,
                                                          SBQQ__OptionType__c = AssetRec.SBQQ__OptionType__c,
                                                          SBQQ__OriginalUnitCost__c = AssetRec.SBQQ__OriginalUnitCost__c,
                                                          SBQQ__PricingMethod__c = AssetRec.SBQQ__PricingMethod__c,
                                                          SBQQ__UnitCost__c = AssetRec.SBQQ__UnitCost__c,
                                                          SBQQ__Quote__c = QuoteId,
                                                          SBQQ__PricebookEntryId__c = PricebookEntryId,
                                                          SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                          Flipped_from_Asset__c = AssetRec.Id);
        return QLRec;
    }
    
    public static SBQQ__QuoteLine__c creatQLFromContracLine(ContractLineItem ContLines, Id RequiredBy, Id QuoteId, Id PricebookEntryId){
        SBQQ__QuoteLine__c QLRec = new SBQQ__QuoteLine__c(SBQQ__ProductOption__c = ContLines.SBQQSC__ProductOption__c,
                                                          SBQQ__Quote__c = QuoteId,
                                                          SBQQ__RequiredBy__c = RequiredBy,
                                                          SBQQ__PricebookEntryId__c = PricebookEntryId,
                                                          Flipped_from_Contract_Line__c = ContLines.Id,
                                                          SBQQ__Quantity__c = ContLines.Quantity,
                                                          SBQQ__Product__c = ContLines.Product2Id,
                                                          SBQQ__Bundle__c = ContLines.SBQQSC__Bundle__c,
                                                          SBQQ__Bundled__c = ContLines.SBQQSC__Bundled__c,
                                                          SBQQ__BundledQuantity__c = ContLines.SBQQSC__BundledQuantity__c,
                                                          SBQQ__ComponentDiscountedByPackage__c = ContLines.SBQQSC__ComponentDiscountedByPackage__c,
                                                          SBQQ__ComponentSubscriptionScope__c = ContLines.SBQQSC__ComponentSubscriptionScope__c,
                                                          SBQQ__DiscountSchedule__c = ContLines.SBQQSC__DiscountSchedule__c,
                                                          SBQQ__DiscountScheduleType__c = ContLines.SBQQSC__DiscountScheduleType__c,
                                                          SBQQ__DynamicOptionId__c = ContLines.SBQQSC__DynamicOptionId__c,
                                                          SBQQ__OptionDiscount__c = ContLines.SBQQSC__OptionDiscount__c,
                                                          SBQQ__OptionDiscountAmount__c = ContLines.SBQQSC__OptionDiscountAmount__c,
                                                          SBQQ__OptionLevel__c = ContLines.SBQQSC__OptionLevel__c,
                                                          SBQQ__OptionType__c = ContLines.SBQQSC__OptionType__c,
                                                          SBQQ__ProductSubscriptionType__c = ContLines.SBQQSC__ProductSubscriptionType__c,
                                                          SBQQ__SubscriptionPricing__c = ContLines.SBQQSC__SubscriptionPricing__c,
                                                          SBQQ__SubscriptionType__c = ContLines.SBQQSC__SubscriptionType__c,
                                                          SBQQ__PricingMethod__c = ContLines.SBQQSC__PricingMethod__c,
                                                          SBQQ__UnitCost__c = ContLines.SBQQSC__UnitCost__c);
        return QLRec;
    }
    // WRAPPER CLASS   
    public class ServiceContractListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public ServiceContract objServiceContract{get;set;}
        public ServiceContractListWrapper(boolean isChecked, ServiceContract objServiceContract){
            this.isChecked = isChecked;
            this.objServiceContract = objServiceContract;
        } 
    }
  
}