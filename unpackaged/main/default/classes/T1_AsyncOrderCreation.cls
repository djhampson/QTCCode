/*******************************************************************************************************
* Class Name      	: T1_AsyncOrderCreation
* Description		: AUTOMATICALLY CREATE ORDER ASYNCHROUNOUSLY
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 5-18-2021
* -----------------------------------------------------------------------------------------------------
* Developer				Date				Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	5-18-2021		Initial version 
******************************************************************************************************/
public class T1_AsyncOrderCreation implements Queueable{
    SBQQ__Quote__c QuoteToUpdate;
    
    public T1_AsyncOrderCreation(SBQQ__Quote__c QuoteToUpdate) {
        this.QuoteToUpdate = QuoteToUpdate;
    }
    
    public void execute(QueueableContext context) {
        QuoteToUpdate.SBQQ__Ordered__c = TRUE; 
        UPDATE QuoteToUpdate; 
    }
}