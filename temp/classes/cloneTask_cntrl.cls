/* 
Class Name        : cloneTask_cntrl 
Test Class Name   : Test_CloneTask_Cntrl
Purpose/Overview  : To clone the Task. 
Author            : Purview Ltd.
Code Coverage     : 86%
Change History    : 
*/
public with sharing class cloneTask_cntrl {
    public String Selectedoption { get; set; } 
    public id selectedSourceSOE { get; set; }
    public soe__c soeobj{get;set;}
    public list<task__c> updateTaskList{get;set;}
    public id SOEid{get;set;}
    public I8Constants i8{get;set;}
    public List<SelectOption> SourceSOEList{get;set;}
    Map<Id,SOE__C> soeMap{get;set;}
    public List<SelectOption> SourceStagesList{get;set;}
    public string SourceStage{get;set;}
    public List<SelectOption> TargetStagesList{get;set;}
    public string TargetStage{get;set;}
    public List<SelectOption> SourceTaskList{get;set;}
    public string SourceTask{get;set;}
    public List<SelectOption> TargetTaskList{get;set;}
    public string TargetTask{get;set;}
    public Map<String,list<TAsk__c>> TargetTaskMap{get;set;}
    Public Boolean errorbool{get;set;}
    Public Boolean errorboolean{get;set;}
    public string errmsg{get;set;}
    Public Map<Id,Id> ImpMgrMap{get;set;}
    public string ImpMgrMapKey{get;set;}
    public Task__c taskobj{get;set;}
    public Task__c taskobj1{get;set;}
    
    public cloneTask_cntrl(){
        SOEId = Apexpages.currentpage().getparameters().get('Sid');
        soeobj = new soe__c();
        errorbool = False;
        errorboolean = False;
        if(SOEId != null){
        i8 = new I8Constants();
        Selectedoption ='Below';
        updateTaskList = new list<task__C>();
        TargetTaskMap = new Map<String,list<Task__c>>();
        TargetStagesList = new List<SelectOption>();
        selectedSourceSOE = SOEid;
        getSourceSOEs();
        SOEOBj = SOEMAP.get(SOEID);
        ImpMgrMap = new Map<Id,Id>();
        list<string> RolesLIst = System.Label.Roles_To_Edit_SOE.split(',');
        if(Utils.isAccess_Create_Update('i8__Task__c') ){
        if(Utils.isAccessible('i8__SOE_Team_Member__c'))
            for( SOE_Team_Member__c imp : [select Id,Name,Team_Member__r.Salesforce_User__c,Access_Level__c  from SOE_Team_Member__c where SOE__c =:SOEID  and Access_Level__c != 'Read' and Role__r.Reference_Role__c  IN : RolesLIst ])  
                ImpMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
        if(Schema.SObjectTYpe.Profile.isAccessible())
            if([Select Id,Name from Profile where Id=:userInfo.getProfileId()].Name == 'System Administrator')
                ImpMgrMap.put(userInfo.getUserId(),userInfo.getUserId());
        
        ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', '');       
        taskobj = new Task__c();
        taskobj1 = new Task__c();
        taskobj.Stage_Level__c = taskobj1.Stage_Level__c = i8.CONTEXT_IMP ;
        for(Task__c tas: [select id,name,Task_Title__c,id_text__c,soe__c,Id_After_Decimal__c,Id_Before_Decimal__c,stage__c,Stage_Level__c,Is_Stack__c from task__c where soe__c =:selectedSourceSOE  and Is_Stack__c = false and End_Stack__c = false order by Id_Before_Decimal__c,Id_After_Decimal__c asc]){
            if(!TargetTaskMap.Containskey(tas.Stage__c+'-'+tas.Stage_Level__c))
                TargetTaskMap.put(tas.Stage__c+'-'+tas.Stage_Level__c,new list<Task__c>());
            TargetTaskMap.get(tas.Stage__c+'-'+tas.Stage_Level__c).add(tas);
        }        
        TargetStageList();
        SourceStageList(); 
        }
        else {errorboolean =true;errorbool = true; errmsg = System.Label.ADMIN001; }
        }
    }
    public void getSourceSOEs() {
        SourceSOEList= new list<selectoption>();
        if(Utils.isAccessible('i8__SOE__c'))
            soeMap = new Map<Id,SOE__C>([select id,name,Status__c,QA_Review_Required__c,QA_Review__c,WalkThrough_Required__c,WalkThrough__c,Is_Template__c,SOE_Title__c,BackOut_Stage__c,Pre_Implementation_Stage__c,Post_Implementation_Stage__c from soe__c order by name desc limit 10000]);
        for(soe__c soe : soeMap.values()){
            if(soe.Is_Template__c == false)
                SourceSOEList.add(new selectoption(soe.id,soe.name+':'+soe.SOE_Title__c ));
        }
    }
    public void SourceStageList(){
        Tasksize = 0;
        TargetTaskSize = 0;
        SourceStagesList = new List<SelectOption>();
        SourceStage  = null;
        if(taskobj.Stage_Level__c == i8.CONTEXT_IMP){
            If(soeMap.get(selectedSourceSOE).Pre_Implementation_Stage__c == True){
                SourceStagesList.add(new selectoption(i8.STAGE_PRE,i8.STAGE_PRE));
                SourceStage = i8.STAGE_PRE;
            }
            SourceStagesList.add(new selectoption(i8.STAGE_Imp,i8.STAGE_Imp));
            If(soeMap.get(selectedSourceSOE).Post_Implementation_Stage__c == True){
                SourceStagesList.add(new selectoption(i8.STAGE_Post,i8.STAGE_Post));
            }
            if(soeMap.get(selectedSourceSOE).Pre_Implementation_Stage__c == False){
                SourceStage = i8.STAGE_IMP;
            }
        }else  if(taskobj.Stage_Level__c == i8.CONTEXT_BO && soeMap.get(selectedSourceSOE).Backout_Stage__c  ==true){           
            SourceStagesList.add(new selectoption(i8.STAGE_Imp,i8.STAGE_Imp));
            SourceStage = i8.STAGE_IMP;
            If(soeMap.get(selectedSourceSOE).Post_Implementation_Stage__c == True)
                SourceStagesList.add(new selectoption(i8.STAGE_Post,i8.STAGE_Post));
        }
        getSourceTasks();
    }
    public void TargetStageList(){
        TargetStagesList = new List<SelectOption>();
        TargetStage  = null;
        if(taskobj1.Stage_Level__c == i8.CONTEXT_IMP){
            If(soeMap.get(SOEid).Pre_Implementation_Stage__c == True){
                TargetStagesList.add(new selectoption(i8.STAGE_PRE,i8.STAGE_PRE));
                TargetStage = i8.STAGE_PRE;
            }
            TargetStagesList.add(new selectoption(i8.STAGE_Imp,i8.STAGE_Imp));
            If(soeMap.get(SOEid).Post_Implementation_Stage__c == True){
                TargetStagesList.add(new selectoption(i8.STAGE_Post,i8.STAGE_Post));
            }
            if(soeMap.get(SOEid).Pre_Implementation_Stage__c == False){
                TargetStage = i8.STAGE_IMP;
            }
        }else  if(taskobj1.Stage_Level__c == i8.CONTEXT_BO && soeMap.get(SOEId).Backout_Stage__c  ==true){           
            TargetStagesList.add(new selectoption(i8.STAGE_Imp,i8.STAGE_Imp));
            TargetStage = i8.STAGE_IMP;
            If(soeMap.get(SOEId).Post_Implementation_Stage__c == True)
                TargetStagesList.add(new selectoption(i8.STAGE_Post,i8.STAGE_Post));
        }
        getTargetTasks();
    }
    Integer Tasksize;
    public void getSourceTasks() {
        SourceTaskList = new list<SelectOption>();
        if(selectedSourceSOE != SOEId){
            List<Task__c> TaskList;
            if(Utils.isAccessible('i8__Task__c'))
                TaskLIst = [select id,name,Task_Title__c,id_text__c,soe__c,Id_After_Decimal__c,Id_Before_Decimal__c,stage__c,Is_Stack__c from task__c where soe__c =: selectedSourceSOE
                                      and Stage_Level__c=:taskobj.Stage_Level__c and Is_Stack__c = false and End_Stack__c = false  and Stage__c =: SourceStage order by Id_Before_Decimal__c,Id_After_Decimal__c asc];
            If(TaskList.size() > 1000 && SourceTask != 'more'){
                Tasksize = 1000;
                for(Integer i=0; i<Tasksize; i++)
                    SourceTaskList.add(new selectoption(TaskList[i].id,TaskList[i].id_text__c+':'+TaskList[i].Task_Title__c));            
            }
            Else If(TaskList.size() > 1000 && SourceTask == 'more'){
                Integer Prevsize = Tasksize;
                Tasksize = Tasksize + 1000;
                If(Tasksize > TaskList.size())
                    Tasksize = TaskList.size();
                SourceTask = TaskList[Tasksize - 1].id;
                for(Integer i=Prevsize; i<Tasksize; i++)
                    SourceTaskList.add(new selectoption(TaskList[i].id,TaskList[i].id_text__c+':'+TaskList[i].Task_Title__c));            
            }
            Else{
                for(Task__c tas: TaskList)
                    SourceTaskList.add(new selectoption(tas.id,tas.id_text__c+':'+tas.Task_Title__c));
            }
        }
        else{
            if(SourceStage != null){
                List<Task__c> TaskList = TargetTaskMap.get(SourceStage+'-'+taskobj.Stage_Level__c);
                If(TaskLIst != null && TaskList.size() > 1000 && SourceTask != 'more'){
                    Tasksize = 1000;
                    for(Integer i=0; i<Tasksize; i++)
                        SourceTaskList.add(new selectoption(TaskList[i].id,TaskList[i].id_text__c+':'+TaskList[i].Task_Title__c));            
                }
                Else If(TaskLIst != null && TaskList.size() > 1000 && SourceTask == 'more'){
                    Integer Prevsize = Tasksize;
                    Tasksize = Tasksize + 1000;
                    If(Tasksize > TaskList.size())
                        Tasksize = TaskList.size();
                    SourceTask = TaskList[Tasksize - 1].id;
                    for(Integer i=Prevsize; i<Tasksize; i++)
                        SourceTaskList.add(new selectoption(TaskList[i].id,TaskList[i].id_text__c+':'+TaskList[i].Task_Title__c));            
                }
                Else if(TaskLIst != null){
                    for(task__c tas : TaskList)
                        SourceTaskList.add(new selectoption(tas.id,tas.id_text__c+':'+tas.Task_Title__c));
                }
            }
        }
    }
    Public void ViewMore(){
        If(SourceTask == 'more')
            getSourceTasks();
        If(TargetTask == 'more')
            getTargetTasks();
    }
    Integer TargetTaskSize;
    public void getTargetTasks(){
        TargetTaskList = new list<SelectOption>();
        List<Task__c> TaskList = TargetTaskMap.get(TargetStage+'-'+taskobj1.Stage_Level__c);
        If(TaskList != null && TaskList.size() > 1000 && TargetTask != 'more'){
            TargetTaskSize = 1000;
            for(Integer i=0; i<TargetTaskSize; i++)
                TargetTaskList.add(new selectoption(TaskList[i].id,TaskList[i].id_text__c+':'+TaskList[i].Task_Title__c));            
        }
        Else If(TaskList != null && TaskList.size() > 1000 && TargetTask == 'more'){
            Integer Prevsize = TargetTaskSize;
            TargetTaskSize = TargetTaskSize + 1000;
            If(TargetTaskSize > TaskList.size())
                TargetTaskSize = TaskList.size();
            TargetTask = TaskList[TargetTaskSize - 1].id;
            for(Integer i=Prevsize; i<TargetTaskSize; i++)
                TargetTaskList.add(new selectoption(TaskList[i].id,TaskList[i].id_text__c+':'+TaskList[i].Task_Title__c));            
        }
        Else{
            if(TargetTaskMap.containskey(TargetStage+'-'+taskobj1.Stage_Level__c)){
                for(task__c tas :TargetTaskMap.get(TargetStage+'-'+taskobj1.Stage_Level__c))
                    TargetTaskList.add(new selectoption(tas.id,tas.id_text__c+':'+tas.Task_Title__c));
            }
        }
    }   
    public list<selectoption> getSelectbefore_or_after() {
        list<selectoption> beforafteroptions = new list<selectoption>();
        beforafteroptions.add(new selectoption('Below','Below'));
        beforafteroptions.add(new selectoption('Above','Above'));        
        return beforafteroptions;
    }
    public PageReference clone_task() {
        updateTaskList = new list<task__C>();
        Task__c task,TargetStack;
        if(Utils.isAccess_Create_Update('i8__Task__c') ){
            if(TargetTask != null){
                task = [select id,SOE__c,name,Stage_Level__c,Status__c,id_text__c,Link__c,Dependency_Type__c,Id_Before_Decimal__c,Id_after_decimal__c,Stage__c from task__c where id =: TargetTask];
                TargetStack = [Select id,Status__c,Jump__c from Task__c where Id_Before_Decimal__c =: task.Id_Before_Decimal__c and SOE__c =: task.SOE__c and Stage__c =:task.Stage__c and Stage_Level__c =: task.Stage_Level__c and Is_STack__c = true];
            }
            if(SourceTask == null){
                errorbool = true;
                errmsg = System.Label.CloneTask001;
            }else if(TargetTask == null){
                errorbool = true;
                errmsg = System.Label.CloneTask002;
            }
            else If(TargetStack.Status__c == i8.STATUS_RUNNING || TargetStack.Status__c == I8.STATUS_COMPLETED || TargetStack.Status__c == I8.STATUS_COMP_JUMP || TargetStack.Jump__c == true){
                errorbool = true;
                errmsg = System.Label.CLoneTask003;
            }
            else{
                Savepoint sp = Database.setSavepoint();
                try{                
                    task__c source_task = [select id,name,Stage_Level__c,Task_Title__c,WalkThrough_Comments__c,Team__c,Type__c,Technical_Skills__c,Time_Bound__c,Technical_Detail__c,Status__c,Task_Comments__c,Owner__c,Review_Comments__c,Minutes__c,Is_Stack__c,Jump__c,Jumped_Duration__c,BackOut__c,Execution_Detail__c,Hours__c,Comments__c,Description__c,End_Stack__c,Days__c,BackOut_Point__c,soe__c,stage__c from task__c where id =: SourceTask];
                    LogFactory.info('CloneTask_Cntrl', 'Clone_Task', 'Source Task', JSON.serialize(source_task),'Line - 228');
                    task__c clone_task = new task__c();       
                    clone_task = source_task.clone();       
                    if(Selectedoption == 'Above'){
                        Task__c Above_Task = [Select id from Task__c where SOE__c =: soeobj.ID and Id_after_decimal__c =: Task.Id_after_decimal__c-1 and Id_Before_Decimal__c =: Task.Id_Before_Decimal__c and Stage_Level__c =: TAsk.Stage_Level__c];
                        If(Task.Link__c == True){
                            Task.Link__c = False;
                            If(Task.Dependency_Type__c == I8.LINKDEP)
                                Task.Dependency_Type__c = I8.NODEP;
                            if(Utils.isUpdateable('i8__Task__c'))
                                Update Task;
                            List<Dependency__c> Del_Dep = New List<Dependency__c>();
                            if(Utils.isAccessible('i8__Dependency__c')){
                                Dependency__c Dep = [select id from Dependency__c where Dep_Type__c =: I8.LINKDEP and Dependent_Type__c =: I8.PREDECESSOR and Task__c =: Task.ID and Preceeding_Task__c =: Above_Task.ID];
                                Dependency__c Dep1 = [select id from Dependency__c where Dep_Type__c =: I8.LINKDEP and Dependent_Type__c =: I8.SUCCESSOR and Task__c =: Above_Task.ID and Preceeding_Task__c =: Task.ID];
                                Del_Dep.add(Dep);
                                Del_Dep.add(Dep1);
                                if(Schema.sObjectType.Dependency__c.isDeletable())
                                    Delete Del_Dep;
                            }else
                                 LogFactory.debug('CLoneTask_Cntrl', 'Clone_Task', 'Dependency Info', System.Label.AddTask001 ,'Line - 256');
                        }
                        clone_task.id_text__c =String.ValueOF(Integer.ValueOf(task.Id_Before_Decimal__c))+'.'+(task.Id_after_decimal__c) ;
                    }
                    else if(Selectedoption == 'Below'){
                        Task__c Below_Task = [Select id,Link__c,Dependency_Type__c from Task__c where SOE__c =: soeobj.ID and Id_after_decimal__c =: Task.Id_after_decimal__c+1 and Id_Before_Decimal__c =: Task.Id_Before_Decimal__c and Stage_Level__c =: TAsk.Stage_Level__c];
                        If(Below_Task.Link__c == True){
                            Below_Task.Link__c = False;
                            If(Below_Task.Dependency_Type__c == I8.LINKDEP)
                                Below_Task.Dependency_Type__c = I8.NODEP; 
                            if(Utils.isUpdateable('i8__Task__c'))
                                Update Below_Task;
                            if(Utils.isAccessible('i8__Dependency__c')){
                            List<Dependency__c> Del_Dep = New List<Dependency__c>();
                            Dependency__c Dep = [select id from Dependency__c where Dep_Type__c =: I8.LINKDEP and Dependent_Type__c =: I8.PREDECESSOR and Task__c =: Below_Task.ID and Preceeding_Task__c =: Task.ID];
                            Dependency__c Dep1 = [select id from Dependency__c where Dep_Type__c =: I8.LINKDEP and Dependent_Type__c =: I8.SUCCESSOR and Task__c =: Task.ID and Preceeding_Task__c =: Below_Task.ID];
                            Del_Dep.add(Dep);
                            Del_Dep.add(Dep1);
                            if(Schema.sObjectType.Dependency__c.isDeletable())    
                                Delete Del_Dep;
                            }else
                                 LogFactory.debug('CloneTask_Cntrl', 'Clone_Task', 'Dependency Info', System.Label.AddTask001 ,'Line - 276');
                        }
                        clone_task.id_text__c =String.ValueOF(Integer.ValueOf(task.Id_Before_Decimal__c))+'.'+(task.Id_after_decimal__c+1) ;
                    }       
                    clone_task.SOE__c = SOEid;
                    clone_task.Status__c = 'Build';
                    clone_task.Stage__c = task.Stage__c ;  
                    clone_task.Stage_Level__c = task.Stage_Level__c ;      
                    for(Task__c tas: [select id,ID_Text__c,Id_Before_Decimal__c,Id_After_Decimal__c from Task__c where SOE__c =:SOEid and Id_Before_Decimal__c =: task.Id_Before_Decimal__c and IS_Stack__c = false and Stage_Level__c=: Task.Stage_Level__c]){
                        if(Selectedoption == 'Below'){
                            if(tas.Id_After_Decimal__c.IntValue() >= task.Id_After_Decimal__c+1){
                                tas.ID_Text__c = string.valueof(task.Id_Before_Decimal__c)+'.'+string.valueof(tas.Id_After_Decimal__c+1);                   
                                updateTaskList.add(tas);
                            }
                        }
                        if(Selectedoption == 'Above'){
                            if(tas.Id_After_Decimal__c.IntValue() > task.Id_After_Decimal__c || tas.Id_After_Decimal__c.IntValue() == task.Id_After_Decimal__c ){
                                tas.ID_Text__c = string.valueof(task.Id_Before_Decimal__c)+'.'+string.valueof(tas.Id_After_Decimal__c+1);
                                updateTaskList.add(tas);
                            }
                        }
                    }
                    if(updateTaskList.size()>0 && Utils.isUpdateable('i8__Task__c'))
                            update updateTaskList;     
                    LogFactory.info('CloneTask_Cntrl', 'Clone_Task', 'New Task', JSON.serialize(clone_task),'Line - 300');
                    if(Utils.isCreateable('i8__Task__c'))    
                        insert clone_task;
                    Task_TriggerHandler.UpdateAllTasks(new list<id>{SOEId},i8.CONTEXT_IMP);
                    LogFactory.SaveLog();
                    return new pagereference('/apex/AllTasks_ClientSide?id='+SOEId);
                }
                catch(Exception e){
                    Database.rollback(sp);
                    LogFactory.error('CloneTask_Cntrl', 'Clone_Task', '', e.getMessage() + '' + e.getStackTraceString());  
                    LogFactory.SaveLog();
                    errorbool = true; 
                    errmsg = e.getMessage();                  
                }
            }
        }else{ errorbool = true;  errmsg = System.Label.ADMIN001;   }
        return null;
    }
    public PageReference openCancel () {
    if(SOEId != null){
        return new pagereference('/apex/AllTasks_ClientSide?id='+SOEId);
        }
       return new pagereference('/'); 
    }
}