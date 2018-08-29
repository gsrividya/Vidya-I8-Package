/* 
Class Name        : SOE_TeamMember_TriggerHandler 
Trigger Name      : SOE_TeamMember_Trigger
Test Class Name   : Test_SOE_TeamMember_TriggerHandler
Purpose/Overview  : Trigger for SOETeamMember.
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 97%
                    Trigger - 100%
Change History    : 
*/

Trigger SOE_Team_Member on SOE_Team_Member__c (after insert,after update,after delete){
    if(Trigger.IsInsert && Trigger.IsAfter)
        SOE_TeamMember_TriggerHandler.SOEShareToSOETeamMember(Trigger.New);
    if(Trigger.IsUpdate && Trigger.IsAfter)
        SOE_TeamMember_TriggerHandler.SOEShareToSOETeamMember(Trigger.New,Trigger.oldMap);
    if(Trigger.IsDelete && Trigger.IsAfter)
        SOE_TeamMember_TriggerHandler.DelSOEShare(Trigger.Old);
}