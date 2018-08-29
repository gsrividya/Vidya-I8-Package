/* 
Class Name        : Task_TriggerHandler 
Trigger Name      : Task_Trigger 
Test Class Name   : Test_Task_TriggerHandler
Purpose/Overview  :  Task Trigger.
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 73%
                    Trigger - 100%
Change History    : 

*/

trigger Task_Trigger on Task__c (before insert,after insert,before update,after update,before delete,after delete) {
    if(Trigger.isInsert && Trigger.isBefore)
        Task_TriggerHandler.BeforeInsert(Trigger.New);
    if(Trigger.isInsert && Trigger.isAfter)
         Task_TriggerHandler.AfterInsert(Trigger.New);
    if(Trigger.isUpdate && Trigger.isBefore )
         Task_TriggerHandler.BeforeUpdate(Trigger.New,Trigger.OldMap);
    if(Trigger.isUpdate && Trigger.isAfter )
        Task_TriggerHandler.AfterUpdate(Trigger.New,Trigger.OldMap);
    if(Trigger.isDelete && Trigger.isBefore)
        Task_TriggerHandler.BeforeDelete(Trigger.Old);
    if(Trigger.isDelete && Trigger.isAfter)
        Task_TriggerHandler.AfterDelete(Trigger.Old);
   
}