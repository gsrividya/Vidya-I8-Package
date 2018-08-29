/* 
Class Name        : Stack_CreateMove_Cntrl
Test Class Name   : Test_Stack_CreateMove_Cntrl
Purpose/Overview  : To create new stack or move stack from one position to another position within SOE.
Author            : Purview Ltd.
Code Coverage     : 94%.
Change History    : 
*/
public with sharing class Stack_CreateMove_Cntrl {
    public SOE__c SOEObj{get;set;}
    public i8Constants i8{get;set;}
    public boolean error{get;set;}
    public string errormessage{get;set;}
    public String BAValue{get;set;}
    public string SourceStage{get;set;}
    public string SourceStack{get;set;}
    public string TargetStage{get;set;}
    public string TargetStack{get;set;}
    public List<SelectOption> StagesList{get;set;}
    public List<SelectOption> SourceStacks{get;set;}
    public List<SelectOption> TargetStacks{get;set;}
    public string page;
    public task__c taskobj{get;set;}
    public Map<string,Task__c> SourceMap{get;set;}
    Public Map<Id,Id> ImpMgrMap{get;set;}
    public string ImpMgrMapKey{get;set;}
    public List<Dependency__c> deplist ;
    boolean Task_Create ;
    public Id SOEId ;
    
    public Stack_CreateMove_Cntrl(){
        SOEId = ApexPages.CurrentPage().getParameters().get('id');
        i8 = new i8Constants();
        Task_Create = Utils.isAccess_Create_Update('i8__Task__c');
        if(Task_Create ) {
        if(Utils.isAccessible('i8__SOE__c'))
            SOEobj = [select id,name,Post_Implementation_Stage__c,Pre_Implementation_Stage__c,BackOut_Stage__c,QA_Review__c,WalkThrough__c,Task_Late_Threshold_Mins__c,status__c,WalkThrough_Required__c,QA_Review_Required__c from SOE__c where id=: SOEId];
        ImpMgrMap = new Map<Id,Id>();
        list<string> RolesLIst = System.Label.Roles_To_Edit_SOE.split(',');
        if(Utils.isAccessible('i8__SOE_Team_Member__c'))
        for( SOE_Team_Member__c imp : [select Id,Name,Team_Member__r.Salesforce_User__c,Access_Level__c  from SOE_Team_Member__c where SOE__c =: SOEObj.Id  and Access_Level__c != 'Read'  and Role__r.Reference_Role__c  IN : RolesLIst ])  
            ImpMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
        if(Schema.sObjectType.Profile.isAccessible())
        if([Select Id,Name from Profile where Id=:userInfo.getProfileId()].Name == 'System Administrator')
             ImpMgrMap.put(userInfo.getUserId(),userInfo.getUserId());
        ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', '');
        page = ApexPages.CurrentPage().getParameters().get('page');
        BAValue ='+';
        taskobj = new Task__c();
        Taskobj.Stage_Level__c = i8.CONTEXT_IMP;
        deplist = new List<Dependency__c>();
            StageList();
        }
    }
    public void TargetStageList(){
        StageList();
    }
    public List<selectOption> StageList(){
        StagesList = new List<SelectOption>();
        if( taskobj.Stage_Level__c == i8.CONTEXT_IMP){
            If(SOEobj.Pre_Implementation_Stage__c == True ){
                StagesList.add(new selectoption(i8.STAGE_PRE,i8.STAGE_PRE));
                SourceStage = i8.STAGE_PRE;
                TargetStage = i8.STAGE_PRE;
            }
            StagesList.add(new selectoption(i8.STAGE_Imp,i8.STAGE_Imp));
            If(SOEobj.Post_Implementation_Stage__c == True){
                StagesList.add(new selectoption(i8.STAGE_Post,i8.STAGE_Post));
            }
            if(SOEobj.Pre_Implementation_Stage__c == False){
                SourceStage = i8.STAGE_IMP;
                TargetStage = i8.STAGE_IMP;
            } 
        } 
        else if( taskobj.Stage_Level__c == i8.CONTEXT_BO && SOEObj.Backout_STage__c == true){
            StagesList.add(new selectoption(i8.STAGE_Imp,i8.STAGE_Imp));
            If(SOEobj.Post_Implementation_Stage__c == True)
                StagesList.add(new selectoption(i8.STAGE_Post,i8.STAGE_Post));
            SourceStage = i8.STAGE_IMP;
            TargetStage = i8.STAGE_IMP;
        }
        if(page == 'move')
            getSourceStackList();  
        getTargetStackList();    
        return StagesList;
    }
    public List<task__c> returntasks(string opt,string contype){
        List<task__c> taslis = new List<task__c>();
        if(SOEObj != null && opt != '' && contype != ''){
            if(Task_Create )
                taslis = [select Id_Before_Decimal__c,Status__c,Task_Title__c,Jump__c  from Task__c where Is_Stack__c = True and SOE__c =: SOEObj.Id and Stage__c =: opt and Stage_Level__c =: contype order by Id_Before_Decimal__c];
        }
        return taslis;
    }
    public void getSourceStackList(){
        SourceStacks = new List<SelectOption>();
        SourceMap = new Map<string,task__c>();
        List<task__c> tasklistret = returntasks(SourceStage,i8.CONTEXT_IMP);
        if(tasklistret.size() == 0){
            SourceStacks = new List<SelectOption>();
        }else{
            for(Task__c tas : tasklistret){
                SourceStacks.add(new selectOption(String.ValueOf(tas.Id_Before_Decimal__c),tas.Id_Before_Decimal__c+'.'+tas.Task_Title__c));
                SourceMap.put(String.ValueOf(tas.Id_Before_Decimal__c),tas);
            }
        } 
    }
    public void getTargetStackList(){
        TargetStacks = new List<SelectOption>();
        List<task__c> tasklistret = returntasks(TargetStage,taskobj.Stage_Level__c);
        if(tasklistret.size() == 0){
            TargetStacks = new List<SelectOption>();
        }
        else{
            for(Task__c tas : tasklistret){
                TargetStacks.add(new selectOption(String.ValueOf(tas.Id_Before_Decimal__c),tas.Id_Before_Decimal__c+'.'+tas.Task_Title__c));
            }
        } 
    }
    public pagereference moveStack(){
        Set<Id> DelTaskId = new Set<Id>();
        if(Task_Create ){
            Savepoint sp = Database.setSavepoint();   
            try{
            Integer StackCount = [select count() from Task__c where SOE__c =: SOEObj.Id and Stage__c =: SourceStage and Id_Before_Decimal__c !=: integer.valueof(SourceStack) and Stage_Level__c =: i8.CONTEXT_IMP];
            if(StackCount == 0){
                error = true;
                errormessage = System.Label.Stack001;            
            }else if( SourceStack == TargetStack){
                error = true;
                errormessage = System.Label.Stack002; 
            }else if( SourceMap.get(SourceStack).Status__c == i8.STATUS_RUNNING || SourceMap.get(SourceStack).Status__c == i8.STATUS_COMPLETED || SourceMap.get(SourceStack).Status__c == i8.STATUS_COMP_JUMP || SourceMap.get(SourceStack).Jump__c == true){
                error = true;
                errormessage = System.Label.Stack003; 
            }            
            else{            
                error = false;
                LogFactory.debug('Stack_CreateMove_Cntrl', 'MoveStack', 'Source Stack ', 'Selected Source Stack Id is '+SourceStack ,'Line - 127');  
                LogFactory.debug('Stack_CreateMove_Cntrl', 'MoveStack', 'Target Stack', 'Selected Target Stack Id is '+TargetStack,'Line - 128');           
                List<Task__c> tasklist = [select id,Total_mins__c,Is_Stack__c,Task_Title__c,Id_after_decimal__c,Id_Before_Decimal__c,Jump__c from Task__c where SOE__c =: SOEObj.Id and Id_Before_Decimal__c =: integer.valueof(SourceStack) and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_Decimal__c];
                for(Task__c tas : tasklist){
                    DelTaskId.add(tas.Id);
                    if(BAValue == '+'){
                        if(SourceStack > TargetStack )
                            tas.Id_Text__c = String.ValueOF(Integer.ValueOf(TargetStack)+1)+'.'+tas.Id_after_decimal__c;
                        else
                            tas.Id_Text__c = String.ValueOF(Integer.ValueOf(TargetStack))+'.'+tas.Id_after_decimal__c;
                    }
                    else{    
                        if(SourceStack < TargetStack )
                            tas.Id_Text__c = String.ValueOF(Integer.ValueOf(TargetStack)-1)+'.'+tas.Id_after_decimal__c;
                        else
                            tas.Id_Text__c = String.ValueOF(Integer.ValueOf(TargetStack))+'.'+tas.Id_after_decimal__c; 
                    }                 
                    tas.Stage__c = TargetStage ;
                    tas.Stage_Level__c  = i8.CONTEXT_IMP ;
                    tas.Dependency_Type__c = i8.NODEP;
                    tas.Link__c = false;
                    tas.Internal_Task__c = false;
                    tas.Sum_Mins__c = tas.Total_mins__c;
                    if(tas.Is_Stack__c == false){
                        tas.Status__c = SOEObj.Status__c;
                        if(tas.Jump__c == true)
                            tas.Status__c += + i8.JUMP;
                    }
                }
                LogFactory.debug('Stack_CreateMove_Cntrl', 'MoveStack', 'Tasks', 'Tasks modified successfully','Line - 156');                    
                if(tasklist != null ){            
                    if(Utils.isUpdateable('i8__Task__c'))
                        update tasklist; 
                    set<Id> TaskIds = new set<Id>();  
                    if(Utils.isAccessible('i8__Dependency__c'))
                        deplist = [select id,Task__c,Preceeding_Task__c from Dependency__c where TAsk__c IN : DelTaskId or Preceeding_Task__c = : DelTaskId ];
                    for(Dependency__c dep: deplist){
                        TaskIds.add(dep.Task__c);
                        TaskIds.add(dep.Preceeding_Task__c);
                    }
                    if(Schema.sObjectType.Dependency__c.isDeletable())
                        delete deplist;
                    Task_TriggerHandler.CalculateDependencyType(TaskIds);
                    Task_TriggerHandler.UpdateAllTasks(new list<id>{SOEObj.Id},i8.CONTEXT_IMP);
                    LogFactory.SaveLog();
                    return new pagereference('/apex/AllTasks_ClientSide?id='+SOEObj.Id);  
                } 
                    
            }
            }catch(Exception e){
               Database.rollback(sp);
               LogFactory.error('Stack_CreateMove_Cntrl', 'moveStack', '', e.getMessage() + '' + e.getStackTraceString());  
               LogFactory.SaveLog();
               error = true; 
               errormessage = e.getMessage();                  
            } 
        }
        return null;       
    }
    public pagereference createStack(){
        List<Task__c> tasrec = new List<Task__c>();
        Task__c tasrec1 = new Task__c();
        if(Task_Create ){
            Map<String, String> parammap = ApexPages.currentPage().getParameters();
            Integer days,hrs,mins;
            string title;
            Savepoint sp = Database.setSavepoint();
            try{
            for (String key : parammap.keySet()) {
                If (key.startsWith('days')){
                    if(parammap.get(key)==' ' ||parammap.get(key)=='')
                        days = 0;
                    else
                        days = integer.ValueOf(parammap.get(key));
                }
                if (key.startsWith('hours') ){
                    if(parammap.get(key)==' ' || parammap.get(key)=='')
                        hrs = 0;
                    else
                        hrs = integer.ValueOf(parammap.get(key));
                }
                if (key.startsWith('minutes') ){
                    if(parammap.get(key)==' ' || parammap.get(key)=='')
                        mins = 0;
                    else
                        mins = integer.ValueOf(parammap.get(key));
                }
                if(key.startsWith('tasktitle'))
                    title = parammap.get(key) ; 
            }
            if(title == null || title == ''){
                error = true;
                errormessage = System.Label.Stack004;
            }
            else if(TargetStack == null){
                error = true;
                errormessage = System.Label.Stack005;
            }
            else if(BAValue != null && BAValue == '+'){
                tasrec.add(CreateTask(TargetStage,title+i8.START_CKP,true,String.ValueOf((Integer.ValueOf(TargetStack)+1))+'.0',SOEObj.Id,'',taskobj.Stage_Level__c,0,0,0,false));
                tasrec.add(CreateTask(TargetStage,title,false,String.ValueOf((Integer.ValueOf(TargetStack)+1))+'.1',SOEObj.Id,SOEobj.Status__c,taskobj.Stage_Level__c,0,0,Integer.valueof(SOEObj.Task_Late_Threshold_Mins__c),false));
                tasrec.add(CreateTask(TargetStage,title+i8.END_CKP,false,String.ValueOf((Integer.ValueOf(TargetStack)+1))+'.2',SOEObj.Id,SOEobj.Status__c,taskobj.Stage_Level__c,days,hrs,mins,true));
            }
            else if(BAValue != null && BAValue == '-'){               
                tasrec.add(CreateTask(TargetStage,title+i8.START_CKP,true,String.ValueOf(Integer.ValueOf(TargetStack))+'.0',SOEObj.Id,'',taskobj.Stage_Level__c,0,0,0,false));
                tasrec.add(CreateTask(TargetStage,title,false,String.ValueOf(Integer.ValueOf(TargetStack))+'.1',SOEObj.Id,SOEobj.Status__c,taskobj.Stage_Level__c,0,0,Integer.valueof(SOEObj.Task_Late_Threshold_Mins__c) ,false));
                tasrec.add(CreateTask(TargetStage,title+i8.END_CKP,false,String.ValueOf(Integer.ValueOf(TargetStack))+'.2',SOEObj.Id,SOEobj.Status__c,taskobj.Stage_Level__c,days,hrs,mins,true));
            }        
                 LogFactory.debug('Stack_CreateMove_Cntrl', 'CreateStack', 'Target Stack ', 'Selected Target Stack Id is '+TargetStack,'Line - 232');  
            if(tasrec.size() > 0){
                LogFactory.debug('Stack_CreateMove_Cntrl', 'CreateStack', 'Tasks', 'Tasks got successfully','Line - 234');
                if(Utils.isCreateable('i8__Task__c'))
                    insert tasrec;
                LogFactory.SaveLog();
                return new pagereference('/apex/AllTasks_ClientSide?id='+SOEObj.Id);  
            }
           }catch(Exception e){
                Database.rollback(sp);
                LogFactory.error('Stack_CreateMove_Cntrl', 'CreateStack', '', e.getMessage() + '' + e.getStackTraceString());  
                LogFactory.SaveLog();
                error=true; 
                errormessage = e.getMessage();                  
            }
        }
        return null;
    } 
    public static Task__c CreateTask(String Stage, string title,boolean b, string d,Id i,string status,string context ,Integer days,integer hours,integer mins,boolean EndStack){
        Task__c t= new Task__c();
        t.Stage__c = Stage;
        t.Task_Title__c = title;
        t.Is_Stack__c = b;
        t.ID_Text__c = String.ValueOf(d);
        t.SOE__c = i;
        t.Status__c = status;
        t.Stage_Level__c= context;
        t.Days__c = days;
        t.Hours__c = hours;
        t.Minutes__c = mins;
        t.End_Stack__c = EndStack;        
        return t;
    }
    public pagereference openCancel(){
        return new pagereference ('/apex/AllTasks_ClientSide?id='+SOEId);
    }  
}