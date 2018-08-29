/* 
Class Name        : Broadcast_TriggerHandler 
Trigger Name      : Broadcast_Trigger
Test Class Name   : Test_Broadcast_TriggerHandler
Purpose/Overview  : Trigger Handler for Broadcast Trigger.
                    When Broadcast message is inserted or updated, it is available for All Users or with in that SOE USers based on field in broadcast.
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 87%
                    Trigger - 100%
Change History    : 

*/
trigger Broadcast_Trigger on Broadcast__c (After insert,After update) {
    if(trigger.IsInsert)
        Broadcast_TriggerHandler.Afterupdate(new Map<id,Broadcast__c>(),Trigger.newMap,'insert');
    if(trigger.IsUpdate)
        Broadcast_TriggerHandler.Afterupdate(Trigger.oldMap,Trigger.newMap,'update');
}