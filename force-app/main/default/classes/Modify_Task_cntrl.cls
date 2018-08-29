/* 
Class Name        : Modify_Task_cntrl 
Test Class Name   : Test_Modify_Task_cntrl
Purpose/Overview  : To modify the task.
Author            : Purview Ltd.
Code Coverage     : 93%
Change History    : 

*/
public with sharing class Modify_Task_cntrl {
    public String errormessage {get;set;}
    public boolean errorbool { get; set; }
    public string review_comments{get;set;}    
    public boolean before {get; set;}
    public boolean after {get; set;}
    public Id TaskId{get;set;}
    public Task__c CurTask{get;set;}
    public List<Dependency__c> PreDepList{get;set;}
    public List<Dependency__c> SucDepList{get;set;}
    public boolean displayPopup {get; set;}
    public Communication__c com{get;set;}
    public list<Communication__c > ComList;
    public string PageType{get;set;}
    public Map<Id,Integer> TotalTaskMap1;
    public Map<Integer,Id> TotalTaskMap2;
    public list<selectoption> stageList{get;set;}
    public String SelectedStage{get;set;}
    public list<selectoption> StackList{get;set;}
    public String SelectedStack{get;set;}
    public String SelectedTask{get;set;}
    public Id SOEId;
    public SOE__c CurSOE{get;set;}
    public Id ActiveTAskId{get;set;}
    public I8Constants I8{get;set;}
    public Map<Decimal,Task__c> StackFirstMap;
    public Boolean jump{get;set;} 
    public Map<Id,Id> ImpMgrMap{get;set;}
    public string ImpMgrMapKey{get;set;}
    Public Integer CountTask{get;set;}
    public Boolean locked{get;set;}
    public Decimal days,hours,mins;
    public string Level{get;set;}
    public boolean bo;
    public list<string> Members{get;set;}
    public Map<id,Member__c> MemberMap;
    public list<SelectOption> items{get;set;}
    public string active{get;set;}
    public boolean popup{get;set;}
    public Id MISID {get;set;}
    public boolean output{get;set;}
    public set<Id> ImpMgrSet;
    public boolean Task_Update {get;set;}
    public boolean Task_Access;
    public boolean Com_Create {get;set;}
      
    public Modify_Task_cntrl (){
        set<string> Stages;
        I8 = new I8Constants();
        errorbool = false;
        displayPopup = false; errormessage  = null;
        locked = false;
        TotalTaskMap1 = new Map<Id,Integer>();
        TotalTaskMap2 = new Map<Integer,Id>();
        Stages = new set<string>();
        items = new list<SelectOption>();
        stageList = new list<SelectOption>();
        stackList = new list<SelectOption>();
        StackFirstMap = new Map<Decimal,Task__c>();  
        list<Task__c> TotalTaskList; 
        taskobj = new Task__c();
        SOEId = ApexPAges.CurrentPage().getParameters().get('SId');
        MISID = ApexPAges.CurrentPage().getParameters().get('MId');
        Level = ApexPAges.CurrentPage().getParameters().get('level');
        Com_Create  = Utils.isCreate_Update('i8__Communication__c');
        if(SOEId != null && Utils.isAccessible('i8__SOE__c'))
            CurSOE = [select id,Name,Status__c,RAG__c,Imp_Start__c,QA_Review_Required__c,QA_Review__c,WalkThrough_Required__c,WalkThrough__c,SOE_Title__c,State__c,Max_Planned_End__c,Max_Forecast_End__c,Max_End_Time__c,
                Dealy_Ahead_mins__c,Post_Implementation_Stage__c,Pre_Implementation_Stage__c,BackOut_Stage__c from SOE__c where id=:SOEId];
        if(SOEId != null &&((CurSOE.QA_Review_Required__c == true &&  CurSOE.QA_Review__c == 'In Progress')|| (CurSOE.WalkThrough_Required__c == true && CurSOE.WalkThrough__c == 'In Progress')))
            locked = true;        
        ImpMgrSet = new set<Id>();
        
        list<string> RolesLIst = System.Label.Roles_To_Edit_SOE.split(',');
        if(Utils.isAccessible('i8__SOE_Team_Member__c'))
        for( SOE_Team_Member__c imp : [select Id,Name,Team_Member__r.Salesforce_User__c,Access_Level__c  from SOE_Team_Member__c where SOE__c =: SOEId  and Access_Level__c != 'Read' and Role__r.Reference_Role__c IN : RolesLIst ])  
                ImpMgrSet.add(imp.Team_Member__r.Salesforce_User__c);
         if(MISID !=null && Utils.isAccessible('i8__MIS_Manager__c')){
            for(MIS_Manager__c mis: [select id,MIS_Manager__c from MIS_Manager__c where MIS__c =: MISID])
                ImpMgrSet.add(mis.MIS_Manager__c );
        }
        if(Schema.sObjectType.Profile.isAccessible())
            if([Select Id,Name from Profile where Id=:userInfo.getProfileId()].Name == 'System Administrator')
                 ImpMgrSet.add(userInfo.getUserId());
        Task_Access  = Utils.isAccessible('i8__Task__c');       
        if(Task_Access  ){
            Task_Update = Utils.isUpdateable('i8__Task__c'); 
            TotalTaskList = [select id,End_Stack__c,Dependency_Type__c,Jump__c,Status__c,Stage_Level__c,SOE__c,ID_Text__c,Start_Time__c ,Task_Title__c,Stage__c ,Dependency_Image__c,Is_Stack__c,State__c,Duration__c,End_Time__c,ID_before_decimal__c,ID_After_decimal__c   from Task__c 
                             where SOE__c =: SOEId and Stage_Level__c =:Level order by ID_Before_Decimal__c, ID_After_Decimal__c ];
            for(integer i=0;i<TotaltaskList.size();i++){
                if(TotaltaskList[i].Is_Stack__c == true)
                    StackFirstMap.put(TotaltaskList[i].ID_Before_Decimal__c,TotaltaskList[i]);
                TotalTaskMap1.put(TotalTaskList[i].Id,i);
                TotalTaskMap2.put(i,TotalTaskList[i].Id);    
                Stages.add(TotalTaskList[i].Stage__c);
            } 
            stageList.add(new SelectOption('0','--None--'));
            stackList.add(new SelectOption('0','--None--'));
            SelectedStack = '0';
            SelectedStage ='0';       
            PageType = ApexPages.currentPage().getParameters().get('page');
            getTasks();
            TotalTaskList = New List<Task__c>();  
            if( PageType == 'droptask' && Task_Update  && Schema.sObjectType.Task__c.isDeletable()){
                ImpMgrMap = new Map<id,Id>();
                for(Id userid : ImpMgrSet)
                    ImpMgrMap.put(userid,userid);            
                ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', '');
            }
       }else errormessage  = System.Label.AddTask001;  
    }
    public void getTasks(){
        errormessage  = null;
        CurTask = new Task__c();
        before = false;
        after = false;
        jump = false;
        PageType = ApexPages.currentPage().getParameters().get('page');        
        if( PageType != 'droptask')
            TaskId = ApexPages.currentPage().getParameters().get('Id');
        if(TaskId != null && Task_Access && Schema.sObjectType.Attachment.isAccessible() && Utils.isAccessible('i8__Dependency__c')){
            ImpMgrMap = new Map<Id,Id>();
            CurTask = [select id,BO_Process__c,Status__c,RV_Comments__c ,Activated_By__c,Completed_By__c,MI_Keyword__c,Technical_Skills__c,Review_Comments__c,Advanced_Notifications__c,When_Task_Ready__c,Task_Completed__c,Minutes__c ,Dependency_Type__c,Hours__c,Days__c,End_Stack__c ,Task_Title__c,Owner__c,Team__c,Time_Bound__c,Description__c,Technical_Detail__c,Comments__c,
                       State__c,Secoundary_User__c,Manager__c,Info__c,Dependency_Image__c,Milestone__c,Trigger_Comms__c,Jump__c,Jumped_Duration__c,SOE__c,SOE__r.SOE_Title__c,SOE__r.Status__c,SOE__r.QA_Review__c,SOE__r.WalkThrough__c,Stage__c,Stage_Level__c,ID_Text__c,SOE__r.name,Owner__r.Member__r.Salesforce_User__c,
                       Actual_Duration__c,Critical_Path__c,User_Defined_Critical_Path__c,BackOut__c,BackOut_Point__c,Baseline_Start__c, Baseline_End__c, End_Time__c, Start_Time__c,Forecast_Start__c,Forecast_End__c, Actual_Start__c, Actual_End__c,Planned_Start__c,Planned_End__c,
                       Add_Comments__c,LastModifiedBy.Name,LastModifiedDate,Baseline_Duration__c,Duration__c,Forecast_Duration__c,Planned_Duration__c,ID_Before_Decimal__C,ID_After_Decimal__c,
                       Is_Stack__c,(select id from Attachments),(select id,Type__c,Dependent_Type__c,Preceeding_Task__r.ID_Text__c,Preceeding_Task__r.Task_Title__c from Dependencies__r ) from Task__c where id=:TaskId];
            for(Id userid : ImpMgrSet)
                ImpMgrMap.put(userid,userid);
            if(CurTask.Owner__c != null && CurTask.Owner__r.Member__r.Salesforce_User__c != null)
               ImpMgrMap.put(CurTask.Owner__r.Member__r.Salesforce_User__c,CurTask.Owner__r.Member__r.Salesforce_User__c);            
            ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', '');
            if(Utils.isAccessible('i8__Dependency__c')){
            PreDepList = [select id,Dependent_Type__c,SOE__c,Preceeding_SOE__r.Name,Preceeding_Task__r.ID_Text__c,Preceeding_Task__r.Task_Title__c,Type__c,Preceeding_Task__c from Dependency__c where Task__c=:TaskId and Dependent_Type__c='Predecessors' and SOE__c=:CurTask.SOE__c];
            SucDepList = [select id,Dependent_Type__c,SOE__c,Preceeding_SOE__r.Name,Preceeding_Task__r.ID_Text__c,Preceeding_Task__r.Task_Title__c,Type__c,Preceeding_Task__c from Dependency__c where Task__c=:TaskId and Dependent_Type__c='Successors' and SOE__c=:CurTask.SOE__c];
            }else errormessage  = System.Label.AddTask001;
            days = CurTAsk.Days__c; hours = CurTAsk.Hours__c; mins = CurTAsk.Minutes__c;bo = CurTask.Backout__c;
            string str = 'Select count() from Task__c where Id_Before_Decimal__c ='+ CurTAsk.Id_Before_Decimal__c+' and SOE__c =\''+ CurTask.SOE__c+'\' and Stage_Level__c=\''+ CurTask.Stage_Level__c+'\'';
            CountTask = Database.countQuery(str);
            if(Utils.isAccessible('i8__Communication__c')){
            Comlist = [select id,Additinal_Emails_Milestone__c,Additinal_Emails_Task_Ready__c,Additional_Emails_Completed__c,
                       Additional_Phone_Milestone__c,Additional_Phone_Task_Ready__c,Additional_Phone_Completed__c,
                       Default_Owner_Completed__c,Default_Owner_Task_ready__c,Milestone_Members__c,Task_Ready_Members__c,Completed_Members__c,
                       Default_Team_Completed__c,Default_Team_Task_ready__c,MileStone_for_default_Imp_Mngrs__c,Task__c from Communication__c where Task__c =:CurTask.Id];
            com = new Communication__c();
            if(Comlist.size()>0)
                com = comlist[0]; 
            }              
            if( TotalTaskMap1.get(CurTask.Id) == 0)
                before = true;
            if( TotalTaskMap1.get(CurTask.Id) == TotaltaskMap1.size()-1)
                after = true;
            if(StackFirstMap.containskey(CurTask.Id_Before_Decimal__c) && StackFirstMap.get(CurTask.Id_Before_Decimal__c).Jump__c == true)
                jump =true;
            if(CurTask.Status__c == i8.STATUS_SUSPENDED || CurTask.Status__c == i8.STATUS_RUNNING || CurTask.Status__c ==I8.STATUS_COMPLETED || CurTask.Status__c == I8.STATUS_FORCE_COMP 
                || CurTask.Status__c == I8.STATUS_COMP_JUMP || CurTask.Status__c == i8.STATUS_WAITING || CurTask.Status__c == i8.STATUS_WAITING_JUMP || CurTask.Status__c == i8.STATUS_ABANDONED
                || CurTask.SOE__r.Status__c == i8.STATUS_IMPINPROGRESS || CurTask.SOE__r.Status__c == i8.STATUS_IMP_COMP || Task_Update == false )                        
                output = true;
            else
                output = false;
        }       
    }
    public pagereference AddNotes(){
        if(CurTask.Add_Comments__c !=null){
            if(CurTask.Comments__c == null) 
                CurTask.Comments__c ='';
            CurTask.Comments__c=system.Now()+'-'+UserInfo.getname()+':'+CurTask.Add_Comments__c + '\n'+ CurTask.Comments__c;
            CurTask.Add_Comments__c=null;
        }
        return null;
    }
       public string comment;
    public pagereference AddNotes1(){
        if(review_comments !=null){
            if(CurTask.Review_Comments__c != null || CurTask.Review_Comments__c != ''){
                comment =  CurTask.Review_Comments__c; 
                CurTask.Review_Comments__c ='';
            }
            if(string.isnotempty(comment))
                CurTask.Review_Comments__c +=system.Now()+'-'+UserInfo.getFirstname()+':'+review_comments+ '\n'+comment ;
            else
                CurTask.Review_Comments__c +=system.Now()+'-'+UserInfo.getFirstname()+':'+review_comments;             
           review_comments=''; 
        }       
        return null;
    }
    public pagereference SaveTask(){
        errorbool  = false;
        if(Task_Update){
            Savepoint sp = Database.setSavepoint();
            try{
                if(CurTask.Task_Title__c == '' || CurTask.Task_Title__c == null){
                    errormessage = System.Label.AddTask005;
                    return null;
                }
                if(CurTask.Jump__c == true && CurTask.Jumped_Duration__c == null)
                    CurTask.Jumped_Duration__c = CurTask.Duration__c;
                Map<String, String> parammap = ApexPages.currentPage().getParameters();
                for (String key : parammap.keySet()) {            
                    If (key.startsWith('days')){
                        if(parammap.get(key)==' ' ||parammap.get(key)=='')
                            CurTask.days__c= 0;
                        else
                            CurTask.days__c= integer.ValueOf(parammap.get(key));
                    }
                    Else  if (key.startsWith('hours') ){
                        if(parammap.get(key)==' ' || parammap.get(key)=='')
                            CurTask.Hours__c = 0;
                        else
                            CurTask.Hours__c = integer.ValueOf(parammap.get(key));
                    }
                    Else  if (key.startsWith('minutes') ){
                        if(parammap.get(key)==' ' || parammap.get(key)=='')
                            CurTask.Minutes__c = 0;
                        else
                            CurTask.Minutes__c = integer.ValueOf(parammap.get(key));
                    }
                }
                if(CurTask.Jump__c == true && CurTask.Is_Stack__c == false && ! CurTASk.Status__c.contains(i8.JUMP))
                    CurTask.Status__c = CurTASk.Status__c + i8.JUMP;
                if(CurTask.time_BOund__c != null)
                   CurTask.Broken_Task__c = true;  
                if(CurTask.User_Defined_Critical_Path__c == true && CurTask.Critical_Path__c != 'C')
                   CurTask.Critical_Path__c = 'UC';
                else if ( CurTask.User_Defined_Critical_Path__c == false && CurTask.Critical_Path__c == 'UC')
                   CurTask.Critical_Path__c = null; 
                CurTask.Add_Comments__c=null;                  
                LogFactory.info('Modify_Task_Cntrl', 'SaveTask', 'Task Info', JSON.serialize(CurTAsk),'Line - 236');
                if(Task_Update)
                    update CurTask;  
                LogFactory.info('Modify_Task_Cntrl', 'SaveTask', 'Communication Info', JSON.serialize(com),'Line - 239');      
                if((CurTask.Task_Completed__c == true || curTask.When_Task_Ready__c == true ||  curTask.Advanced_Notifications__c == true || curTask.Milestone__c == true) ){
                    if(Comlist.size()>0  ){
                        if(Utils.isUpdateable('i8__Communication__c'))
                            update com;
                    } else {
                        com.SOE__c = Curtask.SOE__c;
                        com.Task__c = CurTask.Id;
                        if(Utils.isCreateable('i8__Communication__c'))
                            insert com;
                    }
                }                
                displayPopup = false;
                if(days != CurTask.Days__c || hours != CurTAsk.Hours__c || mins!= CurTask.Minutes__c)        
                    Task_TriggerHandler.UpdateAllTasks(new list<Id>{CurTask.SOE__c},CurTAsk.Stage_Level__c); 
                if(bo != CurTask.Backout__c)
                     Task_TriggerHandler.UpdateAllTasks(new list<id>{CurTask.SOE__c},i8.CONTEXT_BO);              
                errorbool  = true;
                ApexPages.CurrentPage().getParameters().put('id',CurTask.Id);
                getTasks();
            }catch(Exception e){
                 Database.rollback(sp);
                 LogFactory.error('Modify_Task_Cntrl', 'SaveTask', '', e.getMessage() + '' + e.getStackTraceString());               
                 errormessage = e.getMessage();                  
            } 
        }else{errormessage = System.Label.AddTask007; LogFactory.debug('Modify_Task_Cntrl', 'Save Task', 'Task Info', System.Label.AddTask007 ,'Line - 259');}
        LogFactory.SaveLog(); 
        return null;
    }
    public pagereference CancelTask(){          
        if(MISID != null )
            return new pagereference ('/apex/MIS_AllTasks?id='+MISID );  
        else  
            return new pagereference ('/apex/AllTasks_ClientSide?id='+SOEId);
    }    
    public void BeforeTask(){
        id Tas;
        errorbool  = false;errormessage  = null;
        try{
            if( TotalTaskMap1.containskey(CurTask.Id) && TotalTaskMap2.containskey(TotalTaskMap1.get(CurTask.Id)-1))
                tas =   TotalTaskMap2.get(TotalTaskMap1.get(CurTask.Id)-1) ;
            LOgFactory.info('Modify_Task_Cntrl','BeforeTask','Previous Task Id',tas,'Line - 250');
            LogFactory.SaveLog();
            ApexPages.CurrentPage().getParameters().put('id',tas);
            gettasks();
        }catch(Exception e){
             LogFactory.error('Modify_Task_Cntrl', 'BeforeTask', '', e.getMessage() + '' + e.getStackTraceString()); 
             LogFactory.SaveLog();              
             errormessage = e.getMessage();                  
        }      
    }
    public void AfterTask(){
        id Tas;
        errorbool  = false;errormessage  = null;
        try{
        if( TotalTaskMap1.containskey(CurTask.Id) && TotalTaskMap2.containskey(TotalTaskMap1.get(CurTask.Id)+1))
                tas =   TotalTaskMap2.get(TotalTaskMap1.get(CurTask.Id)+1) ;
            LOgFactory.info('Modify_Task_Cntrl','AfterTask','Next Task Id',tas,'Line - 266');
            LogFactory.SaveLog(); 
            ApexPages.CurrentPage().getParameters().put('id',tas);
            gettasks();
         }catch(Exception e){
             LogFactory.error('Modify_Task_Cntrl', 'AfterTask', '', e.getMessage() + '' + e.getStackTraceString()); 
             LogFactory.SaveLog();              
             errormessage = e.getMessage();                  
        } 
    }
    public PageReference openDocuments() {
        if(MISID == null)
            return new pagereference('/apex/AddDocument_ClientSide?id='+CurTask.Id+'&page=Modify_Task');
        else
            return new pagereference('/apex/AddDocument_ClientSide?id='+CurTask.Id+'&page=Modify_Task&MId='+MISID);
    }
    public PageReference deletetask(){ 
        errormessage  = null;
        if(Task_Update && Schema.sObjectType.Task__c.isDeletable()){
            try{   
                LOgFactory.info('Modify_Task_Cntrl','DeleteTask','Deleted Task',JSON.serialize(CurTask),'Line - 284'); 
                LOgFactory.SaveLog();  
                if(Schema.sObjectType.Task__c.isDeletable() )
                    delete CurTask;
                Task_TriggerHandler.UpdateAllTasks(new list<id>{CurTask.SOE__c},CurTAsk.Stage_Level__c);
                return new Pagereference('/apex/AllTasks_ClientSide?id='+CurTask.SOE__c);
             }catch(Exception e){
                 LogFactory.error('Modify_Task_Cntrl', 'DeleteTask', '', e.getMessage() + '' + e.getStackTraceString());  
                 LogFactory.SaveLog(); 
                 errormessage = e.getMessage();                              
            } 
        }else {errormessage = System.Label.AddTask008; LogFactory.debug('Modify_Task_Cntrl', 'Delete Task', 'Task Info', System.Label.AddTask008 ,'Line - 320');}        
        return null;    
    }
    public pagereference OpenDependency(){
        if(MISID == null)
            return new pagereference('/apex/ManageDependencies_ClientSide?Tid='+CurTask.Id+'&page=Modify_Task&Id='+SOEId);
        else
             return new pagereference('/apex/ManageDependencies_ClientSide?Tid='+CurTask.Id+'&page=Modify_Task&MId='+MISID);
    }    
    public void ExecuteTask(){
        errorbool  = false; errormessage  = null;
        if(Task_Access && Task_Update && Utils.isUpdateable('i8__SOE__c')){
            SavePoint sp = Database.SetSavePOint();
            try{
                Task__c CurTask = [select id,status__c,Days__c,Hours__c ,Minutes__c ,Start_Time__c ,End_Time__c ,Actual_Start__c,Forecast_End__c ,Id_Before_decimal__c ,SOE__c,Stage_Level__c from TAsk__c where id =: ActiveTAskId];
                CurTask.Status__c = I8.STATUS_RUNNING ;
                Datetime dt = system.now();
                CurTAsk.Start_Time__c = dt;
                CurTask.End_Time__c = CurTask.Start_Time__c .addDays(Integer.valueof(CurTask.Days__c));
                CurTask.End_Time__c = CurTask.End_Time__c.addHours(Integer.valueof(CurTask.Hours__c ));
                CurTask.End_Time__c = CurTask.End_Time__c.addMinutes(Integer.valueof(CurTask.Minutes__c ));
                curTask.Actual_start__c = CurTAsk.Start_Time__c;
                curTask.Forecast_start__c = CurTAsk.Start_Time__c;
                CurTAsk.Forecast_end__c = CurTask.End_Time__c ;
                CurTask.Activated_By__c = UserInfo.getFirstname() +' '+ UserInfo.getLastname();
                LOgFactory.info('MOdify_Task_Cntrl','ExecuteTask','CurTask',JSON.Serialize(CurTask),'Line - 317');
                if(Task_Update)
                    update CurTask;
                Task__c StackTask = [select id,Status__c,Stage__c,Days__c,Hours__c,Minutes__c,Start_Time__c,End_Time__c,Actual_Start__c ,Forecast_End__c  from task__c where Is_Stack__c = true and ID_Before_Decimal__c =: CurTask.Id_Before_decimal__c and SOE__c =: CurTask.SOE__c and Stage_Level__c=: CurTASk.Stage_Level__c];
                if(StackTask.Status__c == null){
                    StackTask.Status__c = I8.STATUS_RUNNING;
                    StackTask.Actual_start__c = dt;
                    stackTask.Forecast_Start__c = dt;
                    LOgFactory.info('MOdify_Task_Cntrl','ExecuteTask','Stack',JSON.Serialize(stackTask),'Line - 325');
                    if(Task_Update)
                        update StackTask;
                }
                Task_TriggerHandler.UpdateAllTasks(new list<id>{CurTask.SOE__c},CurTAsk.Stage_Level__c);
                system.debug('------------CUrSOE------'+CUrSOE);
                if(StackTask.Stage__c == i8.STAGE_IMP && StackTask.Status__c == I8.STATUS_RUNNING && CUrSOE.Imp_Start__c == false){
                    CUrSOE.Imp_Start__c = true;
                    if(Utils.isUpdateable('i8__SOE__c'))
                        update CurSOE;
                }            
                ApexPages.CurrentPage().getParameters().put('id',CurTask.Id);
                gettasks();
                LogFactory.SaveLog();
            }catch(Exception e){
                 Database.RollBack(sp);
                 LogFactory.error('Modify_Task_Cntrl', 'ExecuteTask', '', e.getMessage() + '' + e.getStackTraceString());  
                 LogFactory.SaveLog(); 
                 errormessage = e.getMessage();                              
            } 
        }else errormessage = System.Label.AddTask007;        
    }    
    public  void CompleteTask1(){
        errorbool  = false; errormessage  = null;
        if(Task_Update){
        SavePOint sp = Database.SetSavePoint();
        try{
            AllTasks_ClientSide_Cntrl.CompleteTaskMethod(ActiveTAskId,i8 );
            Task_TriggerHandler.UpdateAllTasks(new list<id>{CurTask.SOE__c},CurTAsk.Stage_Level__c);
            LogFactory.info('Modify_Task_Cntrl', 'CompleteTAsk1', 'CurTask',CurTask.Id, 'LIne - 352'); 
            ApexPages.CurrentPage().getParameters().put('id',CurTask.Id);
            gettasks();
            LogFactory.SaveLog();
        }catch(Exception e){
             Database.RollBack(sp);
             LogFactory.error('Modify_Task_Cntrl', 'CompleteTask1', '', e.getMessage() + '' + e.getStackTraceString());  
             LogFactory.SaveLog(); 
             errormessage = e.getMessage();                              
        }
        }else errormessage = system.label.AddTask007;
    }
    public task__c taskobj{get;set;}
    public void StagesList(){
        StageList = new List<SelectOption>();
        stageList.add(new SelectOption('0','--None--'));
        SelectedStage ='0';
        if( taskobj.Stage_Level__c == i8.CONTEXT_IMP){
            If(CurSOE.Pre_Implementation_Stage__c == True )
                StageList.add(new selectoption(i8.STAGE_PRE,i8.STAGE_PRE));
            StageList.add(new selectoption(i8.STAGE_Imp,i8.STAGE_Imp));
            If(CurSOE.Post_Implementation_Stage__c == True){
                StageList.add(new selectoption(i8.STAGE_Post,i8.STAGE_Post));
            }            
        } 
        else if( taskobj.Stage_Level__c == i8.CONTEXT_BO && CurSOE.Backout_STage__c == true){
              StageList.add(new selectoption(i8.STAGE_Imp,i8.STAGE_Imp));
              If(CurSOE.Post_Implementation_Stage__c == True)
                  StageList.add(new selectoption(i8.STAGE_Post,i8.STAGE_Post));
        }
        stackList = new list<SelectOption>();
        stackList.add(new SelectOption('0','--None--'));
        StackTaskList = new list<SelectOption>();
        StackTaskList.add(new SelectOption('0','--None--'));
    }
    public void StageChange(){
        stackList = new list<SelectOption>();
        stackList.add(new SelectOption('0','--None--'));
        integer i=0;
        if(Task_Access  )
        for(Task__c tas : [select id,ID_Text__c,Task_Title__c,Stage__c,Is_Stack__c,ID_before_decimal__c from Task__c where SOE__c =: SOEId and Stage_Level__c =: taskobj.Stage_Level__c
                           and Is_Stack__c =: true and Stage__c =: SelectedStage order by ID_Before_Decimal__c, ID_After_Decimal__c ]){
            Stacklist.add(new selectoption(string.valueof(tas.Id_Before_Decimal__c),string.valueof(tas.Id_Before_Decimal__c)+'.'+tas.Task_Title__c));
            if(i==0)
                selectedStack = string.valueof(tas.Id_Before_Decimal__c); 
            i++; 
        }
        SelectedTask = '0';
        LOgFactory.Info('Modify_Task_Cntrl','StageChange',' Selected Stage',SelectedStage,'Line - 398');
        LogFactory.SaveLog();
        getStackTaskList();
    }
    Integer TaskSize;
    public list<SelectOption> StackTaskList{get;set;}
    Public void getStackTaskList(){
        StackTaskList = new list<SelectOption>();
        StackTaskList.add(new SelectOption('0','--None--'));
        LOgFactory.Info('Modify_Task_Cntrl','StackTaskList',' Selected Stack',SelectedStack,'Line - 407');
        LogFactory.SaveLog();
        If(SelectedStack != '0' && Task_Access  ){
            List<Task__c> TaskList = New List<Task__c>();
            if(PageType == 'droptask')
                TaskList = [Select id,Id_Text__c,Task_Title__c from Task__c where SOE__c =: SOEID and Stage__c =: SelectedStage and stage_Level__c =: taskobj.Stage_Level__c and Id_Before_Decimal__c =: Decimal.valueof(selectedStack) and Is_Stack__c = false and End_Stack__c = false  and BO_IdBefore__c = null order by ID_Before_Decimal__c, ID_After_Decimal__c];
            If(TaskList.size() > 1000 && SelectedTask != 'more'){
                TaskSize = 1000;
                for(Integer i=0; i<TaskSize; i++)
                    StackTasklist.add(new selectoption(string.valueof(TaskList[i].Id),string.valueof(TaskList[i].Id_Text__c)+'.'+TaskList[i].Task_Title__c));
            }
            Else If(TaskList.size() > 1000 && SelectedTask == 'more'){
                Integer Prevsize = TaskSize;
                TaskSize = TaskSize + 1000;
                If(TaskSize > TaskList.size())
                    TaskSize = TaskList.size();
                SelectedTask = TaskList[TaskSize - 1].Id_Text__c;
                for(Integer i=Prevsize; i<TaskSize; i++)
                    StackTasklist.add(new selectoption(string.valueof(TaskList[i].Id),string.valueof(TaskList[i].Id_Text__c)+'.'+TaskList[i].Task_Title__c));            
            }
            Else{
                for(Task__c tas : TaskList)
                    StackTasklist.add(new selectoption(string.valueof(tas.Id),string.valueof(tas.Id_Text__c)+'.'+tas.Task_Title__c));
            }
        }
    }
    public void Modify(){
        SelectedTask ='0';       
        getStackTaskList();
    }
    public pagereference DropTask(){
        if(Task_Access   &&Task_Update && Schema.sObjectType.Task__c.isDeletable()) {
            if(SelectedStage == '0' || SelectedStack == '0' || SelectedTask == '0' ){
                errorbool =true;
                errormessage =System.Label.DropTask001;
            }       
            else{
                integer count = [select count() from Task__c where SOE__c =: SOEId and Stage_Level__c =: taskobj.Stage_Level__c and Id_Before_decimal__c =: Decimal.valueof(SelectedStack)];
                If(count <=3){
                    errorbool =true;
                    errormessage =System.Label.DropTask002;
                }
                else{                
                    try{
                        Task__c CurTAsk  = [Select id,Status__c,Id_Before_Decimal__c,SOE__c,Stage_Level__c from Task__c where Id =: SelectedTask];
                        Task__c stack  = [Select id,Status__c,Id_Before_Decimal__c,SOE__c,Stage_Level__c from Task__c where SOE__c =: SOEId and Stage_Level__c =: taskobj.Stage_Level__c and Is_Stack__c = true and Id_Before_Decimal__c =: CurTask.Id_Before_Decimal__c];
                        LogFactory.info('Modify_Task_Cntrl', 'DropTask', 'Deleted Task', JSON.Serialize(CurTask),'Line - 452');  
                        LogFactory.SaveLog(); 
                        If(CurTASk != null && stack.Status__c != i8.STATUS_RUNNING && stack.Status__c != I8.STATUS_COMPLETED && stack.Status__c != I8.STATUS_COMP_JUMP ){
                            if(Schema.sObjectType.Task__c.isDeletable())
                                delete CurTask;
                            Task_TriggerHandler.UpdateAllTasks(new list<id>{CurTask.SOE__c},CurTAsk.Stage_Level__c);   
                            return new Pagereference('/apex/AllTasks_ClientSide?id='+SOEId);
                        }
                        Else{
                            errorbool = True;
                            errormessage = System.Label.AddTask004;
                        }
                    }Catch(Exception e){
                         LogFactory.error('Modify_Task_Cntrl', 'DropTask', '', e.getMessage() + '' + e.getStackTraceString());  
                         LogFactory.SaveLog(); 
                         errormessage = e.getMessage();  
                    }
                }
            }
        }else errormessage = System.Label.AddTAsk008;
        return null;
    }
    public pagereference TaskSuspend(){
        errormessage  = null;
        if(Task_Update){
            if(MISID == null)
                return new pagereference('/apex/CreateIncident_ClientSide?SOEId='+CurTask.SOE__c+'&type=Suspend&TaskId='+ActiveTaskId);
            else
                return new pagereference('/apex/CreateIncident_ClientSide?SOEId='+CurTask.SOE__c+'&type=Suspend&TaskId='+ActiveTaskId+'&MId='+MISID);
        }else errormessage = System.Label.AddTask007;
        return null;
    }
    public pagereference ForceCompleteTask(){
        errormessage  = null;
        if(Task_Update) {
            if(MISID == null)
                return new pagereference('/apex/CreateIncident_ClientSide?SOEId='+CurTask.SOE__c+'&type=Force&TaskId='+ActiveTaskId);
            else
                return new pagereference('/apex/CreateIncident_ClientSide?SOEId='+CurTask.SOE__c+'&type=Force&TaskId='+ActiveTaskId+'&MId='+MISID);
        }else errormessage = System.Label.AddTask007; 
        return null;
    }
    public void TaskReExecute(){ 
        errormessage  = null;  
        if(Task_Update){
            try{    
                CurTask.Status__c = i8.STATUS_RUNNING;
                LogFactory.info('Modify_Task_Cntrl', 'TaskReExecute', 'CurTask', JSON.Serialize(CurTask),'Line - 488');  
                LogFactory.SaveLog(); 
                if(Task_Update)
                    update CurTAsk;
                Task_TriggerHandler.UpdateAllTasks(new list<id>{CurTask.SOE__c},CurTAsk.Stage_Level__c);
                ApexPages.CurrentPage().getParameters().put('id',CurTask.Id);
                gettasks();
            }Catch(Exception e){
                 LogFactory.error('Modify_Task_Cntrl', 'TaskReExecute', '', e.getMessage() + '' + e.getStackTraceString());  
                 LogFactory.SaveLog(); 
                 errormessage = e.getMessage();  
            } 
        }else errormessage = System.Label.AddTAsk007;
    }
     public void Popup(){ 
        if(CurTask.Status__c != i8.STATUS_RUNNING && CurTask.Status__c !=I8.STATUS_COMPLETED&& CurTask.Status__c != I8.STATUS_FORCE_COMP  && CurTask.Status__c != I8.STATUS_COMP_JUMP && CurTask.Status__c != i8.STATUS_WAITING && CurTask.Jump__c == false ){   
            if((CurTask.Task_Completed__c == true && active == 'Completed') || (CurTask.Milestone__c == true && active == 'Milestone') || (CurTask.When_Task_Ready__c == true && active == 'Ready')|| popup == true){
                   displayPopup = true;  
                   items = getMembers1();            
            } 
            popup = false; 
        }   
    }
    public void CancelPopUp(){
        displayPopup = false;
    }
    public List<SelectOption> getMembers1() {
        Members = new list<string>();
        List<SelectOption> members1 = new List<SelectOption>();     
        if(Utils.isAccessible('i8__Member__c') && Utils.isAccessible('i8__Communication__c')){
            MemberMap = New Map<id,Member__c>([select id,name,Email__c,Phone__c from Member__c where Active__c = True  order by Name limit 200]);         
            members1.add(new selectoption('None','--Select Member--'));
            for(Member__c Member : MemberMap.values()){
                members1.add(new selectoption(Member.id,Member.name));
                if((active == 'Milestone' && string.isNotBlank(com.Milestone_Members__c) && com.Milestone_Members__c.contains(Member.id)) || 
                   (active == 'Ready' && string.isNotBlank(com.Task_Ready_Members__c) && com.Task_Ready_Members__c.contains(Member.id)) ||
                   (active == 'Completed' && string.isNotBlank(com.Completed_Members__c) && com.Completed_Members__c.contains(Member.id)))
                Members.add(Member.id);          
            }
        }else LogFactory.debug('Modify_Task_Cntrl', 'Members', 'Member Info', System.Label.AddTask001 ,'Line - 556');
        LogFactory.SaveLog();
        return members1;
    }    
    public void UpdateMembers(){
        string members1 = '';
        for(String MemberId : Members){
            if(MemberId != 'None') 
                members1 +=  MemberId+',';
        }
        if(active == 'Milestone'){
           com.Milestone_Members__c = members1;
           curTask.Milestone__c = true ;
        }
        else if(active == 'Ready'){  
             com.Task_Ready_Members__c  = members1;
             curTask.When_Task_Ready__c = true ;
        }        
        else if(active == 'Completed'){ 
           com.Completed_Members__c  = members1;
           CurTask.Task_Completed__c = true ;
        }
        errorbool  = false;     
        displayPopup = false;
    }
}