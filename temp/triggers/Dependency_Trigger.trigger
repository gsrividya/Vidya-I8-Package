/* 
Class Name        : Dependency_TriggerHandler
Trigger Name      : Dependency_Trigger
Test Class Name   : Test_Dependency_TriggerHandler
Purpose/Overview  : Dependency Trigger
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 100%.
                    Trigger - 100%
Change History    : 
*/
trigger Dependency_Trigger on Dependency__c (after insert,after delete) {
    if(trigger.IsAfter && trigger.IsInsert )
        Dependency_TriggerHandler.AfterInsert(Trigger.new,'Created');
   if(trigger.IsAfter && trigger.IsDelete )
        Dependency_TriggerHandler.AfterInsert(Trigger.old,'Deleted');
}