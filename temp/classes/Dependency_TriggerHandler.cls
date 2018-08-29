/* 
Class Name        : Dependency_TriggerHandler
Trigger Name      : Dependency_Trigger
Test Class Name   : Test_Dependency_TriggerHandler
Purpose/Overview  : Trigger Handler for Dependency Trigger
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 100%.
                    Trigger - 100%
Change History    : 
*/
public class Dependency_TriggerHandler {
    public static i8Constants i8 = new i8Constants ();
    public static void AfterInsert(list<Dependency__c> DepList,string action){
        Set<Id> TaskIds = New Set<Id>();
        Map<Id,Task__c> TAskMap = new Map<Id,Task__c>();
        Map<TAsk__c,list<Dependency__c>> Dep_Map = New Map<Task__c,list<Dependency__c>>();
        For(Dependency__c dep : DepList)
            TaskIds.add(dep.Task__c);
        if(UTils.isAccessible('i8__Task__c'))
            for(Task__c tas: [Select Id,Id_Text__c,Status__c,Task_Title__c,SOE__c,Stage__c,Stage_Level__c from Task__c where Id IN : TaskIds])
                TAskMap.put(tas.Id,tas);
        For(Dependency__c dep : DepList){
            If(Dep.Dependent_Type__c == i8.PREDECESSOR && TAskMap.get(dep.Task__c).Stage_Level__c == i8.CONTEXT_IMP  && TAskMap.get(dep.Task__c).Stage__c == i8.STAGE_IMP && TAskMap.get(dep.Task__c).Status__c == i8.STATUS_FREEZE){
                If(!Dep_Map.containsKey(TAskMap.get(dep.Task__c)))
                    Dep_Map.Put(TAskMap.get(dep.Task__c), new list<Dependency__c>());
                Dep_Map.get(TAskMap.get(dep.Task__c)).add(dep);
            }                
        }  
        if(Dep_Map.size()> 0)
            HistoryInsert(Dep_Map,action);      
    }
    public static void HistoryInsert(Map<Task__c,list<Dependency__c>> DepMap, string action){
        List<History__c> Hist_List = New List<History__c>();
        History__c Hist_Obj;
        if(Utils.isCreateable('i8__History__c')){
            For(Task__c tas: DepMap.keyset()){
                for(Dependency__c dep: DepMap.get(tas)){
                    Hist_Obj = New History__c();
                    Hist_Obj.Action__c = action;
                    Hist_Obj.Field__c = 'Dependency';
                    Hist_Obj.SOE__c = tas.SOE__c;
                    Hist_Obj.Modified_By__c = UserInfo.getUserId();
                    Hist_Obj.Task_Id__c = tas.Id_Text__c;
                    Hist_Obj.New_Value__c =  dep.Dep_Type__c;   
                    Hist_List.add(Hist_Obj);
                }
            }
            If(Hist_List.Size() > 0 && Utils.isCreateable('i8__History__c'))
                Insert Hist_List;
        }
        else{
            LogFactory.debug('Dependency_TriggerHandler', 'HIstory Insert', 'History Info', System.Label.AddTask006 ,'Line - 52');
            LOgFactory.SaveLog();
        }
    }
}