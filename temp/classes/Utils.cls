global with sharing class Utils {   
/*    
Class Name        : Utils
Test Class Name   : Test_Utils
Purpose/Overview  : Simplify the process,we have written common methods to check CRUD and FLS permission in multiple place. 
                    There is no user interface for this class.
Author            : Purview Ltd.
Code Coverage     : 97 %
Change History    : 

*/    
    public static Map<String, String> systemSettings
    {
        get
        {
            if (systemSettings == null)
            {
                systemSettings = new Map<String, String>();
                 if(Schema.sObjectType.SYstem_Setting__c.isAccessible() && Schema.sObjectType.SYstem_Setting__c.fields.Key__c.isAccessible() && 
                    Schema.sObjectType.SYstem_Setting__c.fields.Value__c.isAccessible() && Schema.sObjectType.SYstem_Setting__c.fields.Categories__c.isAccessible())
                    for (System_Setting__c setting : [SELECT Id,Value__c,Key__c,Categories__c FROM System_Setting__c limit 50000])
                        systemSettings.put(setting.Key__c, setting.Value__c);
            }
            return systemSettings;
        }
        set;
    }
    /**
    *   @description get Value__c field by Name from System_Setting__c object
    */
    public static String getSystemSetting(String name)
    {     
        for(string str : systemSettings.keyset()) {
            if(str == name)
                return systemSettings.get(str);
        }
        return null;
    }
   
    global static set<String> RequiredFieldsInObject(string ObjName){ 
        String fields ='';
        Set<String> FieldSet = new Set<String>();
        string setting = getSystemSetting(ObjName);
        if(setting != null ) {
            fields = setting;
            List<string> FieldList = fields.split(',');           
            for(String str : FieldList){
                if(str.startsWithIgnoreCase('i8__'))
                    FieldSet.add(str.toLowerCase());
                else
                    FieldSet.add('i8__'+str.toLowerCase());
            }
        }   
        return FieldSet;
    }
    global static boolean isAccessible(string objName){ 
        Set<String> Fields  = RequiredFieldsInObject(objName);
        Schema.DescribeSobjectResult result = Schema.getGlobalDescribe().get(objName.trim()).getDescribe();
        boolean bool = true;     
        if(Fields.Size() > 0 && result.isAccessible() ){
            Map<String, Schema.SObjectField> fieldMap = result.fields.getMap();
            for (String fieldToCheck : fieldMap.keyset()) {
                Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldToCheck).getDescribe();
                if (! fieldResult.isAccessible() && Fields.contains(fieldToCheck)){ 
                    bool = false;
                    break;
                }
            }
        }
        else
            bool = false;
        return bool;
    }
    global static boolean isCreateable(string objName){ 
        Set<String> Fields  = RequiredFieldsInObject(objName);
        Schema.DescribeSobjectResult result = Schema.getGlobalDescribe().get(objName.trim()).getDescribe();
        boolean bool = true;      
        if(Fields.SIze () > 0 && result.isCreateable()){
            Map<String, Schema.SObjectField> fieldMap = result.fields.getMap();
            for (String fieldToCheck : fieldMap.keyset()) {
                Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldToCheck).getDescribe();
                if (! fieldResult.isCreateable() && Fields.contains(fieldToCheck)){ 
                    bool = false;
                    break;
                }
            }
        }
        else
            bool = false;
        return bool;
    }
    global static boolean isUpdateable(string objName){  
        Set<String> Fields  = RequiredFieldsInObject(objName);
         Schema.DescribeSobjectResult result = Schema.getGlobalDescribe().get(objName.trim()).getDescribe();
        boolean bool = true;       
        if(Fields.Size() > 0 && result.isUpdateable()){
            Map<String, Schema.SObjectField> fieldMap = result.fields.getMap();
            for (String fieldToCheck : fieldMap.keyset()) {
                Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldToCheck).getDescribe();
                if (! fieldResult.isUpdateable() && Fields.contains(fieldToCheck)){ 
                    bool = false;
                    break;
                }
            }
        }
        else
            bool = false;
        return bool;
    }  
    global static boolean isAccess_Create_Update(string objName){
        Set<String> Fields  = RequiredFieldsInObject(objName);
        Schema.DescribeSobjectResult result = Schema.getGlobalDescribe().get(objName.trim()).getDescribe();
        boolean bool = true;
        if(FIelds.SIze() > 0 && result.isAccessible() && result.isCreateable() && result.isUpdateable()){
            Map<String, Schema.SObjectField> fieldMap = result.fields.getMap();
            for (String fieldToCheck : fieldMap.keyset()) {
                Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldToCheck).getDescribe();
                if ((! fieldResult.isCreateable() || ! fieldResult.isAccessible() || ! fieldResult.isUpdateable()) && Fields.contains(fieldToCheck)){ 
                    bool = false;
                    break;
                }
            }
        }
        else
            bool = false;
        return bool;
    }
    global static boolean isAccess_Create(string objName){
        Set<String> Fields  = RequiredFieldsInObject(objName);
        Schema.DescribeSobjectResult result = Schema.getGlobalDescribe().get(objName.trim()).getDescribe();
        boolean bool = true;        
        if(Fields.Size() > 0 && result.isAccessible() && result.isCreateable()){
            Map<String, Schema.SObjectField> fieldMap = result.fields.getMap();
            for (String fieldToCheck : fieldMap.keyset()) {
                Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldToCheck).getDescribe();
                if ((! fieldResult.isCreateable() || ! fieldResult.isAccessible() ) && Fields.contains(fieldToCheck)){ 
                    bool = false;
                    break;
                }
            }
        }
        else
            bool = false;
        return bool;
    }
    global static boolean isCreate_Update(string objName){
        Set<String> Fields  = RequiredFieldsInObject(objName);
        Schema.DescribeSobjectResult result = Schema.getGlobalDescribe().get(objName.trim()).getDescribe();
        boolean bool = true;
        if(Fields.Size()> 0 && result.isCreateable() && result.isUpdateable()){
            Map<String, Schema.SObjectField> fieldMap = result.fields.getMap();
            for (String fieldToCheck : fieldMap.keyset()) {
                Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldToCheck).getDescribe();
                if ((! fieldResult.isCreateable() || ! fieldResult.isUpdateable()) && Fields.contains(fieldToCheck)){ 
                    bool = false;
                    break;
                }
            }
        }
        else
            bool = false;
        return bool;
    }  
    global static boolean isAccess_Update(string objName){
        Set<String> Fields  = RequiredFieldsInObject(objName);
        Schema.DescribeSobjectResult result = Schema.getGlobalDescribe().get(objName.trim()).getDescribe();
        boolean bool = true;
        if(Fields.Size()> 0 && result.isAccessible()&& result.isUpdateable()){
            Map<String, Schema.SObjectField> fieldMap = result.fields.getMap();
            for (String fieldToCheck : fieldMap.keyset()) {
                Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldToCheck).getDescribe();
                if (( ! fieldResult.isAccessible() || ! fieldResult.isUpdateable()) && Fields.contains(fieldToCheck)){ 
                    bool = false;
                    break;
                }
            }
        }
        else
            bool = false;
        return bool;
    }
}