/*******************************************************************************************************
* Class Name      	: AssetTriggerHandler
* Description		: SERVICE CLASS FOR ASSET TRIGGER
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 2-25-2020
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	2-25-2020			Initial version 
******************************************************************************************************/
public class AssetTriggerHandler {
    public static void doBeforeInsert(List<Asset> newAssets){
        Set<Id> AccountIds = new Set<Id>();
        Set<Id> OriginalAssetIds = new Set<Id>();
        List<Asset> toUpdateExistingAssets = new List<Asset>();
        Map<String,Decimal> AssetQuantityCheckerMap = new Map<String,Decimal>();
        
        // GET ALL ACCOUNT IDS OF NEGATIVE LINES
        for(Asset AssetRec :newAssets){
            if(AssetRec.Quantity < 0){
                AccountIds.add(AssetRec.AccountId);
            }
            If(AssetQuantityCheckerMap.get(AssetRec.AccountId+'-'+AssetRec.Product2Id) <> null){
                Decimal legacyVal = AssetQuantityCheckerMap.get(AssetRec.AccountId+'-'+AssetRec.Product2Id);
                Decimal newTotalVal = legacyVal + AssetRec.Quantity;
                AssetQuantityCheckerMap.put(AssetRec.AccountId+'-'+AssetRec.Product2Id,newTotalVal);
            }else{
                AssetQuantityCheckerMap.put(AssetRec.AccountId+'-'+AssetRec.Product2Id,AssetRec.Quantity);
            }
        }
        System.debug('CLASS LOG == newAssets size ' + newAssets.size());
        System.debug('CLASS LOG == newAssets  ' + newAssets);
        System.debug('CLASS LOG == AssetQuantityCheckerMap  ' + AssetQuantityCheckerMap);
        If(AccountIds.size() > 0){
            // GET ALL EXISTING ASSETS
            List<Asset> existingAssets = [SELECT Id,Quantity,
                                          AccountId,Product2Id 
                                          FROM Asset 
                                          WHERE AccountId IN: AccountIds
                                          AND Status != 'Cancelled' ];
            
            System.debug('CLASS LOG == existingAssets size ' + existingAssets.size());
            System.debug('CLASS LOG == existingAssets  ' + existingAssets);
            // GET QUANTITY FOR EXISTING ASSET AND POPULATE MAP
            for(Asset AssetRec :existingAssets){  
                System.debug('CLASS LOG == QTY  ' + AssetRec);
                If(AssetQuantityCheckerMap.get(AssetRec.AccountId+'-'+AssetRec.Product2Id) <> null){
                    Decimal legacyVal = AssetQuantityCheckerMap.get(AssetRec.AccountId+'-'+AssetRec.Product2Id);
                    Decimal newVal = AssetRec.Quantity;
                    Decimal newTotalVal = legacyVal + newVal;
                    AssetQuantityCheckerMap.put(AssetRec.AccountId+'-'+AssetRec.Product2Id,newTotalVal);
                }else{
                    AssetQuantityCheckerMap.put(AssetRec.AccountId+'-'+AssetRec.Product2Id,AssetRec.Quantity);
                }
            }
            
            // SET NEW ASSETS TO CANCELLED IF QUANTITY IN MAP IS NOT NULL AND EQUALS TO 0 
            for(Asset newAssetRec :newAssets){
                if(AssetQuantityCheckerMap.get(newAssetRec.AccountId+'-'+newAssetRec.Product2Id) <> null && AssetQuantityCheckerMap.get(newAssetRec.AccountId+'-'+newAssetRec.Product2Id) == 0){
                    newAssetRec.Status = 'Cancelled';
                }
            }
            
            // SET EXISTING ASSETS TO CANCELLED IF QUANTITY IN MAP IS NOT NULL AND EQUALS TO 0 
            for(Asset exstAssetRec :existingAssets){  
                if(AssetQuantityCheckerMap.get(exstAssetRec.AccountId+'-'+exstAssetRec.Product2Id) <> null && AssetQuantityCheckerMap.get(exstAssetRec.AccountId+'-'+exstAssetRec.Product2Id) == 0){
                    Asset assetToUpdate= new Asset(Id = exstAssetRec.Id,
                                                   Status = 'Cancelled');
                    toUpdateExistingAssets.add(assetToUpdate);
                }
            }
            
            // CHECK SIZE AND UPDATE
            if(toUpdateExistingAssets.size() > 0){
                UPDATE toUpdateExistingAssets;
            }
        }
    }
}