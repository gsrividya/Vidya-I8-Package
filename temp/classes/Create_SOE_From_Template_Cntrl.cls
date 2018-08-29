/* 
Class Name        : Create_SOE_From_Template_Cntrl
Test Class Name   : Test_Create_SOE_From_Template_Cntrl
Purpose/Overview  : To clone the SOE from Template SOE with tasks and Dependencies 
Author            : Purview Ltd.
Code Coverage     : 96%
Change History    : 

*/
public with sharing class Create_SOE_From_Template_Cntrl{
    public SOE__c NewSOE{get;set;}
    public SOE__c SOE{get;set;}
    public list<Task__c> TaskList{get;set;}
    public String TaskRecId{get;set;}
    public list<SOE__c> SOEList{get;set;}
    public Map<string,list<Dependency__c>> Taskmap1{get;set;}
    public Map<string,task__c> Insertmap{get;set;}
    public map<id,task__c> oldTaskMap{get;set;}
    public map<id,string> prectaskmap{get;set;}
    public set<id> taskid1{get;set;}
    public list<Attachment> Atchdoc{get;set;}
    public list<Attachment> AttachList{get;set;}
    public List<Dependency__c > depList {get;set;}    
    Public string Seact_ip {get;set;}
    Public string CloneSOE {get;set;}
    public List<SelectOption> SOE_Options{get;set;}
    public boolean sec2{get;set;}
    public i8Constants i8{get;set;}
    public string errormsg{get;set;}
    boolean Task_Access_Create ;
    boolean SOE_Access_Create ;
    boolean Dep_Access_Create   ;
    
    public Create_SOE_From_Template_Cntrl(ApexPages.StandardController controller) {
        SOE = new SOE__c();
        i8 = new i8Constants();
        TaskList = new List<Task__c>();
        SOEList = New List<SOE__c>(); 
        errormsg = null;  
        SOE_Access_Create  =   Utils.isAccess_Create('i8__SOE__c');
        Task_Access_Create  = Utils.isAccess_Create('i8__Task__c');
        Dep_Access_Create  =  Utils.isAccess_Create('i8__Dependency__c') ;
        if(SOE_Access_Create && Task_Access_Create  && Dep_Access_Create ) 
            getSOEOptions();
        else
            errormsg = System.Label.AddTask006;
    }    
    public void SelectDescription(){
        if(SOE_Access_Create && Task_Access_Create && Dep_Access_Create && Schema.sObjectType.Attachment.isAccessible())  { 
            SOE=[select id,Department__c,BackOut_Stage__c,Backout__c,Post_Implementation_Stage__c,Pre_Implementation_Stage__c,WalkThrough_Required__c,QA_Manager__c,QA_Review_Required__c,Change_Record__c,Conference_Call_No__c,Summary__c,Programme__c,Project__c,BaseLine_Start__c  from SOE__c where id =: CloneSOE limit 1];
            tasklist=[select SOE__c,Stage__c,id,ID_Text__c,End_Stack__c,Dependency_Type__c,Task_Completed__c,Advanced_Notifications__c,When_Task_Ready__c,Trigger_Comms__c,Dependency_Image__c,Id_Before_Decimal__c,Milestone__c,Time_Bound__c ,Is_Stack__c ,Task_Title__c,Duration__c,Team__c,Description__c,(select id from Attachments) from Task__c where SOE__c =: CloneSOE order by ID_Text__c];
            oldTaskMap = new map<id,task__c>(); 
            taskid1=new set<id>();
            Insertmap= new map<string,task__c>();
            prectaskmap = new map<id,string>();
            Taskmap1= new Map<string,list<Dependency__c>>();
            Atchdoc = new list<Attachment>();     
            AttachList = new list<Attachment>();
            NewSOE = new SOE__c();
            NewSOE =SOE.clone(); 
            NewSOE.Status__c = i8.STATUS_BUILD; 
         }else  { errormsg = System.Label.ADMIN001; }     
    }    
    public PageReference Apply() {
        errormsg  = null;  
        if(SOE_Access_Create && Task_Access_Create && Dep_Access_Create ){
        if(NewSOE.SOE_Title__c == '' || NewSOE.SOE_Title__c == null)
            errormsg = System.Label.CloneSOE001 ;
        Else{
            list<Task__c> Applytasklst=new List<Task__c>();
            list<Task__c> Tasktemplist=new List<Task__c>(); 
            Tasktemplist=[select id,Actual_End__c,Broken_Task__c,Actual_Duration__c,Actual_Start__c,Add_Comments__c,Baseline_Duration__c,Baseline_End__c,Baseline_Start__c,Comments__c,Days__c,
                          Dependency_Image__c,Dependency_Type__c,Description__c,Duration__c,End_Stack__c,End_Time__c,Time_Bound__c,Forecast_End__c,Forecast_Duration__c,Forecast_Start__c,
                          Hours__c,ID_Text__c,Id_After_Decimal__c,Id_Before_Decimal__c,Internal_Task__c,Is_Stack__c,Link__c,Minutes__c,Stage__c,Planned_End__c,Planned_Duration__c,
                          Planned_Start__c,Jump__c,Jumped_Duration__c,Owner__c,Start_Time__c,State__c,Status__c,SOE__c,Stage_Level__c,Task_Title__c,Team__c,Technical_Detail__c,Trigger_Comms__c,
                          (select id,Type__c,Dependent_Type__c,Dep_Type__c,Preceeding_Task__r.ID_Text__c,Preceeding_Task__r.Task_Title__c,Preceeding_SOE__c from Dependencies__r) from Task__c  where SOE__c =:CloneSOE ];
            for(task__c t:Tasktemplist){
                oldTaskMap.put(t.id,t);
                taskid1.add(t.id);
            }
            if(Schema.sObjectType.Attachment.isAccessible())
                Atchdoc =[select Id,Name,BodyLength,ownerid,createddate,body,parentid from attachment where parentid =: taskid1];
            for(task__c t:Tasktemplist){  
                if(t.dependencies__r.size()>0){
                    Taskmap1.put(t.ID_Text__c+'-'+t.Stage_Level__c,t.dependencies__r);
                }
                if(t.dependencies__r.size()>0){
                    for(Dependency__c d: t.dependencies__r){
                        if(d.Dep_Type__c=='link' || d.Dep_Type__c=='internal'){ 
                            prectaskmap.put(d.Preceeding_Task__c,oldTaskMap.get(d.Preceeding_Task__c).ID_Text__c+'-'+oldTaskMap.get(d.Preceeding_Task__c).Stage_Level__c); 
                        }
                    }
                }
            }      
            SOE_TriggerHandler.TriggerStop = true;
            Savepoint sp = Database.setSavepoint(); 
            try{ 
                LogFactory.info('Create_SOE_From_Template_Cntrl', 'Apply', 'New SOE', JSON.Serialize(NewSOE), 'Line - 98'); 
                if(Utils.isCreateable('i8__SOE__c'))
                    insert NewSOE;               
                for(Task__c tastemp: Tasktemplist) {
                    Task__c taskrecs = new Task__c();
                    taskrecs = tastemp.clone();
                    taskrecs.SOE__c = NewSOE.id;
                    Applytasklst.add(taskrecs);
                }
                LogFactory.debug('Create_SOE_From_Template_Cntrl', 'Apply', 'New Tasks', 'Tasks in New SOE got successfully', 'Line - 107');  
                if(Applytasklst.size()>0 && Utils.isCreateable('i8__Task__c'))
                    insert Applytasklst;
                Applytasklst= [select id,Add_Comments__c,Comments__c,Days__c,Dependency_Image__c,Dependency_Type__c,Description__c,Duration__c,End_Stack__c,Time_Bound__c, Hours__c,
                               ID_Text__c,Id_After_Decimal__c,Id_Before_Decimal__c,Internal_Task__c,Is_Stack__c,Link__c,Minutes__c,Stage__c,
                               Jump__c,Jumped_Duration__c,Owner__c,State__c,Status__c,SOE__c,Stage_Level__c,Task_Title__c,Team__c,Technical_Detail__c,Trigger_Comms__c,
                               (select id,Type__c,Dependent_Type__c,Dep_Type__c,Preceeding_Task__r.ID_Text__c,Preceeding_Task__r.Task_Title__c,Preceeding_SOE__c from Dependencies__r) from Task__c  where SOE__c =:NewSOE.id];
                for(task__c t:Applytasklst)
                    Insertmap.put(t.ID_Text__c+'-'+t.Stage_Level__c,t);
                depList= new list<Dependency__c>();
                for(task__c t: Applytasklst){
                    if(Taskmap1.containsKey(t.ID_Text__c+'-'+t.Stage_Level__c)){
                        for(Dependency__c d:Taskmap1.get(t.ID_Text__c+'-'+t.Stage_Level__c)){
                            if((d.Dep_Type__c=='Link' || d.Dep_Type__c=='Internal') && d.Dependent_Type__c == 'Predecessors'){
                                Dependency__c dep1 = new Dependency__c();
                                dep1.Dependent_Type__c = 'Predecessors'; 
                                dep1.Task__c = t.Id;
                                dep1.SOE__c = t.SOE__c;
                                dep1.Preceeding_Task__c = Insertmap.get(prectaskmap.get(d.Preceeding_Task__c)).id;
                                dep1.Preceeding_SOE__c = Insertmap.get(prectaskmap.get(d.Preceeding_Task__c)).SOE__c;                           
                                dep1.Type__c = d.Type__c;
                                dep1.Dep_Type__c = d.Dep_Type__c;
                                depList.add(dep1);
                            }
                        }
                        for(Dependency__c d:Taskmap1.get(t.ID_Text__c+'-'+t.Stage_Level__c)){
                            if((d.Dep_Type__c=='Link' || d.Dep_Type__c=='Internal') && d.Dependent_Type__c == 'Successors'){
                                Dependency__c dep2 = new Dependency__c();
                                dep2.Dependent_Type__c = 'Successors';
                                dep2.Preceeding_Task__c =Insertmap.get(prectaskmap.get(d.Preceeding_Task__c)).id;
                                dep2.Preceeding_SOE__c = Insertmap.get(prectaskmap.get(d.Preceeding_Task__c)).SOE__c;
                                dep2.SOE__c =t.SOE__c;
                                dep2.Task__c =t.id;
                                dep2.Type__c = d.Type__c;
                                dep2.Dep_Type__c = d.Dep_Type__c;
                                depList.add(dep2);
                            }
                        }
                    }
                }
                for(task__c t1:Tasktemplist){
                    for(Attachment att: Atchdoc){
                        for(task__c t: Applytasklst){
                            if(t.ID_Text__c == t1.ID_Text__c && att.parentid==t1.id && t.Stage_Level__c== t1.Stage_Level__c){Attachment att1 = new Attachment ();                               
                               att1.name=att.name;
                               att1.body=att.body;
                               att1.parentid=t.id;
                               AttachList.add(att1); 
                            }
                        }
                    }
                }
                if(AttachList.size()>0){
                 LogFactory.info('Create_SOE_From_Template_Cntrl', 'Apply', 'Attachments', 'Attachments got Successfully', 'Line - 160');  
                 if(Schema.sObjectType.Attachment.isCreateable())
                    insert AttachList;
                }
                if(DepList.size()>0 && Utils.isCreateable('i8__Dependency__c'))
                     insert deplist;
                LogFactory.info('Create_SOE_From_Template_Cntrl', 'Apply', 'Dependencies', 'Dependencies got Successfully', 'Line - 166');                   
                LogFactory.SaveLog();                
                return new PageReference('/'+NewSOE.Id);
            }
            catch(DMLException e){
                if(e.getDMLMessage(0).contains('SOE_Title__c duplicates value'))
                    errormsg = System.Label.SOETemplate002;
                else
                    errormsg  = e.getDMLMessage(0);
                LogFactory.error('Create_SOE_From_Template_Cntrl', 'Apply', '', e.getDMLMessage(0) + '' + e.getStackTraceString());  
                LogFactory.SaveLog(); 
                return null;
            }
             catch(Exception e){
                   Database.rollback(sp);
                   LogFactory.error('Create_SOE_From_Template_Cntrl', 'Apply', '', e.getMessage() + '' + e.getStackTraceString());  
                   LogFactory.SaveLog(); 
                   errormsg = e.getMessage();                  
             }
        }
        }else {errormsg = System.LAbel.AddTask006;}        
        return null;
    }    
    public PageReference openDocuments() {
        return new pagereference('/apex/Task_Document?id='+TaskrecId+'&page=SOE');
    }
    public pagereference OpenDependency(){
        return new pagereference('/apex/TaskDependencies?id='+TaskrecId+'&page=SOE');
    }
    public void SOE_List(){
        CloneSOE = null;
        SOE_Options = new List<SelectOption>();
        String val='%'+Seact_ip+'%';
        SOEList.clear();
        if(SOE_Access_Create)
            SOEList = [select id,Name,SOE_Title__c,Department__c from SOE__c where (SOE_Title__c Like: val  or Name Like:val )and Is_Template__c = True];
        for(SOE__c soe : SOEList)
            SOE_Options.add(new selectoption(soe.id,soe.Name+' - '+soe.SOE_Title__c));
        if(SOE_Options.size() < 1) 
            errormsg = System.Label.SOETemplate001;
    }
    public void ClrStr(){
        errormsg = null;
        Seact_ip = '';
        CloneSOE = null;
        getSOEOptions();
    }
    public List<SelectOption> getSOEOptions(){
        SOE_Options = new List<SelectOption>();
        SOEList.clear();
        if(SOE_Access_Create)
            SOEList = [select id,Name,SOE_Title__c from SOE__c where Is_Template__c = True order by Name desc];
        for(SOE__c soe : SOEList){
            SOE_Options.add(new selectoption(soe.id,soe.Name+' - '+soe.SOE_Title__c));
        }
        return SOE_Options;
    }
    Public Void SelectSOE(){
        errormsg = null;
        if(CloneSOE == '' || CloneSOE == null)  
             errormsg = System.Label.CloneSOE007;
        ELSE{
            sec2 = True;
            SelectDescription();
        }
    }
    public pagereference ClearSelection(){
        CloneSOE = null;
        Sec2 = false;
        ClrStr();
        return null;
    }
     public pagereference CancelSOE(){
            return new pagereference('/'+SOE__c.sobjecttype.getDescribe().getKeyPrefix()+'/o');
    }
}