/* 
Class Name        : AllTasks_ClientSide_Cntrl 
Test Class Name   : Test_AllTasks_ClientSide_Cntrl
Purpose/Overview  : To Display tasks in SOE and to add task, dependency, stacks like console
Author            : Purview Ltd.
Code Coverage     : 94%
Change History    : 

*/
Global with sharing class AllTasks_ClientSide_Cntrl {
    public string smsBody{get;set;}
    public string statusmsg{get;set;}
    public Id SOEId{get;set;}
    public i8Constants i8{get;set;}    
    public SOE__c CurSOE {get;set;}
    Public Map<Id,Id> ImpMgrMap{get;set;}
    public Map<Id,Id> QAMgrMap{get;set;}
    public Map<Id,Id> IncMgrMap{get;set;}
    public string ImpMgrMapKey{get;set;}
    public string QAMgrMapKey{get;set;}
    public string IncMgrMapKey{get;set;}
    public boolean BuildComp {get;set;}
    public boolean QAReviewButton{get;set;}
    public boolean QAProcessButton{get;set;}
    public boolean ScheduleButton{get;set;}
    public boolean WalkThroughButton{get;set;}
    public boolean WTProcessButton{get;set;}
    public boolean FreezeButton{get;set;}
    public static boolean Pre_Imp_Ava;
    public Id ActiveTaskId{get;set;}
    public static boolean SOEActiveBool;
    public boolean SuspendButtonBool;
    public Incident__c INCobj ;
    public static boolean tasktrigger ;
    public string errmsg{get;set;}
    public Id QAMgrId{get;set;}
    //for BroadCasting
    public boolean BroadCast{get;set;}
    public string BroadCastMsg{get;set;}
    public user CurUser;
    public string MyView{get;set;}
    public String userTimeZone{get;set;}
    public static boolean isRunComplete = false;
    public boolean TwilioInstalled{get;set;}
    public Map<string,string> TwilioSettings;
    boolean SOE_Accessible;
    boolean Task_Accessible;
    boolean Task_Update ;
    boolean SOE_Update ;
     
    public AllTasks_ClientSide_Cntrl(){
        SOEId = ApexPages.CurrentPage().getParameters().get('id');        
        i8 = new i8Constants();
        BroadCast = false;
        SOE_Accessible = Utils.isAccessible('i8__SOE__c') ;
        Task_Accessible = Utils.isAccessible('i8__Task__c') ;
        Task_Update = Utils.isUpdateable('i8__Task__c');
        SOE_Update = Utils.IsUpdateable('i8__SOE__c');
        GetSOEButtons();
        Id UserId = String.escapeSingleQuotes(UserInfo.getUserId());
        if( Utils.isAccessible('User')){
            CurUser = [select Broadcast__c,SOE_MyView__c from User where id=: UserId ]; 
             MyView = CurUser.SOE_MyView__c ;               
            BroadCast = CurUser.Broadcast__c;
        }
        BroadCastMsg = '***';
        DateTime dt = System.Now();
        if(Utils.isAccessible('i8__Broadcast__c')){
            for( Broadcast__c bc : [select name,Message__c from Broadcast__c where Status__c = 'Active' And Message_Start_Date__c <=: dt and  Message_End_Date__c >=: dt And (SOE__c =: SOEId or All_Users__c = true)  order by lastmodifiedDate  desc limit 5])
                BroadCastMsg += bc.Message__c +' ***';
        }
        if(BroadCastMsg  == '***')
            BroadCastMsg += ' No Messages to display ***';
        userTimeZone = String.valueOf(UserInfo.getTimeZone()); 
    }
   @RemoteAction
    Global  static WrapperTasks getTasks(string s,string t,id sid,integer size,integer offset) {        
        string countquery = 'select count(id) cnt from Task__c where SOE__c = \''+sid+'\' '+ t;
        set<id> Stackowner_set=new set<id>();
        list<task__c> TaskList = new list<Task__C>();
        list<task__c> TaskList1 = new list<Task__C>();
        integer RecCount ;
        if( Utils.isAccessible('i8__Task__c')){
            AggregateResult[] Results = Database.query(countquery);
            RecCount = Integer.valueof(Results[0].get('cnt'));
            if(offset > 2000){
                    TaskList1 = Database.query(s);
                integer last ;        
                if(offset+Size > TaskList1.Size())
                    last = TaskList1.Size() ;
                else
                    last = offset + Size;
                for(Integer i=offset; i< last ;i++)
                    TaskList.add(TaskList1[i]);
            }
            else{
                s+= ' LIMIT '+size + 'OFFSET '+offset; 
                    TaskList = Database.query(s);
            }
        }else
                LogFactory.debug('AllTasks_ClientSide_Cntrl', 'Remote Action', 'Task Info ', System.Label.ADMIN001,'Line - 101');
        SOE__c soe;
        if(Utils.isAccessible('i8__SOE__c') )
            soe = [select id,name,Imp_Duration__c,Max_Forecast_End__c,Dealy_Ahead_mins__c,Min_Start_Time__c,Max_Planned_End__c,Min_Planned_Start__c,Not_Comp_Pre_Stacks__c,Max_End_Time__c,Comp_Pre_Stacks__c,SOE_Title__c,OwnerId,Suspended_Time_mins__c,SOE_RAG__c,RAG__c,QA_Manager__c,QA_Review_Required__c ,WalkThrough_Required__c,WalkThrough__c,QA_Review__c,status__c,State__c,
                  Schedule_Start__c,Schedule_End__c,Warning_Zone__c,BAU_Impact__c,Post_Implementation_Stage__c from SOE__c where id=: sid];
        else
              LogFactory.debug('AllTasks_ClientSide_Cntrl', 'Remote Action', 'SOE Info ', System.Label.ADMIN001,'Line - 107');
        list<String> UserList = new list<string>(); 
        set<id>  TMList  = new set<Id>();  
        set<id>  OwnerList  = new set<Id>();   
        for(Task__c tas: TaskList){
            if(tas.Owner__c != null)
                TMList.add(tas.Owner__c);
        } 
        if(TMList.size()>0){
            if( Utils.isAccessible('i8__Team_Member__c')){
                for(Team_Member__c tm : [select id,Member__c,Member__r.Salesforce_User__c from Team_Member__c where id IN: TMList and  Member__r.Salesforce_User__c !=  null])
                    OwnerList.add(tm.Member__r.Salesforce_User__c);
            } 
            else
                LogFactory.debug('AllTasks_ClientSide_Cntrl', 'Remote Action', 'Team Member Info ', System.Label.ADMIN001,'Line - 121');
        }
        if(Schema.sObjectType.AuthSession.isAccessible() ){       
            AggregateResult[] groupedResults =  [SELECT  Max(LastModifiedDate) LastDate,NumSecondsValid,UsersId FROM AuthSession WHERE SessionType = 'UI' AND LoginType = 'Application' AND UsersID IN: OwnerList Group By UsersId,NumSecondsValid] ;
            for(AggregateResult ar: groupedResults ){
                DAteTime dt = DateTime.valueof(ar.get('LastDate'));
                integer seconds = integer.valueof(ar.get('NumSecondsValid'));
                if(System.Now() < dt.AddSeconds(seconds))
                    UserList.add(string.valueof(ar.get('UsersId')));
            }
        }
        else
            LogFactory.debug('AllTasks_ClientSide_Cntrl', 'Remote Action', 'Auth Session ', System.Label.ADMIN001,'Line - 133');
        LogFactory.SaveLog();
        return new  WrapperTasks(TaskList,RecCount,UserList,soe);  
    }
    Global class WrapperTasks{
        public list<Task__c> Tasks{get;set;}
        public integer count{get;set;}
        public list<string> users{get;set;}
        public SOE__c soe{get;set;}
        public WrapperTasks(list<Task__c> tas, integer cnt,list<string> str,SOE__c so){
            Tasks = tas;
            count = cnt;
            users = str;
            soe = so;
        }
    }
    public void GetSOEButtons(){
        BuildComp = false;  QAReviewButton = false;   QAProcessButton = false;  ScheduleButton = false;  WalkThroughButton = false;  WTProcessButton = false;   FreezeButton = false; 
        TwilioSettings = new Map<string,string>();
        if( SOE_Accessible ){
        try{
            TwilioSettings = SystemSettings_Util.getTwilioSettings();
            if(TwilioSettings.containskey ('Twilio_Installed') &&  TwilioSettings.get('Twilio_Installed').ToUpperCase() == 'YES')
                TwilioInstalled = true;
            else
                 TwilioInstalled = false;          
            CurSOE = [select id,name,Backout_Stage__c,Post_Implementation_Stage__c,Imp_Duration__c,RAG__c,Imp_Start__c,Max_Forecast_End__c,Dealy_Ahead_mins__c,Max_Planned_End__c,Min_Planned_Start__c,Not_Comp_Pre_Stacks__c,Max_End_Time__c,Comp_Pre_Stacks__c,SOE_Title__c,OwnerId,Suspended_Time_mins__c,SOE_RAG__c,QA_Manager__c,QA_Review_Required__c,WalkThrough_Required__c,WalkThrough__c,QA_Review__c,status__c,State__c,Schedule_Start__c,Schedule_End__c,Warning_Zone__c,BAU_Impact__c from SOE__c where id=: SOEId ];
            if(CurSOE.Status__c == i8.STATUS_REVIEW){
                if((CurSOE.QA_Review__c == i8.SOE_NONE  || CurSOE.QA_Review__c == i8.SOE_FEEDBACK ) &&  CurSOE.QA_Review_Required__c ==true)
                    QAReviewButton = true;
                else if(CurSOE.QA_Review__c == i8.SOE_QA_INP  && CurSOE.QA_Review_Required__c ==true)
                    QAProcessButton = true;
            }
            if(( CurSOE.QA_Review_Required__c ==true && CurSOE.QA_Review__c == i8.SOE_COMPLETE && CurSOE.Status__c == i8.STATUS_REVIEW) || (CurSOE.Status__c == i8.STATUS_SCHEDULED || CurSOE.Status__c == i8.STATUS_FREEZE )|| (CurSOE.Status__c == i8.STATUS_REVIEW && CurSOE.QA_Review_Required__C == false))
                ScheduleButton = true;        
            ImpMgrMap = new Map<Id,Id>();
            QAMgrMap = new Map<Id,Id>();
            IncMgrMap = new Map<Id,Id>();
            ImpMgrMap.put(CurSOE.OwnerId,CurSOE.OwnerId);
            if(CurSOE.QA_Manager__c != null)
                QAMgrId = CurSOE.QA_Manager__C;
            else
                QAMgrId = CurSOE.OwnerId;
            set<string> RolesLIst = new set<string>();
            RolesLIst.AddAll(System.Label.Roles_To_Edit_SOE.split(','));
            if(Utils.isAccessible('i8__SOE_Team_Member__c')){
                for( SOE_Team_Member__c imp : [select Id,Name,Role__r.Reference_Role__c,Team_Member__c,Team_Member__r.Salesforce_User__c,Access_Level__c  from SOE_Team_Member__c where SOE__c =: CurSOE.Id ])  {
                    if(RolesLIst.contains(imp.Role__r.Reference_Role__c) && (imp.Access_Level__c == 'Edit' || imp.Access_Level__c == 'All'))
                        ImpMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
                    if(imp.Role__r.Reference_Role__c == 'QA Manager'&& imp.Access_Level__c == 'Edit')
                        QAMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
                    if(imp.Role__r.Reference_Role__c == 'Incident Manager'&& imp.Access_Level__c == 'Edit')
                        IncMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
                }
            }
            if(Schema.sObjectType.Profile.isAccessible() ){
                if([Select Id,Name from Profile where Id=:userInfo.getProfileId()].Name == 'System Administrator')
                     ImpMgrMap.put(userInfo.getUserId(),userInfo.getUserId());
            }
            ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', ''); 
            QAMgrMapKey = string.valueof(QAMgrMap.keyset()).replace('{', '').replace('{', ''); 
            IncMgrMapKey = string.valueof(IncMgrMap.keyset()).replace('{', '').replace('{', '');      
            //for WalkThrough Process if Walk Through is checked
            if(CurSOE.Status__c == i8.STATUS_SCHEDULED){
                if(  CurSOE.WalkThrough_Required__c == true && CurSOE.WalkThrough__c == i8.SOE_NONE)
                    WalkThroughButton = true;
                else if(CurSOE.WalkThrough__c == i8.SOE_QA_INP && CurSOE.WalkThrough_Required__c ==true)
                    WTProcessButton = true;
                else if(((CurSOE.WalkThrough_Required__c == true && CurSOE.WalkThrough__c ==  i8.SOE_COMPLETE) ||CurSOE.WalkThrough_Required__c == false)) 
                    FreezeButton = true;              
            }
        }catch(Exception e){
            errmsg = e.getMessage();
        } 
        }else errmsg = System.Label.ADMIN001;    
    }
    public void UpdateTasks(){
        errmsg = null; 
        statusmsg = null; 
        if(Task_Accessible  && Task_Update) { 
            try{                  
                Task_TriggerHandler.UpdateAllTasks(new list<string>{SOEId},i8.CONTEXT_IMP);
                if(CurSOE.Backout_STage__c == true)
                    Task_TriggerHandler.UpdateAllTasks(new list<string>{SOEId},i8.CONTEXT_BO);
                if( SOE_Accessible )
                    CurSOE = [select id,name,Backout_Stage__c,Post_Implementation_Stage__c,Imp_Duration__c,RAG__c,Imp_Start__c,Max_Forecast_End__c,Dealy_Ahead_mins__c,Max_Planned_End__c,Min_Planned_Start__c,Not_Comp_Pre_Stacks__c,Max_End_Time__c,Comp_Pre_Stacks__c,SOE_Title__c,OwnerId,Suspended_Time_mins__c,SOE_RAG__c,QA_Manager__c,QA_Review_Required__c,WalkThrough_Required__c,WalkThrough__c,QA_Review__c,status__c,State__c,Schedule_Start__c,Schedule_End__c,Warning_Zone__c,BAU_Impact__c from SOE__c where id=: SOEId ];
            }catch(Exception e){
                LogFactory.error('AllTasks_ClientSide_Cntrl','UpdateTask','',e.getMessage()+''+e.getSTackTraceString());
                LOgFactory.SaveLog();
                errmsg = e.getMessage();
            }
        }else errmsg = System.Label.ADMIN001;
    }
    public void ActivateTask1(){
        statusmsg = null;errmsg = null;
        if(Task_Accessible && Task_Update){
            Savepoint sp = Database.setSavePoint();
            try{
                ActiveTAskId = ApexPages.CurrentPage().getParameters().get('ActiveId');          
                Task__c CurTask = [select id,status__c,Days__c,Hours__c ,Minutes__c ,Total_MIns__c,Start_Time__c ,End_Time__c ,Actual_Start__c,Forecast_End__c ,Id_Before_decimal__c ,SOE__c,Stage_Level__c from TAsk__c where id =: ActiveTAskId];
                CurTask.Status__c = i8.STATUS_RUNNING ;
                Datetime dt = system.now();
                CurTAsk.Start_Time__c = dt;
                CurTask.End_Time__c = CurTask.Start_Time__c .addMinutes(Integer.valueof(CurTask.Total_MIns__c));
                curTask.Actual_start__c = CurTAsk.Start_Time__c;
                curTask.Forecast_start__c = CurTAsk.Start_Time__c;
                CurTAsk.Forecast_end__c = CurTask.End_Time__c ;
                CurTask.Activated_By__c = UserInfo.getFirstname() +' '+ UserInfo.getLastname();  
                LogFactory.info('AllTasks_ClientSide_Cntrl','ActivateTask','CurTask',JSON.serialize(CurTask),'Line - 202');
                if(Task_Update)
                    update CurTask;
                Task__c StackTask = [select id,Status__c,Stage__c,Days__c,Hours__c,Minutes__c,Start_Time__c,End_Time__c,Actual_Start__c ,Forecast_End__c  from task__c where Is_Stack__c = true and ID_Before_Decimal__c =: CurTask.Id_Before_decimal__c and SOE__c =: CurTask.SOE__c and Stage_Level__c=: CurTASk.Stage_Level__c];
                LogFactory.info('AllTasks_ClientSide_Cntrl','ActivateTask','Stack HDR',JSON.serialize(StackTask),'Line - 206');
                if(StackTask.Status__c == null){
                    StackTask.Status__c = i8.STATUS_RUNNING;
                    StackTask.Actual_start__c = dt;
                    StackTask.Forecast_start__c = dt;
                    if(Task_Update)
                        update StackTask;            
                }
                isRunComplete = true;
                UpdateTasks();
                isRunComplete = false;
                if(StackTask.Stage__c == i8.STAGE_IMP && StackTask.Status__c == I8.STATUS_RUNNING &&  CUrSOE.Imp_Start__c == false){
                        CUrSOE.Imp_Start__c = true;
                        if(Utils.isUpdateable('i8__SOE__c'))
                            update CurSOE;
                }            
            }catch(Exception e){
                Database.Rollback(sp);
                LogFactory.error('AllTasks_ClientSide_Cntrl','ActivateTask','',e.getMessage()+''+e.getSTackTraceString());
                errmsg = e.getMessage();
            }
        }else errmsg = System.Label.ADMIN001;   
        LogFactory.SaveLog();  
    }
    public pagereference ReRunTask(){
        statusmsg = null;errmsg = null;
        if(Task_Accessible && Task_Update){
            try{
                ActiveTAskId = ApexPages.CurrentPage().getParameters().get('ActiveId');
                    Task__c CurTask = [select id,status__c from TAsk__c where id =: ActiveTAskId];
                    CurTask.Status__c = i8.STATUS_RUNNING ;
                    if(Task_Update)
                        update CurTask;            
            }catch(Exception e){
                LogFactory.error('AllTasks_ClientSide_Cntrl','ReRunTask','',e.getMessage()+''+e.getSTackTraceString());
                errmsg = e.getMessage();
            }
            LogFactory.SaveLog(); 
        } else errmsg = System.Label.ADMIN001;
        return null;
    }
    public pagereference CompleteTask(){
        statusmsg = null;errmsg = null;
        if(Task_Accessible && Task_Update ){
            SavePOint sp = Database.SetSavePOint();
            try{
                ActiveTAskId = ApexPages.CurrentPage().getParameters().get('ActiveId');
                CompleteTaskMethod(ActiveTAskId,i8);
                isRunComplete = true;
                UpdateTasks();
                isRunComplete = false;  
            } Catch(EXception e){
                Database.Rollback(sp);
                LogFactory.error('AllTasks_ClientSide_Cntrl','CompleteTask','',e.getMessage()+''+e.getSTackTraceString());
                errmsg = e.getMessage();
            } 
        }else errmsg = System.Label.ADMIN001;
        LogFactory.SaveLog();   
        return null;
    }
    public static void CompleteTaskMethod(Id ActiveId,i8Constants i8){
        Decimal duration; 
        DateTime dt = System.now();
        Integer mins; 
        if( Utils.isAccessible('i8__Task__c') &&  Utils.isUpdateable('i8__Task__c') && Utils.isAccessible('i8__Incident__c')){       
            Task__c CurTask = [select id,status__c,Start_Time__c ,End_Time__c ,Actual_Start__c,Forecast_End__c ,Id_After_decimal__c ,Id_Before_decimal__c,SOE__c,Stage_Level__c from TAsk__c where id =: ActiveId];
            list<Incident__c> inc = [select id,Inc_Open_Time__c,Inc_Close_Time__c from Incident__c where  Inc_Type__c =: i8.STATUS_FORCE_COMP  and Task__c =: CurTask.Id and INC_on_Object__c = 'Task'];
            if(inc != null && inc.size()>0)
                CurTask.Status__c = i8.STATUS_FORCE_COMP ;
            else
                CurTask.Status__c = i8.STATUS_COMPLETED ;
            CurTask.End_Time__c = dt;
            AggregateResult[] IncResults = new list<AggregateResult>();     
            IncResults = [select SUM(Incident_Duration__c) Dur from Incident__c where Status__c =: i8.STATUS_CLOSE and Inc_Type__c =: i8.STATUS_SUSPENDED and Task__c =: CurTask.Id and INC_on_Object__c = 'Task'];
            duration  = (CurTask.End_Time__c.getTime() - CurTask.Start_Time__c.getTime());
            Integer seconds = Integer.valueof(duration  / 1000);            
            if(IncResults[0].get('Dur') != null) {
                mins = Integer.valueof(seconds/60) - Integer.valueof(IncResults[0].get('Dur'));
                Integer mins1 = Integer.valueof(seconds/60);
                CurTask.End_Time__c = CurTask.Start_Time__c.addMinutes(mins1);
            }
            else{
                mins = Integer.valueof(seconds/60) ;              
                CurTask.End_Time__c = CurTask.Start_Time__c.addMinutes(mins);
            }
            CurTask.Hours__c = Math.floor(mins/60);
            CurTask.Minutes__c = Math.mod(mins,60);
            CurTask.Days__c  = Math.floor( CurTask.Hours__c/ 24);
            CurTask.Hours__c = Math.mod(Integer.valueof(CurTask.Hours__c) , 24);
            CurTask.Completed_By__c = UserInfo.getFirstname() +' '+ UserInfo.getLastname(); 
            CurTAsk.Actual_end__c = CurTask.End_Time__c ;
            LogFactory.info('AllTasks_ClientSide_Cntrl','CompleteTask','CurTask',JSON.serialize(CurTask),'Line - 333');
            if(Utils.isUpdateable('i8__Task__c'))
                update CurTask;
        }else
             LogFactory.debug('AllTasks_ClientSide_Cntrl', 'Rerun Task', 'Task Info', System.Label.AddTask001 ,'Line - 336');
         LogFactory.SaveLog();
    }  
    public void SOEExecute(){
        errmsg=''; statusmsg = null;
        if(CurSOE.Not_Comp_Pre_Stacks__c != CurSOE.Comp_Pre_Stacks__c) 
            errmsg = System.Label.SOEAllTasks001;
        else if(CurSOE.Schedule_Start__c > System.Now() || CurSOE.Max_End_Time__c >= CurSOE.BAU_Impact__c )
            errmsg = System.Label.SOEAllTasks002;
        else{
            try{
                SOEActiveBool = true;
                SuspendButtonBool = true;
                if(CurSOE.Status__c != i8.STATUS_IMPINPROGRESS ){
                    CurSOE.Status__c = i8.STATUS_IMPINPROGRESS;
                    LogFactory.info('AllTasks_ClientSide_Cntrl','SOEExecute','SOE',JSON.Serialize(CurSOE), 'Line - 351');
                    if(SOE_Update)
                        update CurSOE;
                }
                UpdateTasks();
                GetSOEButtons();
            } Catch(EXception e){
                LogFactory.error('AllTasks_ClientSide_Cntrl','SOEExecute','',e.getMessage()+''+e.getSTackTraceString());
                errmsg = e.getMessage();
            }
            LOgFactory.SaveLog(); 
        }
    }    
    public void SOEBuildComplete(){
        statusmsg = null;errmsg = null;
        if(Task_Accessible && Task_Update && SOE_Update){
            try{
                if(CurSOE.Status__c == i8.STATUS_BUILD)
                    CurSOE.Status__c = i8.STATUS_REVIEW;
                if(CurSOE.QA_Review_Required__c == true){
                    QAReviewButton = true;
                }
                LogFactory.info('AllTasks_ClientSide_Cntrl','SOEBuildComplete','SOE',JSON.Serialize(CurSOE), 'Line - 377');
                if(SOE_Update)
                    Update CurSOE;       
                UpdateTasks();
                    GetSOEButtons();
            } Catch(EXception e){
                LogFactory.error('AllTasks_ClientSide_Cntrl','SOEBuildComplete','',e.getMessage()+''+e.getSTackTraceString());
                errmsg = e.getMessage();
            }
        }else errmsg = System.Label.ADMIN001; 
        LogFactory.SaveLog();
    }
    public void QAReview(){
        errmsg = null; statusmsg = null;
        try{
            Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
            req1.setComments('Submitted request for approval.');
            req1.setObjectId(CurSOE.id);
            req1.setNextApproverIds(new Id[] {QAMgrId});
            req1.setProcessDefinitionNameOrId('SOE_Process_for_QA');
            Approval.ProcessResult result = Approval.process(req1);    
            LogFactory.debug('AllTasks_ClientSide_Cntrl','QAReview','Approval Process','Approval Process Activated Successfully', 'Line - 399');     
            QAReviewButton = false;       
            GetSOEButtons();
        } Catch(EXception e){
            LogFactory.error('AllTasks_ClientSide_Cntrl','QAReview','',e.getMessage()+''+e.getSTackTraceString());
            errmsg = e.getMessage();
        } 
        LogFactory.Savelog();     
    }    
    public void WalkThrough(){
        errmsg = null; statusmsg   = null;
        try{
            Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
            req1.setComments('Submitted request for Walk Through Approval.');
            req1.setObjectId(CurSOE.id);  
            req1.setProcessDefinitionNameOrId('WalkThrough_Process_for_SOE');
            Approval.ProcessResult result = Approval.process(req1);
            LogFactory.debug('AllTasks_ClientSide_Cntrl','Wlakthrough','Approval Process','Approval Process Activated Successfully', 'Line - 416');  
            WalkThroughButton = false;
            GetSOEButtons();
        } Catch(EXception e){
            LogFactory.error('AllTasks_ClientSide_Cntrl','SOEWalkthrough','',e.getMessage()+''+e.getSTackTraceString());
            errmsg = e.getMessage();
        } 
        LogFactory.Savelog();
    }    
    public void SOEFreeze(){
        errmsg = null; statusmsg   = null;
         if(Task_Accessible && Task_Update && SOE_Update){
        try{
            CurSOE.Status__c = i8.STATUS_FREEZE;
            LogFactory.info('AllTasks_ClientSide_Cntrl','SOEFreeze','SOE',JSON.Serialize(CurSOE), 'Line - 430'); 
            if(SOE_Update)
                update CurSOE;
           UpdateTasks();
            GetSOEButtons();
        } Catch(EXception e){
            LogFactory.error('AllTasks_ClientSide_Cntrl','SOEFreeze','',e.getMessage()+''+e.getSTackTraceString());
            errmsg = e.getMessage();
        }
        }else errmsg = System.Label.ADMIN001; 
        LogFactory.Savelog();
    }
    public pagereference SOESchedule(){
        errmsg = null; statusmsg   = null;
        if(Task_Accessible && Task_Update && SOE_Update)
            return new pagereference('/apex/SoeSchdule_ClientSide?id='+CurSOE.Id);
        else errmsg = System.Label.ADMIN001;
        return null;
    }   
    public pagereference SOEReExecute(){
    errmsg = null; statusmsg   = null;
        if(Task_Accessible && Task_Update && SOE_Update){
            if(Utils.IsAccess_Update('i8__Incident__c'))
                INCobj = [select id,name,SOE1__c,Status__c from Incident__c where SOE1__c =: CurSOE.Id AND Inc_Type__c =: 'Suspended' AND Status__c =: 'Open' AND INC_on_Object__c = 'SOE'];
            return new pagereference('/apex/CreateIncident_ClientSide?SOEId='+CurSOE.Id+'&type=ReExecute&INCID='+IncObj.Id);
        }else errmsg = System.Label.ADMIN001;
        return null;
    }
    public pagereference SOEAbandon(){
        errmsg = null;statusmsg = null;
         if(Task_Accessible && Task_Update && SOE_Update && Utils.isAccess_Create('i8__Incident__c'))
        return new pagereference('/apex/CreateIncident_ClientSide?SOEId='+CurSOE.Id+'&type=Abandoned');
        else errmsg = System.Label.ADMIN001;
        return null;
    }
    public pagereference  SOESuspend(){
        errmsg = null; statusmsg  = null;
        string type= ApexPages.CurrentPage().getParameters().get('ActiveId');
         if(Task_Accessible && Task_Update && SOE_Update && Utils.isAccess_Create('i8__Incident__c'))
        return new pagereference('/apex/CreateIncident_ClientSide?SOEId='+CurSOE.Id+'&type='+type);
        else 
            errmsg = System.Label.ADMIN001;
        return null;
    }
    public void BroadCastOnOff(){
        if(Utils.isAccessible('User')){
            if(CurUser.Broadcast__c == true)
                CurUser.Broadcast__c = false;
            else
                CurUser.Broadcast__c = true;
            if(Utils.isUpdateable('User'))
                update CurUser;
            BroadCast = CurUser.Broadcast__c;
        }
    }
     public pagereference audioclip(){
        return new pagereference('/apex/Soe_allAttachments?Id='+SOEId );
    }    
     public pagereference Cancel(){
            if(UserInfo.getUiThemeDisplayed() == 'Theme3')
                return new PageReference('javascript:window.close()');
            else
                return new pagereference('/'+CurSoe.Id);
    }
    global void CreateCall() {
        errmsg = null; statusmsg   = null;
        try{
            string phNumber =  ApexPages.CurrentPage().getParameters().get('ActiveId'); 
            LogFactory.debug('AllTasks_ClientSide_Cntrl','CreateCall','Phone Number',phNumber, 'Line - 498');
                Type t = Type.forName(TwilioSettings.get('Twilio_Class_Name')); 
                TwilioUtilityInterface newObj = (TwilioUtilityInterface)t.newInstance(); 
                newObj.SendCall(phNumber);
        } Catch(EXception e){
            LogFactory.error('AllTasks_ClientSide_Cntrl','CreateCall','',e.getMessage()+''+e.getSTackTraceString());
            errmsg = e.getMessage();
        } 
        LogFactory.Savelog();
    }
    global void CreateSMS() {  
        errmsg = null; statusmsg  = null;
        try{    
            string phNumber =  ApexPages.CurrentPage().getParameters().get('ActiveId'); 
            LogFactory.debug('AllTasks_ClientSide_Cntrl','CreateSMS','Phone Number',phNumber, 'Line - 512');
            phNumber = '+'+phNumber;
            string body =  ApexPages.CurrentPage().getParameters().get('body1'); 
                Type t = Type.forName(TwilioSettings.get('Twilio_Class_Name')); 
                TwilioUtilityInterface newObj = (TwilioUtilityInterface)t.newInstance(); 
                statusmsg  = newObj.SendSMS(new list<string>{phNumber},body);        } 
            Catch(EXception e){
            LogFactory.error('AllTasks_ClientSide_Cntrl','CreateSMS','',e.getMessage()+''+e.getSTackTraceString());
            errmsg = e.getMessage();
        } 
        LogFactory.Savelog();
    }
    public pagereference AddPINtoTask(){
        errmsg = null; statusmsg  = null;
        if(Task_Accessible && Task_Update){
        try{
            string body =  ApexPages.CurrentPage().getParameters().get('body1'); 
            string taskid =  ApexPages.CurrentPage().getParameters().get('tas'); 
           
            if(body != null  && body != ''){
                 Task__c tas = [select id,PIN__c,ID_Text__c,SOE__r.Name from Task__c where id=: taskid];
                  LogFactory.info('AllTasks_ClientSide_Cntrl','AddPINToTask','Task',JSON.serialize(tas), 'Line - 532');
                 if(tas.PIN__c == null)
                     tas.PIN__c = '';         
                 tas.PIN__c  =system.Now()+'-'+UserInfo.getFirstname()+':'+body+'<br/>'+tas.PIN__c;
                 if(Task_Update)
                     update tas;
            }
        } Catch(EXception e){
            LogFactory.error('AllTasks_ClientSide_Cntrl','AddPINtoTask','',e.getMessage()+''+e.getSTackTraceString());
            errmsg = e.getMessage();
        } 
        }else errmsg = System.Label.ADMIN001;        
        LogFactory.Savelog();         
        return null;
    }
    public pagereference openAddTask(){
        string TaskId = ApexPages.CurrentPage().getParameters().get('ActiveId');       
        return new pagereference('/apex/AddTask_ClientSide?id='+TaskId +'&SOEId='+CurSOE.Id);
    }
     public pagereference openEditStack(){
        string TaskId = ApexPages.CurrentPage().getParameters().get('ActiveId');
        return new pagereference('/apex/EditStack_ClientSide?id='+TaskId +'&SId='+CurSOE.Id);
    }
    public pagereference openManageDependencies(){
        string TaskId = ApexPages.CurrentPage().getParameters().get('ActiveId');
        return new pagereference('/apex/ManageDependencies_ClientSide?Tid='+TaskId +'&page=SOE&Id='+CurSOE.Id);
    }
    public pagereference openModifyTask(){
        string TaskId = ApexPages.CurrentPage().getParameters().get('ActiveId');
        string level = ApexPages.CurrentPage().getParameters().get('Level');
        return new pagereference('/apex/ModifyTask_ClientSide?Sid='+CurSOE.Id+'&id='+TaskId +'&level='+level+'&page=edit');
    }
    public pagereference openCreateStack(){
        return new pagereference('/apex/CreateStack_ClientSide?id='+CurSOE.Id);
    }
    public pagereference openCloneStack(){
        return new pagereference('/apex/CloneStack_ClientSide?id='+CurSOE.Id+'&page=clone');
    }
    public pagereference openDropStack(){
        return new pagereference('/apex/DropStack_ClientSide?id='+CurSOE.Id);
    }
    public pagereference openJumpStack(){
        return new pagereference('/apex/JumpStack_ClientSide?id='+CurSOE.Id);
    }
    public pagereference openMoveStack(){
        return new pagereference('/apex/MoveStack_ClientSide?id='+CurSOE.Id+'&page=move');
    }
    public pagereference openCloneTask(){
        return new pagereference('/apex/CloneTask_ClientSide?Sid='+CurSOE.Id);
    }
    public pagereference openDropTask(){
        return new pagereference('/apex/DropTask_ClientSide?Sid='+CurSOE.Id+'&page=droptask');
    }
    public pagereference openAddDocuments(){
        string TaskId = ApexPages.CurrentPage().getParameters().get('ActiveId');
        return new pagereference('/apex/AddDocument_ClientSide?id='+TaskId+'&SId='+CurSOE.Id);
    }
    public pagereference openListIncidents(){
        return new pagereference('/apex/ListIncidents_ClientSide?id='+CurSOE.Id);
    }
    public pagereference openCreateIncident(){
        return new pagereference('/apex/CreateIncident_ClientSide?SOEId='+CurSOE.Id);
    }
    public pagereference openListOpenIncidents(){
        return new pagereference('/apex/ListIncidents_ClientSide?id='+CurSOE.Id+'&status=open');
    }
    public pagereference openListClosedIncidents(){
        return new pagereference('/apex/ListIncidents_ClientSide?id='+CurSOE.Id+'&status=closed');
    }
    public pagereference openSOEStatus(){
        return new pagereference('/apex/SOEStatus?id='+CurSOE.Id);
    }   
    public pagereference openSOEDashboards(){
        return new pagereference('/apex/SOE_DashBoards?id='+CurSOE.Id);
    } 
    public pagereference openReviewWalkthroughPage(){
        return new pagereference('/apex/Review_WalkThrough_Approval?id='+CurSOE.Id);
    }
    public pagereference openNewBroadcast(){
        return new pagereference('/apex/Broadcast_New?id='+CurSOE.Id);
    }
    public pagereference openSearchReplace(){
        return new pagereference('/apex/SearchReplace_ClientSide?id='+CurSOE.Id);
    }
    public pagereference openAllDocuments(){
        return new pagereference('/apex/ViewAllDocuments_ClientSide?id='+CurSOE.Id);
    }
    public pagereference openAttachments(){
        return new pagereference('/apex/SOE_uploadAttachments?id='+CurSOE.Id);
    }
    public pagereference openResourceROTA(){
        return new pagereference('/apex/ROTA?id='+CurSOE.Id);
    }
    public pagereference openHistoryPage(){
        return new pagereference('/apex/History?id='+CurSOE.Id);
    }     
    public pagereference openMyView(){
        return new pagereference('/apex/SOE_MyView?id='+CurSOE.Id);        
    }
    public pagereference openTaskGanttChart(){
        return new pagereference('/apex/TaskGanttChart2?id='+CurSOE.Id);        
    }
    public pagereference openResourceGanttChart(){
        return new pagereference('/apex/SOEResource_Gantt?id='+CurSOE.Id);        
    }
    public pagereference openIOAP(){
        return new pagereference('/apex/SOE_SingleDashboard?id='+CurSOE.Id);        
    } 
    public pagereference openEmailPage(){
        string TaskId = ApexPages.CurrentPage().getParameters().get('ActiveId');
        return new pagereference('/apex/SOE_Email_client?id='+CurSOE.Id+'&page=comm&mail='+TaskId);        
    }  
}