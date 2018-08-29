global with sharing class SystemSettings_Util{
/*    
Class Name        : SystemSettings_Util
Purpose/Overview  : With this Utility class, we are retrieving few constant records from SystemSettings__c object to make things centralized and reduce duplicate code.
                    There is no user Interface. Only Admin can able to access.
Author            : Purview Ltd.
Change History    : 

*/    
    global Static Map<string,string> getTwilioSettings(){
        Map<string,String> TwilioMap = new Map<string,String>();
        if(Schema.sObjectType.SYstem_Setting__c.isAccessible() && Schema.sObjectType.SYstem_Setting__c.fields.Key__c.isAccessible() && 
        Schema.sObjectType.SYstem_Setting__c.fields.Value__c.isAccessible() && Schema.sObjectType.SYstem_Setting__c.fields.Categories__c.isAccessible())
            for(System_Setting__c sys : [Select id,Name,Key__c,Value__c,Categories__c from System_Setting__c where Categories__c LIKE '%Twilio%'])
                TwilioMap.put(sys.Key__c , sys.Value__c);
        return TwilioMap;
    }
    global Static Map<string,string> getSystemSettings(){
        Map<string,String> SettingMap = new Map<string,String>();
        if(Schema.sObjectType.SYstem_Setting__c.isAccessible() && Schema.sObjectType.SYstem_Setting__c.fields.Key__c.isAccessible() && 
        Schema.sObjectType.SYstem_Setting__c.fields.Value__c.isAccessible() && Schema.sObjectType.SYstem_Setting__c.fields.Categories__c.isAccessible())
            for(System_Setting__c sys : [Select id,Name,Key__c,Value__c,Categories__c from System_Setting__c where NOT Categories__c LIKE '%Twilio%'])
                SettingMap.put(sys.Key__c , sys.Value__c);
        return SettingMap ;
    }
}