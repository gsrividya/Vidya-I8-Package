/* 
Class Name        : jump_stack_cntrl  
Test Class Name   : Test_Jump_Stack_Cntrl
Purpose/Overview  : To jump the stack in SOE 
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 

*/
public with sharing class jump_stack_cntrl {
    public Boolean error { get; set; }  
    public String selected_Stack { get; set; }
    public SOE__c soeobj{get;set;}
    public I8Constants i8{get; set;}
    public list<selectoption> stack_options{get;set;}
    public list<selectoption> StagesList{get;set;}
    public string SourceStage{get;set;}
    public Map<String,Task__c> StackMap{get;set;}
    public string errmsg{get;set;}
    Public Map<Id,Id> ImpMgrMap{get;set;}
    public string ImpMgrMapKey{get;set;}
    boolean Task_Create ;
    Id SOEId;
        
    public jump_stack_cntrl(){
        i8 = New I8Constants();
        error =false;
        SOEId = Apexpages.currentpage().getparameters().get('id');
        Task_Create = Utils.isAccess_Update('i8__Task__c') ;
        if(Task_Create){
            if(Utils.isAccessible('i8__SOE__c'))
                soeobj=[select id,name,SOE_Title__c,QA_Review_Required__c,QA_Review__c,WalkThrough_Required__c,WalkThrough__c,Pre_Implementation_Stage__c ,Post_Implementation_Stage__c ,State__c,Max_Planned_End__c,Dealy_Ahead_mins__c ,Max_Forecast_End__c,Max_End_Time__c,status__c 
                    from SOE__c where id=: Apexpages.currentpage().getparameters().get('id')];  
            ImpMgrMap = new Map<Id,Id>();
            list<string> RolesLIst = System.Label.Roles_To_Edit_SOE.split(',');
            if(Utils.isAccessible('i8__SOE_Team_Member__c'))
            for( SOE_Team_Member__c imp : [select Id,Name,Team_Member__r.Salesforce_User__c,Access_Level__c  from SOE_Team_Member__c where SOE__c =: SOEObj.id  and Access_Level__c != 'Read' and Role__r.Reference_Role__c  IN : RolesLIst])  
                    ImpMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
            if(Schema.sObjectType.Profile.isAccessible())
            if([Select Id,Name from Profile where Id=:userInfo.getProfileId()].Name == 'System Administrator')
                 ImpMgrMap.put(userInfo.getUserId(),userInfo.getUserId());
            ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', '');     
            StagesList = new List<SelectOption>();
            If(SOEobj.Pre_Implementation_Stage__c == True){
                StagesList.add(new selectoption(i8.STAGE_PRE,i8.STAGE_PRE));
                SourceStage = i8.STAGE_PRE;
            }
            StagesList.add(new selectoption(i8.STAGE_Imp,i8.STAGE_Imp));
            If(SOEobj.Post_Implementation_Stage__c == True){
                StagesList.add(new selectoption(i8.STAGE_Post,i8.STAGE_Post));
            }
            if(SOEobj.Pre_Implementation_Stage__c == False)
                SourceStage = i8.STAGE_IMP;
            getSelect_stack(); 
        } 
    }
    public void getSelect_stack() {
    stack_options = new list<selectoption>();
    if(Task_Create)
    StackMap = new Map<String,Task__c>();
        for(task__c t:[select id,Task_Title__c,Status__c,Jump__c,Days__c ,hours__c ,Minutes__c ,Is_Stack__c,Duration__c,Jumped_Duration__c,Stage__c,Id_Before_Decimal__c,Stage_Level__c,Id_After_Decimal__c,SOE__c,SOE__r.Status__c from task__c where Jump__c =: false and Stage_Level__c=: i8.CONTEXT_IMP and Is_Stack__c =:true and SOE__c =: SOEObj.Id and Stage__c =: SourceStage  order by Id_Before_Decimal__c,Id_After_Decimal__c asc]){
            stack_options.add(new selectoption(string.valueof(t.Id_Before_Decimal__c),t.Id_Before_Decimal__c+'.'+t.Task_Title__c));
            StackMap.put(string.valueof(t.Id_Before_Decimal__c),t);
        }
    }    
    public PageReference jump_stack() { 
        if(Task_Create){       
            Savepoint sp = Database.setSavepoint();
            try{
                list<Task__c> Timp = [select id,Is_Stack__c,Stage__c from Task__c where Jump__c =: false and SOE__c =: SOEObj.Id and Stage_Level__c=: i8.CONTEXT_IMP and Is_Stack__c =: True and Stage__c =: SourceStage];
                if(TImp.Size() < 2){
                     error = true;
                     errmsg = System.Label.JumpStack001;
                } 
                else if((StackMap.get(selected_Stack).Stage__c == i8.STAGE_PRE && StackMap.get(selected_Stack).SOE__r.Status__c == i8.STATUS_SCHEDULED) || StackMap.get(selected_Stack).Status__c == i8.STATUS_RUNNING || StackMap.get(selected_Stack).Status__c == i8.STATUS_COMPLETED || StackMap.get(selected_Stack).Status__c == i8.STATUS_COMP_JUMP){
                    error = true;
                    errmsg = System.Label.AddTAsk004;
                }
                else{       
                  LogFactory.debug('Jump_Stack_Cntrl', 'Jump_Stack', 'Selected Stack', 'The Selected Stack to be Jumped is '+selected_Stack ,'Line - 69'); 
                  list<Task__c> Selected_Stack_list = [select id,Task_Title__c,Status__c,Days__c ,hours__c ,Minutes__c,Jump__c,Duration__c,Jumped_Duration__c,Is_Stack__c,Stage__c,Id_Before_Decimal__c,Stage_Level__c,Id_After_Decimal__c,SOE__c from task__c where Jump__c= false and Stage_Level__c=: i8.CONTEXT_IMP and Id_Before_Decimal__c =: integer.valueof(selected_Stack) and SOE__c =: SOEObj.Id and Stage__c =: SourceStage order by Id_Before_Decimal__c,Id_After_Decimal__c asc];
                    for(task__c tas:Selected_Stack_list){
                        If(tas.Is_Stack__c == True){
                            tas.Jump__c = true;
                            tas.status__c = i8.STATUS_JUMP;
                        }
                        Else 
                            tas.Jump__c = true;
                    }
                    if(Utils.isUpdateable('i8__Task__c'))
                        update Selected_Stack_list;        
                    Task_TriggerHandler.UpdateAllTasks(new list<id>{SOEObj.Id},i8.CONTEXT_IMP);
                    LogFactory.SaveLog();
                    return new pagereference('/apex/AllTasks_ClientSide?id='+SOEObj.Id);
                }
             } 
             catch(Exception e){
                       Database.rollback(sp);
                       LogFactory.error('Jump_Stack_Cntrl', 'Jump_Stack', '', e.getMessage() + '' + e.getStackTraceString());  
                       LogFactory.SaveLog(); 
                       error = true;
                       errmsg = e.getMessage();                  
             }
        } 
        return null;
    }
    public PageReference openCancel() {
        return new pagereference('/apex/AllTasks_ClientSide?id='+SOEId);
    }
}