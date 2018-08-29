/* 
Class Name        : Edit_Stack_Cntrl 
Test Class Name   : Test_Edit_Stack
Purpose/Overview  : To add/move/copy tasks within a stack in that SOE. 
Author            : Purview Ltd.
Code Coverage     : 94%
Change History    : 

*/
public with sharing class Edit_Stack_Cntrl {    
    public List<Task__c> selectedtasks = new List<Task__c>();
    public Integer SelectRow{get;set;}
    public string selectaction{get;set;}
    public string ToStack{get;set;}
    public string selecttask{get;set;}   
    public list<Task__c> TaskList{get;set;}
    public Task__c CurTask{get;set;}
    public SOE__c CurSOE{get;set;}
    public string FromStack{get;set;}
    public list<Task__c> TasksInStack{get;set;}
    public list<WrapperTasks> WrapperList{get;set;}
    public String IdText{get;set;}
    public String IdText1{get;set;}
    public Task__c Task1{get;set;}
    public string taskid{get;set;}
    public Task__c Task2{get;set;}
    public String TaskRecId{get;set;}  
    public Integer ListSize{get;set;}  
    public List<Dependency__c > depList {get;set;}
    public List<Task__c> StackList{get;set;}
    public list<Task__c> ToStackTaskList {get;set;}
    public Map<string,Task__c>ToStackTaskMap{get;set;}
    public Map<string,Task__c>FromStackMap{get;set;}
    public string errormessage{get;set;}
    public boolean errorbool{get;set;}
    public string errormessage1{get;set;}
    public boolean errorbool1{get;set;}
    public list<Task__c> TaskUpdList = new List<Task__c>();
    public list<Id> ExternalIdList= new list<Id>();
    List<Id> insertidList = new list<string>(); 
    public list<Id> PreceedingTaskIdList= new list<Id>();  
    public boolean SelectAll{get;set;}
    public Map<Id,Task__c> TaskMap = new Map<Id,Task__c>();
    public I8Constants i8{get;set;}
    public boolean Stack_Status{get;set;}
    Public Map<Id,Id> ImpMgrMap{get;set;}
    public string ImpMgrMapKey{get;set;}
    public string errmsg{get;set;}
    //pagination
    public integer totalRecs{get;set;}     
    public integer index{get;set;} 
    public integer pageSize{get;set;}  
    public boolean Task_Create_Update_Delete {get;set;}
    public boolean Task_Accessible {get;set;}
    public boolean Dep_Access;
    public boolean Dep_Access_Create_Delete ;
    public Id SOEId {get;set;}
    
    public Edit_Stack_Cntrl (){  
        i8 = new I8Constants();  
        Stack_Status = false;
        TasksInStack = new List<Task__C>(); 
        FromStackMap = new Map<string,Task__c>();
        selectaction = 'Append';
        errorbool = false;
        errorbool1 = false;
        totalRecs = 0;index =0;pageSize = 5;
        SOEId = ApexPages.CurrentPage().getParameters().get('SId');
        depList = new list<Dependency__C>();
        Dep_Access = Utils.isAccessible('i8__Dependency__c');
        Dep_Access_Create_Delete = Utils.isAccess_Create('i8__Dependency__c') && Schema.sObjectType.Dependency__C.isDeletable();
        Task_Create_Update_Delete = Utils.isCreate_Update('i8__Task__c') && Schema.sObjectType.Task__c.isDeletable();
        Task_Accessible = Utils.isAccessible('i8__Task__c');
        if(Task_Accessible ){
            CurTask = [select id,ID_Text__c,Id_Before_Decimal__c,Status__c,Jump__c,Stage_Level__c,SOE__c,Task_Title__c,Stage__c from Task__c where id=: ApexPages.CurrentPage().getParameters().get('Id')];
            if(CurTask.Status__c == i8.STATUS_RUNNING || CurTask.Status__c == i8.STATUS_COMPLETED || CurTask.Status__c == i8.STATUS_COMP_JUMP|| CurTask.Jump__c == true)
                Stack_Status = true;
            if(Utils.isAccessible('i8__SOE__c'))
                CurSOE = [select id,name,Status__c,QA_Review_Required__c,QA_Review__c,WalkThrough_Required__c,WalkThrough__c,SOE_Title__c,Max_Planned_End__c,Max_Forecast_End__c,Max_End_Time__c,Dealy_Ahead_mins__c,State__c,Task_Late_Threshold_Mins__c  from SOE__c where id=: CurTask.SOE__c];
            ImpMgrMap = new Map<Id,Id>();
            list<string> RolesLIst = System.Label.Roles_To_Edit_SOE.split(',');
            if(Utils.isAccessible('i8__SOE_Team_Member__c'))
            for( SOE_Team_Member__c imp : [select Id,Name,Team_Member__r.Salesforce_User__c,Access_Level__c  from SOE_Team_Member__c where SOE__c =: CurSOE.Id  and Access_Level__c != 'Read' and Role__r.Reference_Role__c  IN : RolesLIst ])  
                    ImpMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
            if(Schema.SObjectTYpe.Profile.isAccessible())
                if([Select Id,Name from Profile where Id=:userInfo.getProfileId()].Name == 'System Administrator')
                    ImpMgrMap.put(userInfo.getUserId(),userInfo.getUserId());
            ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', '');
            StackList =[Select id,Stage__c,Jump__c,Id_Before_Decimal__c,Status__c,Task_Title__c,Is_Stack__c,ID_Text__c,SOE__c,Stage_Level__c   from Task__c where SOE__c =:CurTAsk.SOE__c and Is_Stack__c = true and Stage_Level__c =: CurTask.Stage_Level__c order by Id_Before_Decimal__c];
            FromStack= String.valueOF(CurTask.Id_Text__c)  ;
            ToStack = string.valueof(StackList[0].Id_Text__c);   
            for(Task__c t: StackList )
                FromStackMap.put(t.ID_Text__c, t);           
            Tasks();
        }         
    }    
    public void Tasks(){
        errmsg = null;
        SelectAll = false;
        if(Task_Accessible && Schema.sObjectType.Attachment.isAccessible() && Dep_Access && Utils.isAccessible('i8__SOE__c')){
        if(index > =0){
            totalRecs = [select count() from Task__c where SOE__c =: FromStackMap.get(FromStack).SOE__c and Stage_Level__c = : FromStackMap.get(FromStack).Stage_Level__c and Id_Before_Decimal__c =: FromStackMap.get(FromStack).Id_Before_Decimal__c and Is_Stack__c = false]; 
            if(index >=0 && index<= 2000){
                TaskList =[select id,SOE__C,Dependency_Type__c ,Status__c,Is_Stack__c,Stage_Level__c ,Duration__c,ID_Text__c,Link__c,End_Stack__c ,Stage__c,Team__c ,Owner__c ,Jump__c,Days__c,Hours__c,Minutes__c,Task_Title__c,(select id from Attachments),Milestone__c,Time_Bound__c,
                Advanced_Notifications__c,Secoundary_User__c,Manager__c,Info__c,BackOut__c,BackOut_Point__c,Description__c,Execution_Detail__c,Internal_Task__c,Id_After_Decimal__c ,State__c,Id_Before_Decimal__c,Dependency_Image__c,Task_Comments__c,Task_Completed__c,Technical_Detail__c,Technical_Skills__c,
                (select id,Type__c,Dependent_Type__c,Dep_Type__c ,Preceeding_Task__r.Status__c,Preceeding_Task__r.ID_Text__c,Preceeding_Task__r.State__c,Preceeding_Task__r.Task_Title__c,Preceeding_SOE__r.SOE_Title__c,SOE__r.SOE_Title__c  from Dependencies__r order by Preceeding_Task__r.ID_Text__c) 
                from Task__C where SOE__c =: FromStackMap.get(FromStack).SOE__c and Stage_Level__c = : FromStackMap.get(FromStack).Stage_Level__c and Id_Before_Decimal__c =: FromStackMap.get(FromStack).Id_Before_Decimal__c and Is_Stack__c = false order by Id_Before_Decimal__c,Id_After_Decimal__c asc LIMIT:PageSize OFFSET: index ];
            }
            else if(index > 2000){
                list<TAsk__c> TaskList1 =[select id,SOE__C,Dependency_Type__c ,Status__c,Is_Stack__c,Stage_Level__c ,Duration__c,ID_Text__c,Link__c,End_Stack__c ,Stage__c,Team__c ,Owner__c ,Jump__c,Days__c,Hours__c,Minutes__c,Task_Title__c,(select id from Attachments),Milestone__c,Time_Bound__c,
                Advanced_Notifications__c,Secoundary_User__c,Manager__c,Info__c,BackOut__c,BackOut_Point__c,Description__c,Execution_Detail__c,Internal_Task__c,Id_After_Decimal__c ,State__c,Id_Before_Decimal__c,Dependency_Image__c,Task_Comments__c,Task_Completed__c,Technical_Detail__c,Technical_Skills__c,
                (select id,Type__c,Dependent_Type__c,Dep_Type__c ,Preceeding_Task__r.Status__c,Preceeding_Task__r.ID_Text__c,Preceeding_Task__r.State__c,Preceeding_Task__r.Task_Title__c,Preceeding_SOE__r.SOE_Title__c,SOE__r.SOE_Title__c  from Dependencies__r order by Preceeding_Task__r.ID_Text__c) 
                from Task__C where SOE__c =: FromStackMap.get(FromStack).SOE__c and Stage_Level__c = : FromStackMap.get(FromStack).Stage_Level__c and Id_Before_Decimal__c =: FromStackMap.get(FromStack).Id_Before_Decimal__c and Is_Stack__c = false order by Id_Before_Decimal__c,Id_After_Decimal__c asc ];
                integer last ;        
                if(index+PageSize > TaskList1.Size())
                    last = TaskList1.Size() ;
                else
                    last = index + PageSize;
                for(Integer i=index ; i< last ;i++)
                    TaskList.add(TaskList1[i]); 
            }
            ListSize = totalRecs ;
            TaskWithWrapper(TaskList);
            getprev();
            getnxt();
        }
        }
    }
    public List<selectOption> getFromStackList() {
        List<selectOption> StackOptions = new List<selectOption>(); 
        for(Task__c t : StackList  )
            StackOptions.add(new selectOption(String.valueOF(t.ID_Text__c),String.valueOF(t.Id_Before_Decimal__c)+'-'+t.Task_Title__c));
        return StackOptions;
    }
    public List<selectOption> getToStackList() {
        List<selectOption> StackOptions = new List<selectOption>(); 
        for(Task__c t : StackList  )
            StackOptions.add(new selectOption(String.valueOF(t.ID_Text__c),String.valueOF(t.Id_Before_Decimal__c)+'-'+t.Task_Title__c));
        return StackOptions;
    }
    public List<selectOption> getTasks() {
        errorbool = false; errmsg = null;
        decimal Stack =decimal.valueof(ToStack);
        ToStackTaskMap = new Map<string,Task__c>();
        List<selectOption> taskOptions = new List<selectOption>();
        if(Task_Accessible)
            ToStackTaskList = [select id,Dependency_Type__c,Status__c ,ID_Text__c,Link__c,Stage_Level__c ,Task_Title__c,Stage__c,Id_Before_Decimal__c,Id_After_Decimal__c from Task__c where Id_Before_Decimal__c =: Stack  and SOE__c =:CurTask.SOE__c and Is_Stack__c = false and Stage_Level__c =: CurTask.Stage_Level__c order by Id_After_Decimal__c];
        for(Task__c t: ToStackTaskList )
            ToStackTaskMap.put(t.ID_Text__c, t);
        for(Task__c t: ToStackTaskList ) 
            taskOptions.add(new selectOption(String.valueOF(t.ID_Text__c),String.valueOF(t.ID_Text__c)+': '+t.Task_Title__c));
        return taskOptions;
    }  
    public void FromStackChanged(){
        totalRecs = 0;index =0;pageSize = 5;
        Stack_Status = false;        errorbool = false;        Errorbool1 = False;      errmsg = null;
        for(Task__c tas: StackList){
            if(tas.Id_Text__c == FromStack && tas.Is_Stack__c == true && (tas.Status__c == i8.STATUS_RUNNING || tas.Status__c == i8.STATUS_COMPLETED || tas.Status__c == i8.STATUS_COMP_JUMP||tas.Jump__c == true))
                Stack_Status = true;
        }
        Tasks();     
    } 
    public void ToStackChanged(){
        errorbool1 = false;        errorbool = false;    errmsg = null;
        if(Task_Accessible && Schema.sObjectType.Attachment.isAccessible() && Dep_Access && Utils.isAccessible('i8__SOE__c'))
            TaskList =[select id,SOE__C,Dependency_Type__c,Status__c ,Duration__c,Is_Stack__c,State__c,Stage_Level__c ,ID_Text__c,Link__c,Id_After_Decimal__c,Dependency_Image__c,Stage__c,Team__c ,Owner__c ,End_Stack__c ,Jump__c,Days__c,Hours__c,Minutes__c,Task_Title__c,Id_Before_Decimal__c,(select id from Attachments),(select id,Type__c,Dep_Type__c ,Preceeding_Task__r.Status__c,Dependent_Type__c,Preceeding_Task__r.State__c,Preceeding_Task__r.ID_Text__c,Preceeding_Task__r.Task_Title__c,Preceeding_SOE__r.SOE_Title__c,SOE__r.SOE_Title__c from Dependencies__r order by Preceeding_Task__r.ID_Text__c) from Task__C where SOE__c =: CurTask.SOE__c and Stage_Level__c = : CurTask.Stage_Level__c and Id_Before_Decimal__c =: decimal.valueof(ToStack) and Is_Stack__c = false order by Id_Before_Decimal__c,Id_After_Decimal__c asc];
    }
    public class WrapperTasks{
        public boolean check{get;set;}
        public boolean newTask{get;set;}
        public Task__c task{get;set;}
        public WrapperTasks(boolean b,Task__c t,boolean newtas){
            check = b;
            task =t;
            newTask = newtas;
        }
    }
    public void TaskWithWrapper(list<Task__c> TaskList){
        WrapperList = new List<WrapperTasks>();
        for(Task__c t: TaskList )  {  
            WrapperList.add(new WrapperTasks(false,t,false));
            TaskMap.put(t.id,t);
        } 
    }    
    public void Up_Method() {
        Task1 = null; Task2 = null;errmsg = null;
        If(FromStackMap.get(FromStack).Status__c == i8.STATUS_RUNNING || FromStackMap.get(FromStack).Status__c == i8.STATUS_COMPLETED){
            Errorbool1 = True;
            errormessage1 = System.Label.AddTask004;
        }
        else{
            Savepoint sp = Database.setSavepoint();
            try{
                for(WrapperTasks wp: WrapperList){
                    if(wp.task.Id_Before_Decimal__c == decimal.valueof(IdText) && wp.task.Id_After_Decimal__c  == decimal.valueof(IdText1) )
                        Task1 = wp.task;
                    if(wp.task.Id_Before_Decimal__c == decimal.valueof(IdText) && wp.task.Id_After_Decimal__c == decimal.valueof(IdText1)-1 )
                        Task2 = wp.task;
                }
                if(Task2 == null && Task_Accessible)
                    Task2 = [select id,Id_Text__c,Dependency_Type__c  from Task__c where SOE__c =: Task1.SOE__c and Stage_Level__c =: Task1.Stage_Level__c  and Id_Before_Decimal__c =: TAsk1.Id_Before_Decimal__c  and Id_After_Decimal__c  =: decimal.valueof(IdText1)-1];
                Task1.ID_Text__c = Task2.ID_Text__c;
                Task2.Id_Text__c = IdText+'.'+IdText1;
                LogFactory.info('Edit_STack_Cntrl', 'UP_Method', 'Task1', JSON.serialize(Task2), 'Line - 204');
                LogFactory.info('Edit_STack_Cntrl', 'UP_Method', 'Task2', JSON.serialize(Task2),'Line - 205'); 
                if(Dep_Access && Task_Create_Update_Delete){
                    list<Dependency__c> deplist = [select id,Task__c,Preceeding_Task__c from Dependency__c where Task__c =: TAsk1.Id or Preceeding_Task__c =: Task1.Id];
                    set<Id> TaskIds = new set<Id>();
                    for(Dependency__c dep: Deplist){
                        TaskIds.add(dep.Preceeding_Task__c);
                        TaskIds.add(dep.Task__c);
                    }
                    if(deplist.size()>0 && (Schema.sObjectType.Dependency__C.isDeletable()))        
                        delete deplist;  
                    list<Dependency__c> deplist1 = [select id,Task__c,Preceeding_Task__c  from Dependency__c where Task__c =: TAsk2.Id or Preceeding_Task__c =: Task2.Id];
                    for(Dependency__c dep: Deplist1){
                        TaskIds.add(dep.Preceeding_Task__c);
                         TaskIds.add(dep.Task__c);
                    }
                    if(deplist1.size()>0)
                    if(Schema.sObjectType.Dependency__c.isDeletable())
                        delete deplist1;  
                    Task1.Dependency_Type__c = i8.NODEP;
                    Task1.Link__c = False;
                    Task2.Dependency_Type__c = i8.NODEP;
                    Task2.Link__c = False;
                    if(Utils.isUpdateable('i8__Task__c'))
                        update Task1;
                    if(Utils.isUpdateable('i8__Task__c'))
                        update Task2;
                    TaskIds.add(Task2.Id);
                    Task_TriggerHandler.CalculateDependencyType(TaskIds);
                    Tasks();
                    errorbool = true;
                    errormessage = System.Label.EditStack003;  
                }else LogFactory.debug('Edit_Stack_Cntrl', 'UP_Method', 'Task Info', System.Label.AddTask001 ,'Line - 236');
            }catch(Exception e){
                 Database.rollback(sp);
                 LogFactory.error('Edit_STack_Cntrl', 'UP_Method', '', e.getMessage() + '' + e.getStackTraceString());                  
                 errmsg = e.getMessage();                  
            }
            LogFactory.SaveLog();  
        }
    }
    public void  Down_Method() {
        Task1 = null; Task2 = null;
        If(FromStackMap.get(FromStack).Status__c == i8.STATUS_RUNNING || FromStackMap.get(FromStack).Status__c == i8.STATUS_COMPLETED){
            Errorbool1 = True;
            errormessage1 =System.Label.AddTask004;
        }
        else{
            Savepoint sp = Database.setSavepoint();
            try{
                set<Id> TaskIds = new set<Id>();
                for(WrapperTasks wp: WrapperList){
                    if(wp.task.Id_Before_Decimal__c == decimal.valueof(IdText) && wp.task.Id_After_Decimal__c  == decimal.valueof(IdText1) )
                        Task1 = wp.task;
                    if(wp.task.Id_Before_Decimal__c == decimal.valueof(IdText) && wp.task.Id_After_Decimal__c == decimal.valueof(IdText1)+1 )
                        Task2 = wp.task;
                }
                if(task2 == null && Task_Accessible)
                    Task2 = [select id,Id_Text__c,Dependency_Type__c  from Task__c where SOE__c =: Task1.SOE__c and Stage_Level__c =: Task1.Stage_Level__c  and Id_Before_Decimal__c =: TAsk1.Id_Before_Decimal__c  and Id_After_Decimal__c  =: decimal.valueof(IdText1)+1];
                Task1.ID_Text__c = Task2.ID_Text__c;
                Task2.Id_Text__c = IdText+'.'+IdText1;
                LogFactory.info('Edit_STack_Cntrl', 'Down_Method', 'Task1', JSON.serialize(Task1),'Line - 265'); 
                LogFactory.info('Edit_STack_Cntrl', 'Down_Method', 'Task2', JSON.serialize(Task2), 'Line - 266');
                if(Dep_Access && Task_Create_Update_Delete ){
                    list<Dependency__c> deplist = [select id,Preceeding_Task__c,Task__c from Dependency__c where Task__c =: TAsk1.Id or Preceeding_Task__c =: Task1.Id]; 
                    for(Dependency__c dep: Deplist){
                        TaskIds.add(dep.Preceeding_Task__c);
                        TaskIds.add(dep.Task__c);
                    }
                    if(deplist.size()>0 && (Schema.sObjectType.Dependency__c.isDeletable()))
                        delete deplist;
                    list<Dependency__c> deplist1 = [select id,Preceeding_Task__c,Task__c from Dependency__c where Task__c =: TAsk2.Id or Preceeding_Task__c =: Task2.Id]; 
                    for(Dependency__c dep: Deplist1){
                        TaskIds.add(dep.Preceeding_Task__c);
                        TaskIds.add(dep.Task__c);
                    }           
                    if(deplist1.size()>0 && (Schema.sObjectType.Dependency__c.isDeletable()))            
                        delete deplist1;  
                    Task1.Dependency_Type__c = i8.NODEP;
                    Task1.Link__c = False;
                    Task2.Dependency_Type__c = i8.NODEP;
                    Task2.Link__c = False;
                    if(Utils.isUpdateable('i8__Task__c'))
                        update Task1;
                    if(Utils.isUpdateable('i8__Task__c'))
                        update Task2;
                    Task_TriggerHandler.CalculateDependencyType(TaskIds); 
                    Tasks();
                    errorbool = true;
                    errormessage = System.Label.EditStack004;
                } else LogFactory.debug('Edit_Stack_Cntrl', 'Down_Method', 'Task Info', System.Label.AddTask001 ,'Line - 294');
            } catch(Exception e){
                 Database.rollback(sp);
                 LogFactory.error('Edit_Stack_Cntrl', 'Down_Method', '', e.getMessage() + '' + e.getStackTraceString());                  
                 errmsg = e.getMessage();                  
            } 
            LogFactory.SaveLog(); 
        }
    }    
    public List<selectOption> getRows() {
        List<selectOption> rowOptions = new List<selectOption>();       
        Integer i;
        for (i=1;i<=25;i++)
             rowOptions.add(new selectOption(string.valueof(i),string.valueof(i)));
        return rowOptions;
    } 
    public PageReference Go_method() {
        if(Task_Create_Update_Delete && Dep_Access_Create_Delete && Schema.sObjectType.Attachment.isAccessible() ){
            list<Task__c> copyTaskList = new List<Task__c>();
            list<Task__c> delTaskList = new List<Task__c>();
            list<task__C> movetaskllist = new list<Task__C>();
            list<task__C> TaskDepList = new list<Task__C>();
            list<Dependency__c> DepList = new list<Dependency__c>();
            list<WrapperTasks> WrapperList1 = new list<WrapperTasks>();
            InsertIdList.clear();
            integer count =0;         boolean selected = false;         boolean selected1 = false;
            string selectedTask;
            TaskList.Clear();
            depList.clear();
            errorbool = false;        errorbool1 = false;   errmsg = null;      
            if(selectaction == 'Append'){
                If(FromStackMap.get(FromStack).Status__c == i8.STATUS_RUNNING || FromStackMap.get(FromStack).Status__c == i8.STATUS_COMPLETED || FromStackMap.get(FromStack).Jump__c == true){
                    Errorbool1 = True;
                    errormessage1 = System.Label.AddTask004;
                }
                Else{
                    end();
                    for(integer i=0;i<WrapperList.Size()-1;i++){
                        if(WrapperList[i].newtask == false)
                            WrapperList1.add(new WrapperTasks(false,WrapperList[i].task,false));       
                    }   
                    ListSize = WrapperList1.Size();        
                    for(integer j=0;j<integer.valueof(selectRow);j++){
                        Task__c t = new task__c();
                        t.Days__c =0;
                        t.Hours__c = 0;
                        t.Minutes__c =CurSOE.Task_Late_Threshold_Mins__c  ;
                        WrapperList1.add(new WrapperTasks(false,t,true));          
                    } 
                    WrapperList1.add(new WrapperTasks(false,WrapperList[WrapperList.Size()-1].task,false));
                    ListSize = ListSize +1 ;
                    WrapperList.clear();   
                    Errorbool1 = True;
                    errormessage1 = System.Label.EditStack005;
                    WrapperList.addAll(WrapperList1);
                }
            }
            if(selectaction == 'Delete_Selected'){
                If(FromStackMap.get(FromStack).Status__c == i8.STATUS_RUNNING || FromStackMap.get(FromStack).Status__c == i8.STATUS_COMPLETED){
                    Errorbool1 = True;
                    errormessage1 = System.Label.AddTask004;
                }
                Else{
                        for (WrapperTasks wt: WrapperList) {
                            if(wt.check == true)                       
                                delTaskList.add(wt.task);
                        }
                        if(delTaskList.size()==0){
                            errorbool1 = true;
                            errormessage1 = System.Label.EditStack006;
                            errorbool = false;
                        }
                        if(delTaskList.size()>0 && ListSize-1 == delTaskList.size()) {
                            errorbool1 = true;
                            errormessage1 = System.Label.EditStack007;
                            errorbool = false;
                        }
                        else{                                    
                            if(Schema.sObjectTYpe.Task__c.isDeletable())
                                delete delTaskList; 
                            Task_TriggerHandler.UpdateAllTAsks(new list<id>{CurSOE.Id},i8.CONTEXT_IMP); 
                            Tasks();
                        }
                    }
            }  
            if(selectaction == 'Copy_Selected' || selectaction =='Move_Selected'){
                    delTaskList.clear();
                    integer count1=0;
                    for (integer i=0; i< WrapperList.size();i++) {
                        if(WrapperList[i].check == true){ 
                            selected = true;  
                            count1++;
                        }
                        if(WrapperList[i].task.Dependency_Type__c == i8.INTERNALDEP && selectaction == 'Move_Selected' && WrapperList[i].check == true ){
                            selected1 = true;
                        }
                    }
                    if (selected == false){
                        errorbool1 = true;
                        if(selectaction == 'Copy_Selected')
                            errormessage1 = System.Label.EditStack006; 
                        else
                            errormessage1 = System.Label.EditStack006; 
                        errorbool = false;
                    }
                    else if(selected1 == true){
                        errorbool1 = true;
                        errormessage1 =System.Label.EditStack008;
                        errorbool = false;
                    }
                    else if(selectaction =='Move_Selected' && Count1 > 0 && Count1 == ListSize -1){
                         errorbool1 = true;
                        errormessage1 = System.Label.EditStack009;
                        errorbool = false;
                    }
                    else If(selectaction =='Move_Selected' && (FromStackMap.get(FromStack).Status__c == i8.STATUS_RUNNING || FromStackMap.get(FromStack).Status__c == i8.STATUS_COMPLETED || FromStackMap.get(FromStack).Status__c == i8.STATUS_COMP_JUMP )){
                        Errorbool1 = True;
                        errormessage1 = System.Label.AddTask004;
                    }
                     else If(selectaction =='Move_Selected' && (FromStackMap.get(ToStack).Status__c == i8.STATUS_RUNNING || FromStackMap.get(ToStack).Status__c == i8.STATUS_COMPLETED || FromStackMap.get(ToStack).Status__c == i8.STATUS_COMP_JUMP ||FromStackMap.get(ToStack).Jump__c == true )){
                        Errorbool1 = True;
                        errormessage1 = System.Label.CloneTask003;
                    }
                    Else If(selectaction =='Copy_Selected' && (FromStackMap.get(ToStack).Status__c == i8.STATUS_RUNNING || FromStackMap.get(ToStack).Status__c == i8.STATUS_COMPLETED || FromStackMap.get(ToStack).Status__c == i8.STATUS_COMP_JUMP ||FromStackMap.get(ToStack).Jump__c == true)){
                        Errorbool1 = True;
                        errormessage1 = System.Label.CloneTask003;
                    }                
                    else{
                        SavePoint sp = Database.setSavePoint();
                        try{
                            if(Selecttask == '-None-')
                                selectedTask = string.valueof(decimal.valueof(toStack)+0.1);
                            else
                                selectedTask = Selecttask;
                            list<string> StrSplit = selectedTask.split('\\.');
                            // To break Link if destination task has it.
                            Task__c Task = ToStackTaskMap.get(selectedTask);
                            LogFactory.info('Edit_Stack_Cntrl', 'Go_Method', 'To Task', JSON.serialize(Task),'Line - 431'); 
                                If(task.Link__c == True){
                                    task.Link__c = False;
                                If(task.Dependency_Type__c == i8.LINKDEP)
                                    task.Dependency_Type__c = i8.NODEP;                       
                                if(Schema.sObjectType.Task__c.isUpdateable())
                                    Update Task;
                                Task = [Select id from Task__c where SOE__c =: CurTask.SOE__c and Stage_Level__c = : CurTask.Stage_Level__c and Id_Text__c =: ToStackTaskMap.get(selectedTask).Id_Text__c];
                                Task__c Task1 = [Select id from Task__c where SOE__c =: CurTask.SOE__c and Stage_Level__c = : CurTask.Stage_Level__c and Id_Before_Decimal__c =: decimal.valueof(ToStack) and Id_After_Decimal__c =: ToStackTaskMap.get(selectedTask).Id_After_Decimal__c-1];
                                list<Dependency__c> Link_deplist = [select id,Task__c,Preceeding_Task__c from Dependency__c where Task__c =: TAsk.Id and Preceeding_Task__c =: Task1.Id];
                                set<Id> TaskIds = new set<Id>();
                                for(Dependency__c dep: Link_Deplist){
                                    TaskIds.add(dep.Preceeding_Task__c);
                                    TaskIds.add(dep.Task__c);
                                }
                                if(Schema.sObjectTYpe.Dependency__c.isDeletable())
                                    delete Link_deplist;  
                                list<Dependency__c> Link_deplist1 = [select id,Task__c,Preceeding_Task__c  from Dependency__c where Task__c =: TAsk1.Id and Preceeding_Task__c =: Task.Id];
                                for(Dependency__c dep: Link_Deplist1){
                                    TaskIds.add(dep.Preceeding_Task__c);
                                     TaskIds.add(dep.Task__c);
                                }
                                if(Link_deplist1.size()>0&& Schema.sObjectTYpe.Dependency__c.isDeletable() )
                                    delete Link_deplist1;  
                            }
                            for (integer i=0; i< WrapperList.size();i++){
                                if(WrapperList[i].check == true){
                                    delTaskList.add(WrapperList[i].task);
                                    task__c t= WrapperList[i].task.clone();
                                    t.Status__c = i8.STATUS_BUILD;
                                    t.Stage__c = ToStackTaskMap.get(selectedTask ).Stage__c;
                                    t.Stage_Level__c = ToStackTaskMap.get(selectedTask ).Stage_Level__c;
                                    t.Id_Text__c = string.valueof(decimal.valueof(StrSplit[0]) ) + '.'+String.valueof(decimal.valueof (StrSplit[1]) +count);
                                    if( selectaction == 'Copy_Selected'){
                                        t.Link__c = false;
                                        t.Dependency_Type__c = i8.NODEP;
                                        t.Internal_Task__c = false ;
                                    }
                                    if(WrapperList[i].task.Link__c == true && selectaction == 'Move_Selected'){
                                        t.Link__c = false;
                                        t.Dependency_Type__c = i8.NODEP;
                                    }
                                    if(WrapperList[i].task.Dependency_Type__c == i8.EXTERNALDEP && selectaction == 'Move_Selected'){
                                        t.Dependency_Type__c = i8.EXTERNALDEP;
                                        ExternalIdList.add( WrapperList[i].task.Id );
                                    }                            
                                    copyTaskList.add(t);
                                    count++;
                                }
                            }
                            if(Utils.isCreateable('i8__Task__c'))
                                insert copyTaskList;
                            TaskUpdList.clear();
                            for(Task__c tas: ToStackTaskMap.values()){
                                if(tas.Id_Before_decimal__c == Decimal.valueOf(StrSplit[0]) && tas.ID_After_Decimal__c >= Decimal.valueOf(StrSplit[1])){
                                    tas.Id_Text__c = string.valueof(decimal.valueof(StrSplit[0]))  + '.'+String.valueof(tas.Id_After_Decimal__C + count);
                                    TaskUpdList.add(tas);
                                }
                            }
                            if(Utils.isUpdateable('i8__Task__c'))
                                update TaskUpdList;
                            Tasks(); 
                            errorbool = true;
                            errormessage = System.Label.EditStack010;
                            errorbool1  = false;
                            if(selectaction =='Move_Selected' && delTaskList.size()>0){
                                set<Id> PreceedingTaskIds = new set<Id>();
                                list<Task__c> PreceedingTaskList = new list<Task__c>();
                                if(InsertIdList.size()>0){
                                    TaskUpdList.clear();
                                    TaskUpdList=[select id,SOE__C,Is_Stack__c,Stage_Level__c ,Status__c ,State__c,ID_Text__c,Link__c,Id_After_Decimal__c,Dependency_Image__c,(select id,Task__c,Preceeding_Task__c,Dep_type__c,Type__c,Dependent_Type__c,Preceeding_Task__r.ID_Text__c,Preceeding_Task__r.Task_Title__c,Preceeding_SOE__r.SOE_Title__c,SOE__r.SOE_Title__c,Preceeding_Task__r.State__c from Dependencies__r ),Stage__c,Team__c ,Owner__c ,Jump__c,Days__c,Hours__c,Minutes__c,Task_Title__c,Id_Before_Decimal__c,(select id from Attachments)  from Task__C where SOE__c =: CurTask.SOE__c and Stage_Level__c = : CurTask.Stage_Level__c and Id_Before_Decimal__c =: decimal.valueof(ToStack) and Is_Stack__c = false order by Id_Before_Decimal__c,Id_After_Decimal__c asc];
                                    InsertDependency(InsertIdList,TaskUpdList);
                                }
                                if(ExternalIdList.size()>0){
                                    TaskDepList = [select id,Status__c ,Task_Title__c,SOE__c,(select id,Task__c,SOE__c,Dependent_Type__c,Preceeding_Task__c,Preceeding_SOE__c,Type__c,Dep_Type__c  from Dependencies__r where Dep_Type__c =: i8.EXTERNALDEP and Dependent_Type__c =: i8.PREDECESSOR) from Task__c where id IN: ExternalIdList];
                                    for(Task__c t1: TaskDepList){
                                        for(Dependency__c dep: t1.dependencies__r){
                                            for(Task__c t2: CopyTaskList){
                                                if(t1.task_Title__c == t2.Task_Title__c){
                                                    PreceedingTaskIds.add(dep.Preceeding_Task__c);
                                                    Dependency__c dep1 = new Dependency__c();
                                                    dep1.Task__c = t2.Id;
                                                    dep1.SOE__c = t2.SOE__c;
                                                    dep1.Preceeding_Task__c = dep.Preceeding_Task__c;
                                                    dep1.Preceeding_SOE__c = dep.Preceeding_SOE__c;
                                                    dep1.Type__c = dep.Type__c;
                                                    dep1.Dep_Type__c  = dep.Dep_Type__c  ;
                                                    dep1.Dependent_Type__c = i8.PREDECESSOR;
                                                    DepList.add(dep1);
                                                    Dependency__c dep2 = new Dependency__c();
                                                    dep2.Task__c = dep.Preceeding_Task__c;
                                                    dep2.SOE__c = dep.Preceeding_SOE__c;
                                                    dep2.Preceeding_Task__c = t2.Id;
                                                    dep2.Preceeding_SOE__c = t2.SOE__c;
                                                    dep2.Type__c = dep.Type__c;
                                                    dep2.Dep_Type__c  = dep.Dep_Type__c  ;
                                                    dep2.Dependent_Type__c = i8.SUCCESSOR;
                                                    DepList.add(dep2);                                            
                                                }
                                            }
                                        }
                                    }
                                }
                                if(Schema.sObjectTYpe.Task__c.isDeletable())                       
                                    delete delTaskList;
                                if(DepList.size()>0){
                                    if(Utils.isCreateable('i8__Dependency__c'))
                                        insert DepList;
                                    if(Utils.isUpdateable('i8__SOE__c'))
                                        update CurSOE;
                                }
                                for(Task__c t: [select id,Dependency_Type__c from Task__c where id IN: PreceedingTaskIds ]){
                                    t.Dependency_Type__c = i8.EXTERNALDEP;
                                    PreceedingTaskList.add(t);
                                }
                                if(PreceedingTaskList.size()>0 && Utils.isUpdateable('i8__Task__c'))
                                        update PreceedingTaskList;
                                Task_TriggerHandler.UpdateAllTAsks(new list<id>{CurSOE.Id},i8.CONTEXT_IMP);                        
                                Tasks();
                                errorbool = true;
                                errormessage = System.Label.EditStack010;
                                errorbool1 = false;
                            }
                        } Catch ( Exception e){
                            Database.RollBack(sp);                        
                            LogFactory.error('Edit_Stack_Cntrl', 'Go_Method', '', e.getMessage() + '' + e.getStackTraceString()); 
                            errmsg = e.getMessage();
                        }
                       
                    }
            }
        } else { errmsg = System.Label.AddTask001 ; LogFactory.debug('Edit_Stack_Cntrl', 'Go_Method', 'Task Info', System.Label.AddTask001 ,'Line - 562');}
         LOgFactory.SaveLog();
        SelectAll = false;
        return null;
    }    
    public PageReference Apply_action() {
        errorbool1 = false;        errorbool = false; errmsg = null;  InsertIdList.clear();
        if(Task_Create_Update_Delete && Dep_Access_Create_Delete ){
            If(FromStackMap.get(FromStack).Status__c == i8.STATUS_RUNNING || FromStackMap.get(FromStack).Status__c == i8.STATUS_COMPLETED){
                Errorbool1 = True;
                errormessage1 = System.Label.AddTask004;
            }
            Else{
                SavePOint sp = Database.setSavePoint();
                try{
                    list<Task__c> TaskDupList1 = new List<Task__c>();
                    List<Id> LinkInternalIdList = new list<Id>();
                    Set<Id> DeleteIdList = new set<Id>(); 
                    list<WrapperTasks> WrapperList1 = new list<WrapperTasks>();
                    Integer j=0;
                    for (integer i=0; i<WrapperList.size();i++){
                        if(WrapperList[i].task.Task_Title__c ==null || WrapperList[i].task.Task_Title__c == ''){
                            errorbool1 = false;
                            errmsg = System.Label.AddTask005;
                            errorbool = false;
                            return null;
                        }
                    }
                    for (integer i=0; i<WrapperList.size();i++){
                        if(WrapperList[i].task.Task_Title__c !=null && WrapperList[i].newtask == true)
                            WrapperList1.add(WrapperList[i]);
                        if(WrapperList[i].task.Task_Title__c !=null && WrapperList[i].newtask == false)
                            WrapperList1.add(WrapperList[i]);
                    }
                    for (integer i=0; i<WrapperList1.size();i++){
                        if(WrapperList1[i].task.Minutes__c == null)
                            WrapperList1[i].task.Minutes__c =0;
                        if(WrapperList1[i].task.Hours__c== null)
                            WrapperList1[i].task.Hours__c=0;
                        if(WrapperList1[i].task.Days__c== null)
                            WrapperList1[i].task.Days__c=0;
                        if( WrapperList1[i].task.Minutes__c > 59){
                            errorbool1 = true;
                            errormessage1 = System.Label.EditStack001;
                            errorbool = false;
                            return null;
                        }
                        if( WrapperList1[i].task.Hours__c> 23){
                            errorbool1 = true;
                            errormessage1 = System.Label.EditStack002;
                            errorbool = false;
                            return null;
                        }
                        if(WrapperList1[i].newtask==true){
                            WrapperList1[i].task.SOE__c = CurTask.SOE__c;
                            WrapperList1[i].task.Stage_Level__c= CurTask.Stage_Level__c; 
                            WrapperList1[i].task.Stage__c = FromStackMap.get(FromStack).Stage__c;    
                            WrapperList1[i].task.Status__c=i8.STATUS_BUILD; 
                            WrapperList1[i].task.Sum_mins__c = WrapperList1[i].task.Minutes__c;
                            WrapperList1[i].task.Sum_Hours__c = WrapperList1[i].task.Hours__c;
                            WrapperList1[i].task.Sum_Days__c = WrapperList1[i].task.Days__c;
                            WrapperList1[i].task.Id_text__c = string.valueof(WrapperList1[WrapperList1.size()-1].task.Id_Before_Decimal__c)+'.'+string.valueof(totalRecs+j); 
                            j++; 
                            WrapperList1[i].task.Link__c = true;
                            WrapperList1[i].task.Dependency_Type__c = i8.LINKDEP;
                            InsertIdList.add(WrapperList1[i].task.Id_text__c);
                        }
                        if(i==WrapperList1.size()-1  &&  WrapperList1[i].task.End_Stack__c == true)
                            WrapperList1[i].task.Id_text__c = string.valueof(WrapperList1[WrapperList1.size()-1].task.Id_Before_Decimal__c)+'.'+string.valueof(totalRecs+j);
                        if(WrapperList1[i].task.Jump__c == true )
                            WrapperList1[i].task.Status__c = WrapperList1[i].task.Status__c + i8.JUMP;               
                        if(WrapperList1[i].newtask == false){                
                            Task__c curTask;
                            Task__c PrevTask;
                            Map<Id, Dependency__c> PreceedingMap = new Map<Id,Dependency__c>();
                            if(WrapperList1[i].task.Link__c == true && WrapperList1[i].task.Dependency_Type__c !=i8.INTERNALDEP){
                                boolean dep1 = false;
                                for(Dependency__c dep: WrapperList1[i].task.Dependencies__r){    
                                    if(dep.Dep_type__c == i8.LINKDEP && dep.Dependent_Type__c == i8.PREDECESSOR)
                                        dep1 = true;
                                }
                                if(dep1 == false)
                                    insertidList.add(WrapperList1[i].task.Id_Text__c);
                            }
                            else if(WrapperList1[i].task.Link__c == true && WrapperList1[i].task.Dependency_Type__c == i8.INTERNALDEP){
                                curTask = TaskMap.get(WrapperList1[i].task.Id);
                                for(Dependency__c dep : CurTask.Dependencies__r){
                                    if(dep.Dep_type__c == i8.INTERNALDEP && dep.Dependent_Type__c == i8.PREDECESSOR)
                                        PreceedingMap.put(dep.Preceeding_task__c,dep);
                                }
                                for(Task__c tas : TaskMap.values()){
                                    if(tas.Id_Text__c == string.valueof(CurTask.Id_Before_Decimal__c +'.'+(CurTask.Id_After_Decimal__c -1)))
                                        PrevTAsk = TaskMap.get(tas.ID);
                                }                        
                                if(PreceedingMap.containskey(PrevTAsk.Id))
                                    LinkInternalIdList.add(WrapperList1[i].task.Id);
                                else{
                                    boolean dep1 = false;
                                    for(Dependency__c dep: WrapperList1[i].task.Dependencies__r){    
                                        if(dep.Dep_type__c == i8.LINKDEP)
                                            dep1 = true;
                                    }
                                    if(dep1 == false)
                                        insertidList.add(CurTask.Id_Text__c);                             
                                }
                            }
                            else if(WrapperList1[i].task.Link__c == false){
                                for(Dependency__c dep: WrapperList1[i].task.Dependencies__r){    
                                    if(dep.Dep_type__c == i8.LINKDEP)
                                        DeleteIdList.add(WrapperList1[i].task.Id);
                                }
                            }
                        }
                        TaskDupList1.add(WrapperList1[i].task); 
                    }            
                    //to link the tasks that are already having internal dependency
                    if(LinkInternalIdList.size()>0){
                        list<Task__c> CurTaskList = new list<Task__c>();
                        list<Task__c> PrevTaskList = new list<Task__c>();
                        map<id,decimal> CurIdBeforeMap = new map<id,decimal>();
                        map<id,decimal> CurIdAfterMap = new map<id,decimal>();            
                        CurTaskList = [select id,ID_Text__c,Status__c ,Id_Before_Decimal__c,Id_After_Decimal__c,Stage_Level__c,SOE__c,Link__c from Task__C where Id IN: LinkInternalIdList];
                        for(Task__C t: CurTaskList){
                            CurIdBeforeMap.put(t.Id,t.Id_Before_Decimal__c);
                            CurIdAfterMap.put(t.Id,t.Id_After_Decimal__c-1);
                        }
                        PrevTaskList = [select id,Link__c ,Stage_Level__c,ID_Text__c,Task_Title__c,Dependency_Type__c,Dependency_Image__c,SOE__c,Is_Stack__c,State__c,Id_Before_Decimal__c,Id_After_Decimal__c from Task__c where Id_Before_Decimal__c IN: CurIdBeforeMap.values() and Id_After_Decimal__c IN: CurIdAfterMap.values() and SOE__c =: CurTaskList[0].SOE__c and Stage_Level__c =: CurTaskList[0].Stage_Level__c];
                        list<Dependency__c> deplist1 = [select id from Dependency__c where Task__c IN: CurTaskList and Preceeding_Task__c IN: PrevTaskList  and dep_type__c =: i8.INTERNALDEP];
                        list<Dependency__c> deplist2 = [select id from Dependency__c where Task__c IN: PrevTaskList  and Preceeding_Task__c IN: CurTaskList  and dep_type__c =: i8.INTERNALDEP];
                        if(deplist1.size()>0 && deplist2.size()>0){
                            for(Dependency__c d1:deplist1)
                                d1.Dep_Type__c = i8.LINKDEP;
                            for(Dependency__c d1:deplist2)
                                d1.Dep_Type__c = i8.LINKDEP;
                            for(Task__c t1: CurTaskList ){
                                t1.Link__c = true;
                                t1.Dependency_type__c = i8.LINKDEP;
                            }
                            for(Task__c t1: PrevTaskList )
                                t1.Dependency_Type__c = i8.NODEP;   
                            if(Utils.isUpdateable('i8__Dependency__c')) 
                                update deplist1;
                            if(Utils.isUpdateable('i8__Dependency__c'))
                                update deplist2; 
                        }
                    }
                    // to unlink the tasks that are selected
                    if(DeleteIdList.size()>0){
                        TaskList.clear();
                        list<Dependency__C> DependencyList = new List<Dependency__c>();
                        //for link predecessors          
                        for(Task__c t: [select id,(select id,Preceeding_Task__c from Dependencies__r where Dep_Type__c =: i8.LINKDEP and Dependent_Type__c =: i8.PREDECESSOR )  from Task__c where Id IN: DeleteIdList]){
                            for(Dependency__c dep: t.Dependencies__r){
                                PreceedingTaskIdList.add(dep.Preceeding_Task__c);
                                DependencyList.add(dep);
                            }
                        }
                        if(Schema.sObjectTYpe.Dependency__c.isDeletable())
                            delete DependencyList ;
                        //for link successors
                        DependencyList.clear();
                        for(Task__c t: [select id,(select id from Dependencies__r where Dep_Type__c = 'Link' and Preceeding_Task__c IN : DeleteIdList and  Dependent_Type__c =: i8.SUCCESSOR)  from Task__c where Id IN: PreceedingTaskIdList]){
                            for(Dependency__c dep: t.Dependencies__r)
                                DependencyList.add(dep);
                        }
                        if(Schema.sObjectTYpe.Dependency__c.isDeletable())
                            delete DependencyList ;
                        DeleteIdList.clear();
                    }
                    if(Utils.isCreate_Update('i8__Task__c'))
                        upsert TaskDupList1;
                    set<Id> TAskIdsLIst = new Set<Id>();
                    for(Task__c tas: TaskDupList1)
                        TAskIdsLIst.add(tas.Id);
                    TaskDupList1 = [select id,Id_Text__c,SOE__c,Id_Before_Decimal__c,Id_After_Decimal__c,Stage_Level__c from Task__c where id IN: TAskIdsLIst order by Id_Before_Decimal__c,Id_After_Decimal__c];
                    if(InsertIdList.size() > 0){
                        list<Task__c> TaskList12 = new list<Task__c>();
                        if(TaskDupList1[0].Id_After_Decimal__c != 1)
                            TaskList12.add( [select id,Id_Text__c,SOE__c from Task__c where SOE__c =: TaskDupList1[0].SOE__c and Stage_Level__c = : TaskDupList1[0].Stage_Level__c and Id_Before_Decimal__c =: TaskDupList1[0].Id_Before_Decimal__c and Id_After_Decimal__c =: TaskDupList1[0].Id_After_Decimal__c -1]);
                        TaskList12.addAll(TaskDupList1);
                        InsertDependency(InsertIdList,TaskList12);
                    }
                    Task_TriggerHandler.CalculateDependencyType(TAskIdsLIst); 
                    Task_TriggerHandler.UpdateAllTAsks(new list<id>{CurSOE.Id},i8.CONTEXT_IMP);     
                    Tasks();
                    errorbool = true;
                    errormessage = System.Label.EditStack010;
                    errorbool1 = false;
                    LinkInternalIdList.clear();    
                 }Catch(Exception e){
                     Database.RollBack(Sp);
                     LogFactory.error('Edit_Stack_Cntrl', 'Apply_Method', '', e.getMessage() + ''+ e.getStackTraceString()); 
                     errmsg = e.getMessage();
                 }
                      
            }
        }
        else { errmsg = System.Label.AddTask001; LogFactory.debug('Edit_STack_Cntrl', 'Apply_Method', 'Task Info', System.Label.AddTask001 ,'Line - 759');}
        LogFactory.SaveLog(); 
        return null;
    }
    public PageReference Cancel_action() {
        return new pagereference ('/apex/AllTasks_ClientSide?id='+SOEId );
    }    
    public PageReference openDocuments() {
        return new pagereference('/apex/AddDocument_ClientSide?id='+TaskId+'&page=EditStack');
    }
    public pagereference OpenDependency(){
        return new pagereference('/apex/ManageDependencies_ClientSide?Tid='+TaskRecId+'&page=EditStack');
    }   
    public void InsertDependency(list<string> InsertList, list<task__c> TaskDepList){
        if(Dep_Access_Create_Delete ){
        list<Task__c> UpdTaskList = new list<Task__c>();
        depList.clear();
        SavePOint sp = Database.SetSavePOint();
        try{
            if(InsertList.size()>0){ 
                LogFactory.info('Edit_STack_Cntrl','Insert Dependency','Task Ids ',JSON.Serialize(InsertList), 'Line - 779');           
                for(integer i=0; i< TaskDepList.size();i++){
                   for(string s: InsertList){
                        if(TaskDepList[i].Id_Text__c == s ){
                            Dependency__c dep = new Dependency__c();
                            dep.Dependent_Type__c = i8.PREDECESSOR; 
                            dep.Preceeding_Task__c = TaskDepList[i-1].Id;
                            dep.Preceeding_SOE__c = TaskDepList[i-1].SOE__c;
                            dep.SOE__c =TaskDepList[i].SOE__c;
                            dep.Task__c = TaskDepList[i].Id;
                            dep.Type__c = i8.DEP_FS;
                            dep.Dep_Type__c = i8.LINKDEP;
                            depList.add(dep);
                            Dependency__c dep1 = new Dependency__c();
                            dep1.Dependent_Type__c = i8.SUCCESSOR; 
                            dep1.Preceeding_Task__c = TaskDepList[i].Id;
                            dep1.Preceeding_SOE__c = dep.SOE__c;
                            dep1.SOE__c = dep.Preceeding_SOE__c;
                            dep1.Task__c = TaskDepList[i-1].Id;
                            dep1.Type__c = i8.DEP_FS;
                            dep1.Dep_Type__c = i8.LINKDEP;
                            depList.add(dep1);
                        }
                    }
                }
            }       
            if(depList.size()>0 && Utils.isCreateable('i8__Dependency__c'))
                insert depList;
        } catch(Exception e){
            Database.RollBack(sp);
            LogFactory.error('Edit_STack_Cntrl','Insert Dependency','',e.getMessage() + ''+ e.getStackTraceString());
            errmsg = e.getMessage();
        }
        insertidList.clear();
        }
    }
    public void SelectAllCheckbox(){
        if(SelectAll == true && ListSize > 2){
            for(integer i=0;i< WrapperList.size(); i++){
                if(WrapperList[i].task.status__c != i8.STATUS_COMPLETED && WrapperList[i].task.Jump__c != True && WrapperList[i].task.End_Stack__c == false){
                    WrapperList[i].check = true;
                }
            } 
        }
        else{
            for(integer i=0;i< WrapperList.size() ; i++)
                if(WrapperList[i].check == true)
                    WrapperList[i].check = false;            
        } 
    }
    // pagination
    public void beginning() {
        errorbool1 = false;
        index = 0;
        Tasks();
    }    
    public void previous() {
        errorbool1 = false;
        if(index - pageSize >= 0)
            index = index - pageSize;
        else
            index = 0;    
        Tasks();
    }    
    public void next()  {
        errorbool1 = false;
        index = index + pageSize;
        Tasks();
    }
    public void end() { //user clicked end
        errorbool1 = false;
        if(math.mod(totalRecs,pageSize)==0)
            index= totalrecs -pageSize; 
        else
            index = totalrecs - math.mod(totalRecs,pageSize);
        Tasks();
    }    
    public boolean getprev()  {
        errorbool1 = false;
        if(index == 0)
        return true;
        else
        return false;
    }     
    public boolean getnxt() {
        errorbool1 = false;
        if((index + pageSize) >= totalRecs)
            return true;
        else
            return false;
    }  
    public List<selectOption> getTableRows() {
        List<selectOption> rowOptions = new List<selectOption>();       
        Integer i;
        for (i=5;i<=30;i=i+5)
             rowOptions.add(new selectOption(string.valueof(i),string.valueof(i)));
        return rowOptions;
    }
}