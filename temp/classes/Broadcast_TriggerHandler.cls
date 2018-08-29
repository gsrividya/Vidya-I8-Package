/* 
Class Name        : Broadcast_TriggerHandler 
Trigger Name      : Broadcast_Trigger
Test Class Name   : Test_Broadcast_TriggerHandler
Purpose/Overview  : Trigger Handler for Broadcast Trigger.
                    When Broadcast message is inserted or updated, it is available for All Users or with in that SOE USers based on field in broadcast.
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 100%
                    Trigger - 100%
Change History    : 

*/
public class Broadcast_TriggerHandler {
    public static void Afterupdate (Map<Id,Broadcast__c> oldMap,Map<Id,Broadcast__c> newMap,string context){
        set<id> soeid = new set<id>();
        list<User> userUpdate = new list<user>();
        Boolean Alluser = false;
        if(Utils.isAccess_Update('User')){
            for(Broadcast__c bc:newMap.values()){
                if( bc.All_Users__c == true && (context == 'insert' || (bc != oldMap.get(bc.Id) && context == 'update')))
                    Alluser = true;
                else if(bc.This_SOE_Users__c == true && (context == 'insert' || (bc != oldMap.get(bc.Id) && context == 'update')))
                   soeid.add(bc.SOE__c);
            }
            if(Alluser == true){
                for(User u : [SELECT Id,Broadcast__c FROM User WHERE Broadcast__c = false and isActive = true]){
                    u.Broadcast__c = true;
                    userUpdate.add(u);  
                }              
            }
            else { 
                set<Id> UserIds = new set<Id>();   
                if(Utils.isAccessible('i8__SOE_Team_Member__c'))
                for(SOE_Team_Member__c soeteam : [SELECT Id,User_Id__c FROM SOE_Team_Member__c WHERE SOE__c IN :soeid])
                    UserIds.add(soeteam.User_Id__c ); 
                if(Utils.isAccessible('i8__Task__c'))
                for(Task__c tas : [select id,Owner__r.Member__r.Salesforce_User__c from Task__c where SOE__c =: soeid]){
                    if(tas.Owner__c != null && tas.Owner__r.Member__r.Salesforce_User__c != null)
                        UserIds.add(tas.Owner__r.Member__r.Salesforce_User__c);
                } 
                for(User u : [SELECT Id,Broadcast__c FROM User WHERE Broadcast__c = false and isActive = true and ID IN : UserIds]){
                    u.Broadcast__c = true;
                    userUpdate.add(u);  
                }                     
           }
           try{
           if(userUpdate.Size() > 0 && Utils.isUpdateable('User'))
               UPDATE userUpdate;
           }Catch(EXception e){
                LogFactory.error('Broadcast_triggerHandler','AfterUpdate','',e.getMessage()+''+e.getSTackTraceString());
                LogFactory.Savelog();
            } 
        } 
        else{LogFactory.debug('Broadcast_TriggerHandler', 'AfterUpdate', 'User Info', System.Label.ADMIN001,'Line - 54');
        LogFactory.SaveLog();}
    }
}