/*******************************************************************************************************
* @Class Name   : T1_AssetCompoundInterest
* @description  : Schedulable class to update asset compound interest.
* @author       : Gerald Arzadon
* @date         : 5/5/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon             5/5/2021      1000        Initial version
******************************************************************************************************/
public class T1_AssetCompoundInterest  implements Schedulable {
    public Set<Id> ServiceContractIds;
    public T1_AssetCompoundInterest(Set<Id> ServiceContractIds) {
        this.ServiceContractIds = ServiceContractIds;
    }
    public void execute(SchedulableContext sc) {
        try {
            Set<Id> AssetIds = new Set<Id>();
            List<Asset> AssetsToUpdate = new List<Asset>();
            
            // GET CONTRACT LINES AND UPLIFT RATE
            List<ContractLineItem> ContractLines = [SELECT Id,SBQQSC__QuoteLine__r.Uplift_Rate__c,SBQQSC__RequiredById__c FROM ContractLineItem WHERE ServiceContractId IN :ServiceContractIds];
            Map<String,Decimal> AssetIdToUpliftRate = new Map<String,Decimal>();
            
            for(ContractLineItem ContLines: ContractLines){
                If(AssetIdToUpliftRate.get(ContLines.SBQQSC__RequiredById__c) == null){
                    AssetIdToUpliftRate.put(ContLines.SBQQSC__RequiredById__c,ContLines.SBQQSC__QuoteLine__r.Uplift_Rate__c <> null ? ContLines.SBQQSC__QuoteLine__r.Uplift_Rate__c : 0);
                }
                
                AssetIds.add(ContLines.SBQQSC__RequiredById__c);
            }
            If(!AssetIds.IsEmpty()){
                // GET ASSETS AND UPDATE COMPOUND INTEREST RATE
                List<Asset> Assets = [SELECT Id,SBQQ__RequiredByAsset__c,Compound_Increase_Rate__c FROM Asset WHERE Id IN :AssetIds OR SBQQ__RequiredByAsset__c IN :AssetIds];
                
                for(Asset AssetRec :Assets){
                    Decimal IncreaseRate;
                    If(AssetIds.contains(AssetRec.Id)){
                        IncreaseRate = AssetIdToUpliftRate.get(AssetRec.Id);
                    }else if(AssetRec.SBQQ__RequiredByAsset__c <> null && AssetIds.contains(AssetRec.SBQQ__RequiredByAsset__c)){
                        IncreaseRate = AssetIdToUpliftRate.get(AssetRec.SBQQ__RequiredByAsset__c);
                    }
                    If(IncreaseRate <> null){
                        Decimal CompoundIncreaseRateVal = AssetRec.Compound_Increase_Rate__c <> null ? AssetRec.Compound_Increase_Rate__c : 0;
                        Decimal NewCompoundIncreaseRate = (1 + CompoundIncreaseRateVal) * (1 + IncreaseRate) - 1;
                        AssetsToUpdate.add(new Asset(Id = AssetRec.Id, Compound_Increase_Rate__c = NewCompoundIncreaseRate)); 
                    }
                }
            }
            
            // UPDATE ASSET RECORDS
            If(!AssetsToUpdate.IsEmpty()){
                UPDATE AssetsToUpdate;
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