/*******************************************************************************************************
* Class Name      	: T1_InvoiceSyncBatch
* Description		: Batch class for Invoice Date Sync	
* Author          	: Simplus - Gerald Arzadon	
* Created On      	: 1-12-2020
* Modification Log	: 
* -----------------------------------------------------------------------------------------------------
* Developer				Date					Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon    	1-12-2020				Initial version 
******************************************************************************************************/
Global class T1_InvoiceSyncBatch implements Database.Batchable<sObject>{
    Private Id invoiceId; 
    FINAL STATIC STRING STATUS = 'Draft';
    Global T1_InvoiceSyncBatch(){}
    Global T1_InvoiceSyncBatch(Id invoiceId){
        This.invoiceId = invoiceId;
    }
    Global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,blng__InvoiceDate__c,blng__DueDate__c,Ready_to_sync__c FROM blng__Invoice__c WHERE Processed__c = FALSE AND blng__InvoiceStatus__c = \''+STATUS+'\'';
        If(invoiceId <> null){
            query += ' AND Id = \''+invoiceId+ '\'';
        }
        return Database.getQueryLocator(query);
    }
    
    Global void execute(Database.BatchableContext bc, List<blng__Invoice__c> scope){
        List<blng__Invoice__c> InvoicesToUpdate = new List<blng__Invoice__c>();
        Map<Id,Integer> InvoiceToPaymentTerm = new Map<Id,Integer>();
        Map<Id,String> InvoiceToDealType = new Map<Id,String>();
        Map<Id,String> InvoiceToTransType = new Map<Id,String>();
        Set<Id> InvoiceIds = new Set<Id>();
        
        for(blng__Invoice__c invRec : scope){
            InvoiceIds.add(invRec.Id);
        }
        If(InvoiceIds.size() > 0){
            List<blng__InvoiceLine__c> InvLines = [SELECT Id,blng__Invoice__c,
                                                   blng__OrderProduct__r.Order.Deal_Type__c,
                                                   blng__OrderProduct__r.Order.Transaction_Type__c, 
                                                   blng__OrderProduct__r.Order.SBQQ__PaymentTerm__c
                                                   FROM blng__InvoiceLine__c 
                                                   WHERE blng__Invoice__c IN: InvoiceIds]; 
            
            // LOOP ON ALL INVOICE LINES
            for(blng__InvoiceLine__c InvLinesRec :InvLines){
                // CHECK IF ID IS ALREADY EXISTING AS KEY IN THE MAP
                if(InvoiceToPaymentTerm.get(InvLinesRec.blng__Invoice__c) == null){
                    // POPULATE MAP
                    If(InvLinesRec.blng__OrderProduct__r.Order.SBQQ__PaymentTerm__c <> null){
                        InvoiceToPaymentTerm.put(InvLinesRec.blng__Invoice__c,Integer.valueOf(InvLinesRec.blng__OrderProduct__r.Order.SBQQ__PaymentTerm__c));
                    }               
                }  
                
                if(InvoiceToDealType.get(InvLinesRec.blng__Invoice__c) == null){
                    // POPULATE MAP
                    If(InvLinesRec.blng__OrderProduct__r.Order.Deal_Type__c <> null){
                        InvoiceToDealType.put(InvLinesRec.blng__Invoice__c,InvLinesRec.blng__OrderProduct__r.Order.Deal_Type__c);
                    }               
                }  
                
                if(InvoiceToTransType.get(InvLinesRec.blng__Invoice__c) == null){
                    // POPULATE MAP
                    If(InvLinesRec.blng__OrderProduct__r.Order.Transaction_Type__c <> null){
                        InvoiceToTransType.put(InvLinesRec.blng__Invoice__c,String.valueOf(InvLinesRec.blng__OrderProduct__r.Order.Transaction_Type__c));
                    }               
                }  
            }
            
            // LOOP ON SCOPE RECORD
            for(blng__Invoice__c invRec : scope){
                if(invRec.blng__DueDate__c == null && invRec.blng__InvoiceDate__c != null){
                    
                    // CALCULATE THE FINAL DUE DATE ON INVOICE 
                    Integer DaysToAdd = 0;
                    If(InvoiceToPaymentTerm.get(invRec.Id) <> null){
                        DaysToAdd = InvoiceToPaymentTerm.get(invRec.Id);                      
                    }
                    Date invoiceStartDate =  invRec.blng__InvoiceDate__c;
                    Date FinalDate = invoiceStartDate.addDays(DaysToAdd);
                    
                    blng__Invoice__c invRecToUpdate = new blng__Invoice__c(Id = invRec.Id,
                                                                           Processed__c = TRUE,
                                                                           Ready_to_sync__c = TRUE,
                                                                           Deal_Type__c = InvoiceToDealType.get(invRec.Id),
                                                                           Transaction_Type__c = InvoiceToTransType.get(invRec.Id),
                                                                           blng__DueDate__c = FinalDate);
                    
                    // ADD THE RECORD TO BE UPDATED ON THE LIST
                    InvoicesToUpdate.add(invRecToUpdate);
                }
            }
            
        }
        
        // CHECK LIST SIZE AND UPDATE RECORDS
        If(InvoicesToUpdate.size() > 0){
            Update InvoicesToUpdate;
        } 
    }
    
    Global void finish(Database.BatchableContext bc){}
}