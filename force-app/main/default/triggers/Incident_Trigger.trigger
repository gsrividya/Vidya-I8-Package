/* 
Class Name        : Incident_TriggerHandler 
Trigger Name      : Incident_Trigger 
Test Class Name   : Test_Incident_TriggerHandler
Purpose/Overview  : Trigger Handler for Incident Trigger.
                    When Incident is closed, SOE Managers wil receive mail.
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 100%
                    Trigger - 100%
Change History    : 

*/
Trigger Incident_Trigger on Incident__c (After Update) {
    If(Trigger.IsUpdate && Trigger.IsAfter){
        Incident_TriggerHandler.AfterUpdate(Trigger.New,Trigger.OldMap);
        
    }
}