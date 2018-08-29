/* 
Class Name        : MIS_TriggerHandler
Trigger Name      : MIS_Trigger
Test Class Name   : Test_MIS_SOEs_cntrl
Purpose/Overview  : MIS Trigger
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 100%.
                    Trigger - 100%
Change History    : 
*/
trigger MIS_Trigger on MIS__c (before update) {
    Map<Id,MIS__c> mislist = new map<Id,MIS__c>();
    if(trigger.isUpdate && trigger.isbefore){    
        for(MIS__c mis: Trigger.New){
            if(mis.SOEs__c != null)
                mislist.put(mis.id,mis);
        }        
    }
    if(mislist.size() > 0)
        mIS_triggerHandler.BeforeUpdate(mislist);
    
}