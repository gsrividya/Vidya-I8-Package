/* 
Class Name        : Manage_Dependencies_Cntrl 
Test Class Name   : Test_Manage_Dependency
Purpose/Overview  : To add/delete dependencies to task 
Author            : Purview Ltd.
Code Coverage     : 91 %
Change History    : 

*/
public with sharing class Manage_Dependencies_Cntrl {
    Public String SOEName{get;set;}
    public String selectSOE { get; set; }
    public Task__c taskobj {get;set;}
    public id TaskId{get;set;}
    public list<task__c> TaskList{get;set;}
    public Map<Id,Integer> TotalTaskMap1;
    public Map<Integer,Id> TotalTaskMap2;
    public boolean before{get;set;}
    public boolean after{get;set;}
    public boolean link{get;set;}
    public List<Dependency__c> Dependent_List{get;set;}
    public Id PrevTaskId{get;set;}
    public Id DelDepId{get;set;}
    public string page{get;set;}
    public Id SOEId ;
    Public Id MISID ; 
    public string Context{get;set;}
    public string FromStack{get;set;}
    public string FromTask{get;set;}
    public I8Constants i8{get;set;}
    public boolean errorbool{get;set;}
    public boolean check{get;set;}
    public Task__c Stack;
    Public Map<Id,Id> ImpMgrMap;
    public string ImpMgrMapKey{get;set;}
    public integer totalsize{get;set;}
    public Dependency__c type_dep{get;set;}
    public list<Dependency__c> DepList12 ;
    public string errmsg {get;set;}
    public boolean Task_Dep {get;set;}
    boolean Task_Dep_Access;
    
    public Manage_Dependencies_Cntrl (){
        i8 = new I8Constants();errmsg = null; Task_Dep = false;
        page = ApexPages.currentPage().getParameters().get('page');
        TaskList = new list<Task__c>();
        Dependent_List = new List<Dependency__c>();
        DepList12 = new list<Dependency__c>();
        TotalTaskMap1 = new Map<Id,Integer>();
        TotalTaskMap2 = new Map<Integer,Id>();
        taskid = System.currentPageReference().getParameters().get('TId'); 
        SOEId = ApexPages.CurrentPage().getParameters().get('Id');
        Context = ApexPages.CurrentPage().getParameters().get('context');
        MISID = ApexPages.CurrentPage().getParameters().get('MId');
        Task_Dep_Access = Utils.isAccessible('i8__Task__c');
        if(taskId != null ) 
            InitializeTask(taskId);       
        FromStack= '0';
        FromTask ='0';        
        type_dep = new Dependency__c(type__c ='FS'); 
    }   
    public list<SelectOption> getSOEOPtion(){
        list<SelectOPtion> SOElist = new list<SelectOption>();
        Id soeid1 ;
        if(SOEName == null)
            SOEName ='s';
        String str = '%'+SOEName+'%';
        if(Utils.isAccessible('i8__SOE__c')){
            for(SOE__c SOE : [Select id,Name,SOE_Title__c,Status__c,State__c,QA_Review_Required__c,QA_Review__c,WalkThrough_Required__c,WalkThrough__c,Max_Planned_End__c,
                              Max_Forecast_End__c,Is_Template__c ,Max_End_Time__c,Dealy_Ahead_mins__c  From SOE__c where (status__c =: i8.STATUS_BUILD or 
                              status__c =: i8.STATUS_REVIEW or status__c =: i8.STATUS_SCHEDULED or Status__c =: i8.STATUS_FREEZE) and Is_Template__c =: False 
                              and( name like : str or SOE_Title__c like : str) order by Name desc limit 1000]){
                                  SOElist.add(new selectOption(SOE.id,SOE.Name+':'+SOE.SOE_Title__c));
                                  soeid1 = SOE.Id;
                              }
            if(SOEList.Size() ==1){
                selectSOE = soeid1 ;
                ChangeSOEs();
            }
        }
        return SOEList;
    }
    public void InitializeTask(Id Task_Id){
        Task_Dep  = Utils.isAccess_Update('i8__Task__c') && Utils.isAccess_Create_Update('i8__Dependency__c') && Schema.sObjectType.Dependency__C.isDeletable() ;
        if(Task_Dep_Access ){
            taskobj = [select id,Link__c,Start_Time__c,Stage_Level__c,Dependency_Type__c,ID_Text__c,Task_Title__c,SOE__r.Is_Template__c,Dependency_Image__c,SOE__c,Status__c,Is_Stack__c,State__c,Id_Before_Decimal__c,Id_After_Decimal__c from Task__c where id =: Task_Id];
                selectSOE = taskobj.SOE__c;
            integer count =0;
            list<Task__c>TotalTaskList = [select id,End_Stack__c,status__c,Dependency_Type__c,Stage_Level__c,SOE__c,ID_Text__c,Start_Time__c ,Task_Title__c,Stage__c ,Dependency_Image__c,Is_Stack__c,State__c,Duration__c,End_Time__c,ID_before_decimal__c,ID_After_decimal__c from Task__c 
                             where SOE__c =: taskobj.SOE__c and End_Stack__c = false and Stage_Level__c=: taskObj.Stage_Level__c order by ID_Before_Decimal__c, ID_After_Decimal__c ];
            for(integer i=0;i<TotaltaskList.size();i++){
                if(TotalTaskList[i].Is_Stack__c == true && TotalTaskList[i].Id_Before_Decimal__c == taskobj.Id_Before_Decimal__c)
                    Stack = TotalTaskList[i];
                else if(TotalTaskList[i].Is_Stack__c == false ){
                    TotalTaskMap1.put(TotalTaskList[i].Id,count);
                    TotalTaskMap2.put(count,TotalTaskList[i].Id);
                    count++;
                }    
            }    
            ApexPages.CurrentPage().getParameters().put('TId',Task_Id);
            getTasks();
            TotalTaskList = New List<Task__c>();
        }
        
    }
    public void getTasks(){
        if(Task_Dep_Access ){
        check = false; errmsg = null;
        list<string> IdList = new list<string>();
        TaskList.clear();
        list<Task__c> TaskList1 = new list<Task__c>();
        before = false;
        after = false;
        link = false;
        string DataBase_Query = '';
        if(Context != null)        
            ApexPages.CurrentPage().getParameters().put('TId',FromTask);
        taskid = System.currentPageReference().getParameters().get('Tid'); 
        taskobj =[select id,Link__c,SOE__r.SOE_Title__c,SOE__r.Status__c,SOE__r.Qa_Review_Required__c,SOE__r.QA_Review__c,SOE__r.Walkthrough_Required__c,SOE__r.WalkThrough__c,SOE__r.Is_Template__c,SOE__r.Max_Planned_End__c,SOE__r.Max_End_Time__c,SOE__r.Dealy_Ahead_mins__c
            ,SOE__r.Max_Forecast_End__c,SOE__r.Name,Start_Time__c,Stage_Level__c,Dependency_Type__c,ID_Text__c,Internal_Task__c,Status__c,Task_Title__c,Dependency_Image__c,SOE__c,Stage__c,Is_Stack__c,State__c,Id_Before_Decimal__c,Id_After_Decimal__c from Task__c where id=: taskid];
        if(Stack.Status__c == i8.STATUS_RUNNING || Stack.Status__c == i8.STATUS_COMPLETED || Stack.Status__c == i8.STATUS_COMP_JUMP || Stack.Status__c == i8.STATUS_JUMP || taskobj.SOE__r.Status__c == i8.STATUS_ABANDONED || taskobj.SOE__r.Status__c == i8.STATUS_SUSPENDED || 
        taskobj.SOE__r.Status__c == i8.STATUS_IMPINPROGRESS || taskobj.SOE__r.Status__c == i8.STATUS_IMP_COMP || taskobj.SOE__r.Status__c == i8.STATUS_SOE_COMP || (taskobj.SOE__r.QA_Review_Required__c == true &&  taskobj.SOE__r.QA_Review__c == 'In Progress')|| (taskobj.SOE__r.WalkThrough_Required__c == true && taskobj.SOE__r.WalkThrough__c == 'In Progress')){
            check = true;
        }
        ImpMgrMap = new Map<Id,Id>();
        list<string> RolesLIst = System.Label.Roles_To_Edit_SOE.split(',');
        if(Utils.isAccessible('i8__SOE_Team_Member__c'))
        for( SOE_Team_Member__c imp : [select Id,Name,Team_Member__r.Salesforce_User__c,Access_Level__c  from SOE_Team_Member__c where SOE__c =: taskobj.soe__c  and Access_Level__c != 'Read' and Role__r.Reference_Role__c  IN : RolesLIst])  
                ImpMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
        if(Schema.sObjectType.Profile.isAccessible())
            if([Select Id,Name from Profile where Id=:userInfo.getProfileId()].Name == 'System Administrator')
                 ImpMgrMap.put(userInfo.getUserId(),userInfo.getUserId());
        ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', '');       
        if( TotalTaskMap1.get(taskobj.Id) == 0)
            before = true;
        if( TotalTaskMap1.get(taskobj.Id) == TotaltaskMap1.size()-1)
            after = true;
        if(Utils.isAccessible('i8__Dependency__c') )
            Dependent_List = [Select id,Dependent_Type__c,Dep_Type__c,Preceeding_SOE__c,Preceeding_SOE__r.SOE_Title__c,Preceeding_Task__r.ID_Text__c,Preceeding_Task__r.Task_Title__c,Preceeding_Task__r.Dependency_Type__c,Preceeding_Task__r.State__C,Preceeding_Task__r.Status__c,SOE__c,Task__c,Type__c,Task__r.Link__c from Dependency__c where Task__c =: taskid and Dependent_Type__c =: i8.PREDECESSOR and SOE__c =: taskobj.SOE__c  order by Preceeding_Task__r.ID_Text__c];
        for(Dependency__c dep : Dependent_List )
            IdList.add(dep.Preceeding_Task__r.ID_Text__c+'_'+dep.Preceeding_SOE__c);
        if(SelectSoe == taskobj.SOE__C){
            TaskList.clear();
            for(Task__c tas: [select id,End_Stack__c ,Dependency_Type__c,Stage_Level__c,SOE__c,ID_Text__c,Start_Time__c ,Task_Title__c,Stage__c ,Dependency_Image__c,Is_Stack__c,State__c,Duration__c,End_Time__c,ID_before_decimal__c,ID_After_decimal__c   from Task__c 
                              where SOE__c =: SelectSoe and Stage__c =: taskobj.Stage__c  and Is_Stack__c = false and Stage_Level__c=: taskObj.Stage_Level__c and
                               (status__c =:i8.STATUS_BUILD or status__c =: i8.STATUS_READY or status__c =: i8.STATUS_WAITING or status__c =: i8.STATUS_WAITING_JUMP or Status__c =: i8.STATUS_BUILD_JUMP or Status__c =: i8.STATUS_REVIEW or Status__c =: i8.STATUS_REVIEW_JUMP or Status__c =: i8.STATUS_SCHEDULED or Status__c =: i8.STATUS_SCHEDULED_JUMP or Status__c =: i8.STATUS_FREEZE or Status__c =: i8.STATUS_FREEZE_JUMP) 
                               order by ID_Before_Decimal__c, ID_After_Decimal__c ]){
                                  if(tas.ID_before_decimal__c < taskobj.ID_before_Decimal__c)
                                      TasklIst1.add(tas);
                                  if(tas.ID_before_decimal__c == taskobj.ID_before_Decimal__c && tas.ID_After_decimal__c < taskobj.ID_After_Decimal__c )
                                      TasklIst1.add(tas);
                              }                                  
        }
        else
            TaskList1 = [select id,Dependency_Type__c,End_Stack__c ,Stage_Level__c,SOE__c,ID_Text__c,Start_Time__c ,Task_Title__c,Stage__c ,Dependency_Image__c,Is_Stack__c,State__c,Duration__c,End_Time__c,ID_before_decimal__c,ID_After_decimal__c from Task__c 
                        where SOE__c =: selectSoe and Is_Stack__c = false and Stage_Level__c=: taskObj.Stage_Level__c and
                         (status__c =:i8.STATUS_BUILD or Status__c =: i8.STATUS_BUILD_JUMP or Status__c =: i8.STATUS_REVIEW or Status__c =: i8.STATUS_REVIEW_JUMP or Status__c =: i8.STATUS_SCHEDULED or Status__c =: i8.STATUS_SCHEDULED_JUMP or Status__c =: i8.STATUS_FREEZE or Status__c =: i8.STATUS_FREEZE_JUMP)  
                          order by ID_Before_Decimal__c, ID_After_Decimal__c ]; 
        boolean b;
        If(TaskList1.size() > 1000){
           PrevSize = 0;
            If(More == True){
                PrevSize = Tasksize;
                Tasksize = Tasksize + 1000;
            }
            Else
                Tasksize = 1000;
                If(Tasksize > TaskList1.size())
                    Tasksize = TaskList1.size();
                for(Integer i=PrevSize; i<Tasksize; i++){
                    b= false;
                    for(string s : IdList){
                        if(TaskList1[i].ID_Text__c+'_'+TaskList1[i].SOE__c == s)
                            b = true;
                    }
                    if(b == false)
                        TaskList.add(TaskList1[i]);
                }
        }
        Else
            for(Task__c tas : TaskList1){
                b= false;
                for(string s : IdList){
                    if(tas.ID_Text__c+'_'+tas.SOE__c == s)
                        b = true;
                }
                if(b == false)
                    TaskList.add(tas);
            }
            totalsize = TaskList1.Size();
          TaskList1.clear();
       }
    }
    Public Integer Tasksize{get;set;}
    Public Integer PrevSize{get;set;}
    Boolean More = False;
    Public Void MoreTasks(){
        More = True; errmsg = null;errorbool = false;
        getTasks();
    }
    public void BeforeTask(){
        errorbool=false; errmsg = null;
        id Tas;
        if(Task_Dep_Access ) {
            tas = TotalTaskMap2.get(TotalTaskMap1.get(taskobj.Id)-1) ; 
            ApexPages.CurrentPage().getParameters().put('TId',tas);
            if(Context != null)
                FromTask= tas;
            InitializeTask(tas);
        } else errmsg = System.Label.AddTask001;
    }
    public void AfterTask(){
        errorbool=false; errmsg = null;
        id Tas;
        if(Task_Dep_Access ){
            tas =   TotalTaskMap2.get(TotalTaskMap1.get(taskobj.Id)+1) ;  
            ApexPages.CurrentPage().getParameters().put('TId',tas);
            if(Context != null)
                FromTask= tas;
            InitializeTask(tas);
        }   else errmsg = System.Label.AddTask001;
    }
    public void Save(){
      if(Task_Dep_Access ){
        try{
            errorbool = false; errmsg = null;
            Task_TriggerHandler.UpdateAllTasks(new list<id>{taskobj.SOE__c},i8.CONTEXT_IMP);
            Task_TriggerHandler.UpdateAllTasks(new list<Id>{taskobj.SOE__c},i8.CONTEXT_BO); 
            errorbool = true;       
        }catch(Exception e){
             LogFactory.error('Manage_Dependencies_Cntrl','LinkTask','',e.getMessage()+''+e.getStackTraceString());
             errmsg = e.getMessage();
         }
         LogFactory.SaveLog();
       }else errmsg = System.Label.ADMIN001;  
    }
    public pagereference Cancel(){
        if(page=='EditStack' && Utils.isAccessible('i8__Task__c')){
            Task__c Stack = [select id,Start_Time__c from Task__c where SOE__c = : TaskObj.SOE__c and Stage_Level__c=: taskobj.Stage_Level__c and Id_Before_Decimal__c=: Taskobj.Id_Before_Decimal__c and Is_Stack__c= true ];
            return new PageReference('/apex/EditStack_ClientSide?id='+Stack.Id+'&SId='+TaskObj.SOE__c);
        }
        else if(page=='SOE')
            return new PageReference('/apex/AllTasks_ClientSide?id='+SOEId );
        else if(page=='Modify_Task'){
            if(MISID == null)
                return new PageReference('/apex/ModifyTask_ClientSide?id='+taskid+'&Sid='+SOEId+'&level='+taskobj.Stage_Level__c );
            else
                 return new PageReference('/apex/ModifyTask_ClientSide?id='+taskid+'&MId='+MISID+'&level='+taskobj.Stage_Level__c +'&page=edit'); 
        }
        return null;
    }
    public void LinkTask(){
        errmsg = null; errorbool = false;
        boolean Task_Update = Utils.isUpdateable('i8__Task__c');
        boolean Dep_Update = Utils.isUpdateable('i8__Dependency__c');
        
        if(Task_Dep ){
            Savepoint sp = Database.setSavePOint();
            try{
                list<dependency__c> deplist = new list<dependency__c>();
                Dependency__c dep11 ; 
                Dependency__c dep21 ;
                dep11 = null;
                dep21 = null;
                Task__c PrevTask = [select id,Link__c,Start_Time__c,Stage_Level__c,ID_Text__c,Task_Title__c,Dependency_Type__c,Dependency_Image__c,SOE__c,Is_Stack__c,State__c,Id_Before_Decimal__c,Id_After_Decimal__c,Internal_Task__c from Task__c where Id_Before_Decimal__c =: taskobj.Id_Before_Decimal__c and Id_After_Decimal__c =: taskobj.Id_After_Decimal__c-1 and SOE__c =: taskobj.SOE__c and Stage_Level__c=: taskobj.Stage_Level__c];
                LogFactory.info('Manage_Dependencies_Cntrl','LinkTask','Prev Task',JSON.serialize(PrevTask),'Line - 242');
                list<Dependency__c> deplist1 = [select id,Preceeding_Task__c,dep_type__c,Dependent_Type__c  from Dependency__c where Task__c = :taskobj.id];
                list<Dependency__c> deplist2 = [select id,Preceeding_Task__c,dep_type__c,Dependent_Type__c from Dependency__c where Task__c = :PrevTask.id];
                taskobj.Broken_Task__c = true;  
                for(Integer i=0;i< deplist1.size();i++){
                    if(deplist1[i].Preceeding_Task__c == PrevTask.id && deplist1[i].dep_type__c == i8.INTERNALDEP){
                        dep11= deplist1[i];
                        deplist1.remove(i);
                        break;
                    }
                }
                for(Integer i=0;i< deplist2.size();i++){
                    if(deplist2[i].Preceeding_Task__c == taskobj.id && deplist2[i].dep_type__c == i8.INTERNALDEP){
                        dep21= deplist2[i];
                        depList2.remove(i);
                        break;
                    }
                }
                if(dep11!= null && dep21 != null){
                    dep11.Dep_Type__c = i8.LINKDEP;
                    dep21.Dep_Type__c = i8.LINKDEP;
                    dep11.type__c = type_dep.Type__c;
                    dep21.type__c = type_dep.Type__c;
                    deplist.add(dep11);
                    deplist.add(dep21);
                    if(Dep_Update)
                        update deplist;
                    if(deplist1.size() ==0){
                        taskobj.Dependency_type__c = i8.LINKDEP;
                        taskobj.Link__c = true;
                        taskobj.Internal_Task__c = false; 
                        if(Task_Update )
                            update taskobj;
                    }
                    else{
                        for(Dependency__c dep:deplist1){
                            if(dep.Dep_type__c == i8.EXTERNALDEP ){
                                taskobj.Dependency_type__c = i8.EXTERNALDEP;
                                break;
                            }
                            else if(dep.Dep_type__c == i8.INTERNALDEP){
                                taskobj.Dependency_type__c = i8.INTERNALDEP;
                                break;
                            }
                            else if(dep.Dep_type__c == i8.LINKDEP){
                                taskobj.Dependency_type__c = i8.LINKDEP;
                                taskobj.Link__c = true;
                                break;
                            }
                        }
                        taskobj.Internal_Task__c = false;
                        taskobj.Link__c = true;
                        if(Task_Update )
                            update taskobj; 
                    }
                    if(deplist2.size() ==0){
                        Prevtask.Dependency_type__c = 'None';
                        Prevtask.Internal_Task__c = false;
                        if(Task_Update )
                            update prevtask;
                    }
                    else{
                        for(Dependency__c dep:deplist2){
                            if(dep.dependent_Type__c == i8.PREDECESSOR){
                                if(dep.Dep_type__c == i8.EXTERNALDEP ){
                                    prevTask.Dependency_type__c = i8.EXTERNALDEP;
                                    break;
                                }
                                else if(dep.Dep_type__c == i8.INTERNALDEP){
                                    prevTask.Dependency_type__c = i8.INTERNALDEP;
                                    break;
                                }
                                else if(dep.Dep_type__c == i8.LINKDEP){
                                    prevTask.Dependency_type__c = i8.LINKDEP;
                                    PrevTask.Link__c = true;
                                    break;
                                }
                                else
                                    prevTask.Dependency_type__c = 'None';
                            }        
                        }
                        PrevTAsk.Internal_Task__c = false;
                        if(Task_Update )    
                            update PrevTAsk;
                    }  
                }
                else{
                    Dependency__c dep1 = new Dependency__c();
                    dep1.Dependent_Type__c = i8.PREDECESSOR; 
                    dep1.Preceeding_Task__c = PrevTask.Id;
                    dep1.Preceeding_SOE__c = PrevTask.SOE__c;
                    dep1.SOE__c =taskobj.SOE__c;
                    dep1.Task__c = taskobj.Id;
                    dep1.Type__c =  type_dep.Type__c;
                    dep1.Dep_Type__c = i8.LINKDEP;
                    Dependency__c dep2 = new Dependency__c();
                    dep2.Dependent_Type__c = i8.SUCCESSOR; 
                    dep2.Preceeding_Task__c = taskobj.Id;
                    dep2.Preceeding_SOE__c = taskobj.SOE__c;
                    dep2.SOE__c =PrevTask.SOE__c;
                    dep2.Task__c = PrevTask.Id;
                    dep2.Type__c = type_dep.Type__c;
                    dep2.Dep_Type__c = i8.LINKDEP;
                    if( taskobj.Dependency_Type__c == 'None')
                        taskobj.Dependency_Type__c = i8.LINKDEP;
                    taskobj.Link__c = true;
                    if(Task_Update )
                        update taskobj;
                    list<Dependency__c> InsertDepList = new list<Dependency__c>();
                    InsertDepList.add(dep1);
                    InsertDepList.add(dep2);
                    LogFactory.info('Manage_Dependencies_Cntrl','LinkTask','Predecessor',JSON.serialize(dep1),'Line - 354');
                    LogFactory.info('Manage_Dependencies_Cntrl','LinkTask','Successor',JSON.serialize(dep2),'Line - 355');
                    if(Utils.isCreateable('i8__Dependency__c'))
                        insert InsertDepList;
                }
                ApexPages.CurrentPage().getParameters().put('TId',taskobj.Id);
                getTasks();
             }catch(Exception e){
                 Database.RollBack(sp);
                 LogFactory.error('Manage_Dependencies_Cntrl','LinkTask','',e.getMessage()+''+e.getStackTraceString());
                 errmsg = e.getMessage();
             }
         }else{ errmsg = System.Label.AddTask001;
             LogFactory.debug('Manage_Dependencies_Cntrl', 'LInk Task', 'Task Info', System.Label.AddTask001 ,'Line - 366');      }
         LogFactory.SaveLog();
    }
    public void Add_Dependency(){
        errmsg = null;  errorbool = false;
        boolean Task_Update  = Utils.isUpdateable('i8__Task__c');
        if(Task_Dep){
            SavePOint sp = Database.setSavePOint();
            try{
                integer count;
                Task__c PrevTask = [select id,Link__c,Start_Time__c,Stage_Level__c,status__c,ID_Text__c,Task_Title__c,Dependency_Type__c,Dependency_Image__c,SOE__c,Is_Stack__c,State__c,Id_Before_Decimal__c,Id_After_Decimal__c from Task__c where id=: PrevTaskId];
                LogFactory.info('ManageDependency','Add_Dependency','PrevTask',JSON.Serialize(PrevTask),'Line - 374');
                Dependency__c dep2 = new Dependency__c();
                dep2.Dependent_Type__c = i8.PREDECESSOR; 
                dep2.Preceeding_Task__c = PrevTask.Id;
                dep2.Preceeding_SOE__c = PrevTask.SOE__c;
                dep2.SOE__c =taskobj.SOE__c;
                dep2.Task__c = taskobj.Id;
                dep2.Type__c = type_dep.type__c;
                Dependency__c dep1 = new Dependency__c();
                dep1.Dependent_Type__c = i8.SUCCESSOR; 
                dep1.Preceeding_Task__c = taskobj.Id;
                dep1.Preceeding_SOE__c = taskobj.SOE__c ;
                dep1.SOE__c =PrevTask.SOE__c;
                dep1.Task__c = PrevTask.Id;
                dep1.Type__c = type_dep.type__c;
                if(SelectSOE == taskobj.SOE__C) {
                    if(taskobj.Dependency_Type__c == i8.EXTERNALDEP)
                        taskobj.Dependency_Type__c = i8.EXTERNALDEP;
                    else
                        taskobj.Dependency_Type__c = i8.INTERNALDEP;
                    taskobj.Internal_Task__c = true;         
                    dep2.Dep_Type__c = i8.INTERNALDEP;
                    dep1.Dep_Type__c = i8.INTERNALDEP;
                }
                else {
                    taskobj.Dependency_Type__c = i8.EXTERNALDEP;
                    dep2.Dep_Type__c = i8.EXTERNALDEP;
                    dep1.Dep_Type__c = i8.EXTERNALDEP;
                    dep2.Preceeding_SOE__c = SelectSOE ;
                    dep1.SOE__c= SelectSOE ;
                }
                taskobj.Broken_Task__c = true;
                if(Task_Update )
                    update taskobj;
                if(SelectSOE == taskobj.SOE__C) {
                    if(PrevTask.Dependency_Type__c == i8.EXTERNALDEP)
                        PrevTask.Dependency_Type__c = i8.EXTERNALDEP;
                    else
                        PrevTask.Dependency_Type__c = i8.INTERNALDEP;
                    PrevTask.Internal_Task__c = true;
                }
                else
                    PrevTask.Dependency_Type__c = i8.EXTERNALDEP;  
                if(Task_Update )    
                    update PrevTask;
                list<Dependency__c> InsertDepList = new list<Dependency__c>();
                InsertDepList.add(dep1);
                InsertDepList.add(dep2);
                LogFactory.info('ManageDependency','Add_Dependency','Predecessor',JSON.Serialize(dep2),'Line - 422');
                LogFactory.info('ManageDependency','Add_Dependency','Successor',JSON.Serialize(dep1),'Line - 423');
                if(Utils.isCreateable('i8__Dependency__c'))    
                    insert InsertDepList;            
                ApexPages.CurrentPage().getParameters().put('TId',taskobj.Id);
                getTasks();
             }catch(Exception e){
                 Database.Rollback(sp);
                 LogFactory.error('ManageDependency','Add_Dependency','',e.getMessage()+ ''+ e.getStackTraceString());
                 errmsg = e.getMessage();
             }
         }else{ errmsg = System.Label.AddTask001;
             LogFactory.debug('Manage_Dependencies_Cntrl', 'Add Dependecy', 'Dependency Info', System.Label.AddTask001 ,'Line - 433');      }
         LogFactory.SaveLog();
    }
    public void Delete_Action(){
        errmsg = null;  errorbool = false;
        if(Task_Dep){
            SavePoint sp = Database.SetSavePOint();
            Dependency__c d1 ;
            Task__c tas;
            try{
                for(Dependency__c dep: Dependent_List ){
                    if(dep.Id == DelDepId)
                        d1 = dep;
                }
                tas =[select id,Dependency_Type__c,Start_Time__c,Link__c,SOE__c,Internal_Task__c from Task__C where id=: d1.Preceeding_Task__c];
                LogFactory.info('ManageDependency','Delete_Action','Task',JSON.Serialize(tas),'Line - 448');
                Dependency__c dep1 = [Select id from Dependency__c where Task__c =: d1.Preceeding_Task__c and Dependent_Type__c=:i8.SUCCESSOR and Preceeding_Task__c =: taskobj.Id  ];
                DepList12.clear();
                DepList12.add(d1);
                DepList12.add(dep1);
                LogFactory.info('ManageDependency','Delete_Action','Predessor',JSON.Serialize(d1),'Line - 453');
                LogFactory.info('ManageDependency','Delete_Action','Successor',JSON.Serialize(dep1),'Line - 454');
                if(Schema.SObjectTYpe.Dependency__c.isDeletable())
                    delete DepList12;
                set<Id> TaskIdsList = new set<Id>();
                TaskIdsList.add(taskobj.Id);
                TaskIdsList.add(tas.Id);
                Task_TriggerHandler.CalculateDependencyType(TaskIdsList);
                ApexPages.CurrentPage().getParameters().put('TId',taskobj.Id);
                getTasks();
            }catch(Exception e){
                Database.RollBack(sp);
                LogFactory.error('Manage_Dependencies_Cntrl','Delete_Action','',e.getMessage()+''+e.getStackTraceString());
                errmsg = e.getMessage();
            }
          }else{errmsg = System.Label.AddTask001;
             LogFactory.debug('Manage_Dependencies_Cntrl', 'Delete_Action', 'Dependency Info', System.Label.AddTask001 ,'Line - 468');      }
        LogFactory.SaveLog(); 
    }
    public void UnLinkTask(){
        errmsg = null;   errorbool = false;
        if(Task_Dep){
            SavePOint sp = Database.setSavePoint();
            try{
                Dependency__c d1 ;
                Task__c tas;
                for(Dependency__c dep: Dependent_List ){
                    if(dep.Dep_Type__c == 'Link')
                        d1 = dep;
                }
                tas =[select id,Dependency_Type__c ,Link__c from Task__C where id=: d1.Preceeding_Task__c];
                LogFactory.info('ManageDependency','UnLinkTask','Task',JSON.Serialize(tas),'Line - 480');
                Dependency__c dep1 = [Select id from Dependency__c where Task__c =: d1.Preceeding_Task__c and Dependent_Type__c=:i8.SUCCESSOR and Preceeding_Task__c =: taskobj.Id and SOE__c=:taskobj.SOE__c ];
                if(taskobj.Dependency_Type__c == i8.INTERNALDEP) {
                    taskobj.Dependency_Type__c = i8.INTERNALDEP;
                    taskobj.Link__c = false;
                }
                else if(taskobj.Dependency_Type__c == i8.EXTERNALDEP) {
                    taskobj.Dependency_Type__c = i8.EXTERNALDEP;
                    taskobj.Link__c = false;
                }
                else {
                    taskobj.Dependency_Type__c = 'None';
                    taskobj.Link__c = false;
                    taskobj.Broken_Task__c = false;
                }
                if(Utils.isUpdateable('i8__Task__c'))
                    update taskobj;
                DepList12.clear();
                DepList12.add(d1);
                DepList12.add(dep1);
                LogFactory.info('ManageDependency','UnLinkTask','Predecessor',JSON.Serialize(d1),'Line - 500');
                LogFactory.info('ManageDependency','UnLinkTask','Successor',JSON.Serialize(dep1),'Line - 501');
                if(Schema.SObjectTYpe.Dependency__c.isDeletable())
                    delete DepList12;
                ApexPages.CurrentPage().getParameters().put('TId',taskobj.Id);
                getTasks();
            }catch(Exception e){
                Database.RollBack(sp);
                LogFactory.error('Manage_Dependencies_Cntrl','UnKInkTask','',e.getMessage()+''+e.getStackTraceString());
                errmsg = e.getMessage();
            }
        } else{ errmsg = System.Label.AddTask001;
             LogFactory.debug('Manage_Dependencies_Cntrl', 'UnlinkTask', 'Dependency Info', System.Label.AddTask001 ,'Line - 513');      }
        LogFactory.SaveLog();
    }
    public void DeleteDependency(){
        errmsg = null;  errorbool = false;
        if(Task_Dep){
            SavePOint sp = Database.setSavePOint();
            try{
                Map<Id,Id> SucDelMap = new Map<ID,Id>();
                list<Task__c> UpdateTaskList = new list<Task__c>();
                Task__c tas;
                Map<Id,Task__c> TaskdelMap = new Map<Id,Task__C>();
                for(Dependency__c dep: Dependent_List)
                    SucDelMap.put(dep.Preceeding_Task__c,dep.Task__c);            
                for(Dependency__c d1 : [Select id,Preceeding_Task__c,Task__c from Dependency__c where Task__c IN: SucDelMap.keyset() and Preceeding_Task__c IN: SucDelMap.values() and Dependent_Type__c=:i8.SUCCESSOR   order by Preceeding_Task__r.ID_Text__c]){
                    if(d1.Preceeding_Task__c == SucDelMap.get(d1.Task__c))
                        Dependent_List.add(d1);
                }
                if(Dependent_List.size()>0 && Schema.SObjectTYpe.Dependency__c.isDeletable()) 
                        delete Dependent_List; 
                set<Id> DepeIds = new set<ID>();
                DepeIds.addAll(SucDelMap.keyset());
                DepeIds.add(taskobj.Id);
                Task_TriggerHandler.CalculateDependencyType(DepeIds);
                ApexPages.CurrentPage().getParameters().put('TId',taskobj.Id);
                getTasks();
            }catch(EXception e){
                Database.RollBack(sp);
                LogFactory.error('Manage_Dependencies_Cntrl','DeleteDependency','',e.getMessage()+''+e.getStackTraceString());
                errmsg = e.getMessage();
            }
         }else{errmsg = System.Label.AddTask001;
             LogFactory.debug('Manage_Dependencies_Cntrl', 'DeleteDependency', 'Dependency Info', System.Label.AddTask001 ,'Line - 547');      }
        LogFactory.SaveLog();
    }   
    public void ChangeSOEs(){
        if(Task_Dep  ){
            ApexPages.CurrentPage().getParameters().put('TId',taskobj.Id);
            if(Context != null)
                FromTask= taskobj.Id;
            getTasks();
        } else errmsg = System.Label.AddTask001;
    }
}