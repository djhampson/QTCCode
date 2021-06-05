/*******************************************************************************************************
* Class Name      	: StaticUtil
* Description		: Static Util functions  
* Author          	: Simplus - Abeer Qureshi
* Created On      	: 
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         		        1000				Initial version
******************************************************************************************************/
public with sharing class StaticUtil {
    public StaticUtil() {

    }

/*
    *@description To avoid no row returned exception and delegating error handling by returning null
    *@author Abeer Qureshi - Simplus 
    *@param List<SObject> query rows to check
    *@return SObject returns first item of the query rows
*/ 
    public static SObject Single(List<SObject> result){

        if(result <> null && result.size() > 0)
            return result[0];

        return null;
    }
/*
    *@description returns unique GUUID, mostly unique over a very large repetition
    *@author Abeer Qureshi - Simplus 
    *@param 
    *@return String GUUID
*/ 
    public static string getGUUID(){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return 
            h.SubString(0,8) + '-' + 
            h.SubString(8,12) + '-' + 
            h.SubString(12,16) + '-' + 
            h.SubString(16,20) + '-' + 
            h.substring(20);
    }
}