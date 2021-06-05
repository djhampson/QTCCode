/*********************************************************************************************
* @author         Cludo
* @date           22/8/18
* @description:   Helper class for test classes
* @Version:
**********************************************************************************************/

public without sharing class CIAnywhereTestClassHelper {
    /**
    *    Description     : Creates custom setting
    **/
    public static void createCustomSetting(){
        CiAnywhereSetting__c wsSettings = new CiAnywhereSetting__c();
        wsSettings.Username__c = 'testUserName';
        wsSettings.Host_URL__c = 'AU';
        wsSettings.Password__c = 'EN';
        insert wsSettings;
    }

}