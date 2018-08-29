/* 
Class Name        : SOE_SingleDashboard_Cntrl
Test Class Name   : Test_SOE_SingleDashboard_Cntrl
Purpose/Overview  : To display all critical information related to the SOE in a single page.
Author            : Purview Ltd.
Code Coverage     : 90%.
Change History    : 
*/
global with sharing class SOE_SingleDashboard_Cntrl{  
    public Id SOEId{get;set;}
    public SOE__c soe{get;set;}
    public integer count{get;set;}
    public list<Task__c> MilestoneList1{get;set;}
    public list<Task__c> CriticalPath1{get;set;}
    public list<Task__c> MilestoneList2{get;set;}
    public list<Task__c> CriticalPath2{get;set;}
    public i8Constants i8{get;set;}
    public list<Incident__c> Incidents1{get;set;}
    public list<Incident__c> Incidents2{get;set;}
    public String OpenIncidents{get;set;}
    public String ClosedIncidents{get;set;}
    public String OverallStatus{get;set;}
    public SOE_SingleDashboard_Cntrl()
    {
        SOEId = ApexPages.CurrentPage().getParameters().get('id'); 
        if(Utils.isAccessible('i8__SOE__c')) {
            soe = [select id,Name,SOE_RAG__c,Completed__c,SOE_Title__c,Dealy_Ahead_mins__c,Max_Planned_End__c,Max_Forecast_End__c,Max_End_Time__c,Min_Forecast_Start__c,Min_Planned_Start__c,Min_Start_Time__c  from SOE__c where id=: SOEId];
        if(soe.Dealy_Ahead_mins__c > 0)
            OverallStatus = 'red';
        else
            OverallStatus = 'green';
        if(soe.SOE_RAG__c=='amber')
            soe.SOE_RAG__c='Orange';  
        i8 = new I8Constants();
        if(UTils.isAccessible('i8__Task__c')){
            count = Database.countquery('select count() from Task__c where SOE__c =: SOEId');
            MilestoneList1 = [select id,name,Milestone__c,Planned_End__c,Task_Title__c,ID_Text__c,Forecast_End__c,Actual_End__c,Run_Delay__c from Task__c where SOE__c =: SOEId and Stage__c =: i8.STAGE_IMP and Stage_Level__c =: i8.CONTEXT_IMP  and Milestone__c = true and (Status__c =: i8.STATUS_COMPLETED OR Status__c =: i8.STATUS_FORCE_COMP  or Status__c = : i8.STATUS_COMP_JUMP) order by End_Time__c  limit 5]; 
            CriticalPath1 = [select id,name,Critical_Path__c,Planned_End__c,Task_Title__c,ID_Text__c,Forecast_End__c,Actual_End__c,Run_Delay__c from Task__c where SOE__c =: SOEId and Stage__c =: i8.STAGE_IMP and Stage_Level__c =: i8.CONTEXT_IMP  and Critical_Path__c != null  and (Status__c =: i8.STATUS_COMPLETED OR Status__c =: i8.STATUS_FORCE_COMP  or Status__c = : i8.STATUS_COMP_JUMP) order by End_Time__c  limit 5]; 
            MilestoneList2 = [select id,name,Milestone__c,Planned_End__c,Task_Title__c,ID_Text__c,Forecast_End__c,Actual_End__c,Run_Delay__c from Task__c where SOE__c =: SOEId and Stage__c =: i8.STAGE_IMP and Stage_Level__c =: i8.CONTEXT_IMP  and Milestone__c = false and (Status__c =: i8.STATUS_WAITING_JUMP OR Status__c =: i8.STATUS_WAITING OR Status__c =: i8.STATUS_RUNNING) order by End_Time__c limit 5]; 
            CriticalPath2 = [select id,name,Critical_Path__c,Planned_End__c,Task_Title__c,ID_Text__c,Forecast_End__c,Actual_End__c,Run_Delay__c from Task__c where SOE__c =: SOEId and Stage__c =: i8.STAGE_IMP and Stage_Level__c =: i8.CONTEXT_IMP  and Critical_Path__c != null and (Status__c =: i8.STATUS_WAITING_JUMP OR Status__c =: i8.STATUS_WAITING OR Status__c =: i8.STATUS_RUNNING) order by End_Time__c limit 5]; 
        }
        if(UTils.isAccessible('i8__Incident__c')){
            Incidents1 = [select id,name,Status__c,Priority__c,Summary__c,Inc_Type__c from Incident__c where SOE1__C =: SOEId and Priority__c = 'High' order by createdDate limit 5];
            Incidents2 = [select id,name,Status__c,Priority__c,Summary__c,Inc_Type__c from Incident__c where SOE1__C =: SOEId and Priority__c = 'Medium' order by createdDate limit 5];
            AggregateResult[] closedResults    = [SELECT COUNT(Id) cnt FROM Incident__c WHERE Status__c='Closed' and SOE1__c=:SOEId GROUP BY SOE1__c ];
            if(closedResults != null&& closedResults.SIze() > 0)
                ClosedIncidents=String.valueOf(closedResults[0].get('cnt')); 
            else
                ClosedIncidents ='0';
            AggregateResult[] openedResults    = [SELECT COUNT(Id) cnt FROM Incident__c WHERE Status__c='Open' and SOE1__c=:SOEId GROUP BY SOE1__c ];
            if(openedResults != null&& openedResults.SIze() > 0)
                OpenIncidents=String.valueOf(openedResults[0].get('cnt')); 
            else
                OpenIncidents='0'; 
        }
        String FileName =soe.Name+'-'+soe.SOE_Title__c+'.pdf' ;
        Apexpages.currentPage().getHeaders().put( 'content-disposition', 'inline; filename=' + FileName );
        }
    }
    @RemoteAction    
    global static list<Task__c> getTasks(string sid,integer start,integer end1) {
        list<task__c> TaskList = new list<Task__C>(); 
        list<task__c> TaskList1 = new list<Task__C>();
        if(Utils.isAccessible('i8__Task__c')){         
            TaskList = [select Task_Title__c,id,Start_time__c,End_Time__c,Owner__c,Minutes__c,Duration__c,Id_Text__c,Id_Before_Decimal__c,Planned_End__c,Forecast_End__c  from Task__c where SOE__c =: sid and Stage_Level__c = 'Implementation' and Is_Stack__c = true and Stage__c = 'Imp' order by End_Time__c asc limit 5];       
            integer last;
            if(start+end1 < = Tasklist.Size())
                last = start+end1;
            else
                last = Tasklist.Size();
            for(  integer i=start; i< last;i++)
                TaskList1.add(tasklist[i]);
        }
        return TaskList1 ;
    }
    public pagereference openCancel(){
        return new pagereference ('/apex/AllTasks_ClientSide?id='+SOEId);
    }
}