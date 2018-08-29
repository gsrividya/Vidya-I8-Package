/* 
Class Name        : SOEResource_Gantt_Cntrl
Test Class Name   : Test_SOEResource_Gantt_Cntrl
Purpose/Overview  : To display the REsource Gantt Chart in that SOE.
Author            : Purview Ltd.
Code Coverage     : 100%.
Change History    : 
*/
global with sharing class SOEResource_Gantt_Cntrl {
    public Id SOEId{get;set;}
    public Id MISId{get;set;}
    public SOE__C soe{get;set;}
    public Id RecordId {get;set;}
    public DateTime MinDateTime{get;set;}
    
    public SOEResource_Gantt_Cntrl (){
        SOEId = ApexPages.CurrentPage().getParameters().get('id');
        MISId = ApexPages.CurrentPage().getParameters().get('Mid');
        if(Utils.isAccessible('i8__SOE__c')){
            if(MISId == null){
                soe = [select id,SOE_Title__C,Min_Start_All__c from SOE__c where id=: SOEId];
                MinDateTime  = soe.Min_Start_All__c ;
                RecordId  = soe.id;
            }
            else{
                AggregateResult[] groupedResults =  [SELECT  MIN(Min_Start_All__c ) LastDate FROM SOE__c WHERE MIS__C =: MISID  Group By MIS__c] ;       
                if(groupedResults.Size() > 0)
                    MinDateTime  = DateTime.valueof(groupedResults[0].get('LastDate'));
                RecordId  = MISID;
            }
        }
    }
    @RemoteAction    
    global static list<Task__c> getTasks(string sid) {
        List<Task__c> TaskList ;
        if(Utils.isAccessible('i8__Task__c')){
            if(sid.substring(0,3) == SOE__c.sobjecttype.getdescribe().getkeyprefix())
                TaskLIst = [select Task_Title__c,SOE__r.Name,id,Start_time__c,Stack_Owner_Name__c,End_Time__c,Owner__c,Minutes__c,Duration__c,Id_Text__c,Id_Before_Decimal__c,Is_Stack__c,Dependency_Type__c from Task__c where SOE__c =: sid and Stage_Level__c = 'Implementation' and IS_Stack__c = false order by Id_Before_Decimal__c,Id_After_Decimal__c];       
            else
                TaskLIst = [select Task_Title__c,SOE__r.Name,id,Start_time__c,Stack_Owner_Name__c,End_Time__c,Owner__c,Minutes__c,Duration__c,Id_Text__c,Id_Before_Decimal__c,Is_Stack__c,Dependency_Type__c from Task__c where SOE__r.MIS__c =: sid and Stage_Level__c = 'Implementation' and IS_Stack__c = false order by Id_Before_Decimal__c,Id_After_Decimal__c];       
        }           
        return TaskList;
    }
    public pagereference CancelPage(){
        if(MISID == null)
            return new pagereference('/apex/AllTasks_ClientSide?id='+SOEId);
        else
            return new pagereference('/apex/MIS_AllTasks?id='+MISID);
    }
}