/**
 * @description       : Order Trigger
 * @author            : sakshi.chauhan@simplus.com
 * @group             : 
 * @last modified on  : 02-19-2021
 * @last modified by  : sakshi.chauhan@simplus.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   02-19-2021   sakshi.chauhan@simplus.com   Initial Version
**/
trigger OrderTrigger on Order (After Insert,after update) {
    If(Trigger.IsAfter){
        
       If(Trigger.IsInsert){
            OrderTriggerHandler.doAfterInsert(Trigger.new);
        } 

        // After update check
        if( Trigger.isUpdate){
            system.debug('Inside trigger update ');
            // collect Order Ids that got Activated
            Set<Id> orderIds = new Set<Id>();
            for( Order orderVar: Trigger.newMap.values() ) {
                system.debug('orderVar ' + orderVar );

                system.debug('orderVar status ' + orderVar.Status );
                if( orderVar.Status != Trigger.oldMap.get(orderVar.Id).Status  && orderVar.Status == 'Activated' ){
                    orderIds.add( orderVar.Id );
                }
            }
            System.debug('Order Ids to be processed ' + orderIds);

            if( orderIds.size() > 0){
                // Process Orders and Order products for creating Revenue Recognition Records
                T1_RevRecognitionService.generateRevRecognitionScheduleAndTransactions( orderIds );
            }
            
        }
    }
}