/**
 * @description       : Test class
 * @author            : Grant Hamlyn
 * @group             : 
 * @last modified on  : 21-05-2021
 * @last modified by  : Grant Hamlyn
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-03-2021   Grant Hamlyn   Initial Version
 * 1.1   21-05-2021   Grant Hamlyn   Remove Delete function due to Order Line ref integrity which was introduced recently
**/
@isTest(SeeAllData=True)
public class ContractLineItemTriggerHandlerTest 
{
    static testMethod void testMethod1() 
    {
        Date todaysDate = system.today();

        // set of Active Service Contracts for the Account set
        /* Set<Id> serviceContractSet = new Set<Id>();
        List<ServiceContract> servicecontracts = [select id from ServiceContract where startdate <= :todaysDate and enddate >= :todaysDate limit 10];  
        for (ServiceContract servcontract : servicecontracts) {  
            serviceContractSet.add(servContract.id);
            system.debug('Service Contract Id ' + servContract.Id);
        } */

        list <ContractLineItem> newCLI = [select id, SBQQSC__Account__c, description, ServiceContractId, PricebookEntryId, Quantity, UnitPrice from ContractLineItem 
                                                where Category__c = 'Support Fee' 
                                                and SBQQSC__SubscriptionStartDate__c <= :todaysDate
                                                and End_Terminated_Date__c >= :todaysDate limit 100];
        list <ContractLineItem> updatedCLI = new list<ContractLineItem>();
        list <ContractLineItem> insertedCLI = new list<ContractLineItem>();
        list <ContractLineItem> deletedCLI = new list<ContractLineItem>();
        integer cnt = 0;

        for(ContractLineItem newCLIs : newCLI){
            ++cnt;
            newCLIs.Description = 'I have changed';
            updatedCLI.add(newCLIs);
            system.debug('Account ' + newclis.SBQQSC__Account__c);
            if (cnt == 1){
                ContractLineItem cloneCLI = newCLIs.clone(false, false, false, false);
                insertedCLI.add(cloneCLI);
            }
            if (cnt == 2){
                deletedCLI.add(newCLIs);
            }
        }

        if (updatedCLI.size() > 0){
            update updatedCLI;
        }

        if (insertedCLI.size() > 0){
            insert insertedCLI;
        }

        // temporary exclusion to to ref integrity check on Order Line
        //if (deletedcli.size() > 0){
            //delete deletedcli;
        //}
    } 
}