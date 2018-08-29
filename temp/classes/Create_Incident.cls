/* 
Class Name        : Create_Incident
Test Class Name   : Test_Create_Incident_Method
Purpose/Overview  : To raise the incident on either SOE,MIS or Task.
Author            : Purview Ltd.
Code Coverage     :     86%.
Change History    : 
*/
public with sharing class Create_Incident {
    public boolean errorbool { get; set; }
    public Incident__c INCOBJ {get; set;}
    Public String MaxInc{get;set;}
    Public SOE__c SOE {get; set;}
    Public String GetID {get; set;}
    Public string Add_Note {get; set;}
    public String type{get;set;}
    public Id INCID{get;set;}
    public Id MISID{get;set;}
    public Id TaskId{get;set;}
    public I8Constants i8{get;set;}
    public Task__c tas;
    public static boolean ReExecute{get;set;}
    public string errmsg{get;set;}
    public static boolean SOE_ReExe;
    public boolean access{get;set;}
    
    Public Create_Incident(){
        ReExecute = false;
        errorbool = false;
        access = true;
        INCID = ApexPages.CurrentPage().GetParameters().Get('INCId');
        TaskId = ApexPages.CurrentPage().GetParameters().Get('TAskId');
        MISID = ApexPages.CurrentPage().GetParameters().Get('MId');
        i8= new I8Constants();
        GetID = ApexPages.CurrentPage().GetParameters().Get('SOEId');
        type = ApexPages.CurrentPage().GetParameters().Get('type');
        if(GetID !=  null && Utils.isAccessible('i8__SOE__c'))
            SOE = [select id,name,SOE_Title__c,State__c,QA_Review_Required__c,QA_Review__c,WalkThrough_Required__c,WalkThrough__c,Max_Planned_End__c,Max_End_Time__c,Max_Forecast_End__c,Dealy_Ahead_mins__c,Status__c from SOE__c where id =: GetID];
        
        if(Utils.isAccess_Create('i8__Incident__c')){
            Integer count = [SELECT count() FROM Incident__c limit 1];
        string IncNo;
        If(count > 0){
            IncNo = [select name from Incident__c order by name desc  limit 1 ALL ROWS].Name;
            If(INCID != NULL)
                IncNo= String.valueof(Integer.valueof(IncNo.substring(2,IncNo.length())));
            else
                IncNo= String.valueof(Integer.valueof(IncNo.substring(2,IncNo.length()))+1);
        }
        else
            IncNo= String.valueof(1);
        if(IncNo.length() ==1)
            MAxInc = 'I - 000'+IncNo;
        else if(IncNo.length() ==2)
            MAxInc = 'I - 00'+IncNo;
        else if(IncNo.length() ==3)
            MAxInc = 'I - 0'+IncNo;         
        else
            MAxInc = 'I - '+IncNo;
            if(INCID != null)
                INCOBJ = [select id,name,Assignee__c,INC_on_Object__c,CI__c,Company__c,Impact_Analysis__c,Technical_Recommendation__c,Resolution_Type__c,Risk_Mitigation__c,Root_Cause__c,Contact__c,Customer__c,Impact__c,Inc_Close_Time__c,Inc_Open_Time__c,Inc_Type__c,Notes__c,Priority__c,Service__c,SOE1__c,MIS__c,Status__c,Summary__c,Target_Date__c,Task__c,Urgency__c from Incident__c  where id=: INCID];
            if(INCID == null){
                INCOBJ = New Incident__c();
                if(SOE != null)
                    INCOBJ.SOE1__c = SOE.id;
                INCOBJ.MIS__c = MISID;
                INCOBJ.Status__c = 'open';
                INCOBJ.Inc_Open_Time__c = system.now();
            }
            if(TaskId != null){
                if(Utils.isAccessible('i8__Task__c'))
                    tas = [select id,Status__c,Id_Before_Decimal__c,SOE__c,Stage_Level__c from Task__c where id=:TaskId];
                INCOBJ.Task__c = TaskId;
                if(type == 'Suspend')
                    INCOBJ.Inc_Type__c = i8.STATUS_SUSPENDED;
                else  if(type == 'Force')
                    INCOBJ.Inc_Type__c = i8.STATUS_FORCE_COMP;
                INCOBJ.INC_on_Object__c = 'Task';
            }
            if(TaskId == null){
                if(Type == 'Abandoned'){
                    INCOBJ.Inc_Type__c = i8.STATUS_ABANDONED;
                    INCOBJ.INC_on_Object__c = 'SOE';
                }
                else if(type == 'Suspend'){
                    INCOBJ.Inc_Type__c = i8.STATUS_SUSPENDED;
                    INCOBJ.INC_on_Object__c = 'SOE';
                }
                else if(type == 'Backout'){
                    INCOBJ.Inc_Type__c = 'Backout';
                    INCOBJ.INC_on_Object__c = 'SOE';
                }
                else{
                    INCOBJ.INC_on_Object__c = 'SOE';
                }
            }
        }
        else{errorbool = true; errmsg = System.Label.AddTask006;access = false;}
    }    
    public pagereference Add_Note_Action(){        
        if(Add_Note != null && Add_Note != ''){
            if(Incobj.Notes__c == null)
                Incobj.Notes__c ='';
            Incobj.Notes__c+='\n'+system.Now()+'-'+UserInfo.getFirstName() +':'+ Add_Note;
            Add_Note='';            
        }  
        return null;
    }    
    Public Pagereference save_INC(){
        errorbool = false;
        errmsg ='';         
        if(type == 'Suspend' && TaskId == null){
            INCOBJ.Inc_Type__c = i8.STATUS_SUSPENDED;
            INCOBJ.INC_on_Object__c = 'SOE';
        }
        else if( type == 'ReExecute' && TaskId == null) {
            INCOBJ.Status__c = i8.STATUS_CLOSE;
            IncOBj.Inc_Close_Time__c = System.now();
        }
        else if( type == 'backout' && TaskId == null) {
            INCOBJ.Inc_Type__c = 'Backout';
            INCOBJ.Status__c = i8.STATUS_CLOSE;
            IncOBj.Inc_Close_Time__c = System.now();
            INCOBJ.INC_on_Object__c = 'SOE';
        }
        else if(type == 'Abandoned') {
            INCOBJ.Inc_Type__c = i8.STATUS_ABANDONED;
            INCOBJ.Status__c = i8.STATUS_CLOSE;
            IncOBj.Inc_Close_Time__c = System.now();
            INCOBJ.INC_on_Object__c = 'SOE';
        }
        else if(type == 'Suspend' && TaskId != null){
            INCOBJ.Inc_Type__c = i8.STATUS_SUSPENDED;
            INCOBJ.INC_on_Object__c = 'Task';
        }
        else if(type == 'ReExecute' && TaskId != null) {
            INCOBJ.Status__c = i8.STATUS_CLOSE;
            IncOBj.Inc_Close_Time__c = System.now();
        }
        if(INCOBJ.Inc_Type__c == 'Bug' || INCOBJ.Inc_Type__c == 'Info' ){
            INCOBJ.Status__c = i8.STATUS_CLOSE ;
            IncOBj.Inc_Close_Time__c = System.now();
        }        
        if(INCOBJ.Inc_Type__c  == '' || INCOBJ.Inc_Type__c == null){
            errorbool = true;
            errmsg= System.Label.CreateIncident001+'\n';
        }
        if(INCOBJ.Summary__c== '' || INCOBJ.Summary__c== null){
            errorbool = true;
            errmsg = '\n'+System.Label.CreateIncident002+'\r\n';
        }
        if(INCOBJ.Priority__c== '' || INCOBJ.Priority__c== null){
            errorbool = true;
            errmsg ='\n '+System.Label.CreateIncident003;
        }
        if( INCOBJ.Assignee__c == null && INCOBJ.Inc_Type__c == i8.STATUS_SUSPENDED ){
            errorbool = true;
            errmsg = '\n '+System.Label.CreateIncident004;
        }
        Savepoint sp = Database.setSavepoint();
        try{
            if(errorbool == false){
                boolean soeUpdate = Utils.isUpdateable('i8__SOE__c');
                boolean taskUpdate = Utils.isUpdateable('i8__Task__c');
                If(INCOBJ.INC_on_Object__c == 'SOE')
                    INCOBJ.Task__c = null;
                LogFactory.info('Create_Incident', 'save_INC', 'Incident', JSON.serialize(INCOBJ), 'Line - 167');
                if(INCOBJ.Id == null && Utils.isCreateable('i8__Incident__c'))
                    insert INCOBJ;
                else if(INCOBJ.Id != null && Utils.isUpdateable('i8__Incident__c'))
                    Update INCOBJ;
                else {errorbool = true;errmsg = System.Label.AddTask001;access = false;
                LogFactory.debug('Create_Incident', 'Save_Inc', 'Incident Info', System.Label.AddTask001 ,'Line - 173');}
                if(type == 'Suspend' && SOE.Status__c != i8.STATUS_SUSPENDED && TaskId == null) {
                    SOE.Status__c = i8.STATUS_SUSPENDED;
                    LogFactory.info('Create_Incident', 'save_INC', 'SOE', JSON.serialize(SOE), 'Line - 176');
                    if(soeUpdate )   update SOE;
                    Task_TriggerHandler.UpdateAllTasks(new list<id>{SOE.Id},i8.CONTEXT_IMP);
                }
                else if(type == 'backout' && SOE.Status__c != i8.STATUS_BOINPROGRESS && TaskId == null) {
                    SOE.Status__c = i8.STATUS_BOINPROGRESS;
                    LogFactory.info('Create_Incident', 'save_INC', 'SOE', JSON.serialize(SOE), 'Line - 182');
                    if(soeUpdate )
                        update SOE;
                    Task_TriggerHandler.UpdateAllTasks(new list<Id>{SOE.Id},i8.CONTEXT_IMP);
                    Task_TriggerHandler.UpdateAllTasks(new list<id>{SOE.Id},i8.CONTEXT_BO);
                }
                else if(type == 'Abandoned' && SOE.Status__c != i8.STATUS_ABANDONED && TaskId == null) {
                    SOE.Status__c = i8.STATUS_ABANDONED;
                    LogFactory.info('Create_Incident', 'save_INC', 'SOE', JSON.serialize(SOE), 'Line - 181');
                    if(soeUpdate)
                        update SOE;
                    Task_TriggerHandler.UpdateAllTasks(new list<id>{SOE.Id},i8.CONTEXT_IMP);
                }
                else if(type == 'ReExecute' && SOE.Status__c == i8.STATUS_SUSPENDED) {
                    SOE.Status__c =  i8.STATUS_IMPINPROGRESS ;
                    if(Utils.isAccessible('i8__Incident__c')){
                        AggregateResult[] IncResults = [select SUM(Incident_Duration__c) Dur from Incident__c where SOE1__c =: SOE.Id and Inc_Type__c =: i8.STATUS_SUSPENDED and (Status__c =: i8.STATUS_CLOSE or Status__c =: i8.STATUS_OPEN) and INC_on_Object__c = 'SOE' group By SOE1__c];
                        SOE.Suspended_Time_mins__c = Integer.valueof(IncResults[0].get('Dur'));
                    }
                    LogFactory.info('Create_Incident', 'save_INC', 'SOE', JSON.serialize(SOE), 'Line - 201');
                    if(soeUpdate)
                        update SOE;
                    SOE_ReExe = true;
                    Task_TriggerHandler.UpdateAllTasks(new list<id>{SOE.Id},i8.CONTEXT_IMP);
                    SOE_ReExe = false;
                    ReExecute = true;
                }
                else if(type == 'Suspend' && TaskId != null){
                    tas.Status__c = i8.STATUS_SUSPENDED;
                    LogFactory.info('Create_Incident', 'save_INC', 'Task', JSON.serialize(tas), 'Line - 211');
                    if(taskUpdate )
                        update tas;
                }
                else if(type == 'Force' && TaskId != null){
                    AllTasks_ClientSide_Cntrl.CompleteTaskMethod(TaskId,i8);
                    Task_TriggerHandler.UpdateAllTasks(new list<id>{SOE.Id},i8.CONTEXT_IMP);
                }
                else if(type == 'ReExecute' && TaskId != null) {
                    tas.Status__c = i8.STATUS_RUNNING;
                    LogFactory.info('Create_Incident', 'save_INC', 'Task', JSON.serialize(tas), 'Line - 221');
                    if(taskUpdate )
                        update tas;                   
                }
                LogFactory.SaveLog(); 
                if(TaskId  == null){
                    if(MISID != null)
                        return new pagereference('/apex/MIS_AllTasks?id='+MISID);
                    else
                        return new pagereference('/apex/AllTasks_ClientSide?id='+GetID);
                }
                else {
                    if(MISID != null)
                        return new pagereference('/apex/ModifyTask_ClientSide?id='+TaskId+'&page=edit&MId='+MISID+'&level='+tas.Stage_Level__c);
                    else
                        return new pagereference('/apex/ModifyTask_ClientSide?id='+TaskId+'&page=edit&SId='+GetId+'&level='+tas.Stage_Level__c);
                }
            }
        }catch(Exception e){
            Database.rollback(sp);
            LogFactory.error('Create_Incident', 'save_INC', '', e.getMessage() + '' + e.getStackTraceString());  
            LogFactory.SaveLog(); 
            errorbool = true;
            errmsg = e.getMessage();                  
        }
        return null;
    }
    Public Pagereference cancel_INC(){
        if(TaskId  == null){
            if(MISID != null)
                return new pagereference('/apex/MIS_AllTasks?id='+MISID);
            else
                return new pagereference('/apex/AllTasks_ClientSide?id='+GetID); 
        }
        else{
            if(tas == null)
                tas = new Task__c(Stage_level__c = 'Implementation');
            if(MISID != null)
                return new pagereference('/apex/ModifyTask_ClientSide?id='+TaskId+'&page=edit&MId='+MISID+'&level='+tas.Stage_Level__c);
            else            
                return new pagereference('/apex/ModifyTask_ClientSide?id='+TaskId+'&page=edit&SId='+GetId+'&level='+tas.Stage_Level__c);
        }
        return null;
    }
}