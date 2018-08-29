/* 
Class Name        : Add_Task_cntrl 
Test Class Name   : Test_Add_Task_cntrl
Purpose/Overview  : To Add New Task to SOE.
Author            : Purview Ltd.
Code Coverage     : 98%
Change History    : 

*/
public with sharing class Add_Task_cntrl {
    public Task__c taskObj{get;set;}
    public Task__c CurTask{get;set;}
    public Task__c NewTask{get;set;}
    public List<Task__c> updateTaskList{get;set;}
    public string NewtaskId{get;set;}
    public integer beforeDecimal{get;set;}
    public integer afterDecimal {get;set;}
    public string errormessage{get;set;}
    public boolean errorbool{get;set;}
    public I8Constants i8{get;set;}
    public SOE__c SOEobj {get;set;}
    public Task__c Stack{get;set;} 
    Public Map<Id,Id> ImpMgrMap{get;set;}
    public string ImpMgrMapKey{get;set;}
    public string statusmsg {get;set;}
    public boolean Task_Accessible;
    public Add_Task_cntrl(){         
         i8 = new I8Constants();
         Task_Accessible = Utils.isAccessible('i8__Task__c');
         if(Utils.isAccessible('i8__SOE__c'))
                SOEobj = [select id,name,SOE_Title__c,State__c,status__c,QA_Review_Required__c,QA_Review__c,WalkThrough_Required__c,WalkThrough__c,Max_Planned_End__c,Dealy_Ahead_mins__c,Max_End_Time__c,Max_Forecast_End__c,Task_Late_Threshold_Mins__c from SOE__c where id=:ApexPages.currentPage().getParameters().get('SOEId') ];
         if(Task_Accessible && Utils.isCreateable('i8__Task__c')){
            CurTask = [select id,ID_Text__c,Stage__c,Stage_Level__c,Status__c,Dependency_Type__c,Link__c,Internal_Task__c,Id_After_Decimal__c,Id_Before_Decimal__c,SOE__c,Is_Stack__c from Task__c where id=:ApexPages.currentPage().getParameters().get('Id')];
            Stack = [Select id, Status__c,Jump__c from TAsk__c where Id_Before_Decimal__c =: CurTAsk.Id_Before_Decimal__c and Is_Stack__c = true and Stage_Level__c = : CurTAsk.Stage_Level__c and Stage__c =: CurTAsk.Stage__c and SOE__c =: CurTAsk.SOE__c];
            ImpMgrMap = new Map<Id,Id>();
            list<string> RolesLIst = System.Label.Roles_To_Edit_SOE.split(',');            
            if(Utils.isAccessible('i8__SOE_Team_Member__c'))
                for( SOE_Team_Member__c imp : [select Id,Name,Team_Member__r.Salesforce_User__c,Access_Level__c  from SOE_Team_Member__c where SOE__c =: CurTask.soe__c  and Access_Level__c != 'Read' and Role__r.Reference_Role__c  IN: RolesLIst ])  
                    ImpMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
            if(Schema.sObjectType.Profile.isAccessible() ){
                if([Select Id,Name from Profile where Id=:userInfo.getProfileId()].Name == 'System Administrator')
                     ImpMgrMap.put(userInfo.getUserId(),userInfo.getUserId());
            }
            ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', ''); 
            if(Stack.Status__c == i8.STATUS_RUNNING || Stack.Status__c == i8.STATUS_COMPLETED || Stack.Status__c == i8.STATUS_COMP_JUMP || Stack.Jump__c== true){
                errorbool = true;
                errormessage = System.Label.AddTask004;
            }
            else{
                if(CurTask.ID_Text__c!= null) {
                    getTaskInfo();
                }
            }
        }else{errorbool = true;  errormessage = System.Label.ADMIN001;}
        
    }
    public void getTaskInfo(){
        list<string> TaskIdList = CurTask.ID_Text__c.split('\\.');
        beforeDecimal = integer.valueof(TaskIdList[0]);
        afterDecimal = integer.valueof(TaskIdList[1]);
        errorbool = false;
        NewtaskId= string.valueof(beforeDecimal) +'.'+ string.valueof(afterDecimal+1) ;
        if(Task_Accessible)
            taskObj= [select id,Task_Title__c,SOE__c,Stage_Level__c,Stage__c,Team__c,Owner__c  from task__c where SOE__c =: CurTask.SOE__c and Is_Stack__c = true and Id_Before_Decimal__c =: beforeDecimal and Stage_Level__c =: CurTask.Stage_Level__c] ;
        NewTask = new Task__c();
    }
    public pagereference CreateTask(){
        statusmsg = null;errorbool  = false; errormessage = null;
        Map<String, String> parammap = ApexPages.currentPage().getParameters();
        Savepoint sp = Database.setSavepoint();
        try{
            if(Utils.isAccess_Create_Update('i8__Task__c') && Utils.isACcess_Create('i8__Dependency__c') && Schema.sObjectType.Dependency__c.isDeletable()){
                for (String key : parammap.keySet()) {
                    if(key.startsWith('days')){
                        if (parammap.get(key) != null && parammap.get(key).length() > 0)
                            NewTask.Days__c = integer.ValueOf(parammap.get(key));
                        else
                            NewTask.Days__c = 0; 
                    }
                    if(key.startsWith('hours')){
                        if (parammap.get(key) != null && parammap.get(key).length() > 0)
                            NewTask.Hours__c = integer.ValueOf(parammap.get(key));
                        else
                             NewTask.Hours__c = 0;
                    }    
                    if(key.startsWith('minutes')){          
                        if (parammap.get(key) != null && parammap.get(key).length() > 0)
                            NewTask.Minutes__c = integer.ValueOf(parammap.get(key));
                        else
                             NewTask.Minutes__c = 0;
                    }
                    if(key.startsWith('limitedtextarea1'))
                        NewTask .Description__c = parammap.get(key);
                    if(key.startsWith('limitedtextarea2'))
                        NewTask .Technical_Detail__c = parammap.get(key);
                    if(key.startsWith('tasktitle'))
                        NewTask.Task_Title__c = parammap.get(key);
                } 
                if(NewTask.Task_Title__c == ''){
                    statusmsg = System.Label.AddTask005;
                    return null;
                }
                else{
                    statusmsg = null;                  
                NewTask.Stage_Level__c = taskobj.Stage_Level__c;
                NewTask.Stage__c = taskobj.Stage__c ;
                NewTask.ID_Text__C = NewTaskId;
                Newtask.SOE__c = taskObj.SOE__c;
                NewTask.Status__c = i8.STATUS_BUILD ;
                NewTask.Sum_Days__c = NewTask.Days__c;
                NewTask.Sum_Hours__c = NewTask.Hours__c;
                NewTask.Sum_Mins__c = NewTask.Minutes__c ;        
                if(NewTask.Link__c == true){
                    NewTask.Dependency_Type__c =i8.LINKDEP ;
                    NewTask.Broken_Task__c = true;
                }
                if(afterDecimal+1 == 1){
                    NewTask.Link__c = false;
                    NewTask.Dependency_Type__c =i8.NODEP;
                    NewTask.Broken_Task__c = false;
                }
                updateTaskList = new List<Task__c>(); 
                for(Task__c tas: [select id,ID_Text__c,Id_Before_Decimal__c,Id_After_Decimal__c from Task__c where SOE__c =:CurTask.SOE__c and Id_Before_Decimal__c =: beforeDecimal  and IS_Stack__c = false and Stage_Level__c =: CurTask.Stage_Level__c]){
                    if(tas.Id_After_Decimal__c.IntValue() >= afterDecimal+1 ){
                        tas.ID_Text__c = string.valueof(beforeDecimal)+'.'+string.valueof(tas.Id_After_Decimal__c+1);
                        updateTaskList.add(tas);
                    }
                }        
                if(updateTaskList.size()>0 ){
                    if(Utils.isUpdateable('i8__Task__c'))
                        update updateTaskList;
                    LogFactory.info('Add_Task_Cntrl', 'CreateTask', 'Task Info', JSON.serialize(NewTAsk),'LIne - 131');
                    if(Utils.isCreateable('i8__Task__c'))
                        insert NewTask;
                    Task__c Next_Task = [select id,Dependency_Type__c,Link__c,Internal_Task__c,Id_Before_Decimal__c from Task__c where SOE__c =: CurTask.SOE__c and Id_Before_Decimal__c =: CurTask.Id_Before_Decimal__c and Id_After_Decimal__c =: CurTask.Id_After_Decimal__c+2 and IS_Stack__c = false and Stage_Level__c =: CurTask.Stage_Level__c];
                    If(Next_Task.Link__c == True){
                        Next_Task.Link__c = False;
                        If(Next_Task.Dependency_Type__c == I8.LINKDEP){
                            Next_Task.Dependency_Type__c = I8.NODEP;
                            if(Utils.isUpdateable('i8__Task__c'))
                                Update Next_Task;
                        }                       
                        List<Dependency__c> Del_Dep = New List<Dependency__c>();
                        Dependency__c SUC_DEP = [select id,Dependent_Type__c,Dep_Type__c,Preceeding_SOE__c,Preceeding_Task__c,SOE__c,Task__c,Type__c from Dependency__c where Task__c =: Curtask.id and Preceeding_Task__c =: Next_Task.id and Dependent_Type__c =: I8.SUCCESSOR];
                        Dependency__c PRE_DEP = [select id,Dependent_Type__c,Dep_Type__c,Preceeding_SOE__c,Preceeding_Task__c,SOE__c,Task__c,Type__c from Dependency__c where Task__c =: Next_Task.id and Preceeding_Task__c =: Curtask.id and Dependent_Type__c =: I8.PREDECESSOR];
                        Del_Dep.add(SUC_DEP);
                        Del_Dep.add(PRE_DEP);                       
                        if(Schema.SOBjectType.Dependency__c.isDeletable())
                            Delete Del_Dep;
                    }
                    list<Dependency__c> deplist = new list<Dependency__c>();
                    if(NewTask.Link__c == true && (afterDecimal+1) >1){
                        Dependency__c dep = new Dependency__c();
                        dep.Dependent_Type__c = i8.PREDECESSOR ; 
                        dep.Preceeding_Task__c = CurTask.Id;
                        dep.Preceeding_SOE__c = CurTask.SOE__c;
                        dep.SOE__c =CurTask.SOE__c;
                        dep.Task__c = NewTask.Id;
                        dep.Type__c = i8.DEP_FS;
                        dep.Dep_Type__c = i8.LINKDEP;
                        deplist.add(dep);
                        Dependency__c dep1 = new Dependency__c();
                        dep1.Dependent_Type__c = i8.SUCCESSOR; 
                        dep1.Preceeding_Task__c = NewTask.Id;
                        dep1.Preceeding_SOE__c = CurTask.SOE__c;
                        dep1.SOE__c =CurTask.SOE__c;
                        dep1.Task__c = CurTask.Id;
                        dep1.Type__c = i8.DEP_FS;
                        dep1.Dep_Type__c = i8.LINKDEP;
                        deplist.add(dep1);
                        LogFactory.info('Add_Task_Cntrl', 'CreateTask', 'Predecessor', JSON.serialize(dep),'LIne - 167');
                        LogFactory.info('Add_Task_Cntrl', 'CreateTask', 'Successor', JSON.serialize(dep1),'LIne - 168');    
                    }                        
                    if(deplist.size()>0 && Utils.isCreateable('i8__Dependency__c'))                       
                            insert deplist;
                    Task_TriggerHandler.UpdateAllTasks(new list<id>{NewTask.SOE__c},I8.CONTEXT_IMP);
                    Task_TriggerHandler.UpdateAllTasks(new list<id>{NewTask.SOE__c},I8.CONTEXT_BO);
                    LogFactory.SaveLog(); 
                    return new pagereference('/apex/AllTasks_ClientSide?id='+CurTask.SOE__c);           
                    }
                 }
                 }else{errorbool = true;  errormessage = System.Label.ADMIN001;}                
             }catch(Exception e){
                   Database.rollback(sp);
                   LogFactory.error('Add_Task_Cntrl', 'CreateTask', '', e.getMessage() + '' + e.getStackTraceString());  
                   LogFactory.SaveLog(); 
                   statusmsg = e.getMessage();                  
             }             
              return null;
    }
    public pagereference CancelTask(){
        return new pagereference ('/apex/AllTasks_ClientSide?id='+SOEObj.Id);
    }    
}