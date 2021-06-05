public with sharing class PCSMVisitModules 
{
    private PCSM_Visit_Cyc__c productRecord;
    public List<Asset> modules {get;set;}
    
    public PCSMVisitModules(ApexPages.StandardController controller)
    {
        //controller.addFields(new String[]{'id', 'Account__c', 'Product__c'});
        PCSM_Visit_Cyc__c pcsmVisit = (PCSM_Visit_Cyc__c) controller.getRecord();
        this.productRecord = [Select id, account__c, product__c from PCSM_Visit_Cyc__c
                            where id =: pcsmVisit.id];
            
        this.modules = [Select a.Product__c, a.Product2.Family, a.Product2.ProductCode, a.Product2.Name, a.Product2Id, a.Name, a.Id, 
        a.Description, a.AccountId, a.Status From Asset a
                where a.accountId =: productRecord.Account__c
                and a.product__c =: productRecord.Product__c];        
    }

}