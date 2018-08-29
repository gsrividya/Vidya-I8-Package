/* 
Class Name        : SOE_TriggerHandler 
Trigger Name      : SOE_Trigger 
Test Class Name   : Test_SOE_Trigger_Handler
Purpose/Overview  : SOE Trigger.
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 97%
                    Trigger - 100%
Change History    : 
*/

Trigger SOE_Trigger on SOE__c (after insert, before update,after update) {    
     if(Trigger.IsInsert && Trigger.IsAfter) {
            SOE_TriggerHandler.AfterInsert(Trigger.newMap.keyset());           
            SOE_TriggerHandler.TeamMemberInsert(Trigger.New,'Insert');
     }   
     if(Trigger.IsUpdate && Trigger.IsBefore) {
          Map<Id,SOE__c>  soeMap = new Map<Id,SOE__C>();
          for(SOE__c soe : Trigger.New){
              if(soe.MIS__c != null && Trigger.OldMap.get(soe.Id).MIS__c != null &&soe.MIS__c != Trigger.OldMap.get(soe.Id).MIS__c )
                  soeMap.put(soe.id,soe);
          }
          SOE_TriggerHandler.BeforeUpdate(soeMap);
     }  
     if(Trigger.IsUpdate && Trigger.IsAfter) {
         SOE_TriggerHandler.AfterUpdate(Trigger.NewMap,Trigger.oldMap);
     }
}