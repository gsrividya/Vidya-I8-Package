/* 
Class Name        : Stack_Management_Delete
Test Class Name   : Test_Stack_Management_Delete
Purpose/Overview  : To copy and drop the Stack.
Author            : Purview Ltd.
Code Coverage     : 93%.
Change History    : 
*/
public with sharing class Stack_Management_Delete {    
    public String Description { get; set; }
    public String tasktitle { get; set; }
    public Boolean SkipCheck { get; set; }
    public Boolean TeamCheck { get; set; }
    public Boolean OwnerCheck { get; set; }
    public String selectDesStack { get; set; }
    public String selectDesStage { get; set; }
    public String selectStack { get; set; }
    public String selectSOE {get; set;}
    public integer Stackno {get;set;}
    public String BAValue {get;set;}
    public Id SOEId{get;set;}
    public string selectdeletecon{get;set;}
    public list<selectoption> deloptins{get;set;}
    public string errormessage{get;set;}
    public Task__c taskObj{get;set;} 
    public Task__c taskObj1{get;set;} 
    public SOE__c SOEobj{get;set;}
    public list<Task__c> destasks1{set;get;} 
    public map<integer,id> taskMap{get;set;}
    public I8Constants i8{get;set;}
    public boolean error{get;set;}
    Public String Page{get;set;}
    public Map<string,task__c> TaskMap1;
    Public Map<Id,Id> ImpMgrMap{get;set;}
    public string ImpMgrMapKey{get;set;}
    public list<selectoption> SetSourceStacks{get;set;}
    public list<selectoption> SetTargetStages{get;set;}
    public list<selectoption> SetTargetStacks{get;set;}
    boolean Task_Create ;
    
    public Stack_Management_Delete(){        
        i8 = new I8Constants();
        SetTargetStages = New List<selectoption>();
        SetTargetStacks = New List<selectoption>();
        BAValue = '+';
        SOEId = ApexPages.CurrentPage().getParameters().get('id');
        Page = ApexPages.CurrentPage().getParameters().get('page');
        Task_Create = Utils.isAccess_Create_Update('i8__Task__c');
        if(page != 'clone')
            Task_Create = Task_Create && Schema.sObjectType.Task__c.isDeletable() ;
        if(Task_Create ) {
            if(Utils.isAccessible('i8__SOE__c'))
                SOEobj = [select id,name,SOE_Title__c,State__c,QA_Review_Required__c,QA_Review__c,WalkThrough_Required__c,WalkThrough__c,Max_Planned_End__c ,Max_Forecast_End__c,Pre_Implementation_Stage__c,Post_Implementation_Stage__c,Backout_Stage__c,Max_End_Time__c,status__c,Dealy_Ahead_mins__c from SOE__c where id=:SOEId];
            destasks1 = new list<Task__c>();
            taskMap = new map<integer,id>();
            Description='';
            tasktitle ='';
            selectSOE = SOEId;                 
            taskObj = new task__c();
            taskObj1 = new task__c();
            if(page == 'clone'){
                taskobj.Stage_Level__c= i8.CONTEXT_IMP;
                taskobj1.Stage_Level__c= i8.CONTEXT_IMP;
            }
            ImpMgrMap = new Map<Id,Id>();
            list<string> RolesLIst = System.Label.Roles_To_Edit_SOE.split(',');
            if(Utils.isAccessible('i8__SOE_Team_Member__c'))
            for( SOE_Team_Member__c imp : [select Id,Name,Team_Member__r.Salesforce_User__c,Access_Level__c  from SOE_Team_Member__c where SOE__c =: SOEObj.Id  and Access_Level__c != 'Read' and Role__r.Reference_Role__c  IN : RolesLIst])  
                    ImpMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
            if(Schema.sObjectType.Profile.isAccessible())
                if([Select Id,Name from Profile where Id=:userInfo.getProfileId()].Name == 'System Administrator')
                    ImpMgrMap.put(userInfo.getUserId(),userInfo.getUserId());
            ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', '');
            If(Page == 'clone'){
                GetSourceStacks();
                getTargetStages();
            } 
            else
                getdeleteitems(); 
          }     
    }
    public void getTargetStages(){
        SetTargetStages = New List<selectoption>();
        if(taskobj1.Stage_Level__c == i8.CONTEXT_IMP){         
            If(SOEObj.Pre_Implementation_Stage__c == True){
                SetTargetStages.add(new selectoption(i8.STAGE_PRE,i8.STAGE_PRE));
                selectDesStage = i8.STAGE_PRE;
            }
            If(SOEObj.Pre_Implementation_Stage__c == False)
                selectDesStage = i8.STAGE_IMP;
            SetTargetStages.add(new selectoption(i8.STAGE_IMP ,i8.STAGE_IMP ));
            If(SOEObj.Post_Implementation_Stage__c == True){
                SetTargetStages.add(new selectoption(i8.STAGE_POST ,i8.STAGE_POST ));
            }
        }
        else if(taskobj1.Stage_Level__c == i8.CONTEXT_BO && SOEObj.Backout_Stage__c == true){ 
            selectDesStage = i8.STAGE_IMP;
            SetTargetStages.add(new selectoption(i8.STAGE_IMP ,i8.STAGE_IMP ));
            If(SOEObj.Post_Implementation_Stage__c == True)
                SetTargetStages.add(new selectoption(i8.STAGE_POST ,i8.STAGE_POST ));
        }
        getDestStacks();
    }
    public void  getdeleteitems(){
        error = false;
        errormessage = null;
        deloptins = new LIst<selectoption>();
        TaskMap1 = new Map<string,Task__c>();
        deloptins.add(new selectOption('None','--None--'));
        if( Task_Create)
        for(Task__c tas : [select id,Id_text__c,Task_Title__c,Status__c from Task__c where Is_Stack__c = True and SOE__c =: SOEid and Stage_Level__c=: taskobj.Stage_Level__c and BO_IdBefore__c = null order by id_before_decimal__c]){
            TaskMap1.put(String.ValueOf(Integer.ValueOf(tas.Id_text__c)),tas);
            deloptins.add(new selectOption(String.ValueOf(Integer.ValueOf(tas.Id_text__c)),Integer.ValueOf(tas.Id_text__c)+'.'+tas.Task_Title__c));
        }
    }
    public pagereference deleteStack(){
        List<task__c> deltsklst = new List<task__c>();
        if(Task_Create){
            Savepoint sp = Database.setSavepoint();
            try{
            if(selectdeletecon == 'None'){
                error = true;
                errormessage = System.Label.Stack006;             
            }else if(TaskMap1.get(selectdeletecon).Status__c == i8.STATUS_RUNNING || TaskMap1.get(selectdeletecon).Status__c == i8.STATUS_COMPLETED || TaskMap1.get(selectdeletecon).Status__c == i8.STATUS_COMP_JUMP){
                error = true;
                errormessage = System.Label.AddTask004;
            }else{                     
                String selectStage = [select id,Stage__C from Task__c where Stage_Level__c=:taskobj.Stage_Level__c and SOE__c =: SOEId and Id_Before_Decimal__c =: Integer.ValueOf(selectdeletecon) LIMIT 1].Stage__c;
                    List<Task__c> tList = [select id from TAsk__c where Stage_Level__c =: taskobj.Stage_Level__c and SOE__c =: SOEId and Jump__c =: False and Stage__c =: selectStage and Is_Stack__c = true];
                    if(tList.size() > 1)
                        deltsklst = [select id from Task__c where Id_Before_Decimal__c =: Integer.ValueOf(selectdeletecon) and Stage_Level__c=: taskobj.Stage_Level__c and SOE__c=: SOEId];
                    else{
                        error = true;
                        errormessage = System.Label.Stack007;                                       
                    } 
                    LogFactory.debug('Stack_CreateMove_Cntrl', 'DeleteStack', 'Target Stack ', 'Deleted Stack Id is '+selectdeletecon,'Line - 125');             
                    if(deltsklst.size() >0 ){  
                        if(Schema.SObjectTYpe.Task__c.isDeletable() )
                            delete deltsklst;
                        Task_TriggerHandler.UpdateAllTAsks(new list<id>{SOEObj.Id},taskobj.Stage_Level__c);
                        LogFactory.SaveLog();
                        return new Pagereference('/apex/AllTasks_ClientSide?id='+SOEid);
                    }          
               }
            }
            catch(Exception e){
                   Database.rollback(sp);
                   LogFactory.error('Stack_Management_Delete', 'DeleteStack', '', e.getMessage() + '' + e.getStackTraceString());  
                   LogFactory.SaveLog();
                   error = true; 
                   errormessage = e.getMessage();                  
                   }        
          }
          return null;        
    }
    public list<selectoption> getGetSOES() {
        list<selectoption> copyopts = new list<selectoption>();
        list<SOE__c> SOElist = new list<SOE__c>(); 
        if(Utils.isAccessible('i8__SOE__c'))                        
            SOElist = [select id,SOE_Title__c,name from SOE__c order by Name desc limit 10000];        
        for(SOE__c SOE : SOElist){           
            copyopts.add(new selectOption(SOE.id,SOE.Name+':'+SOE.SOE_Title__c));
        }             
        return copyopts;
    }
    public void GetSourceStacks() {
        list<Task__c> tasklist = new list<Task__c>();
        SetSourceStacks = New List<selectoption>(); 
        if(Task_Create && Utils.isAccessible('i8__Dependency__c') )
        tasklist = [select SOE__r.SOE_Title__c,Actual_Start__c,Add_Comments__c,Baseline_Duration__c,Comments__c,Days__c,Dependency_Type__c,Description__c,End_Stack__c,Time_Bound__c,
                    Hours__c,ID_Text__c,Id_After_Decimal__c,Id_Before_Decimal__c,Internal_Task__c,Is_Stack__c,Link__c,Minutes__c,Stage__c,
                    Planned_Start__c,Jump__c,Jumped_Duration__c,Owner__c,Start_Time__c,State__c,Status__c,SOE__c,Stage_Level__c,Task_Title__c,Team__c,Technical_Detail__c,
                    (select Type__c,Dependent_Type__c,Dep_Type__c,Preceeding_Task__r.ID_Text__c,Preceeding_Task__r.Task_Title__c,Preceeding_SOE__c,Preceeding_SOE__r.SOE_Title__c from Dependencies__r) from Task__c
                    where SOE__c =: selectSOE and Is_Stack__c =: true and Stage_Level__c =: taskobj.Stage_Level__c order by id_before_decimal__c];
        for(Task__c t:tasklist)
            SetSourceStacks.add(new selectOption(String.valueOF(t.Id_Before_Decimal__c),String.valueOF(t.Id_Before_Decimal__c)+'.'+t.Task_Title__c));
    }   
    Public void  getDestStacks(){
        list<Task__c> taslist = new list<Task__c>();
        SetTargetStacks = New List<selectoption>();
        if(Task_Create && Utils.isAccessible('i8__Dependency__c') )
        taslist = [select SOE__r.SOE_Title__c,Actual_Start__c,Add_Comments__c,Comments__c,Days__c,Dependency_Type__c,Description__c,End_Stack__c,Time_Bound__c,
                   Hours__c,ID_Text__c,Id_After_Decimal__c,Id_Before_Decimal__c,Internal_Task__c,Is_Stack__c,Link__c,Milestone__c,Minutes__c,Stage__c,
                   Jump__c,Jumped_Duration__c,Owner__c,Status__c,SOE__c,Stage_Level__c,Task_Title__c,Team__c,Technical_Detail__c,
                   (select Type__c,Dependent_Type__c,Dep_Type__c,Preceeding_Task__r.ID_Text__c,Preceeding_Task__r.Task_Title__c,Preceeding_SOE__c,Preceeding_SOE__r.SOE_Title__c from Dependencies__r) from Task__c
                   where SOE__c =: SOEId and Is_Stack__c =: true and Stage__c =: selectDesStage and Stage_Level__c=: taskobj1.Stage_Level__c order by id_before_decimal__c];
        for(Task__c t: taslist){
            SetTargetStacks.add(new selectOption(String.valueOF(t.Id_Before_Decimal__c),String.valueOF(t.Id_Before_Decimal__c)+'.'+t.Task_Title__c));
        } 
    }    
    public PageReference CopyStack(){
        List<Task__c> srctasks = new List<Task__c>();
        List<Task__c> destasks = new List<Task__c>();
        error = false ; errormessage = null;
        if(Task_Create ){
            Savepoint sp = Database.setSavepoint();
            try{
                if(selectStack == Null || selectStack == ''){
                    error = true;
                    errormessage = System.Label.Stack008;
                }else  if(selectDesStack == Null || selectDesStack == ''){
                    error = true;
                    errormessage = System.Label.Stack005;
                }else If( taskobj.Task_Title__c == null || taskobj.Task_Title__c ==''){
                    error = true;
                    errormessage = System.Label.Stack004;
                }
                else{            
                    LogFactory.debug('Stack_Management_Delete', 'CopyStack', 'Source Stack ', 'Selected Source Stack Id is '+selectStack,'Line - 191');  
                    LogFactory.debug('Stack_Management_Delete', 'CopyStack', 'Target Stack', 'Selected Target Stack Id is '+selectDesStack,'Line - 192');               
                    srctasks = [select SOE__r.SOE_Title__c,Add_Comments__c,Comments__c,Days__c,Description__c,End_Stack__c,Time_Bound__c,
                                Hours__c,ID_Text__c,Id_After_Decimal__c,Id_Before_Decimal__c,Internal_Task__c,Is_Stack__c,Link__c,Minutes__c,Stage__c,
                                Jump__c,Jumped_Duration__c,Owner__c,SOE__c,Stage_Level__c,Task_Title__c,Team__c,Technical_Detail__c,Trigger_Comms__c from Task__c
                                where SOE__c =: selectSOE and Stage_Level__c =: taskobj.Stage_Level__c and Id_Before_Decimal__c =: Integer.ValueOf(selectStack) order by Is_Stack__c,End_Stack__c];
                    for(Task__c tas: srctasks){
                        Task__c taskrec = new Task__c();
                        taskrec = tas.clone();
                        taskrec.SOE__c = SOEId;
                        taskrec.Link__c=false;
                        taskrec.Dependency_Type__c = i8.NODEP;
                        if(BAValue != null && BAValue == '+'){ 
                            taskrec.ID_text__c = String.ValueOF(Integer.ValueOf(selectDesStack)+1)+'.'+tas.Id_after_decimal__c;
                            Stackno = Integer.ValueOf(selectDesStack)+1;                 
                        }
                        else if(BAValue != null && BAValue == '-'){
                            taskrec.ID_text__c = String.ValueOF(Integer.ValueOf(selectDesStack))+'.'+tas.Id_after_decimal__c;
                            Stackno = Integer.ValueOf(selectDesStack);                         
                       }                   
                        if(taskrec.Is_Stack__c == false)                
                            taskrec.Status__c= SOEObj.Status__c;                  
                        taskrec.Stage__c = selectDesStage;   
                        taskrec.Stage_Level__c = taskobj1.Stage_Level__c;                                                                 
                        if(tas.Is_Stack__c == true){
                            taskrec.Task_Title__c= taskobj.Task_Title__c+ i8.START_CKP;
                            taskrec.Description__c = taskobj.Description__c ; 
                            taskrec.Minutes__c=0;
                            taskrec.Hours__c=0;
                            taskrec.Days__c= 0;
                        }
                        else if(tas.End_Stack__c == true)
                            taskrec.Task_Title__c= taskobj.Task_Title__c+ i8.END_CKP;
                        if(TeamCheck != true)
                            taskrec.Team__c=null; 
                        if(OwnerCheck !=true)
                            taskrec.Owner__c= null;
                        if(SkipCheck == true )
                            taskrec.Jump__c= tas.Jump__c; 
                        else
                            taskrec.Jump__c = false;           
                      
                        destasks.add(taskrec);              
                    }              
                    integer i=2;
                    destasks1.clear();
                    if(destasks.size() > 0) 
                        destasks1.addAll(destasks); 
                    for(task__c t:destasks){            
                        if(t.Is_Stack__c == true)              
                            destasks1.set(0,t);              
                        else if(t.End_Stack__c == true)
                            destasks1.set(1,t);                
                        else if(i<destasks1.size()){               
                            destasks1.set(i,t);                               
                            i++;
                        }            
                    }          
                    if(destasks1.size() > 0 && Utils.isCreateable('i8__Task__c'))
                            insert destasks1;
                    LogFactory.SaveLog();
                    return new Pagereference('/apex/AllTasks_ClientSide?id='+SOEid);
                }
            }catch(Exception e){
                   Database.rollback(sp);
                   LogFactory.error('Stack_Management_Delete', 'CopyStack', '', e.getMessage() + '' + e.getStackTraceString());  
                   LogFactory.SaveLog();
                   error = true;
                   errormessage = e.getMessage();                  
                }
        }
        return null;
    }   
    public pagereference openCancel(){
        return new pagereference ('/apex/AllTasks_ClientSide?id='+SOEId);
    }  
}