/*******************************************************************************************************
* Class Name      	: T1_ServiceContract
* Description		: Schedulable class for calculating latest weighted average on Service Contract.
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 2-9-2020
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	2-9-2020			Initial version 
******************************************************************************************************/
public class T1_ServiceContract implements Schedulable {
    // public Id ServContId;
    public List<ContractLineItem> ContractLineItemList;
    public T1_ServiceContract(List<ContractLineItem> ContractLineItemList) {
        this.ContractLineItemList = ContractLineItemList;
    }
    
    public void execute(SchedulableContext sc) {
        try {
            
            List<ContractLineItem> toUpdateLines = new List<ContractLineItem>();
            Map<Id,ContractLineItem> OriginalLineToNewLinesMap = new Map<Id,ContractLineItem>();
            
            /*// GET ALL CONTRACT LINES ON THE SAME CONTRACT
            List<ContractLineItem> ContractLineItemList = [SELECT Id,CreatedDate,
                                                           Weighted_Average_Price__c,SBQQSC__RevisedSubscription__c
                                                           FROM ContractLineItem
                                                           WHERE ServiceContractId =: ServContId AND SBQQSC__RevisedSubscription__c != null];*/
            
            // LOOP ON ALL THE LINES
            for(ContractLineItem ContlineItem : ContractLineItemList){
                // POPULATE MAP
                If(OriginalLineToNewLinesMap.get(ContlineItem.SBQQSC__RevisedSubscription__c) == null){
                    OriginalLineToNewLinesMap.put(ContlineItem.SBQQSC__RevisedSubscription__c,ContlineItem);
                }else{
                    ContractLineItem LegacyContractLine = OriginalLineToNewLinesMap.get(ContlineItem.SBQQSC__RevisedSubscription__c);
                    If(ContlineItem.CreatedDate > LegacyContractLine.CreatedDate){
                        OriginalLineToNewLinesMap.put(ContlineItem.SBQQSC__RevisedSubscription__c,ContlineItem); 
                    }
                }
            }
            
            // LOOP ON MAP RECORDS AND CREATE THE LINES FOR UPDATE
            for(Id OrigContLineId:OriginalLineToNewLinesMap.keySet()){
                ContractLineItem ContlineRec = new ContractLineItem(Id = OrigContLineId,
                                                                   Latest_Weighted_Average_Price__c = OriginalLineToNewLinesMap.get(OrigContLineId).Weighted_Average_Price__c);
                toUpdateLines.add(ContlineRec);
            }
            
            // LOOP ON ALL OTHER LINES AND UPDATE 
            for(ContractLineItem contLines :ContractLineItemList){
                ContractLineItem ContlineRec = new ContractLineItem(Id = contLines.Id,
                                                                    Latest_Weighted_Average_Price__c = OriginalLineToNewLinesMap.get(contLines.SBQQSC__RevisedSubscription__c).Weighted_Average_Price__c);
                toUpdateLines.add(ContlineRec);
            }
            
            // UPDATE LINES
            if (toUpdateLines.size() > 0) {
                System.debug('SAVING CONTRACT LINES: ' + JSON.serialize(toUpdateLines));
                UPDATE toUpdateLines;
            }
            
        } catch (Exception ex) {
            System.debug('Error: ' + ex);
        } finally {  
            System.abortJob(sc.getTriggerId());
        }
    }
}