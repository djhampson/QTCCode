/**
*	Class providing utility methods for dealing with record types
*
*	Key usage is the caching of record types in memory for the duration of a transaction
*	once they have been called to minimise changes of hitting describe or SOQL limits
*
*	Copyright 2017 Cludo Pty Ltd
**/
public with sharing class RecordTypeUtil {
    private static Map<String, Map<String, Schema.RecordTypeInfo>> objectRecordTypesByName = new Map<String, Map<String, Schema.RecordTypeInfo>>();
    private static Map<String, Map<Id, Schema.RecordTypeInfo>> objectRecordTypesById = new Map<String, Map<Id, Schema.RecordTypeInfo>>();

    /**
    *	Retrieve the Id of a record type on a given object
    *
    * 	@param	objectType the object type on which the record type resides
    * 	@param	recordTypeName the name of the record type on the given object
    *
    * 	@return the Id value of the record type
    **/
    public static Id getRecordTypeIdByName(Schema.SObjectType objectType, String recordTypeName){
        Schema.RecordTypeInfo recordType = getRecordTypeByName(objectType, recordTypeName);
        if(recordType != null){
            return recordType.getRecordTypeId();
        }
        else{
            return null;
        }
    }

    /**
	*	Retrieve the Name of a record type on a given object
	*
	* 	@param	objectType the object type on which the record type resides
	* 	@param	recordTypeId the id of the record type on the given object
	*
	* 	@return the Name value of the record type
	**/
    public static String getRecordTypeNameById(Schema.SObjectType objectType, Id recordTypeId){
        Schema.RecordTypeInfo recordType = getRecordTypeById(objectType, recordTypeId);
        if(recordType != null){
            return recordType.getName();
        }
        else{
            return null;
        }
    }

    /**
	*	Retrieve the record type on a given object by name
	*
	* 	@param	objectType the object type on which the record type resides
	* 	@param	recordTypeName the name of the record type on the given object
	*
	* 	@return record type info class for matching record type
	**/
    public static Schema.RecordTypeInfo getRecordTypeByName(Schema.SObjectType objectType, String recordTypeName){
        if(getObjectRecordTypesByName(objectType).containsKey(recordTypeName)){
            return getObjectRecordTypesByName(objectType).get(recordTypeName);
        }
        else{
            return null;
        }
    }

    /**
	*	Retrieve the record type on a given object by Id
	*
	*	@param	objectType the object type on which the record type resides
	* 	@param	recordTypeId the id of the record type on the given object
	*
	* 	@return record type info class for matching record type
	**/
    public static Schema.RecordTypeInfo getRecordTypeById(Schema.SObjectType objectType, Id recordTypeId){
        if(getObjectRecordTypesById(objectType).containsKey(recordTypeId)){
            return getObjectRecordTypesById(objectType).get(recordTypeId);
        }
        else{
            return null;
        }
    }

    /**
    *	Retrieve record types for the given object type.
    *	If they are not already loaded they will be added to the map otherwise returned
    *
    * 	@param  objectType the object type on which the record type reside
    *
    * 	@return map of object record type info classes for the desired object keyed by record type name
    **/
    private static Map<String, Schema.RecordTypeInfo> getObjectRecordTypesByName(Schema.SObjectType objectType){
        if(!objectRecordTypesByName.containsKey(objectType.getDescribe().getName())){
            objectRecordTypesByName.put(objectType.getDescribe().getName(), objectType.getDescribe().getRecordTypeInfosByName());
        }

        return objectRecordTypesByName.get(objectType.getDescribe().getName());
    }

    /**
    *	Retrieve record types for the given object type.
    *	If they are not already loaded they will be added to the map otherwise returned
    *
    * 	@param  objectType the object type on which the record type reside
    *
    * 	@return map of object record type info classes for the desired object keyed by record type id
    **/
    private static Map<Id, Schema.RecordTypeInfo> getObjectRecordTypesById(Schema.SObjectType objectType){
        if(!objectRecordTypesById.containsKey(objectType.getDescribe().getName())){
            objectRecordTypesById.put(objectType.getDescribe().getName(), objectType.getDescribe().getRecordTypeInfosById());
        }

        return objectRecordTypesById.get(objectType.getDescribe().getName());
    }
}