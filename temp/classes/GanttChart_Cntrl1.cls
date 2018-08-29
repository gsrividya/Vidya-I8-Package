/* 
Class Name        : GanttChart_Cntrl1
Test Class Name   : Test_GanttChart_Cntrl1
Purpose/Overview  : To display tasks in Gantt Chart.
Author            : Purview Ltd.
Code Coverage     : 100 %.
Change History    : 
*/
global with sharing class GanttChart_Cntrl1 {  
    public Id SOEId{get;set;}
    
    public GanttChart_Cntrl1 ()
    {
        SOEId = ApexPages.CurrentPage().getParameters().get('id');
    }
    @RemoteAction    
    global static WrapperClass getTasks(string sid) {
        list<Dependency__c> DepList = new list<Dependency__c>();
        Map<Id,Task__c> TaskList ;
        if( Utils.isAccessible('i8__Task__c')&& Utils.isAccessible('i8__Dependency__c')){
            TaskList = new Map<Id,Task__c>([select Task_Title__c,id,Start_time__c,End_Time__c,Owner__c,Minutes__c,Duration__c,Id_Text__c,Id_Before_Decimal__c,Is_Stack__c,Dependency_Type__c from Task__c where SOE__c =: sid and Stage_Level__c = 'Implementation' order by Id_Before_Decimal__c,Id_After_Decimal__c]);       
                DepList = [select id,Task__c,Task__r.ID_Text__c,Preceeding_Task__c,Preceeding_Task__r.ID_Text__c,Dep_Type__c,Type__c from Dependency__c where Task__c IN: TaskList.keyset() and Dependent_Type__c = 'Predecessors' ];       
        return new WrapperClass(TaskList.values(), DepList);
        }
        return null;
    }
    global class WrapperClass{
        public list<Task__c> Tasks{get;set;}
        public list<Dependency__c> Deps{get;set;}
        public WrapperClass(list<Task__c> task, List<Dependency__c> Dep){
            Tasks = task; Deps = Dep;
        }
    }
    public pagereference OpenCancel(){
        return new pagereference('/apex/AllTasks_ClientSide?id='+SOEId);
    }
}