public with sharing class OpportunityTriggerHandler  extends BaseTriggerHandler{
	public override void beforeUpdate(List<SObject> newObjects, Map<Id, SObject> newObjectsMap, Map<Id, SObject> oldObjectsMap) {
		Map<Id, Opportunity> oldItemsOpportunityMap = new Map<Id, Opportunity>();
		if (!oldObjectsMap.isEmpty()) {
			oldItemsOpportunityMap = (Map<Id, Opportunity>) oldObjectsMap;
		}
	}

	public override void afterUpdate(List<SObject> newObjects, Map<Id, SObject> newObjectsMap, Map<Id, SObject> oldObjectsMap) {
		Map<Id, Opportunity> oldItemsOpportunityMap = new Map<Id, Opportunity>();
		if (!oldObjectsMap.isEmpty()) {
			oldItemsOpportunityMap = (Map<Id, Opportunity>) oldObjectsMap;
		}
		updateOpportunityTriggerHandler(newObjects, oldItemsOpportunityMap);
		opportunitySplitHandler(newObjects, oldItemsOpportunityMap);
	}
	public void opportunitySplitHandler(List<Opportunity> opportunities, Map<Id, Opportunity> oppOldMap){
		//Opportunity has line items and not from pricebook
		Map<Id, Opportunity>  oppMapNotFromPricebook = new Map<Id, Opportunity>();
		//Opportunity has module items from price book
		Map<Id, Opportunity>  oppMapHasModuleItemsFromPricebook = new Map<Id, Opportunity>();

		for(Opportunity o:opportunities){
			if (o.HasOpportunityLineItem && o.pricebook_overridden__c == false  &&
					(o.Amount !=  oppOldMap.get(o.Id).Amount ||
							o.Product_Modified_Date__c!=oppOldMap.get(o.Id).Product_Modified_Date__c) ) {
				oppMapNotFromPricebook.put(o.id, o);
			}
			if (o.Module_Modified_Date__c!=oppOldMap.get(o.Id).Module_Modified_Date__c &&
					o.pricebook_overridden__c == true) {
				oppMapHasModuleItemsFromPricebook.put(o.id, o);
			}
		}
		OpportunityItemSplit sp = new OpportunityItemSplit();
		if(oppMapNotFromPricebook.keySet().size()>0){
			//Remove data from OpportunityItemSplit
			sp.deleteItemSplit(oppMapNotFromPricebook);
			sp.deleteModuleItem(oppMapNotFromPricebook);
			sp.deleteGroupedProduct(oppMapNotFromPricebook);
			//system.debug('pricebook overridden false');

			//add data from OpportunityLineItem
			sp.insertLineItemSplit(oppMapNotFromPricebook);
			sp.insertGroupedProduct(oppMapNotFromPricebook);
		}

		if(oppMapHasModuleItemsFromPricebook.keySet().size()>0){
			//Remove data
			sp.deleteItemSplit(oppMapHasModuleItemsFromPricebook);
			sp.deleteGroupedProduct(oppMapHasModuleItemsFromPricebook);

			//Add data from ModuleItem
			sp.insertModuleItemSplit(oppMapHasModuleItemsFromPricebook) ;
			sp.insertGroupedProduct(oppMapHasModuleItemsFromPricebook);
		}
	}

	public void updateOpportunityTriggerHandler(List<Opportunity> opportunities, Map<Id, Opportunity> oldOppMaps){
		List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId() LIMIT 1];
		String	Role = PROFILE[0].Name;

		return;
	}
}