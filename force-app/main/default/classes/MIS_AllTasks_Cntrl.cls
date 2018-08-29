/* 
Class Name        : MIS_AllTasks_Cntrl
Test Class Name   : Test_MIS_AllTasks_Cntrl
Purpose/Overview  : To display All tasks in SOEs that are added to MIS. 
Author            : Purview Ltd.
Code Coverage     : 92%
Change History    : 

*/
Global with sharing class MIS_AllTasks_Cntrl{
    public Id MISID{get;set;}
    public i8Constants i8{get;set;}
    public string inputValue{get;set;}   
    public Id ActiveTaskId{get;set;}    
    public user CurUser;
    public string MyView{get;set;}
    public String userTimeZone{get;set;}
    public static string MisStatus{get;set;}
    public list<SOE__c> SOEList;
    public boolean BroadCast{get;set;}
    public string BroadCastMsg{get;set;}
    public string statusmsg{get;set;}
    public string errmsg{get;set;}    
    Public Map<Id,Id> ImpMgrMap{get;set;}
    public string ImpMgrMapKey{get;set;}
    public boolean TwilioInstalled{get;set;}
    public Map<string,string> TwilioSettings;
    boolean SOE_Accessible;
    boolean Task_Accessible;
    boolean Task_Update ;
    boolean SOE_Update ;
     
    public MIS_AllTasks_Cntrl(){        
        MISID = ApexPages.CurrentPage().getParameters().get('id');            
        i8 = new i8Constants();  
        BroadCast = false;
        SOE_Accessible = Utils.isAccessible('i8__SOE__c') ;
        Task_Accessible = Utils.isAccessible('i8__Task__c') ;
        Task_Update = Utils.isUpdateable('i8__Task__c');
        SOE_Update = Utils.IsUpdateable('i8__SOE__c');     
        Id UserId = String.escapeSingleQuotes(UserInfo.getUserId());
        if(Utils.isAccessible('User')) {
            CurUser = [select Broadcast__c,MIS_MyView__c from User where id=: UserId ];       
            MyView = CurUser.MIS_MyView__c;
            BroadCast = CurUser.Broadcast__c;
        }
        userTimeZone = String.valueOf(UserInfo.getTimeZone());
        if(SOE_Accessible){
        SOEList = [select id,Name,Imp_Start__c ,Status__c,SOE_Title__c,MIS__r.Name,Min_Planned_Start__c ,Max_Planned_End__c,SOE_RAG__c,Imp_Duration__c,Schedule_Start__c,
        Min_Forecast_Start__c,Max_Forecast_End__c,Dealy_Ahead_mins__c,OwnerId,Not_Comp_Pre_Stacks__c,Comp_Pre_Stacks__c,  
        BAU_Impact__c,Schedule_End__c,Max_End_Time__c from SOE__c where MIS__c =: MISID  order by Schedule_Start__c,Min_Planned_Start__c]; 
        boolean bool = true,bool1 = true,bool2 = true;
        set<id> SOEIds = new set<id>();
        for(SOE__c soe: SOEList){
            SOEIds.add(soe.id);
            if(soe.Status__c != i8.STATUS_IMPINPROGRESS){
                bool = false;
                break;
            }
            else if(soe.Status__c == i8.STATUS_IMPINPROGRESS){
                bool = true;
                break;
            }
        }
        for(SOE__c soe: SOEList){
            if(soe.Status__c != i8.STATUS_IMP_COMP ){
                bool1 = false;
                break;
            }
            else if(soe.Status__c == i8.STATUS_IMP_COMP ){
                bool1 = true;
                break;
            }
       }for(SOE__c soe: SOEList){
            if(soe.Status__c != i8.STATUS_SOE_COMP ){
                bool2 = false;
                break;
            }
            else if(soe.Status__c == i8.STATUS_SOE_COMP ){
                bool2 = true;
                break;
            }
        }
        if(bool == false && bool1 == false && bool2 == false)
            MisStatus ='NOT In Progress';
        else if(bool == true)
            MisStatus = i8.STATUS_IMPINPROGRESS;
        else if(bool1 == true)
            MisStatus = i8.STATUS_IMP_COMP ;
        else if(bool2 == true)
            MisStatus = i8.STATUS_SOE_COMP ;
        //broadcast message         
        BroadCastMsg = '***';
        DateTime dt = System.Now();
        if(Utils.isAccessible('i8__BroadCast__c'))
        for( Broadcast__c bc : [select name,Message__c from Broadcast__c where Status__c = 'Active' And Message_Start_Date__c <=: dt and  Message_End_Date__c >=: dt And (SOE__c IN : SOEIds or All_Users__c = true)  order by lastmodifiedDate  desc limit 5])
            BroadCastMsg += bc.Message__c +' ***';
        if(BroadCastMsg  == '***')
            BroadCastMsg += ' No Messages to display ***';             
        ImpMgrMap = new Map<Id,Id>();
        if(Utils.IsAccessible('i8__MIS_Manager__c'))
        for(MIS_Manager__c mis: [select id,MIS_Manager__c from MIS_Manager__c where MIS__c =: MISID])
                ImpMgrMap.put(mis.MIS_Manager__c ,mis.MIS_Manager__c );
       if(Schema.SOBjectTYpe.Profile.isAccessible())
         if([Select Id,Name from Profile where Id=:userInfo.getProfileId()].Name == 'System Administrator')
             ImpMgrMap.put(userInfo.getUserId(),userInfo.getUserId());
        ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', ''); 
        TwilioSettings = new Map<string,string>();
        TwilioSettings = SystemSettings_Util.getTwilioSettings();
        if(TwilioSettings.containskey ('Twilio_Installed') &&  TwilioSettings.get('Twilio_Installed').ToUpperCase() == 'YES')
            TwilioInstalled = true;
        else
             TwilioInstalled = false;  
        }else errmsg = System.Label.ADMIN001;
    }
   @RemoteAction
    Global  static WrapperTasks getTasks(string s,string t,id misid,integer size,integer offset) {   
        string countquery = 'select count(id) cnt from Task__c where SOE__c IN(select id from SOE__c where MIS__c =\'' + misid+ '\') '+ t;
        set<id> Stackowner_set=new set<id>();
        integer RecCount ;
        list<task__c> TaskList = new list<Task__C>(); 
        list<task__c> TaskList1 = new list<Task__C>(); 
        if( Utils.isAccessible('i8__Task__c') && Utils.isAccessible('i8__SOE__c')){
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
        }else LogFactory.debug('MIS_AllTasks_Cntrl', 'Remote Action', 'Task Info ', System.Label.ADMIN001,'Line - 138');
        MIS__c mis;
        if( Utils.isAccessible('i8__MIS__c'))
            mis = [select id,Name,MIS_Title__c,MIS_PlannedStart__c,MIS_PlannedEnd__c from MIS__c where id=:misid];
        else
              LogFactory.debug('MIS All Tasks', 'Remote Action', 'MIS Info ', System.Label.ADMIN001,'Line - 144');
        Map<ID,ID> soeMap = new Map<Id,Id>();
        string soe='';
        for(Task__c tas: TAskList){
            if(!SOEMap.containskey(tas.SOE__c)){
                SOEMap.put(tas.SOE__c,tas.SOE__c);
                soe += tas.SOE__c+',';
            }
        }
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
                LogFactory.debug('MIS_AllTasks_Cntrl', 'Remote Action', 'Team Member Info ', System.Label.ADMIN001,'Line - 165');
        }
        if(Schema.sObjectType.AuthSession.isAccessible()){        
            AggregateResult[] groupedResults =  [SELECT  Max(LastModifiedDate) LastDate,NumSecondsValid,UsersId FROM AuthSession WHERE SessionType = 'UI' AND LoginType = 'Application' AND UsersID IN: OwnerList Group By UsersId,NumSecondsValid] ;
            for(AggregateResult ar: groupedResults ){
                DAteTime dt = DateTime.valueof(ar.get('LastDate'));
                integer seconds = integer.valueof(ar.get('NumSecondsValid'));
                if(System.Now() < dt.AddSeconds(seconds))
                    UserList.add(string.valueof(ar.get('UsersId')));
            }
        }
        else
            LogFactory.debug('MIS All Tasks', 'Remote Action', 'Auth Session ', System.Label.ADMIN001,'Line - 177');
        LogFactory.SAveLog();
        return new  WrapperTasks(TaskList,RecCount,UserList,mis,soe);          
    }
    Global class WrapperTasks{
        public list<Task__c> Tasks{get;set;}
        public integer count{get;set;}
        public list<string> users{get;set;}
        public MIS__c mis{get;set;}
        public string listsoes{get;set;}
        public WrapperTasks(list<Task__c> tas, integer cnt,list<string> str,MIS__c so,string slst){
            Tasks = tas;
            count = cnt;
            users = str;
            mis = so;
            listsoes = slst;
        }
    }    
    public void UpdateTasks(){ 
    errmsg = null;
        inputValue = ApexPages.CurrentPage().getParameters().get('input1');
        if(Task_Accessible && Task_Update){
        try{ 
            if(inputValue.length() >= 15){
                list<string> Soes = inputValue.split(',');
                if(soes.Size() >0)
                    Task_TriggerHandler.UpdateAllTasks(Soes,i8.CONTEXT_IMP);            }
         }catch(Exception e){
            LogFactory.error('MIS_AllTasks_Cntrl','UpdateTasks','',e.getMessage()+''+e.getSTackTraceString());
            LOgFactory.SaveLog();
            errmsg = e.getMessage();
        }
        }else errmsg = System.Label.ADMIN001;
    }
    public void ActivateTask1(){
        ActiveTAskId = ApexPages.CurrentPage().getParameters().get('ActiveId');
        inputValue = ApexPages.CurrentPage().getParameters().get('input1');
        errmsg = null;
        if(Task_Accessible && Task_Update){
        Savepoint sp = Database.setSavePoint();
        try{
            Task__c CurTask = [select id,status__c,Days__c,Hours__c ,Minutes__c ,Start_Time__c ,End_Time__c ,Actual_Start__c,Forecast_End__c ,Id_Before_decimal__c ,SOE__c,Stage_Level__c from TAsk__c where id =: ActiveTAskId];
            CurTask.Status__c = i8.STATUS_RUNNING ;
            Datetime dt = system.now();
            CurTAsk.Start_Time__c = dt;
            CurTask.End_Time__c = CurTask.Start_Time__c .addDays(Integer.valueof(CurTask.Days__c));
            CurTask.End_Time__c = CurTask.End_Time__c.addHours(Integer.valueof(CurTask.Hours__c ));
            CurTask.End_Time__c = CurTask.End_Time__c.addMinutes(Integer.valueof(CurTask.Minutes__c ));
            curTask.Actual_start__c = CurTAsk.Start_Time__c;
            curTask.Forecast_start__c = CurTAsk.Start_Time__c;
            CurTAsk.Forecast_end__c = CurTask.End_Time__c ;
            CurTask.Activated_By__c = UserInfo.getFirstname() +' '+ UserInfo.getLastname();  
            LogFactory.info('MIS_AllTasks_Cntrl','ActivateTask','CurTask',JSON.serialize(CurTask),'Line - 198');
            if(Task_Update)      
                update CurTask;
            Task__c StackTask = [select id,SOE__c,Status__c,Stage__c,Days__c,Hours__c,Minutes__c,Start_Time__c,End_Time__c,Actual_Start__c ,Forecast_End__c  from task__c where Is_Stack__c = true and ID_Before_Decimal__c =: CurTask.Id_Before_decimal__c and SOE__c =: CurTask.SOE__c and Stage_Level__c=: CurTASk.Stage_Level__c];
            if(StackTask.Status__c == null){
                StackTask.Status__c = i8.STATUS_RUNNING;
                StackTask.Actual_start__c = dt;
                StackTask.Forecast_start__c = dt;
                if(Task_Update)
                    update StackTask;            
            }
            UpdateTasks();
            if(SOE_Accessible){       
            SOE__c CurSOE = [select id,Imp_Start__c from SOE__C where id=: StackTask.SOE__c];
            if(StackTask.Stage__c == i8.STAGE_IMP && StackTask.Status__c == I8.STATUS_RUNNING &&  CurSOE.Imp_Start__c  == false){
                   CurSOE.Imp_Start__c = true;
                   if(Utils.isUpdateable('i8__SOE__c') )
                       update CurSOE;
            }           
            }else LogFactory.debug('MIS All Tasks', 'ActivateTasks1', 'MIS Info ', System.Label.ADMIN001,'Line - 246');
        }catch(Exception e){
            Database.Rollback(sp);
            LogFactory.error('AllTasks_ClientSide_Cntrl','ActivateTask','',e.getMessage()+''+e.getSTackTraceString());
            errmsg = e.getMessage();
        }   
        }else errmsg = System.Label.ADMIN001;
        LogFactory.SaveLog();  
    }
    public pagereference CompleteTask(){
        errmsg = null;
        if(Task_Accessible && Task_Update ){
        try{
            ActiveTAskId = ApexPages.CurrentPage().getParameters().get('ActiveId');
            AllTasks_ClientSide_Cntrl.CompleteTaskMethod(ActiveTAskId,i8);
            UpdateTasks();
         } Catch(EXception e){
            LogFactory.error('MIS_AllTasks_cntrl','CompleteTask','',e.getMessage()+''+e.getSTackTraceString());
            errmsg = e.getMessage();
        } 
        }
        else errmsg = System.Label.ADMIN001;
        LogFactory.Savelog();
        return null;
    }   
     public pagereference ReRunTask(){
         errmsg = null;
         if(Task_Accessible && Task_Update ){
         try{
            ActiveTAskId = ApexPages.CurrentPage().getParameters().get('ActiveId');            
            Task__c CurTask = [select id,status__c from TAsk__c where id =: ActiveTAskId];
            CurTask.Status__c = i8.STATUS_RUNNING ;
            LogFactory.info('MIS_AllTasks_Cntrl','ReRunTask','CurTask',JSON.serialize(CurTask),'Line - 240');
            if(Task_Update)
                update CurTask;
         } Catch(EXception e){
            LogFactory.error('MIS_AllTasks_Cntrl','ReRunTask','',e.getMessage()+''+e.getSTackTraceString());
            errmsg = e.getMessage();
        } 
        }else errmsg = System.Label.ADMIN001;
        LogFactory.Savelog();
        return null;
    }   
    public pagereference Cancel(){
            if(UserInfo.getUiThemeDisplayed() == 'Theme3')
                return new PageReference('javascript:window.close()');
            else
                return new pagereference('/'+MISId);
    }
    public void BroadCastOnOff(){
        if(CurUser.Broadcast__c == true)
            CurUser.Broadcast__c = false;
        else
            CurUser.Broadcast__c = true;
       if(Utils.isUpdateable('User'))
        update CurUser;
        BroadCast = CurUser.Broadcast__c;
    }    
    global void CreateCall() {
        string phNumber =  ApexPages.CurrentPage().getParameters().get('ActiveId');
        try{
            LogFactory.info('MIS_AllTasks_Cntrl','CreateCall','Phone Number',phNumber,'Line - 268');
                Type t = Type.forName(TwilioSettings.get('Twilio_Class_Name')); 
                TwilioUtilityInterface newObj = (TwilioUtilityInterface)t.newInstance(); 
                newObj.SendCall(phNumber);         } Catch(EXception e){
            LogFactory.error('MIS_AllTasks_Cntrl','CreateCall','',e.getMessage()+''+e.getSTackTraceString());
            errmsg = e.getMessage();
        } 
        LogFactory.Savelog();
    }
    global void CreateSMS() {      
        string phNumber =  ApexPages.CurrentPage().getParameters().get('ActiveId'); 
        try{
            phNumber = '+'+phNumber;
             LogFactory.info('MIS_AllTasks_Cntrl','CreateSMS','Phone number',phNumber,'Line - 284');
            string body =  ApexPages.CurrentPage().getParameters().get('body1'); 
                Type t = Type.forName(TwilioSettings.get('Twilio_Class_Name')); 
                TwilioUtilityInterface newObj = (TwilioUtilityInterface)t.newInstance(); 
                statusmsg  = newObj.SendSMS(new list<string>{phNumber},body);
         } Catch(EXception e){
            LogFactory.error('MIS_AllTasks_Cntrl','CreateSMS','',e.getMessage()+''+e.getSTackTraceString());
            errmsg = e.getMessage();
        } 
        LogFactory.Savelog();
    }
    public pagereference AddPINtoTask(){
        string body =  ApexPages.CurrentPage().getParameters().get('body1'); 
        string taskid =  ApexPages.CurrentPage().getParameters().get('tas'); 
        errmsg = null;
        if(Task_Accessible && Task_Update){
        try{
            if(body != null  && body != ''){
                 Task__c tas = [select id,PIN__c,ID_Text__c,SOE__r.Name from Task__c where id=: taskid];
                 LogFactory.info('MIS_AllTasks_Cntrl','AddPINToTask','Task',JSON.serialize(tas),'Line - 303');
                 if(tas.PIN__c == null)
                     tas.PIN__c = '';         
                 tas.PIN__c  =system.Now()+'-'+UserInfo.getFirstname()+':'+body+'@'+tas.PIN__c; 
                 if(Task_Update)
                     update tas;
                 errmsg = 'updated successfully'; 
            }  
         } Catch(EXception e){
            LogFactory.error('MIS_AllTasks_Cntrl','AddPINtoTask','',e.getMessage()+''+e.getSTackTraceString());
            errmsg = e.getMessage();
        } 
        }else errmsg = System.Label.ADMIN001;
        LogFactory.Savelog();       
        return null;
    }
    public pagereference openListIncidents(){
        return new pagereference('/apex/ListIncidents_ClientSide?Mid='+MISID);
    }
    public pagereference openListOpenIncidents(){
        return new pagereference('/apex/ListIncidents_ClientSide?Mid='+MISID+'&status=open');
    }
    public pagereference openListClosedIncidents(){
        return new pagereference('/apex/ListIncidents_ClientSide?Mid='+MISID+'&status=closed');
    }
    public pagereference openModifyTask(){
        string TaskId = ApexPages.CurrentPage().getParameters().get('ActiveId');
        string level = ApexPages.CurrentPage().getParameters().get('Level');
        return new pagereference('/apex/ModifyTask_ClientSide?Mid='+MISID+'&id='+TaskId +'&level='+level+'&page=edit');
    }
    public pagereference openMISDashboards(){
        return new pagereference('/apex/MIS_DashBoards?id='+MISID);
    }
    public pagereference openAddDocuments(){
        string TaskId = ApexPages.CurrentPage().getParameters().get('ActiveId');
        return new pagereference('/apex/AddDocument_ClientSide?id='+TaskId+'&Mid='+MISID);
    }
    public pagereference openCreateIncident(){
        return new pagereference('/apex/CreateIncident_ClientSide?MId='+MISId);
    } 
     public pagereference openAllDocuments(){
        return new pagereference('/apex/ViewAllDocuments_ClientSide?id='+MISId);
    }
    public pagereference openResourceROTA(){
        return new pagereference('/apex/ROTA?id='+MISId);
    }
    public pagereference openHistoryPage(){
        return new pagereference('/apex/History?id='+MISId);
    } 
    public pagereference openMyView(){
        return new pagereference('/apex/SOE_MyView?id='+MISId);        
    } 
    public pagereference openTaskGanttChart(){
        return new pagereference('/apex/StackGanttChart?id='+MISId);        
    }
    public pagereference openResourceGanttChart(){
        return new pagereference('/apex/SOEResource_Gantt?Mid='+MISId);        
    }     
}