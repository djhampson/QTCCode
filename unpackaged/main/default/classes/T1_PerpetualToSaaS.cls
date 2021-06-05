/*******************************************************************************************************
* @Class Name   : T1_PerpetualToSaaS
* @description  : Schedulable class to link records for perpetual transactions.
* @author       : Gerald Arzadon
* @date         : 5/5/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon             5/5/2021      1000        Initial version
******************************************************************************************************/
public class T1_PerpetualToSaaS implements Schedulable {
    public Set<Id> ServiceContractIds;
    public T1_PerpetualToSaaS(Set<Id> ServiceContractIds) {
        this.ServiceContractIds = ServiceContractIds;
    }
    
    public void execute(SchedulableContext sc) {
        try {
            Map<Id,Id> PCloudToAssetId = new Map<Id,Id>();
            Map<Id,Id> AssetToAssetId = new Map<Id,Id>();
            Map<Id,Id> AssetToPerpetualIdMap = new Map<Id,Id>();
            Set<String> AssetIds = new Set<String>();
            // GET ALL SERVICE CONTRACT AND CHILD CONTRACT LINE ITEMS
            List<ContractLineItem> ContractLineItemList = [SELECT Id,SBQQSC__RequiredById__c,ServiceContractId FROM ContractLineItem WHERE ServiceContractId IN: ServiceContractIds AND SBQQSC__RequiredById__c <> null];  
            for(ContractLineItem contLine: ContractLineItemList){
                If(contLine.SBQQSC__RequiredById__c.substring(0,3) == '02i'){
                    AssetIds.add(contLine.SBQQSC__RequiredById__c);
                    if(PCloudToAssetId.get(contLine.ServiceContractId) == null){
                        PCloudToAssetId.put(contLine.ServiceContractId,contLine.SBQQSC__RequiredById__c); 
                    }
                }
            }
            
            // CHECK SIZE BEFORE PROCESSING
            If(AssetIds.size() > 0){
                List<Asset> AssetList = new List<Asset>();
                Set<Id> OriginalAssetList = new Set<Id>();
                Set<Id> AssetChecker = new Set<Id>();
                // GET ALL ASSETS LINKED TO THE SHADOW PRODUCT AND MARK AS MIGRATED TO SAAS
                for(Asset AssetRec: [SELECT Id,Migrated_from_Asset__c FROM Asset WHERE Id IN:AssetIds AND Migrated_from_Asset__c <> null]){
                    if(!AssetChecker.contains(AssetRec.Migrated_from_Asset__c)){
                        AssetList.add(new Asset(Id = AssetRec.Migrated_from_Asset__c, Migrated_to_SaaS_Platform__c = TRUE));
                        OriginalAssetList.add(AssetRec.Migrated_from_Asset__c);
                        AssetChecker.add(AssetRec.Migrated_from_Asset__c);  
                    }
                    
                    If(AssetToAssetId.get(AssetRec.id) == null){
                        AssetToAssetId.put(AssetRec.id,AssetRec.Migrated_from_Asset__c);
                    }
                }  
                
                // GET ALL CHILD ASSETS LINKED TO THE SHADOW PRODUCT AND MARK AS MIGRATED TO SAAS                
                for(Asset Level2Rec: [SELECT Id,(SELECT Id FROM ChildAssets) FROM Asset WHERE SBQQ__RequiredByAsset__c IN:OriginalAssetList]){
                    If(Level2Rec.ChildAssets.size() > 0){
                        for(Asset Level3Rec:Level2Rec.ChildAssets){
                            if(!AssetChecker.contains(Level3Rec.Id)){
                                AssetList.add(new Asset(Id = Level3Rec.Id, Migrated_to_SaaS_Platform__c = TRUE));  
                                AssetChecker.add(Level3Rec.Id);  
                            }
                        }  
                    }
                    if(!AssetChecker.contains(Level2Rec.Id)){
                        AssetList.add(new Asset(Id = Level2Rec.Id, Migrated_to_SaaS_Platform__c = TRUE)); 
                        AssetChecker.add(Level2Rec.Id);  
                    }
                }  
                
                System.debug('@@ ASSET LIST' + AssetList);
                // CHECK THE SIZE AND UPDATE LIST
                If(AssetList.size() > 0){
                    UPDATE AssetList;
                }
                
                // CHECK SIZE BEFORE PROCESSING
                If(OriginalAssetList.size() > 0){
                    List<ContractLineItem> OriginalContractLineItemList = new List<ContractLineItem>();
                    
                    Set<Id> OriginalServiceContractIds = new Set<Id>();
                    // GET ALL ORIGINAL CONTRACT LINES AND MARKED AS MIGRATED TO SAAS
                    for(ContractLineItem contLineRec: [SELECT Id,ServiceContractId,SBQQSC__RequiredById__c FROM ContractLineItem WHERE SBQQSC__RequiredById__c IN :OriginalAssetList]){ 
                        OriginalContractLineItemList.add(new ContractLineItem(Id = contLineRec.Id, Migrated_to_SaaS_Platform__c = TRUE));
                        OriginalServiceContractIds.add(contLineRec.ServiceContractId);
                        if(AssetToPerpetualIdMap.get(contLineRec.SBQQSC__RequiredById__c) == null){
                            AssetToPerpetualIdMap.put(contLineRec.SBQQSC__RequiredById__c,contLineRec.ServiceContractId);
                        }
                    }
                    System.debug('@@ CONTRACT LINE LIST' + OriginalContractLineItemList);
                    // CHECK THE SIZE AND UPDATE LIST
                    if(OriginalContractLineItemList.size() > 0){
                        UPDATE OriginalContractLineItemList;
                    }
                    
                    // CHECK SIZE BEFORE PROCESSING                   
                    If(OriginalServiceContractIds.size() > 0){
                        List<ServiceContract> ServiceContractsToUpdate = new List<ServiceContract>();
                        
                        // GET ALL ORIGINAL SERVICE CONTRACTS FOR PROCESSING
                        for(Id ContractId: OriginalServiceContractIds){
                            ServiceContractsToUpdate.add(new ServiceContract(Id = ContractId, Migrated_to_SaaS_Platform__c = TRUE));
                        }
                        
                        //  PCloudToAssetId.put(contLine.ServiceContractId,contLine.SBQQSC__RequiredById__c); 
                        for(Id PerpetualOnCloudId: PCloudToAssetId.keySet()){
                            ServiceContractsToUpdate.add(new ServiceContract(Id = PerpetualOnCloudId, Linked_Perpetual_Agreement__c = AssetToPerpetualIdMap.get(AssetToAssetId.get(PCloudToAssetId.get(PerpetualOnCloudId)))));
                        }
                        System.debug('@@ SERVICE CONTRACT LIST' + ServiceContractsToUpdate);
                        // CHECK THE SIZE AND UPDATE LIST
                        if(ServiceContractsToUpdate.size() > 0){
                            UPDATE ServiceContractsToUpdate; 
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
            Insert DM_ApplicationLog.createApplicationLog(e); 
        } finally {  
            System.abortJob(sc.getTriggerId());
        }
    }
}