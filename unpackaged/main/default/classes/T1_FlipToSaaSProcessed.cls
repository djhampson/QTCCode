/*******************************************************************************************************
* Class Name      	: T1_FlipToSaaSProcessed
* Description		: UPDATE FLIP TO SAAS CONTRACT TO PROCESSED
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 2-17-2020
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	2-17-2020		Initial version 
******************************************************************************************************/
public class T1_FlipToSaaSProcessed implements Schedulable {
    Set<Id> ContractIdsToInProgress;
    
    public T1_FlipToSaaSProcessed(Set<Id> ContractIdsToInProgress) {
        this.ContractIdsToInProgress = ContractIdsToInProgress; 
    }
    
    public void execute(SchedulableContext sc) {
        try {
            // UPDATE FLIP CONTRACTS STATUS TO IN PROGRESS
            List<ServiceContract> FlipContractsToProcessed = new List<ServiceContract>();
            for(Id ContractId:ContractIdsToInProgress){
                ServiceContract ServCont = new ServiceContract(Id = ContractId,
                                                               Flip_to_SaaS_Status__c = 'Processed');  
                FlipContractsToProcessed.add(ServCont);
            }
            
            // CHECK COLLECTION SIZE AND UPDATE
            If(FlipContractsToProcessed.size() > 0){
                UPDATE FlipContractsToProcessed;
            }
            
        } catch (Exception ex) {
            System.debug('Error: ' + ex);
            INSERT DM_ApplicationLog.createApplicationLog(ex); 
        } finally {
            System.abortJob(sc.getTriggerId());
        }
    }
}