/* 
Class Name        : Task_TriggerHandler 
Trigger Name      : Task_Trigger 
Test Class Name   : Test_Task_TriggerHandler
Purpose/Overview  : Trigger Handler for Task Trigger.
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 73%
                    Trigger - 100%
Change History    : 

*/

public class Task_TriggerHandler {
    public static i8Constants i8 = new i8Constants ();
    public static boolean BoolRun = true;
    public static boolean BoolUpdate = true;
    public static boolean Task_Access_Create_Update = Utils.IsAccess_Create_Update('i8__Task__c');
    public static boolean Task_Access = Utils.isAccessible('i8__Task__c');
    public static boolean Task_Update = Utils.isUpdateable('i8__Task__c');
    
    public static void BeforeInsert(List<Task__c> TaskList){
        list<Task__c>ImpTaskList = new list<Task__c>();
        list<Task__c>BOTaskList = new list<Task__c>();
        list<Task__C> ImpTaskLIst11 = new list<Task__C>();
        Map<Id,SOE__c> SOEMap = new Map<Id,SOE__c>();
        set<Id> SOEIds = new set<Id>();
        if(Task_Access_Create_Update && Utils.isAccessible('i8__SOE__c')) {
            for(Task__c tas: taskList)
                SOEIds.add(tas.SOE__c);
            for(SOE__c s: [select id,Schedule_Start__c,Status__c,Pre_Imp_Start__c,Schedule_End__c, Baseline_Start__c,Warning_Zone__c,BAU_Impact__c from SOE__c where id =: SOEIds])
                SOEMap.put(s.Id,s);
            for(Task__c tas: TaskList){
                tas.Sum_mins__c = tas.Minutes__c + (tas.Hours__c*60) + (tas.Days__C*24*60);
                tas.Total_Mins__c = tas.Minutes__c + (tas.Hours__c*60) + (tas.Days__C*24*60);
                tas.Start_Time__c = SOEMap.get(tas.SOE__c).Baseline_Start__c;
                tas.End_Time__c = tas.Start_time__c.addDays(Integer.valueof(tas.Days__c));
                tas.End_Time__c = tas.End_Time__c.addHours(Integer.valueof(tas.Hours__c ));
                tas.End_Time__c = tas.End_Time__c.addMinutes(Integer.valueof(tas.Minutes__c ));                
                tas.Baseline_start__c = tas.Start_Time__c;
                tas.Baseline_end__c = tas.end_Time__c;                
                if(tas.Is_Stack__c == true)
                    tas.Status__C =null;
                else
                    tas.Status__c =  SOEMap.get(tas.SOE__c).Status__c ; 
                if(tas.Jump__c == true)
                    tas.Status__c = tas.Status__c + i8.JUMP;
                if(tas.Stage_Level__c == I8.CONTEXT_IMP)
                    ImpTaskList.add(tas);
                if(tas.Stage_Level__c== I8.CONTEXT_BO)
                    BOTaskList.add(tas);
            }
            if(ImpTaskList.size()>0)
                IncrementTaskIDWhenStackAdded(ImpTaskList,I8.CONTEXT_IMP);
            if(BOTaskList.size()>0)
                IncrementTaskIDWhenStackAdded(BOTaskList,I8.CONTEXT_BO); 
        }
             
    }
    public static void AfterInsert(list<Task__c> TaskList){
        list<Task__c> FreezeTasks= new list<Task__c>();
        list<Task__c> BOTasks= new list<Task__c>();
        for(Task__c t: TaskList) {            
            if(t.Status__c == i8.STATUS_FREEZE && t.Stage__c == i8.STAGE_IMP)
                FreezeTasks.add(t); 
            if(t.Stage__c == i8.STAGE_IMP && t.Backout__c == true)
                BOTasks.add(t);            
        }    
        if(FreezeTasks.size()>0)
            InsertHistory(FreezeTasks,'insert'); 
    }
    public static void BeforeUpdate(list<Task__c> TaskList,Map<Id,Task__c> OldTaskMap){
        if(AllTasks_ClientSide_Cntrl.isRunComplete  == false){
            list<Task__c> ImpTaskList = new list<Task__c>();
            list<Task__c> ImpTaskList3 = new list<Task__c>();
            list<Task__c> ImpTaskList1 = new list<Task__c>();
            Map<Id,Task__c> ImpTaskMap = new map<id,Task__c>();
            Map<Id,Task__c> ImpTaskMap1 = new map<id,Task__c>();
            list<Task__c> JUmpTaskList = new list<Task__c>();
            list<Task__c> UnJumpTAskList = new list<Task__c>();
            if(Task_Access_Create_Update ){
                for(task__C tas: TaskList){
                    if(Decimal.valueOf(tas.Id_Text__c) < Decimal.valueOf(OldTaskMap.get(tas.id).Id_Text__c)  && tas.Stage_Level__c== I8.CONTEXT_IMP && tas.Is_Stack__c == true && Task_TriggerHandler.BoolRun == true) {
                        ImpTaskMap.put(tas.id,OldTaskMap.get(tas.id));
                        ImptaskList.add(tas);
                    }
                    if(Decimal.valueOf(tas.Id_Text__c) > Decimal.valueOf(OldTaskMap.get(tas.id).Id_Text__c)  && tas.Stage_Level__c== I8.CONTEXT_IMP && tas.Is_Stack__c == true && Task_TriggerHandler.BoolRun == true) {
                        ImpTaskMap1.put(tas.id,OldTaskMap.get(tas.id));
                        ImptaskList1.add(tas);
                    }  
                    if((tas.Minutes__c != OldTaskMap.get(tas.Id).Minutes__c  || tas.Hours__c != OldTaskMap.get(tas.Id).Hours__c || tas.Days__c != OldTaskMap.get(tas.Id).Days__c) && tas.IS_Stack__c == false ){
                        ImpTaskList3.add(tas);
                    }
                    if(tas.Jump__c == true && tas.Jump__c != OldTAskMAp.get(tas.Id).Jump__c)
                        JumpTaskList.add(tas);
                    if(tas.Jump__c == false && tas.Jump__c != OldTAskMAp.get(tas.Id).Jump__c)
                        UnJumpTaskList.add(tas);
                }
                if(ImptaskList.size()>0)
                    UpdateIdsWhenStackMoved(ImptaskList,ImpTaskMap,I8.CONTEXT_IMP,'Increment');
                if(ImptaskList1.size()>0)
                    UpdateIdsWhenStackMoved(ImptaskList1,ImpTaskMap1,I8.CONTEXT_IMP,'Decrement');       
                if(ImpTaskList3.size()>0)
                    UpdateTaskDuration(ImpTaskList3,OldTaskMap);
                if(JumpTaskList.size()>0 || UnJumpTaskList.size()>0)
                    JumpedTasks(JumpTaskList,UnJumpTaskList);
            }
         }
    }
    public static void AfterUpdate(list<Task__c> TaskList,Map<Id,Task__c> OldTaskMap){
        if(AllTasks_ClientSide_Cntrl.isRunComplete == false){
            list<Task__c> MileStoneTaskList = new list<Task__C>();
            list<Task__c> TaskReadyList = new list<Task__C>();
            list<Task__c> TaskCompleteList = new list<Task__C>();
            list<Task__c> BOTasks = new list<Task__C>();
            list<Task__c> tasksPinList = new list<Task__c>();
            set<id> SOEIds = new set<Id>();
            set<id> TaskSOEIds = new set<Id>(); 
            set<id> TaskOwnerIds = new set<Id>();
            Map<String,Task__c> NewFreezeTasksMap = new Map<String,Task__c>();
            Map<Id,Task__c> OldFreezeTasksMap = new Map<Id,Task__c>(); 
            Map<Id,Task__c> NewTaskIdsMap = new Map<Id,Task__c>(); 
            Map<Id,Task__c> OldTaskIdsMap = new Map<Id,Task__c>();
            Map<Id,Team_Member__c> TeamMemberMap;  
            if(Task_Access_Create_Update ) {              
                for(task__C tas: TaskList){
                    TaskOwnerIds.add(tas.Owner__c);
                    TaskSOEIds.add(tas.SOE__c);
                }
                if(TaskOwnerIds.size() > 0 && Utils.isAccessible('i8__Team_Member__c')){
                    TeamMemberMap = new Map<Id,Team_Member__c>([SELECT Id,Name,Member__r.Name FROM Team_Member__c WHERE Id =: TaskOwnerIds]); 
                }
                for(task__C tas: TaskList){
                    if(tas.Milestone__c == true && tas.Status__c != OldTaskMap.get(tas.Id).Status__c && tas.Status__c == 'Completed')
                        MileStoneTaskList.add(tas);
                    if(tas.When_Task_Ready__c == true && tas.Status__c != OldTaskMap.get(tas.Id).Status__c && tas.Status__c == 'Ready')
                        TaskReadyList.add(tas);
                    if(tas.Task_Completed__c == true && tas.Status__c != OldTaskMap.get(tas.Id).Status__c && tas.Status__c == 'Completed')
                        TaskCompleteList.add(tas);
                    if(tas.Stage__c == i8.STAGE_IMP && tas.Backout__c == true && OldTaskMap.get(tas.Id).Backout__c == false){
                        BOTasks.add(tas);
                        SOEIds.add(tas.SOE__c);
                    }            
                    if(tas.Id_Text__c != OldTaskMap.get(tas.Id).Id_Text__c && (tas.Backout__c == true || tas.End_Stack__c == true || tas.Is_Stack__c == true ) && tas.Stage__c == i8.STAGE_IMP && tas.Stage_Level__c == i8.CONTEXT_IMP && tas.BO_Process__c == i8.BO_AUTOMATED){
                        NewTaskIdsMap.put(tas.id,tas);
                        OldTaskIdsMap.put(tas.id,OldTaskMap.get(tas.Id));
                    }
                    if(tas.Owner__c != null && tas.PIN__c != null && tas.PIN__c != OldTaskMap.get(tas.Id).PIN__c){
                        String pin = string.valueOf(tas.PIN__c);
                        String[] pinlist = pin.split('-');
                        String pin1    = String.valueOf(pinlist[3]);
                        String[] pinlist1 = pin1.split(':');
                        String MemberName = String.valueOf(pinlist1[0]);
                        if(MemberName != TeamMemberMap.get(tas.Owner__c).Member__r.Name)
                            tasksPinList.add(tas);
                    }
                    if(BoolUpdate == true ){
                        if(tas.Status__c == i8.STATUS_FREEZE && tas.Stage__c == i8.STAGE_IMP && tas.Task_Title__c != OldTaskMap.get(tas.Id).Task_Title__c){
                            NewFreezeTasksMap.put('Task Title',tas);
                            OldFreezeTasksMap.put(tas.id,OldTaskMap.get(tas.Id));
                        }
                        if(tas.Status__c == i8.STATUS_FREEZE && tas.Stage__c == i8.STAGE_IMP && tas.Duration__c != OldTaskMap.get(tas.Id).Duration__c){
                            NewFreezeTasksMap.put('Duration',tas);
                            OldFreezeTasksMap.put(tas.id,OldTaskMap.get(tas.Id));
                        }           
                        if(tas.Status__c == i8.STATUS_FREEZE && tas.Stage__c == i8.STAGE_IMP && tas.Technical_Detail__c != OldTaskMap.get(tas.Id).Technical_Detail__c){
                            NewFreezeTasksMap.put('Technical Detail',tas);
                            OldFreezeTasksMap.put(tas.id,OldTaskMap.get(tas.Id));
                        }
                        if(tas.Status__c == i8.STATUS_FREEZE && tas.Stage__c == i8.STAGE_IMP && tas.Description__c != OldTaskMap.get(tas.Id).Description__c){
                            NewFreezeTasksMap.put('Description',tas);
                            OldFreezeTasksMap.put(tas.id,OldTaskMap.get(tas.Id));
                        }           
                        if(tas.Status__c == i8.STATUS_FREEZE && tas.Stage__c == i8.STAGE_IMP && tas.Milestone__c != OldTaskMap.get(tas.Id).Milestone__c){
                            NewFreezeTasksMap.put('Milestone',tas);
                            OldFreezeTasksMap.put(tas.id,OldTaskMap.get(tas.Id));
                        }
                    }
                }
                if(NewFreezeTasksMap.size()>0 && BoolUpdate == true)
                    InsertHistoryWhenTaskUpdate(NewFreezeTasksMap,OldFreezeTasksMap);
                if(MileStoneTaskList.size()>0)
                    email_milestone(MileStoneTaskList,'Milestone');
                if(TaskReadyList.size()>0)
                    email_milestone(TaskReadyList,'Ready');
                if(TaskCompleteList.size()>0)
                    email_milestone(TaskCompleteList,'Complete'); 
                if(BOTasks.size()>0)
                    InsertBackout(BOTasks,SOEIds);
                if(NewTaskIdsMap.Size() > 0)
                    UpdateTaskIdsinBackout(NewTaskIdsMap,OldTaskIdsMap);
                if(tasksPinList.size()>0)
                    email_Pin(tasksPinList,TaskSOEIds);
            }    
        }
    }
    public static void BeforeDelete(list<task__c> DelTaskList){
        map<Id,id> ImpTaskList2 = new map<Id,id>();
        map<Id,id> BOTaskList2 = new map<Id,id>();
        if(Schema.SOBjectType.Task__c.isDeletable()){
            for(Task__c tas: DelTaskList){
                if(tas.Stage_Level__c  == I8.CONTEXT_IMP && tas.Is_Stack__c == false )
                    ImpTaskList2.put(tas.Id,tas.Id);
                if(tas.Stage_Level__c== I8.CONTEXT_BO && tas.Is_Stack__c == false )
                    BOTaskList2.put(tas.Id,tas.Id);    
            }        
            if(ImpTaskList2.size()>0) 
                DeleteSuccessors(ImpTaskList2,I8.CONTEXT_IMP);
            if(BOTaskList2.size()>0)  
                DeleteSuccessors(BOTaskList2,I8.CONTEXT_BO);       
        }
    }
    public static void AfterDelete(list<task__c> DelTaskList){
        list<Task__c> ImpTaskList = new list<Task__c>();
        list<Task__c> ImpTaskList1 = new list<Task__c>();
        list<Task__c> ImpTaskList2 = new list<Task__c>();
        list<Task__c> ImpTaskList3 = new list<Task__c>();
        list<Task__c> FreezeTasks = new list<Task__c>();
        if(Schema.SObjectType.Task__c.isDeletable()){
            for(Task__c tas: DelTaskList){
                if(tas.Stage_Level__c== I8.CONTEXT_IMP && tas.Is_Stack__c == true)
                    ImpTaskList.add(tas);
                if(tas.Stage_Level__c== I8.CONTEXT_BO && tas.Is_Stack__c == true)
                    ImpTaskList2.add(tas); 
                if(tas.Stage__c == i8.STAGE_IMP && tas.Status__c == i8.STATUS_FREEZE)
                    FreezeTasks.add(tas);
            }
            if(ImpTaskList.size()<=0){ 
                for(Task__c tas: DelTaskList){         
                    if(tas.Stage_Level__c== I8.CONTEXT_IMP && tas.Is_Stack__c == false && tas.End_Stack__c == false)
                        ImpTaskList1.add(tas);
                }
            }
            if(ImpTaskList2.size()<=0){ 
                for(Task__c tas: DelTaskList){ 
                    if(tas.Stage_Level__c== I8.CONTEXT_BO && tas.Is_Stack__c == false && tas.End_Stack__c == false)
                        ImpTaskList3.add(tas); 
                }      
            }
            if(ImpTaskList.size()>0)
                DecrementTaskIDWhenStackDeleted(ImpTaskList,I8.CONTEXT_IMP);
            if(ImpTaskList2.size()>0)
                DecrementTaskIDWhenStackDeleted(ImpTaskList2,I8.CONTEXT_BO);       
            if(ImpTaskList1.size()>0)
                DecrementIdsWhenTaskDeleted(ImpTaskList1,I8.CONTEXT_IMP);
            if(ImpTaskList3.size()>0)
                DecrementIdsWhenTaskDeleted(ImpTaskList3,I8.CONTEXT_BO); 
            if(FreezeTasks.size()>0)
                InsertHistory(FreezeTasks,'delete');
        }    
    }   
    public static void UpdateAllTasks(list<string> SOEIds,string SOEContext) {
        if(Utils.isAccess_Update('i8__Task__c') && Utils.isAccessible('i8__Dependency__c')){ 
            integer count= database.countQuery('select count() from Task__c where SOE__c In: SOEIds and Stage_Level__c =: SOEContext');
            if(count > 2000)
                FutureUpdateTasks(SOEIds,SOEContext);
            else if(count > 0 && count <= 2000)
                UpdateTasks(SOEIds,SOEContext);
        }
    }
    @future
    public static void FutureUpdateTasks(list<string> SOEIds,string SOEContext)
    {
        UpdateTasks(SOEIds,SOEContext);
    }
    public static void UpdateTasks(list<string> SOEId,string SOEContext)
    {
    If(Utils.isAccess_Update('i8__Task__c') && Utils.isAccessible('i8__SOE__c') && Utils.isAccessible('i8__Dependency__c')){
        Map<Id,Task__c> TotalTaskMap = new Map<Id,Task__c>();
        Map<Id,Task__c> UpdateTaskList = new Map<Id,Task__C>();
        Map<string,Task__c> StackFirstMap = new Map<String,Task__c>();
        Map<string,Task__c> StackLastMap = new Map<String,Task__c>();
        Boolean DepBool,RunBool,StackBool ;
        Set<Id> ExtDep = new Set<Id>();
        Map<Id,Task__c> ExtTAskMap = new Map<Id,TAsk__c>();
        Map<Id,SOE__c> SOEList = new Map<Id,SOE__c>();
        map<string,list<task__C>> TasksInSatgeMap= new map<string,list<task__c>>();
        map<id,list<task__C>> SOETaskMap = new map<id,list<task__c>>();
        boolean PostStage = false;        
        for(SOE__c s: [select id,BackOut_Stage__c,Schedule_Start__c,Status__c,Pre_Imp_Start__c,Imp_Start__c,Schedule_End__c, Baseline_Start__c,Warning_Zone__c,BAU_Impact__c from SOE__c where id =: SOEId])
            SOEList.put(s.Id,s);
        for(Task__c tas: [select id,Status__c ,Jump__c ,Total_Mins__c,Time_Bound__c,Sus_Status__c,First_Ready__c,Stage_Level__c,ID_Before_decimal__c,Dependency_Type__c,Sum_Mins__c,Sum_Hours__c,Sum_DAys__c,Is_Stack__c ,Id_After_Decimal__c,Start_Time__c,SOE__c ,ID_Text__c ,End_Stack__c ,Stage__c ,Forecast_Start__c ,Forecast_End__c ,Actual_Start__c ,Baseline_Start__c,Baseline_End__c,End_time__c,days__c,Hours__c,Minutes__c, 
                          Max_Task_In_Stack__c,Sum_Tasks__c,Critical_Path__c,(select id,Task__c,Preceeding_Task__c,Dep_Type__c ,Dependent_Type__c,Type__c from Dependencies__r where Dependent_Type__c = 'Predecessors') from Task__c where SOE__c =: SOEId and Stage_Level__c=: SOEContext order by ID_Before_decimal__c,Id_After_Decimal__c]) {
                              if(tas.Is_Stack__c == true){
                                  StackFirstMap.put(tas.ID_Before_decimal__c+'_'+ tas.SOE__c,tas);
                              }
                              else {
                                  if(!SOETaskMap.containsKey(tas.SOE__c))
                                          SOETaskMap.put(tas.SOE__c,new list<Task__c>());
                                      SOETaskMap.get(tas.SOE__c).add(tas);
                                  TotalTaskMap.put(tas.Id,tas);
                                  if(tas.End_Stack__c == false){
                                      if(!TasksInSatgeMap.containsKey(tas.Id_Before_Decimal__c.intValue()+'_'+tas.SOE__c))
                                          TasksInSatgeMap.put(tas.Id_Before_Decimal__c.intValue()+'_'+tas.SOE__c,new list<Task__c>());
                                      TasksInSatgeMap.get(tas.Id_Before_Decimal__c.intValue()+'_'+tas.SOE__c).add(tas);
                                  }
                                  if(tas.End_Stack__c == true)
                                      StackLastMap.put(tas.ID_Before_decimal__c+'_'+ tas.SOE__c,tas);
                              }
                              if(tas.Dependency_Type__c == I8.EXTERNALDEP ){            
                                  for(Dependency__c dep : tas.Dependencies__r){                  
                                      if(dep.Dep_Type__c == I8.EXTERNALDEP )
                                          ExtDep.add(dep.Preceeding_Task__c);
                                  }
                              }
                              if(tas.Stage__c == I8.STAGE_POST)
                                  PostStage = true;            
                          }
        for(Task__c tas: [select id,Status__c ,total_Mins__c,Jump__c ,ID_Before_decimal__c,Stage_Level__c,Dependency_Type__c,Sum_Mins__c,Sum_Hours__c,Sum_DAys__c,Is_Stack__c ,Id_After_Decimal__c,Start_Time__c,SOE__c ,ID_Text__c ,End_Stack__c ,Stage__c ,Forecast_Start__c ,Forecast_End__c ,Actual_Start__c ,
                          Sum_Tasks__c,Baseline_Start__c,Baseline_End__c,Planned_Start__c,Planned_End__c,End_time__c,days__c,Hours__c,Minutes__c from Task__c where ID IN: ExtDep])
            ExtTAskMap.put(tas.Id,tas);
        DateTime dt=System.Now();   
        for(string soe_id : SOEId){
        for(Task__c tas : SOETaskMap.get(soe_id)){
            depBool = false;
            RunBool = false;
            StackBool = false;
            Task__c Task1;
            List<Dependency__c> FSDepList = new list<Dependency__c>();
            List<Dependency__c> SSDepList = new list<Dependency__c>();
            //for calculating Task Start Time
            if(tas.Status__c == I8.STATUS_BUILD || tas.Status__c == I8.STATUS_BUILD_JUMP || tas.Status__c == I8.STATUS_REVIEW || tas.Status__c == I8.STATUS_REVIEW_JUMP || tas.Status__c == I8.STATUS_SCHEDULED || tas.Status__c == I8.STATUS_SCHEDULED_JUMP || tas.Status__c == I8.STATUS_READY ||
               tas.Status__c == I8.STATUS_WAITING || tas.Status__c == I8.STATUS_WAITING_JUMP || tas.Status__c == I8.STATUS_FREEZE || tas.Status__c == I8.STATUS_FREEZE_JUMP || (tas.Status__c == I8.STATUS_SUSPENDED && tas.Actual_Start__c == null) || tas.Status__c == I8.STATUS_TOBE_RELEASED ){
                   if(tas.Time_Bound__c != null && integer.valueof((tas.time_Bound__c.getTime() - dt.getTime())/(1000*60))>=1)
                       tas.Start_Time__c = tas.Time_Bound__c;
                   else if(tas.Dependencies__r.Size()>0){
                       tas.Sum_Tasks__c = tas.Id ;
                       tas.Sum_Mins__c = tas.total_Mins__c;
                       Task__c MaxTAsk;
                       if(stackFirstMap.containskey( (tas.Id_Before_Decimal__c.intValue()-1)+'_'+tas.SOE__c))
                           MaxTask = stackFirstMap.get( (tas.Id_Before_Decimal__c.intValue()-1)+'_'+tas.SOE__c);
                       else
                           MaxTask = StackFirstMap.get(tas.ID_Before_decimal__c+'_'+ tas.SOE__c);
                       DateTime MaxEndTime = MaxTask.Start_Time__c;
                       DateTime Start,Max;
                       for(Dependency__c dep : tas.Dependencies__r){
                           if(dep.Type__c == I8.DEP_FS)
                               FSDepList.add(dep);
                           if(dep.Type__c == I8.DEP_SS)
                               SSDepList.add(dep);
                       }
                       if(SSDepList.size() > 0 ){
                           for(Dependency__c dep: SSDepLIst){
                               task__c  t2, ExtdepTask;
                               if(UpdateTaskList.containskey(dep.Preceeding_Task__c))
                                   ExtdepTask = UpdateTaskList.get(dep.Preceeding_Task__c);
                               else
                                   ExtdepTask  = ExtTAskMap.get(dep.Preceeding_Task__c) ;
                               if(dep.Dep_type__c == I8.EXTERNALDEP)
                                   ExtdepTask   = t2;
                               else
                                   t2 = TotalTaskMap.get(dep.Preceeding_Task__c);
                               Task1 = t2;
                               if(MaxEndTime < t2.Start_Time__c){
                                   MaxEndTime = t2.Start_Time__c;
                                   Task1 = t2;
                               }
                               if(t2.Status__c != I8.STATUS_RUNNING && t2.Status__c != I8.STATUS_COMPLETED  && t2.Status__c != I8.STATUS_COMP_JUMP && t2.Status__C != I8.STATUS_FORCE_COMP)
                                   RunBool = true;
                               start = Task1.Start_Time__c ;
                           }
                       }
                       if(FSDepList.size() > 0 ){
                           for(Dependency__c dep : FSDepList ){
                               task__c  t2,ExtdepTask;
                               if(UpdateTaskList.containskey(dep.Preceeding_Task__c))
                                   ExtdepTask = UpdateTaskList.get(dep.Preceeding_Task__c);
                               else
                                   ExtdepTask  = ExtTAskMap.get(dep.Preceeding_Task__c) ;
                               if(dep.Dep_type__c == I8.EXTERNALDEP)
                                   t2 = ExtdepTask  ;
                               else
                                   t2 = TotalTaskMap.get(dep.Preceeding_Task__c);
                               if(MaxEndTime < t2.End_Time__c){
                                   MaxEndTime = t2.End_Time__c;
                                   Task1 = t2;
                               }
                               if(t2.Status__c != I8.STATUS_COMPLETED  && t2.Status__c != I8.STATUS_COMP_JUMP && t2.Status__C != I8.STATUS_FORCE_COMP)
                                   DepBool = true;
                           }
                           if(DepBool == true)
                               Max = MaxEndTime ;
                           else
                               Max = dt;
                       }
                       if(SSDepList.size()>0 && FSDepList.size()>0){
                           if(start >= max){
                               tas.Start_Time__c = start;
                           }
                           else
                               tas.Start_time__c = max;
                       }
                       else if(SSDepList.size()>0 && FSDepList.size()<=0){
                           tas.Start_Time__c = start;                           
                       }
                       else if(SSDepList.size()<=0 && FSDepList.size()>0){
                           tas.Start_time__c = max;
                       }                       
                       
                       if(Task1 != null){
                           if(tas.Start_Time__c == start){
                               if(tas.Sum_MIns__c <= Task1.Sum_Mins__c){
                                   tas.Sum_Mins__c = Task1.Sum_Mins__c;
                                   if(Task1.Sum_Tasks__c != null)
                                       tas.Sum_Tasks__c += ','+Task1.Sum_Tasks__c;
                                   else
                                       tas.Sum_Tasks__c += ','+Task1.Id;
                               }
                           }
                           else if(tas.Start_Time__c == max){
                               tas.Sum_Mins__c = tas.Total_mins__c + Task1.Sum_mins__c;
                               if(Task1.Sum_Tasks__c != null)
                                   tas.Sum_Tasks__c += ','+Task1.Sum_Tasks__c;
                               else
                                   tas.Sum_Tasks__c += ','+Task1.Id;
                           } 
                       }                   
                   }                   
                   else if( tas.End_Stack__c == true ){  
                       decimal MaxMins = 0,MaxHrs = 0,MaxDys  = 0 ;
                       Task__C stack = StackFirstMap.get(tas.Id_Before_Decimal__c.intValue()+'_'+tas.SOE__c);
                       if(TasksInSatgeMap.get(tas.Id_Before_Decimal__c.intValue()+'_'+tas.SOE__c)!= null){
                           DateTime StartMinDate = TasksInSatgeMap.get(tas.Id_Before_Decimal__c.intValue()+'_'+tas.SOE__c)[0].Start_time__c;
                           DateTime EndMaxDate = StartMinDate ;
                           for(Task__c tas1: TasksInSatgeMap.get(tas.Id_Before_Decimal__c.intValue()+'_'+tas.SOE__c)){
                               if(EndMaxDate < tas1.End_Time__c )
                                   EndMaxDate = tas1.End_Time__c;
                               if(StartMinDate > tas1.Start_Time__c )
                                   StartMinDate = tas1.Start_Time__c ;
                               if( MaxMins <= tas1.Sum_Mins__c ){
                                   MaxMins = tas1.Sum_Mins__c ; 
                                   Task1 = tas1;
                               }
                               if(tas1.Status__c != i8.STATUS_COMPLETED  && tas1.Status__c != i8.STATUS_COMP_JUMP && tas1.Status__c != i8.STATUS_FORCE_COMP )
                                   StackBool = true;                                
                           }
                           stack.Start_time__c = StartMinDate ;
                           if(tas.Status__c == i8.STATUS_READY && EndMaxDate < dt)
                               EndMaxDate = dt;
                           stack.End_time__c = EndMaxDate ;                            
                           tas.Start_Time__c = EndMaxDate ;
                           stack.End_Time__c = stack.End_Time__c.addDays(Integer.valueof(tas.Days__c));
                           stack.End_Time__c = stack.End_Time__c.addHours(Integer.valueof(tas.Hours__c ));
                           stack.End_Time__c = stack.End_Time__c.addMinutes(Integer.valueof(tas.Minutes__c ));
                           Decimal duration  = Stack.End_Time__c.getTime() - stack.Start_Time__c.getTime();
                           Integer seconds = Integer.valueof(duration  / 1000);
                           Integer mins = Integer.valueof(seconds/60);
                           stack.Hours__c = Math.floor(mins/60);
                           stack.Minutes__c = Math.mod(mins,60);
                           stack.Days__c  = Math.floor( stack.Hours__c/ 24);
                           stack.Hours__c = Math.mod(Integer.valueof(stack.Hours__c) , 24);
                           tas.Sum_Mins__c = stack.Minutes__c + (stack.Hours__c*60) + (stack.Days__C*24*60);
                           tas.Sum_Tasks__c = Task1.Id;
                           stack.Max_Task_In_Stack__c = TAsk1.Id;
                           if( TotalTaskMap.get(stack.Max_Task_In_Stack__c).Sum_Tasks__c == null)
                               tas.Sum_Tasks__c = tas.Id+','+TotalTaskMap.get(stack.Max_Task_In_Stack__c).Id;
                           else    
                               tas.Sum_Tasks__c = tas.Id+','+TotalTaskMap.get(stack.Max_Task_In_Stack__c).Sum_Tasks__c;
                       }
                       else
                           tas.Start_Time__c = StackFirstMap.get(tas.ID_Before_decimal__c+'_'+ tas.SOE__c).End_Time__c;
                       if(PostStage == true && stackFirstMap.containskey( (tas.Id_Before_Decimal__c.intValue()+1)+'_'+tas.SOE__c)){
                           if(tas.Stage__c == I8.STAGE_IMP && StackFirstMap.get( (tas.Id_Before_Decimal__c.intValue()+1)+'_'+tas.SOE__c).Stage__c == I8.STAGE_POST){
                               DateTime MaxEnd = stack.Start_Time__c;
                               for(Task__C tas1: StackFirstMap.values()){
                                   if(MaxEnd  <= tas1.End_time__c  && tas1.Stage__c == i8.STAGE_IMP)
                                       MaxEnd = tas1.End_time__c;
                               }
                               stackFirstMap.get( (tas.Id_Before_Decimal__c.intValue()+1)+'_'+tas.SOE__c).Start_Time__c = MaxEnd;
                           }
                       }
                   }
                   else if(tas.Stage__c == I8.STAGE_IMP && SOEList.get(tas.SOE__c).Schedule_Start__c != null ){
                       tas.Sum_Tasks__C = tas.Id;                       
                       tas.Total_Mins__c = tas.Minutes__c + (tas.Hours__c*60) + (tas.Days__C*24*60);
                       tas.Sum_Mins__c = tas.Total_Mins__c;
                       if(SOEList.get(tas.SOE__c).Schedule_Start__c > dt)                 
                           tas.Start_Time__c = SOEList.get(tas.SOE__c).Schedule_Start__c ;
                       else
                           tas.Start_Time__c = dt;
                   }
                   else if(tas.Stage__c == I8.STAGE_POST){
                       if(StackFirstMap.get(tas.ID_Before_decimal__c+'_'+ tas.SOE__c).Start_Time__c  > dt)
                           tas.Start_Time__c = StackFirstMap.get(tas.ID_Before_decimal__c+'_'+ tas.SOE__c).Start_Time__c;
                       else
                           tas.Start_Time__c = dt;
                   }                   
                   else{
                       tas.Sum_Tasks__C = tas.Id;                       
                       tas.Total_Mins__c = tas.Minutes__c + (tas.Hours__c*60) + (tas.Days__C*24*60);
                       tas.Sum_Mins__c = tas.Total_Mins__c;
                       if(SOEList.get(tas.SOE__c).Status__c != i8.STATUS_BUILD && SOEList.get(tas.SOE__c).Status__c != i8.STATUS_REVIEW && tas.Stage__c == i8.STAGE_PRE){                           
                           tas.Start_time__c = dt;
                       }
                       else
                           tas.Start_Time__c = SOEList.get(tas.SOE__c).Baseline_Start__c;
                   }                   
               }     
            //for calculating Task End Time
            if(tas.Status__c != i8.STATUS_COMPLETED && tas.Status__c != i8.STATUS_FORCE_COMP && tas.Status__c != i8.STATUS_COMP_JUMP){
                tas.End_Time__c = tas.Start_Time__c.addMinutes(Integer.valueof(tas.Minutes__c));
                tas.End_Time__c = tas.End_Time__c.addhours(Integer.valueof(tas.Hours__c));
                tas.End_Time__c = tas.End_Time__c.addDays(Integer.valueof(tas.Days__c));
            }
            //for calcluting status of the Task
            if(SOEList.get(tas.SOE__c).Status__C == I8.STATUS_REVIEW)
                tas.Status__c = I8.STATUS_REVIEW;
            else if(SOEList.get(tas.SOE__c).Status__C == I8.STATUS_SCHEDULED && (tas.Status__c == i8.STATUS_REVIEW || tas.Status__c == i8.STATUS_REVIEW_JUMP))
                tas.Status__c = I8.STATUS_SCHEDULED;
            else if(SOEList.get(tas.SOE__c).Status__C == I8.STATUS_FREEZE && tas.Stage__c != I8.STAGE_PRE)
                tas.Status__c = I8.STATUS_FREEZE;          
            //If SOE is Abandoned
            if(SOEList.get(tas.SOE__c).Status__C == I8.STATUS_ABANDONED){
                if(tas.Status__C == I8.STATUS_RUNNING || tas.Status__c == I8.STATUS_READY  || tas.Status__C == I8.STATUS_WAITING || tas.Status__c == I8.STATUS_SUSPENDED 
                   || tas.Status__C == I8.STATUS_WAITING_JUMP || tas.Status__c == i8.STATUS_RERUN)
                    tas.Status__c = I8.STATUS_ABANDONED;
                if(tas.End_Stack__c == true)
                    StackFirstMap.get(tas.ID_Before_decimal__c+'_'+ tas.SOE__c).Status__c = I8.STATUS_ABANDONED;
            }
            //If SOE is suspended
            else if(SOECOntext == i8.CONTEXT_IMP && (SOEList.get(tas.SOE__c).Status__C == I8.STATUS_SUSPENDED || SOEList.get(tas.SOE__c).Status__C == i8.STATUS_BOINPROGRESS) ){
                if(tas.Status__c == I8.STATUS_READY  || tas.Status__c == I8.STATUS_RUNNING || tas.Status__C == I8.STATUS_WAITING 
                   || tas.Status__C == I8.STATUS_WAITING_JUMP || tas.Status__c == I8.STATUS_SUSPENDED || tas.Status__c == i8.STATUS_RERUN){
                       tas.Sus_Status__c = tas.Status__c;
                       tas.Status__c = I8.STATUS_SUSPENDED;
                   }
                if(tas.End_Stack__c == true){
                    StackFirstMap.get(tas.ID_Before_decimal__c+'_'+ tas.SOE__c).Sus_Status__c = StackFirstMap.get(tas.ID_Before_decimal__c+'_'+ tas.SOE__c).Status__c;
                    StackFirstMap.get(tas.ID_Before_decimal__c+'_'+ tas.SOE__c).Status__c = I8.STATUS_SUSPENDED;
                }
            }
            else if(SOEList.get(tas.SOE__c).Status__C == I8.STATUS_IMPINPROGRESS && Create_Incident.SOE_ReExe == true ){
                if(tas.Status__c == i8.STATUS_SUSPENDED  || tas.Status__c == i8.STATUS_SUSPENDED +i8.JUMP)
                    tas.Status__c = tas.Sus_Status__c;
                if(tas.End_Stack__c == true && StackFirstMap.get(tas.ID_Before_decimal__c+'_'+ tas.SOE__c).Status__c == I8.STATUS_SUSPENDED)
                    StackFirstMap.get(tas.ID_Before_decimal__c+'_'+ tas.SOE__c).Status__c = StackFirstMap.get(tas.ID_Before_decimal__c+'_'+ tas.SOE__c).Sus_Status__c;
            }
            else if( tas.Stage__c == I8.STAGE_PRE && (tas.Status__c == I8.STATUS_SCHEDULED || tas.Status__c == I8.STATUS_SCHEDULED_JUMP || tas.Status__c == I8.STATUS_WAITING || tas.Status__c == i8.STATUS_WAITING_JUMP || tas.Status__c == I8.STATUS_FREEZE || tas.Status__c == i8.STATUS_FREEZE_JUMP || tas.Status__c == i8.STATUS_READY)){
                if(tas.Dependencies__r.Size()==0 && tas.Start_Time__c.date()  ==dt.date() && tas.Start_Time__c .Hour() == dt.Hour() && tas.Start_Time__c.minute() == dt.Minute() && tas.End_Stack__c == false)
                    tas.Status__c = I8.STATUS_READY ;   
                else if(((FSDepList.Size()>0 && SSDepList.size()<=0 && depBool == false) || (SSDepList.size()>0 && FSDEpList.size()<=0 && RunBool== false)|| (SSDepList.size()>0 && FSDEpList.size()>0 && RunBool== false && depBool == false)) && tas.Start_Time__c.date()  ==dt.date() && tas.Start_Time__c .Hour() == dt.Hour() && tas.Start_Time__c.minute() == dt.Minute())
                    tas.Status__c = I8.STATUS_READY ;
                else
                    tas.Status__c = I8.STATUS_WAITING ;                
            }
            else if(SOEList.get(tas.SOE__c).Status__c == I8.STATUS_IMPINPROGRESS  && SOECOntext == i8.CONTEXT_IMP && tas.Stage__c == I8.STAGE_IMP  && (tas.Status__C == I8.STATUS_FREEZE || tas.Status__C == I8.STATUS_FREEZE_JUMP || tas.Status__c == I8.STATUS_WAITING  || tas.Status__c == I8.STATUS_WAITING_JUMP ) ){
                if(tas.Dependencies__r.Size()==0 && tas.Start_Time__c.date()  ==dt.date() && tas.Start_Time__c .Hour() == dt.Hour() && tas.Start_Time__c.minute() == dt.Minute() && tas.End_Stack__c == false)
                    tas.status__c = I8.STATUS_READY;
                else if(((FSDepList.Size()>0 && SSDepList.size()<=0 && depBool == false) || (SSDepList.size()>0 && FSDEpList.size()<=0 && RunBool== false)|| (SSDepList.size()>0 && FSDEpList.size()>0 && RunBool== false && depBool == false)) && tas.Start_Time__c.date()  ==dt.date() && tas.Start_Time__c .Hour() == dt.Hour() && tas.Start_Time__c.minute() == dt.Minute())
                    tas.status__c = I8.STATUS_READY; 
                else 
                    tas.Status__c = I8.STATUS_WAITING;
            }
            else if(SOEList.get(tas.SOE__c).Status__c == I8.STATUS_IMPINPROGRESS && SOECOntext == i8.CONTEXT_IMP && tas.Stage__c == I8.STAGE_POST)
                tas.Status__c = I8.STATUS_WAITING;
            
            else if(SOEList.get(tas.SOE__c).Status__c == I8.STATUS_IMP_COMP && tas.Stage__c == I8.STAGE_POST  && (tas.Status__c == I8.STATUS_WAITING || tas.Status__c == I8.STATUS_WAITING_JUMP)){
                if(tas.Dependencies__r.Size()==0 && tas.Start_Time__c.date()  ==dt.date() && tas.Start_Time__c .Hour() == dt.Hour() && tas.Start_Time__c.minute() == dt.Minute() && tas.End_Stack__c == false)
                    tas.status__c = I8.STATUS_READY;
                else if(((FSDepList.Size()>0 && SSDepList.size()<=0 && depBool == false) || (SSDepList.size()>0 && FSDEpList.size()<=0 && RunBool== false)|| (SSDepList.size()>0 && FSDEpList.size()>0 && RunBool== false && depBool == false)) && tas.Start_Time__c.date()  ==dt.date() && tas.Start_Time__c .Hour() == dt.Hour() && tas.Start_Time__c.minute() == dt.Minute())
                    tas.status__c = I8.STATUS_READY; 
                else 
                    tas.Status__c = I8.STATUS_WAITING;
            }  
            else if(SOEList.get(tas.SOE__c).Status__c == I8.STATUS_IMPINPROGRESS && SOECOntext == i8.CONTEXT_BO )
                tas.Status__c = I8.STATUS_TOBE_RELEASED ;
            else if(SOEList.get(tas.SOE__c).Status__c == I8.STATUS_BOINPROGRESS  && SOECOntext == i8.CONTEXT_BO && tas.Stage__c == I8.STAGE_IMP  && (tas.Status__C == I8.STATUS_TOBE_RELEASED || tas.Status__c == I8.STATUS_WAITING  || tas.Status__c == I8.STATUS_WAITING_JUMP ) ){
                if(tas.Dependencies__r.Size()==0 && tas.Start_Time__c.date()  ==dt.date() && tas.Start_Time__c .Hour() == dt.Hour() && tas.Start_Time__c.minute() == dt.Minute() && tas.End_Stack__c == false)
                    tas.status__c = I8.STATUS_READY;
                else if(((FSDepList.Size()>0 && SSDepList.size()<=0 && depBool == false) || (SSDepList.size()>0 && FSDEpList.size()<=0 && RunBool== false)|| (SSDepList.size()>0 && FSDEpList.size()>0 && RunBool== false && depBool == false)) && tas.Start_Time__c.date()  ==dt.date() && tas.Start_Time__c .Hour() == dt.Hour() && tas.Start_Time__c.minute() == dt.Minute())
                    tas.status__c = I8.STATUS_READY; 
                else 
                    tas.Status__c = I8.STATUS_WAITING;
            }
            else if(SOEList.get(tas.SOE__c).Status__c == I8.STATUS_BOINPROGRESS && SOECOntext == i8.CONTEXT_BO && tas.Stage__c == I8.STAGE_POST)
                tas.Status__c = I8.STATUS_WAITING;
            else if(SOEList.get(tas.SOE__c).Status__c == I8.STATUS_BO_COMP && tas.Stage__c == I8.STAGE_POST  && (tas.Status__c == I8.STATUS_WAITING || tas.Status__c == I8.STATUS_WAITING_JUMP)){
                if(tas.Dependencies__r.Size()==0 && tas.Start_Time__c.date()  ==dt.date() && tas.Start_Time__c .Hour() == dt.Hour() && tas.Start_Time__c.minute() == dt.Minute() && tas.End_Stack__c == false)
                    tas.status__c = I8.STATUS_READY;
                else if(((FSDepList.Size()>0 && SSDepList.size()<=0 && depBool == false) || (SSDepList.size()>0 && FSDEpList.size()<=0 && RunBool== false)|| (SSDepList.size()>0 && FSDEpList.size()>0 && RunBool== false && depBool == false)) && tas.Start_Time__c.date()  ==dt.date() && tas.Start_Time__c .Hour() == dt.Hour() && tas.Start_Time__c.minute() == dt.Minute())
                    tas.status__c = I8.STATUS_READY; 
                else 
                    tas.Status__c = I8.STATUS_WAITING;
            }
             if(tas.jump__c == true && !tas.Status__c.contains(i8.JUMP))
                tas.Status__c = tas.Status__c+ i8.JUMP;  
            if(tas.End_stack__c == true){
                if(StackBool == false && (tas.Status__c == i8.STATUS_WAITING || tas.Status__c == i8.STATUS_WAITING_JUMP)){
                    if(tas.Days__c == 0 && tas.Hours__c == 0 && tas.Minutes__c == 0  ){
                        if(tas.Jump__c == true)
                            tas.Status__c = i8.STATUS_READY; 
                        else{
                            tas.Status__c = i8.STATUS_COMPLETED;
                            tas.Actual_Start__c = dt;
                            tas.Actual_End__c = dt;
                            tas.Start_Time__c = dt;
                            tas.End_Time__c = dt;
                        }
                    } 
                    else 
                        tas.Status__c = i8.STATUS_READY;   
                }  
                if(tas.Status__c == i8.STATUS_READY && tas.Stage__c == i8.STAGE_IMP && tas.First_Ready__c == null)
                    tas.First_Ready__c = dt;                                  
            }
            if(tas.status__c == I8.STATUS_READY || tas.Status__c == I8.STATUS_READY +i8.JUMP){
                if(tas.Jump__c == true){
                    tas.Status__c = I8.STATUS_COMP_JUMP ; 
                    tas.Actual_Start__c = dt ; 
                    tas.Actual_End__c =   dt;
                    tas.Start_Time__c = dt;
                    tas.End_Time__c = dt;
                }
                if(tas.Stage__c == i8.STAGE_IMP && tas.First_Ready__c == null)
                    tas.First_Ready__c = dt;
            }          
            // Update Baseline planned, Forecast Time            
            Task__c Stack1 = StackFirstMap.get( tas.Id_Before_Decimal__c.intValue() +'_'+ tas.SOE__c);
            if(SOEList.get(tas.SOE__c).Status__C == i8.STATUS_BUILD || SOEList.get(tas.SOE__c).Status__C == i8.STATUS_REVIEW){
                tas.Baseline_Start__c = tas.Start_Time__c;
                tas.Baseline_End__c = tas.End_Time__c;
                Stack1.Baseline_Start__c = Stack1.Start_Time__c;
                Stack1.Baseline_End__c = Stack1.End_Time__c;   
            } 
            else  if( (SOEList.get(tas.SOE__c).Status__C == i8.STATUS_SCHEDULED || SOEList.get(tas.SOE__c).Status__C == i8.STATUS_FREEZE ) && (tas.Stage__c == i8.STAGE_IMP || tas.Status__c == i8.STAGE_POST)){
                tas.Planned_Start__c = tas.Start_Time__c;
                tas.Planned_End__c = tas.End_Time__c;
                tas.Forecast_Start__c = tas.Start_Time__c;
                tas.Forecast_End__c = tas.End_Time__c; 
                Stack1.Planned_Start__c = Stack1.Start_Time__c;
                Stack1.Planned_End__c = Stack1.End_Time__c;
                Stack1.Forecast_Start__c = Stack1.Start_Time__c;
                Stack1.Forecast_End__c = Stack1.End_Time__c;   
            }
            else if( Stack1.Status__c == i8.STATUS_JUMP || Stack1.Status__c == null || tas.Status__c == i8.STATUS_READY || tas.Status__c == i8.STATUS_WAITING || tas.Status__c == i8.STATUS_WAITING_JUMP || tas.Status__c == i8.STATUS_SUSPENDED ){
                tas.Forecast_Start__c = tas.Start_Time__c;
                tas.Forecast_End__c = tas.End_Time__c;
                Stack1.Forecast_Start__c = Stack1.Start_Time__c;
                Stack1.Forecast_End__c = Stack1.End_Time__c; 
            } 
            if( SOEList.get(tas.SOE__c).Status__C != I8.STATUS_REVIEW  && SOEList.get(tas.SOE__c).Status__C != I8.STATUS_BUILD  && SOEList.get(tas.SOE__c).Imp_Start__c == false &&
               tas.Status__c !=  I8.STATUS_RUNNING  && tas.Status__c !=  I8.STATUS_COMPLETED && tas.Status__c !=  I8.STATUS_FORCE_COMP && tas.Status__c !=  I8.STATUS_COMP_JUMP && tas.Status__c !=  I8.STATUS_SUSPENDED){
                   tas.Planned_Start__c = tas.Start_Time__c;
                   tas.Planned_End__c = tas.End_Time__c;
                   Stack1.Planned_Start__c = Stack1.Start_Time__c;
                   Stack1.Planned_End__c = Stack1.End_Time__c;
               }
            if(tas.Status__c ==  I8.STATUS_RUNNING && tas.End_Time__c < dt){
                tas.End_Time__c = dt;
                tas.Forecast_End__c = dt;
                Decimal duration  = tas.End_Time__c.getTime() - tas.Start_Time__c.getTime();
                Integer seconds = Integer.valueof(duration  / 1000);
                Integer mins = Integer.valueof(seconds/60);
                tas.Hours__c = Math.floor(mins/60);
                tas.Minutes__c = Math.mod(mins,60);
                tas.Days__c  = Math.floor( tas.Hours__c/ 24);
                tas.Hours__c = Math.mod(Integer.valueof(tas.Hours__c) , 24);
                if(tas.End_STack__c == true){
                    Stack1.End_Time__c = dt;
                    STack1.Forecast_End__c = dt;
                    duration  = stack1.End_Time__c.getTime() - stack1.Start_Time__c.getTime();
                    seconds = Integer.valueof(duration  / 1000);
                    mins = Integer.valueof(seconds/60);
                    stack1.Hours__c = Math.floor(mins/60);
                    stack1.Minutes__c = Math.mod(mins,60);
                    stack1.Days__c  = Math.floor( stack1.Hours__c/ 24);
                    stack1.Hours__c = Math.mod(Integer.valueof(stack1.Hours__c) , 24);
                }    
            }
            else if((tas.Status__c == I8.STATUS_COMPLETED  || tas.Status__c == I8.STATUS_FORCE_COMP || tas.Status__c == I8.STATUS_COMP_JUMP)&& tas.End_Stack__c == true){
                Task__C stage = StackFirstMap.get(tas.Id_Before_Decimal__c.intValue()+'_'+tas.SOE__c);
                if(Stage.Status__c != I8.STATUS_COMPLETED){
                    if(Stage.Jump__c == true)
                        Stage.Status__c = I8.STATUS_COMP_JUMP ;
                    else
                        Stage.Status__c = I8.STATUS_COMPLETED ;
                    if(Stage.Status__c == I8.STATUS_COMP_JUMP )
                        stage.Actual_Start__c = tas.Start_Time__c;
                    stage.Forecast_start__c = stage.Actual_Start__c;
                    stage.End_Time__c = tas.End_Time__c;
                    stage.Actual_End__c = stage.End_Time__c;
                    Decimal duration  = Stage.End_Time__c.getTime() - Stage.Start_Time__c.getTime();
                    Integer seconds = Integer.valueof(duration  / 1000);
                    Integer mins = Integer.valueof(seconds/60);
                    Stage.Hours__c = Math.floor(mins/60);
                    Stage.Minutes__c = Math.mod(mins,60);
                    Stage.Days__c  = Math.floor( Stage.Hours__c/ 24);
                    Stage.Hours__c = Math.mod(Integer.valueof(Stage.Hours__c) , 24);
                    tas.Sum_Mins__c = stage.Minutes__c + (stage.Hours__c*60) + (stage.Days__C*24*60);
                    if(Stage.Stage__c == I8.STAGE_IMP && PostStage  == true && StackFirstMap.get((tas.Id_Before_Decimal__c.intValue()+1)+'_'+tas.SOE__c).Stage__c == I8.STAGE_POST)
                        StackFirstMap.get((tas.Id_Before_Decimal__c.intValue()+1)+'_'+tas.SOE__c).Start_time__c = Stage.End_Time__c; 
                }
            } 
            if(   (tas.Critical_Path__c != 'UC' || tas.Critical_Path__c != 'uc' ) && (SOEList.get(tas.SOE__c).Status__c != I8.STATUS_IMPINPROGRESS && SOEList.get(tas.SOE__c).Status__c != I8.STATUS_IMP_COMP && SOEList.get(tas.SOE__c).Status__c != I8.STATUS_SOE_COMP))       
                tas.Critical_Path__c = null;
            if( tas.Status__C != I8.STATUS_FORCE_COMP)
                UpdateTaskList.put(tas.Id,tas);
        }  // end of task loop
        } // end of soe loop
        //for calclutaing critical path
        if(StackFirstMap.values().size() > 0 && SOEList.get(StackFirstMap.values()[0].SOE__c).Status__c != I8.STATUS_IMPINPROGRESS && SOEList.get(StackFirstMap.values()[0].SOE__c).Status__c != I8.STATUS_IMP_COMP && SOEList.get(StackFirstMap.values()[0].SOE__c).Status__c != I8.STATUS_SOE_COMP){
            DateTime MaxEndTime;
            if(StackFirstMap.values().size()>0)
                MaxEndTime = StackFirstMap.values()[0].Start_Time__c;
            Task__c MaxTask;
            for(Task__c tas: StackFirstMap.values()){
                if(MaxEndTime <= tas.End_Time__c && tas.Stage__c == i8.STAGE_IMP){
                    MaxEndTime  = tas.End_Time__c;
                    MaxTask = tas;
                }
            } 
            if(MaxTask != null &&  MaxTask.Stage__c == 'Imp' && MaxTask.Max_Task_In_Stack__c != null){
                if( TotalTaskMap.get(MaxTask.Max_Task_In_Stack__c).Sum_Tasks__c != null){
                    list<String> filelines = TotalTaskMap.get(MaxTask.Max_Task_In_Stack__c).Sum_Tasks__c.split(',');
                    for(String str1: filelines ){
                        TAsk__c tas = TotalTaskMAp.get(str1);
                        if(tas != null){
                            tas.Critical_Path__c = 'C';
                            UpdateTaskList.put(tas.Id,tas);
                        }                     
                    }
                }            
                TAsk__c tas1 = TotalTaskMAp.get(MaxTask.Max_Task_In_Stack__c);           
                string str = tas1.ID_Before_decimal__c+'_'+tas1.SOE__c;
                if(StackLastMap.get(str).Total_Mins__C > 0){
                    TAsk__c tas = StackLastMap.get(str);
                    tas.Critical_Path__c = 'C';
                    UpdateTaskList.put(tas.Id,tas);
                }
            }
        }
        for(Task__c tas: StackFirstMap.values())
            UpdateTaskList.put(tas.Id,tas);
        if(Task_Update )
        update UpdateTaskList.values();
      }  
    }
    public static void IncrementTaskIDWhenStackAdded(list<Task__c> TaskList,String Context){
        Map<Decimal,Integer> IDList = new Map<Decimal,Integer>();
        list<Task__c> UpdateTaskList = new List<Task__c>();
        set<Id> taskId = new set<Id>();
        set<Id> SOEIdList = new set<Id>();
        list<Task__c> NextTaskList = new list<Task__c>();
        for(Task__c t:TaskList){
            if(t.Is_Stack__c == true && t.Stage_Level__c== Context){
                IDList.put(Decimal.valueOf(t.ID_Text__c),Integer.valueof(t.ID_Text__c));
                taskId.add(t.Id);
                SOEIdList.add(t.SOE__c);
            }
        }
        if(IDList.values().size()>0 && Task_Access )
            NextTaskList = [select id,ID_Text__c,Is_Stack__c,SOE__c,Id_Before_Decimal__c,Id_After_Decimal__c from Task__c where Id_Before_Decimal__c >=: IDList.values() and SOE__c IN:SOEIdList and Stage_Level__c=:Context];
        if(NextTaskList.size()>0){
            for(Task__C t:NextTaskList ){
                t.ID_Text__c = String.ValueOf(t.Id_Before_Decimal__c+1)+'.'+String.Valueof(t.Id_After_Decimal__c);
                UpdateTaskList.add(t);
            }
        }
        if(UpdateTaskList.size()>0 && Task_Update )
            update UpdateTaskList;
    }    
    public static void UpdateIdsWhenStackMoved(list<Task__c> NewTaskList,Map<Id,Task__c> OldTaskMap,String Context,String operation){
        BoolRun = false;
        Map<Id,Decimal> SourceMap = new map<Id,Decimal>();
        Map<Id,Decimal> DestMap = new Map<Id,Decimal>();
        list<Task__c> UpdateTaskList = new List<Task__c>();
        list<Task__c> NextTaskList = new list<Task__c>();
        set<Id> SOEIdList = new set<Id>();
        for(Task__c tas: NewTaskList){
            if(operation == 'Increment'){
                SourceMap.put(tas.Id,tas.Id_Before_Decimal__c);
                DestMap.put(tas.Id,OldTaskMap.get(tas.Id).Id_Before_Decimal__c);
                SOEIdList.add(tas.SOE__c);
            }
            else {
                DestMap.put(tas.Id,tas.Id_Before_Decimal__c+1);
                SourceMap.put(tas.Id,OldTaskMap.get(tas.Id).Id_Before_Decimal__c+1);
                SOEIdList.add(tas.SOE__c);
            }
        }
        if(SourceMap.values().size()>0 && Task_Access)
            NextTaskList = [select id,ID_Text__c,Task_Title__c from task__c where Id_Before_Decimal__c >=:SourceMap.Values() and Id_Before_Decimal__c <:DestMap.values() and SOE__c IN:SOEIdList and Stage_Level__c=:Context];
        for(Task__c tas: NextTaskList ){
            if(operation == 'Increment'){
                tas.ID_Text__c =  String.ValueOf(Decimal.valueOf(tas.ID_Text__c) + 1);
                UpdateTaskList.add(tas);
            }
            else {
                tas.ID_Text__c =  String.ValueOf(Decimal.valueOf(tas.ID_Text__c) - 1);
                UpdateTaskList.add(tas);
            }
        }
        if(UpdateTaskList.size()>0 && Task_Update )
            update UpdateTaskList;        
    }    
    public  static void DecrementTaskIDWhenStackDeleted(list<Task__c> TaskList,String Context){
        Map<Id,Integer> IDList = new Map<Id,Integer>();
        list<Task__c> UpdateTaskList = new List<Task__c>();
        list<Task__c> NextTaskList = new list<Task__c>();
        for(Task__c t:TaskList){
            if( t.Stage_Level__c== Context)
                IDList.put(t.SOE__c,Decimal.valueOf(t.ID_Text__c).IntValue()+1);
        }
        if(IDList.keyset().size()>0 && Task_Access)
            NextTaskList = [select id,ID_Text__c,Is_Stack__c,SOE__c,Id_Before_Decimal__c,Id_After_Decimal__c   from Task__c where Id_Before_Decimal__c >= :IDList.values() and SOE__c IN: IDList.keyset() and Stage_Level__c=:Context  ];
        if(NextTaskList .size()>0) {   
            for(Task__C t:NextTaskList ){
                t.Id_Text__c = string.valueof(t.Id_Before_Decimal__c -1) +'.'+ string.valueof(t.Id_After_Decimal__c);
                UpdateTaskList.add(t);
            }
            if(UpdateTaskList.size()>0 && Task_Update )
                update UpdateTaskList;
        }
    }    
    public static void DecrementIdsWhenTaskDeleted(list<Task__c> TaskList,String Context){
        list<Task__c> TotalTaskList = new List<Task__c>();
        Map<string,Task__c> UpdateTaskMap= new map<string,Task__c>();
        Map<string,Task__c> TaskMap= new map<string,Task__c>();
        list<Id> SOEList = new list<Id>();
        list<Decimal> IdBeforeList = new list<Decimal>();
        for(Task__c t: TaskList){
            SOEList.add(t.SOE__c);
            IdBeforeList.add(t.ID_Before_Decimal__c );
        }
        if(Task_Access)
        TotalTaskList =[select id,Id_Text__c,Id_Before_decimal__c, ID_After_Decimal__c from Task__c where SOE__c =:SOEList  and ID_Before_Decimal__c =:IdBeforeList  and Stage_Level__c=: Context and Is_Stack__c = false order by Id_Before_Decimal__c,Id_After_Decimal__c];
        for(Task__C t: TotalTaskList ){
            TaskMAp.put(t.Id_Text__c,t);
        }
        if(TotalTaskList.size()>0) {  
            for(task__C t1: TaskList){
                for(string str: TaskMAp.keyset()){
                    list<string> StrSplit = str.split('\\.');
                    if(t1.Id_Before_decimal__c == Decimal.valueOf(StrSplit[0]) && t1.ID_After_Decimal__c < Decimal.valueOf(StrSplit[1])){
                        if(!UpdateTaskMap.ContainsKey(str)){
                            TaskMap.get(str).ID_Text__c = String.ValueOf(Decimal.valueOf(StrSplit[0]) )+'.'+String.ValueOf(Decimal.valueOf(StrSplit[1]) - 1 );
                            UpdateTaskMap.put(str,TaskMap.get(str));
                        }
                        else{
                            string str1 = UpdateTaskMap.get(str).Id_Text__c;
                            list<string> StrSplit1 = str1.split('\\.');
                            TaskMap.get(str).ID_Text__c  = String.ValueOf(Decimal.valueOf(StrSplit1[0]) )+'.'+String.ValueOf(Decimal.valueOf(StrSplit1[1]) - 1 );
                            UpdateTaskMap.remove(str);
                            UpdateTaskMap.put(str,TaskMap.get(str));
                        }
                    }
                }
            }
        }
        if(UpdateTaskMap.size()>0 && Task_Update )
            update UpdateTaskMap.values();
    }    
    public static void UpdateTaskDuration(list<Task__c> NewTaskList,Map<Id,Task__c> OldTaskMap){
        list<Task__c> UpdateTaskList = new list<Task__c>();
        list<Task__c> PreDecessorList  = new list<Task__c>();
        for(Task__c tas: NewtaskList){
            tas.Sum_Mins__c = tas.Minutes__c + (tas.Hours__c*60) + (tas.Days__C*24*60);
            tas.Total_Mins__c = tas.Minutes__c + (tas.Hours__c*60) + (tas.Days__C*24*60);
        }
    }
    public  static void DeleteSuccessors(Map<Id,Id> TaskList,String Context){
        list<Dependency__c> DepMAp = new list<dependency__c>();
        set<id> PreceedingTaskIdList = new set<id>(); 
        if(Utils.isAccessible('i8__Dependency__c'))       
        for(Dependency__c dep: [select id,Dep_Type__c,SOE__c,Task__c,Preceeding_Task__c,Task__r.Status__c from Dependency__c  where Task__c IN: TaskList.keyset() or Preceeding_Task__c =: TaskList.keyset() ]){
            if(!TaskList.Containskey(dep.Preceeding_Task__c))
                PreceedingTaskIdList.add(dep.Preceeding_Task__c);
            if(!TaskList.Containskey(dep.Task__c))
                PreceedingTaskIdList.add(dep.Task__c);               
            DepMAp.add(dep);
        }  
        if(DepMAp.size()>0 && Schema.SOBjectTYpe.Dependency__c.isDeletable())            
            delete DepMAp;            
        CalculateDependencyType(PreceedingTaskIdList);
    }
    public static void CalculateDependencyType(set<Id> Tasklist){
        list<Task__c> TaskUpdList = new list<Task__c>();
        if(Task_Access && Utils.isAccessible('i8__Dependency__c'))
        for(Task__c t: [select id,Internal_Task__c,Link__c ,Dependency_Type__c ,(select id,Dep_Type__c,Dependent_Type__c  from Dependencies__r )  from Task__c where Id IN: Tasklist]){
            Integer external =0;
            Integer internal = 0;
            integer link =0;            
            t.Broken_Task__c = false;
            for(Dependency__c dep: t.Dependencies__r){
                if(dep.Dep_Type__c == I8.EXTERNALDEP )
                    external++;
                else if(dep.Dep_Type__c == I8.INTERNALDEP )
                    internal++;
                else if(dep.Dependent_Type__c == I8.PREDECESSOR  && dep.Dep_type__c == I8.LINKDEP )
                    link++;
                if((dep.Dep_Type__c == I8.EXTERNALDEP && dep.Dependent_Type__c == I8.PREDECESSOR) || 
                   (dep.Dep_Type__c == I8.INTERNALDEP  && dep.Dependent_Type__c == I8.PREDECESSOR) ||
                   (dep.Dependent_Type__c == I8.PREDECESSOR  && dep.Dep_type__c == I8.LINKDEP ))                    
                    t.Broken_Task__c = true;              
            }
            if(external >0)
                t.Dependency_Type__c = I8.EXTERNALDEP ;
            else if(external ==0 && internal>0)
                t.Dependency_Type__c = I8.INTERNALDEP ;
            else if(external == 0 && internal==0 && link >0)
                t.Dependency_Type__c = I8.LINKDEP ;
            else
                t.Dependency_Type__c = I8.NODEP ;
            if(internal>0)
                t.Internal_Task__c = true;
            else
                t.Internal_Task__c = false;
            if(link > 0)
                t.Link__c = true;
            else
                t.Link__c = false;
            
            TaskUpdList.add(t);
        }        
        if(TaskUpdList.size()>0 && Task_Update )
            update TaskUpdList;
    }
    public static void InsertHistory(list<Task__c> TaskList,string Status){
        History__c History;
        List<History__c> History_List = new List<History__c>();
        for(Integer i=0; i<TaskList.size(); i++){
            History = new History__c();
            History.SOE__c = TaskList[i].SOE__c;
            History.Field__c = 'Task';
            History.Modified_By__c = UserInfo.getUserId();
            History.Task_Id__c = TaskList[i].Id_Text__c;
            History.New_Value__c =  TaskList[i].Task_Title__c;            
            if(Status == 'insert')
                History.Action__c = 'Created';
            else if(Status == 'delete')
                History.Action__c = 'Deleted';
            History_List.add(History);
        }
        if(History_List.size()>0 && Utils.isCreateable('i8__History__c'))
            Insert History_List;        
    }
    public static void InsertHistoryWhenTaskUpdate(Map<String,task__c> NewMap,Map<Id,Task__c> OldMap){
        History__c History;
        List<History__c> History_List = new List<History__c>();
        for(String str : NewMap.keyset()){
            History = new History__c();
            History.SOE__c = NewMap.get(str).SOE__c;
            History.Task_Id__c = NewMap.get(str).Id_text__c;
            History.Modified_By__c = UserInfo.getUserId();
            History.Field__c = str;
            History.Action__c = 'Updated';
            if(str == 'Task Title'){
                History.New_Value__c = NewMap.get(str).Task_Title__c;
                History.Old_Value__c = OldMap.get(NewMap.get(str).Id).Task_Title__c; 
            } 
            if(str == 'Duration'){
                History.New_Value__c = NewMap.get(str).Duration__c;
                History.Old_Value__c = OldMap.get(NewMap.get(str).Id).Duration__c; 
            }
            else if(str == 'Technical Detail'){
                if(NewMap.get(str).Technical_Detail__c != null && NewMap.get(str).Technical_Detail__c.length() > 100 )
                    History.New_Value__c = NewMap.get(str).Technical_Detail__c.substring(0,100);
                else
                    History.New_Value__c = NewMap.get(str).Technical_Detail__c;
                if(OldMap.get(NewMap.get(str).Id).Technical_Detail__c != null && OldMap.get(NewMap.get(str).Id).Technical_Detail__c.length() > 100 )
                    History.Old_Value__c = OldMap.get(NewMap.get(str).Id).Technical_Detail__c.substring(0,100);
                else
                    History.Old_Value__c = OldMap.get(NewMap.get(str).Id).Technical_Detail__c; 
            }
            else if(str == 'Description'){
                if(NewMap.get(str).Description__c != null && NewMap.get(str).Description__c.length() > 100 )
                    History.New_Value__c = NewMap.get(str).Description__c.substring(0,100);
                else
                    History.New_Value__c = NewMap.get(str).Description__c; 
                if(OldMap.get(NewMap.get(str).Id).Description__c != null && OldMap.get(NewMap.get(str).Id).Description__c.length() > 100 )
                    History.Old_Value__c = OldMap.get(NewMap.get(str).Id).Description__c.substring(0,100); 
                else
                    History.Old_Value__c = OldMap.get(NewMap.get(str).Id).Description__c; 
            }
            else if(str == 'Milestone'){
                History.New_Value__c = NewMap.get(str).Milestone_Task__c;
                History.Old_Value__c = OldMap.get(NewMap.get(str).Id).Milestone_Task__c; 
            }                      
            History_List.add(History);
        }
        if(History_List.size()>0 && Utils.isCreateable('i8__History__c'))
            Insert History_List;
    }
    public static void JumpedTasks(list<Task__c> JumpList,list<task__c> UnJumpList){
        if(JumpList.size() > 0){
            for(Task__C tas: JumpList){
                tas.Jumped_Duration__c = tas.Duration__c;
                tas.Days__c = 0;
                tas.Hours__c = 0;
                tas.Minutes__c = 0;
                if(!tas.Status__c.Contains(i8.STATUS_JUMP))
                    tas.Status__c = tas.Status__c + i8.JUMP ;
            }
        } 
        if(UnJumpList.size() >  0){
            for(Task__c tas: UnJumpList){
                if(tas.Jumped_Duration__c.indexOf('d') == -1 ){
                    tas.Days__c = 0;
                    tas.Hours__c = Decimal.valueof(tas.Jumped_Duration__c.substring(0,tas.Jumped_Duration__c.indexOf('h')));
                }
                else{
                    tas.Days__c = Decimal.valueof(tas.Jumped_Duration__c.substring(0,tas.Jumped_Duration__c.indexOf('d')));
                    tas.Hours__c = Decimal.valueof(tas.Jumped_Duration__c.substring(tas.Jumped_Duration__c.indexOf('d')+2,tas.Jumped_Duration__c.indexOf('h')));
                }                 
                tas.Minutes__c = Decimal.valueof(tas.Jumped_Duration__c.substring(tas.Jumped_Duration__c.indexOf('h')+2,tas.Jumped_Duration__c.indexOf('m')));
                if(tas.Status__c.Contains(i8.JUMP)){
                    tas.Status__c = tas.Status__c.Replace(i8.JUMP,'');
                    tas.Jumped_Duration__c= null;
                }
            }
        }
    }
    public static void InsertBackout(list<Task__c> TaskList,set<Id> SOEIds){
        list<Task__c> NewTaskList = new list<Task__c>();
        list<Task__c> NewTaskList1 = new list<Task__c>();
        Task__c task;
        Map<string,task__c> HeaderTaskMap = new Map<string,Task__c>();
        list<Decimal> JList = new list<Decimal>();
        Map<string,task__c> TrailerTaskMap = new Map<string,Task__c>();
        Map<string,list<task__c>> StackTaskMap = new Map<string,list<Task__c>>();
        Map<Decimal,String> BeforeSOEMap = new Map<Decimal,string>();
        Map<Decimal,Integer> BeforeSOEMap1 = new Map<Decimal,Integer>();        
        if(Task_Access_Create_Update){
        NewTaskList1 = [select id,SOE__c,Stage_Level__c,Id_Text__c,BO_IDBefore__c,BO_IDAfter__c,Is_Stack__c,End_Stack__c,Id_Before_Decimal__c,Id_After_Decimal__c  
                        from Task__c where SOE__c IN : SOEIds and Stage_Level__c =: i8.CONTEXT_BO and Stage__c =: i8.STAGE_IMP order by Id_Before_Decimal__c,Id_After_Decimal__c  ];
        for(Task__c tas : NewTaskList1 ){
            if(tas.Is_Stack__c == true)
                HeaderTaskMap.put(tas.SOE__c+'-'+tas.BO_IDBefore__c ,tas);
            else  if( tas.Is_Stack__c == false && tas.End_STack__c == false ){
                if(!StackTaskMap.containskey(tas.SOE__c+'-'+tas.BO_IDBefore__c))
                    StackTaskMap.put(tas.SOE__c+'-'+tas.BO_IDBefore__c ,new list<Task__c>());
                StackTaskMap.get(tas.SOE__c+'-'+tas.BO_IDBefore__c).add(tas);
            }            
            else if(tas.End_Stack__c == true)
                TrailerTaskMap.put(tas.SOE__c+'-'+tas.BO_IDBefore__c ,tas);
        }
        for(Task__c tas : HeaderTaskMap.values())
            JList.add(tas.BO_IDBefore__c);
        for(Task__c tas : TaskList){
            if(!HeaderTaskMap.containskey(tas.SOE__c+'-'+tas.ID_Before_Decimal__c)){
                BeforeSOEMap.put(tas.Id_Before_Decimal__c,tas.SOE__c); 
                decimal dec = null;
                if(HeaderTaskMap.Size() == 0)
                    dec = 1;
                else{
                    decimal i = tas.Id_Before_Decimal__c;
                    for(Integer j=0;j<JList.SIZe();j++ ){
                        if(i > JList[j]){
                            if(dec == null){
                                dec = HeaderTaskMap.get(tas.SOE__c+'-'+JLIst[j]).ID_Before_Decimal__c;
                                for(Task__c tas4 : NewTaskList1){
                                    if(tas4.Id_Before_Decimal__c >= dec){
                                        tas4.Id_Text__c = (tas4.Id_Before_Decimal__c + 1) +'.'+ tas4.Id_After_Decimal__c ;
                                        NewTaskList.add(tas4);
                                    }
                                }
                            }
                            break;
                        }
                    }
                    if(dec == null)
                        dec = JList.Size() + 1;
                }             
                BeforeSOEMap1.put(tas.Id_Before_Decimal__c,Integer.valueof(dec));
            }
        }
        if(BeforeSOEMap.Size() > 0)
            CreateBOSTackHeader(BeforeSOEMap,BeforeSOEMap1);  
        for(Task__c tas : TaskList){    
            task = new Task__c();
            task = tas.Clone();
            task.Link__c = false;
            task.Internal_Task__c = false;
            task.Critical_Path__c = null;
            task.Task_Title__c += '-BO : '+tas.Id_Text__c;
            task.Stage_Level__c = i8.CONTEXT_BO;
            task.Dependency_Type__c = i8.NODEP ;
            task.Sum_mins__c = task.Minutes__c + (task.Hours__c*60) + (task.Days__C*24*60);
            task.Total_Mins__c = task.Sum_mins__c;
            task.Start_Time__c =  task.End_Time__c = task.Baseline_start__c = task.Baseline_end__c = task.Planned_Start__c = task.Planned_End__c = task.Forecast_Start__c = task.Forecast_End__c = task.Actual_Start__c = task.Actual_end__c = null;                 
            task.BO_IDBefore__c = tas.ID_Before_Decimal__c;            
            task.BO_IDAfter__c =  tas.ID_After_Decimal__c;
            if(!HeaderTaskMap.containskey(tas.SOE__c+'-'+tas.ID_Before_Decimal__c))
                task.Id_Text__c = BeforeSOEMap1.get(tas.Id_Before_Decimal__c)+'.1';
            else{
                list<Task__c> TaskList2 = new list<Task__c>();
                Task__c trailer = TrailerTaskMap.get(tas.SOE__c+'-'+tas.ID_Before_Decimal__c);
                TaskLIst2 = StackTaskMap.get(tas.SOE__c+'-'+tas.ID_Before_Decimal__c);
                Integer cnt = TaskList2.Size()-1;
                string no = null;
                if(TaskList2[cnt].BO_IDBefore__c  == tas.ID_Before_Decimal__c && TaskList2[cnt].BO_IDAfter__c  < tas.ID_After_Decimal__c){
                    for(Task__c tas2 : TaskLIst2){
                        if(tas2.BO_IDBefore__c  == tas.ID_Before_Decimal__c && tas2.BO_IDAfter__c  < tas.ID_After_Decimal__c){
                            tas2.Id_Text__c = tas2.Id_Before_decimal__c + '.' + (tas2.Id_After_Decimal__c +1);
                            NewTaskList.add(tas2);
                            if(no == null)
                                no = tas2.Id_Before_decimal__c + '.' + tas2.Id_After_Decimal__c ;
                        }
                    }
                }
                else{
                    if(no == null)
                        no = TaskList2[cnt].Id_Before_decimal__c + '.' + (TaskList2[cnt].Id_After_Decimal__c +1);
                }
                task.Id_Text__c = no;
                trailer.Id_Text__c = trailer.Id_Before_decimal__c + '.' + (trailer.Id_After_Decimal__c +1);
                NewTaskList.add(trailer);           
            }                
            NewTaskList.add(task);
        }        
        if(NewTaskList.Size() > 0 && Utils.isCreate_Update('i8__Task__c'))
            upsert NewTaskList ;
        }
    }
    public static void  CreateBOSTackHeader(Map<Decimal,String> BeforeSOEMap, Map<Decimal,Integer> BeforeSOEMap1){
        list<Task__c> TaskList1 = new list<Task__c>();
        list<Task__c> TaskList2 = new list<Task__c>();
        Task__c task;
        if(Task_Access_Create_Update){
        for(Task__c tas: [select id,ID_Text__c,Task_Title__c,SOE__c,Stage__c,Is_Stack__c,End_Stack__c,ID_Before_Decimal__c,ID_After_Decimal__c,Team__c,Owner__c from Task__c where Id_Before_Decimal__c IN: BeforeSOEMap.keyset() and SOE__c IN: BeforeSOEMap.values() and (Is_Stack__c = true or End_Stack__c = true) and Stage_Level__c =: i8.CONTEXT_IMP]){
            task = new Task__c();
            task = tas.Clone();
            task.minutes__c = 0;
            task.Task_Title__c += '-BO : '+tas.Id_Text__c;
            task.Stage_Level__c = i8.CONTEXT_BO;
            task.Dependency_Type__c = i8.NODEP ;
            task.BO_IDBefore__c = tas.ID_Before_Decimal__c;            
            task.BO_IDAfter__c =  tas.ID_After_Decimal__c; 
            task.OriginalTask_Id__c = tas.Id; 
            if(tas.Is_Stack__c == true)
                task.Id_Text__c =   BeforeSOEMap1.get(tas.ID_Before_Decimal__c)+'.0';
            else
                task.Id_Text__c =   BeforeSOEMap1.get(tas.ID_Before_Decimal__c)+'.2';
            TaskList1.add(task);
        }
        if(TaskList1.Size() > 0 && Utils.isCreateable('i8__Task__c'))
            insert TaskList1;        
        }
    }
    public static void UpdateTaskIdsinBackout(Map<Id,Task__c> NewTaskMap,Map<id,Task__c> OldTaskMap){
        Map<string,Id> TaskIds = new Map<String,Id>();
        list<Task__c> UpdateTaskList = new list<Task__c>();
        for(Task__c tas : OldTaskMap.values())
            TaskIds.put(tas.Id_Text__c,tas.SOE__c);        
        Map<string,Task__c> BackoutTasks = new Map<string,Task__c>();
        if(Task_Access_Create_Update){
        for(Task__c tas : [select id,BO_IDBefore__c ,BO_IDAfter__c,Stage__c,Stage_Level__c,BO_IdText__c,SOE__c,Task_Title__c   
                           from Task__c where SOE__C IN: TaskIds.values() and Stage_Level__c =: i8.CONTEXT_BO and Stage__c =: i8.STAGE_IMP and BO_IdText__c IN: TaskIds.keyset()])
            BackoutTasks.put(tas.SOE__c+'-'+tas.BO_IdText__c ,tas);
        for(Task__c tas: OldTaskMap.values()){
            if(BackoutTasks.containskey(tas.SOE__c+'-'+tas.Id_Text__c)){
                Task__c task = BackoutTasks.get(tas.SOE__c+'-'+tas.Id_Text__c);
                task.BO_IDBefore__c = NewTaskMap.get(tas.Id).Id_Before_Decimal__c;
                task.BO_IDAfter__c = NewTaskMap.get(tas.Id).Id_after_Decimal__c; 
                string str = '-BO : '+ tas.Id_Text__c ;
                string replacestr = '-BO : '+ task.BO_IDBefore__c+'.'+ task.BO_IDAfter__c;
                task.Task_Title__c = task.Task_Title__c.replace(str,replacestr);
                UpdateTaskList.add(task);
            }            
        }
        if(UpdateTaskList.Size() > 0 && Utils.isUpdateable('i8__Task__c')) 
            update UpdateTaskList ;
        }
    } 
    @Future(callout=true)
    public static void SendSMS(set<Id> TaskIds,string operation){
        Map<string,string> TwilioSettings = new Map<string,string>();
        TwilioSettings = SystemSettings_Util.getTwilioSettings();
        map<id,Communication__c> task_commap = new map<id,Communication__c>();
      
        if(Utils.isAccessible('i8__Communication__c'))
        for(Communication__c com: [select id,Task__c,Task__r.ID_Text__c,Task__r.Task_Title__c,SOE__c,SOE__r.Name,SOE__r.SOE_Title__c,Completed_Mails__c,Completed_Phones__c,Milestone_Mails__c,Milestone_Phones__c,Ready_Mails__c,Ready_Phones__c from Communication__c where Task__c =: TaskIds ]){
            task_commap.put(com.task__c,com);
        }
        if(TwilioSettings.containskey('Twilio_Class_Name') && TwilioSettings.get('Twilio_Installed').ToUpperCase() == 'YES'){
            Type t = Type.forName(TwilioSettings.get('Twilio_Class_Name'));
            TwilioUtilityInterface newObj = (TwilioUtilityInterface)t.newInstance(); 
            string body;
            if(operation == 'Milestone'){
                for(Id tasid :TaskIds){
                    body = 'SOE Title :'+task_commap.get(tasid).SOE__r.Name+'-'+task_commap.get(tasid).SOE__r.SOE_Title__c+'\n Task Title :'+task_commap.get(tasid).Task__r.ID_Text__c+'-'+task_commap.get(tasid).Task__r.Task_Title__c;
                    body += '\n This Milestone Task is completed';
                    if(task_commap.get(tasid).Milestone_Phones__c != null)
                        newObj.SendSMS2(task_commap.get(tasid).Milestone_Phones__c.split(','),body);
                }
            }
            else if(operation == 'Ready'){
                for(Id tasId : TaskIds){
                    body = 'SOE Title :'+task_commap.get(tasid).SOE__r.Name+'-'+task_commap.get(tasid).SOE__r.SOE_Title__c+'\n Task Title :'+task_commap.get(tasid).Task__r.ID_Text__c+'-'+task_commap.get(tasid).Task__r.Task_Title__c;
                    body += '\n This Task is Ready';
                    if(task_commap.get(tasid).Ready_Phones__c != null)
                        newObj.SendSMS2(task_commap.get(tasid).Ready_Phones__c.split(','),body);
                }
            }
            else if(operation == 'Complete'){
                for(Id tasId : TaskIds){
                    body = 'SOE Title :'+task_commap.get(tasid).SOE__r.Name+'-'+task_commap.get(tasid).SOE__r.SOE_Title__c+'\n Task Title :'+task_commap.get(tasid).Task__r.ID_Text__c+'-'+task_commap.get(tasid).Task__r.Task_Title__c;
                    body += '\n This Task is Completed';
                    if(task_commap.get(tasid).Completed_Phones__c != null)
                        newObj.SendSMS2(task_commap.get(tasid).Completed_Phones__c.split(','),body);
                }            
            } 
        }       
    }
    public static void email_milestone(list<Task__c> Tasklist,string operation){
        set<Id> TaskIds = new set<Id>();
        map<id,Communication__c> task_commap = new map<id,Communication__c>();
        List<Messaging.Singleemailmessage> messages = new List<Messaging.Singleemailmessage>();
        for(Task__c t:Tasklist)
            TaskIds.add(t.id);
        if(Utils.isAccessible('i8__Communication__c'))
        for(Communication__c com: [select id,Task__c,SOE__c,SOE__r.Name,SOE__r.SOE_Title__c,Completed_Mails__c,Completed_Phones__c,Milestone_Mails__c,Milestone_Phones__c,Ready_Mails__c,Ready_Phones__c from Communication__c where Task__c =: TaskIds ]){
            task_commap.put(com.task__c,com);
        }     
        Integer count =0;
        string body;
        Messaging.Singleemailmessage mail;
        if(operation == 'Milestone'){
            for(task__c tas:Tasklist){
                mail = new Messaging.Singleemailmessage(); 
                list<String> toAddresses = new list<String>(); 
                if(task_commap.get(tas.id).Milestone_Mails__c !=  null){  
                    String[] toAddresses2 = task_commap.get(tas.id).Milestone_Mails__c.split(',');               
                    toAddresses.addall(toAddresses2);
                }
                mail.setToAddresses(toAddresses);
                Count+= toAddresses.Size();
                body = 'SOE Title :'+task_commap.get(tas.id).SOE__r.Name+'-'+task_commap.get(tas.id).SOE__r.SOE_Title__c+'\n Task Title :'+tas.ID_Text__c+'-'+tas.Task_Title__c;
                body += '\n This Milestone Task is completed';
                mail.setSubject(tas.Name +' : MileStone Task is Completed'); 
                mail.setPlainTextBody(body);            
                messages.add(mail);               
            }
        }
        else if(operation == 'Ready'){
            for(task__c tas:Tasklist){
                mail = new Messaging.Singleemailmessage(); 
                list<String> toAddresses = new list<String>(); 
                if(task_commap.get(tas.id).Ready_Mails__c !=  null){  
                    String[] toAddresses2 = task_commap.get(tas.id).Ready_Mails__c.split(',');               
                    toAddresses.addall(toAddresses2);
                }
                mail.setToAddresses(toAddresses);
                Count+= toAddresses.Size();
                body = 'SOE Title :'+task_commap.get(tas.id).SOE__r.Name+'-'+task_commap.get(tas.id).SOE__r.SOE_Title__c+'\n Task Title :'+tas.ID_Text__c+'-'+tas.Task_Title__c;
                body += '\n This Task is Ready';
                mail.setSubject(tas.Name +' : Task is Ready.'); 
                mail.setPlainTextBody(body);            
                messages.add(mail);
            }
        }
        else if(operation == 'Complete'){
            for(task__c tas:Tasklist){
                mail = new Messaging.Singleemailmessage(); 
                list<String> toAddresses = new list<String>(); 
                if(task_commap.get(tas.id).Completed_Mails__c !=  null){  
                    String[] toAddresses2 = task_commap.get(tas.id).Completed_Mails__c.split(',');               
                    toAddresses.addall(toAddresses2);
                }
                mail.setToAddresses(toAddresses);
                Count+= toAddresses.Size();
                body = 'SOE Title :'+task_commap.get(tas.id).SOE__r.Name+'-'+task_commap.get(tas.id).SOE__r.SOE_Title__c+'\n Task Title :'+tas.ID_Text__c+'-'+tas.Task_Title__c;
                body += '\n This Task is Completed';
                mail.setSubject(tas.Name +' : Task is Completed'); 
                mail.setPlainTextBody(body);            
                messages.add(mail);
            }            
        }        
        List<Messaging.Email> allMails = new List<Messaging.Email>();
        for (Integer j = 0; j<messages.size(); j++) {
            allMails.add(messages.get(j));
        }        
        try{
            Messaging.reserveSingleEmailCapacity(Count);
            Messaging.sendEmail(allMails);
        }
        catch(Exception e){
            system.debug('---------'+e.getMessage());
        } 
        SendSMS(taskids,operation);
    } 
    public static void email_Pin(list<Task__c> Tasklist,set<Id> TaskSOEIds){
        Integer count =0;
        string body;
        Messaging.Singleemailmessage mail;
        List<Messaging.Singleemailmessage> messages = new List<Messaging.Singleemailmessage>();
        if(Tasklist.size() >0 && Utils.isAccessible('i8__SOE__c')){
            Map<Id,SOE__c> SOEFields = new Map<Id,SOE__c>([SELECT Id,Name, SOE_Title__c FROM SOE__c WHERE Id =: TaskSOEIds]);
            for(task__c tas:Tasklist){
                mail = new Messaging.Singleemailmessage(); 
                list<String> toAddresses = new list<String>(); 
                if(tas.Owner_Mail_ID__c !=  null){  
                    String[] toAddresses2 = tas.Owner_Mail_ID__c.split(',');               
                    toAddresses.addAll(toAddresses2 );
                }
                mail.setToAddresses(toAddresses);
                Count+= toAddresses.Size();
                body = 'SOE Title :'+SOEFields.get(tas.SOE__c).Name+'-'+SOEFields.get(tas.SOE__c).SOE_Title__c+'\n Task Title :'+tas.Name+'-'+tas.Task_Title__c;
                string pintext =String.valueOf(tas.PIN__c); 
                String multipintext = pintext.replace('<br/>','\n' );
                body += '\n'+multipintext;          
                mail.setSubject(tas.Name +' : Pin is Modified'); 
                mail.setPlainTextBody(body);
                messages.add(mail);            
            }
            List<Messaging.Email> allMails = new List<Messaging.Email>();
            for (Integer j = 0; j<messages.size(); j++) {
                allMails.add(messages.get(j));
            }        
            try{
                Messaging.reserveSingleEmailCapacity(Count);
                Messaging.sendEmail(allMails);
            }
            catch(Exception e){
                system.debug('---------'+e.getMessage());
            } 
        }   
    } 
}