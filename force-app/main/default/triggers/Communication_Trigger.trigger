/* 
Class Name        : Communication_TriggerHandler
Trigger Name      : Communication_Trigger
Test Class Name   : Test_Communication_TriggerHandler
Purpose/Overview  : To Update Phone and Email Fields in a Single Field.
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 87%.
                    Trigger - 100%
Change History    : 
*/
trigger Communication_Trigger on Communication__c (before insert,before update) {
    if(trigger.isinsert)
        Communication_TriggerHandler.BeforeInsert(trigger.new,'insert',new map<Id,Communication__c>());
    if(trigger.isupdate){
        list<communication__c> ComlIst = new list<communication__c>();
        Map<Id,communication__c> ComMap = new Map<Id,communication__c>();
        for(Communication__c com : Trigger.New){
            if(com != trigger.oldmap.get(com.id)){
                ComList.add(com);
                ComMap.put(com.id,trigger.oldmap.get(com.id));
            }
        }
        if(comList.Size() > 0)
           Communication_TriggerHandler.BeforeUpdate(ComList,'update',ComMap); 
    }    
}