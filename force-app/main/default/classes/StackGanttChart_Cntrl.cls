/* 
Class Name        : StackGanttChart_Cntrl 
Test Class Name   : Test_MIS_AllTasks_Cntrl 
Purpose/Overview  : To display all STack records in SOE's that are related with MIS
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 
*/
global with sharing class StackGanttChart_Cntrl {
    public Id MISId{get;set;}
    
    public StackGanttChart_Cntrl ()
    {
        MISID = ApexPages.CurrentPage().getParameters().get('id');  
    }    
    @RemoteAction    
    global static list<Task__c> getTasks(string mid) {
       list<Task__c> TaskList;
       if( Utils.isAccessible('i8__Task__c'))
           TaskList = [select Task_Title__c,id,Start_time__c,SOE__r.Name,End_Time__c,Owner__c,Minutes__c,Duration__c,Id_Text__c,Id_Before_Decimal__c,Is_Stack__c,Dependency_Type__c from Task__c where SOE__r.MIS__c =: mid and Stage_Level__c = 'Implementation' and Is_Stack__c = true order by Start_Time__c];       
       else
                LogFactory.debug('Stack Gantt Chart', 'Remote Action', 'Task Info ', System.Label.AddTask001 ,'Line - 22');
       return TaskList;
    }   
    public pagereference OpenCancel(){
        return new pagereference('/apex/MIS_AllTasks?id='+MISID);
    }
}