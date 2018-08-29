/* 
Class Name        : User_TriggerHandler 
Trigger Name      : User_Trigger 
Test Class Name   : Test_USER_TriggerHandler
Purpose/Overview  : Trigger Handler for User Trigger.
                    When user is created, update default values for SOE My View and MIS My View Fields.
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 100%
                    Trigger - 100%
Change History    : 

*/

trigger User_Trigger on User (before insert,after update) {
    If(Trigger.Isinsert && Trigger.Isbefore){
        User_TriggerHandler.setUserDefultValues(trigger.new);
     }    
}