/* 
Class Name        : Clone_SOE_cntrl 
Test Class Name   : Test_Clone_SOE_Cntrl
Purpose/Overview  : To clone the SOEs, Tasks and Dependencies
Author            : Purview Ltd.
Code Coverage     : 96%
Change History    : 

*/
public with sharing class Clone_SOE_cntrl { 
    public string Plus_Minus_value{get;set;}
    public string Extnl_depcy_selct{get;set;}
    public SOE__c OriginalSOE1 { get; set; }
    public SOE__c NewSOE1 { get; set; }
    public string CloneSOE{get;set;}
    public string PageName{get;set;}
    public String Seact_ip{get;set;}
    public List<SelectOption> SOE_Options{get;set;}
    public boolean Imp{get;set;}
    public boolean Jump{get;set;}
    public boolean TimeBound{get;set;}
    public integer Contingency{get;set;}
    public boolean SelectList{get;set;}
    public boolean err{get;set;}
    public boolean err1{get;set;}
    public boolean displayPopup {get; set;} 
    public List<wrapperclass> WrapperList{get;set;}
    public boolean errmsg{get;set;}
    public string errormsg{get;set;}
    public static Map<Id,SOE__c> Ext_Orig_SOEMap;
    public set<Id> Ext_SOEIds;
    public list<string> TitleList;
    boolean SOE_Access_Create;
    boolean Task_Access_Create ;
    boolean Dep_Access_Create ;
    Id SOEId ;
        
    public Clone_SOE_cntrl(ApexPages.StandardController controller) {
        err = err1 = false;
        TitleList = new list<string>();
        SelectList = false;
        NewSOE1 = new SOE__c();
        Contingency =0;
        errormsg = null;
        SOEId = ApexPages.CurrentPage().getParameters().get('id') ;
        PageName = ApexPages.CurrentPage().getParameters().get('Page');
        SOE_Access_Create = Utils.isAccess_Create('i8__SOE__c') ;
        Task_Access_Create  = Utils.isAccess_Create('i8__Task__c') ;
        Dep_Access_Create  = Utils.isAccess_Create('i8__Dependency__c') ;
        if(SOE_Access_Create && Task_Access_Create  && Dep_Access_Create  ){
            if(PageName != 'tab') 
                SelectedSOEClone();
            else
                getSOEOptions();  
        }
        else { SelectLIst = true;  errormsg = System.Label.AddTask006; }     
    }    
    public list<selectoption> getPlus_Minus_values(){ 
        list<selectoption> Plus_Minus= new list<selectoption>();
        Plus_Minus.add(new selectoption('+','+'));
        Plus_Minus.add(new selectoption('-','-'));
        return Plus_Minus;
    }
    public list<selectoption> getExtnl_depndcy(){ 
        list<selectoption> SelectedExternalDepency = new list<selectoption>();
        SelectedExternalDepency.add(new selectoption('0','None'));
        SelectedExternalDepency.add(new selectoption('1','External Dependencies only'));
        SelectedExternalDepency.add(new selectoption('2','External Dependencies with linked SOEs'));
        return SelectedExternalDepency;
    } 
    public void SelectedSOEClone(){
        if(SOE_Access_Create ){
            if(PageName == 'tab')
                 OriginalSOE1 = [select id,Name,SOE_Title__c,Summary__c,Baseline_Start__c,Department__c, Programme__c,Project__c,Change_Record__c,Conference_Call_No__c,Post_Implementation_Stage__c,Pre_Implementation_Stage__c,BackOut_Stage__c,Backout__c,Task_Late_Threshold_mins__c,QA_Review_Required__c,WalkThrough_Required__c,QA_Manager__c from SOE__c where id =: CloneSOE];
            else
                OriginalSOE1 = [select id, Name,SOE_Title__c,Summary__c,Baseline_Start__c,Department__c,Programme__c,Project__c,Change_Record__c,Conference_Call_No__c,Post_Implementation_Stage__c,Pre_Implementation_Stage__c,BackOut_Stage__c,Backout__c,Task_Late_Threshold_mins__c,QA_Review_Required__c,WalkThrough_Required__c,QA_Manager__c from SOE__c where id =: ApexPages.CurrentPage().getParameters().get('Id')];
            CloneSOE = string.valueof(OriginalSOE1.Id);
            SelectList = true;
            NewSOE1 = OriginalSOE1.Clone();
            NewSOE1.SOE_Title__c = null;
            NewSOE1.Status__c = 'Build';
        }
    }
    public pagereference CancelSOE(){
        if(PageName == 'tab')
            return new pagereference('/'+SOE__c.sobjecttype.getDescribe().getKeyPrefix()+'/o');
        else
            return new pagereference('/'+SOEId);
    }
    public void ClrStr(){
        CloneSOE = null;
        errormsg = null;
        Seact_ip = '';
        err1 = false;
        err = false;
        getSOEOptions();
    }
    public List<SelectOption> getSOEOptions(){        
        SOE_Options = new List<SelectOption>();
        if(SOE_Access_Create )
            for(SOE__c soe : [select id,Name,SOE_Title__c from SOE__c where Is_Template__c = false order by Name desc])
                SOE_Options.add(new selectoption(soe.id,soe.Name+' - '+soe.SOE_Title__c));
        return SOE_Options;
    }
    public void SOE_List(){
        errormsg = null;
        SOE_Options = new List<SelectOption>();
        CloneSOE = null;
        String val='%'+Seact_ip+'%';
        if(SOE_Access_Create )
        for(SOE__c soe : [select id,Name,SOE_Title__c from SOE__c where (SOE_Title__c Like: val  or Name Like:val )and Is_Template__c = false])
            SOE_Options.add(new selectoption(soe.id,soe.Name+' - '+soe.SOE_Title__c));
    }
    public void Select_CloneSOE(){
        errormsg = null;
        if(CloneSOE == '' || CloneSOE== null){           
            errormsg = System.Label.CloneSOE007;
        }else{
            SelectList = true;
            SelectedSOEClone();
        }
    }
    public void ClearSelection(){
        SelectList = false;
        CloneSOE = null;
        clrstr();
        err1 = false;        
    }
    public void CloneSOE(){    
        err = false;  
        errmsg = false;  
        Ext_Orig_SOEMap = new Map<Id,SOE__c>();
        Ext_Orig_SOEMap.put(OriginalSOE1.Id,OriginalSOE1 ); 
        if(SOE_Access_Create && Task_Access_Create && Dep_Access_Create  ){
        if(Extnl_depcy_selct == '2'){                  
          WrapperList = new List<Wrapperclass>();
          Ext_SOEIds = new set<Id>();
          if(Utils.isAccessible('i8__Dependency__c')){
          for(Dependency__c dep: [select id,Preceeding_SOE__c,Preceeding_SOE__r.SOE_Title__c from Dependency__c where SOE__c =: OriginalSOE1.id and Dep_Type__c = 'External' and Dependent_Type__c = 'Predecessors'])
              Ext_SOEIds.add(dep.Preceeding_SOE__c);
          }
          else{
              LogFactory.debug('Clone_SOE_Cntrl', 'CloneSOE', 'Dependency Info', System.Label.AddTask001 ,'Line - 143');
          }
          if(Ext_SOEIds.size()>0){                     
              for(SOE__c soe:  [select id, Name,SOE_Title__c from SOE__c where id IN: Ext_SOEIds])
              Ext_Orig_SOEMap.put(soe.id,soe);
              for( SOE__c soe: Ext_Orig_SOEMap.values()){
                  if(soe.Id != OriginalSOE1.Id){
                      SOE__c so = new SOE__c();
                      so = soe.clone();
                      so.SOE_TiTLE__c = '';
                      WrapperList.add(new wrapperclass(soe.Id,soe.Name,soe.SOE_Title__c,so));
                  }
              }
           }
        }       
        if(NewSOE1.SOE_Title__c == null || newSOE1.SOE_title__c == '')
            err = true;  
        if(err == false)
            displaypopup = true;
        }
        LogFactory.SaveLog();
    }
    public pagereference PopUpOk(){
        errmsg = false;
        err = false;
        errormsg = null;
        TitleList = new list<String>();
        if(SOE_Access_Create   && Task_Access_Create   && Dep_Access_Create  ){
        if(err == false)
            TitleList.add(NewSOE1.SOE_Title__c);
        if(Extnl_depcy_selct == '2'){   
            for(Wrapperclass wc: WrapperList){
                if(wc.newSOE.SOE_title__c == ''|| wc.newSOE.SOE_title__c == null)
                    errmsg = true;
            }
            if (errmsg == false){
                displaypopup = false;                 
                    for(WrapperClass wc:WrapperList)
                        TitleList.add(wc.NewSOE.SOE_Title__c);
             }
        } 
        list<SOE__C> SOEList;
        SOEList  = [select id  from SOE__c where SOE_TItle__c IN : TitleList];     
        if(SOEList != null && SOEList.SIze() > 0){
            displayPopUP = false;
            errormsg = System.Label.SOETemplate002;
        }            
        If(errormsg == null &&  errmsg == false && err == false){
            Clone_SOE_cntrl.CreateSOE(OriginalSOE1.Id, TitleList,new list<id>(Ext_SOEIds),Extnl_depcy_selct,jump,Contingency,TimeBound,Imp,Plus_Minus_value);
            displayPopUP = false;
            err1 = true;
        }
        }
        return null;
    }
    public class wrapperclass{
        public id SOEId{get;set;}
        public string OldSOETitle{get;set;}
        public SOE__c newSOE{get;set;}
        public string NewSOETitle{get;set;}
        public string SOEName {get;set;}        
        public wrapperclass(id i,string soeno, string old,SOE__c soe){
            SOEId = i;
            SOEName = soeno;
            OldSOETitle = old;
            newSOE = soe;
            NewSOETitle = ' ';
        }        
    }
      @future
      public static void CreateSOE(id SOEId,list<string> SOETitles,list<id> SOEIds,string Extnl_depcy_selct,boolean jump,Integer Contingency,Boolean TimeBound,Boolean Imp,String Plus_Minus_value ){
            if(Utils.isAccessible('i8__SOE__c')){
            Map<id,SOE__c> New_SOEMap  = new MAp<Id,SOE__c>();
            Map<id,SOE__c> old_SOEMap = new Map<id,SOE__c>([select id,Name,SOE_Title__c,Summary__c,Baseline_Start__c,Department__c,Programme__c,Project__c,Change_Record__c,Conference_Call_No__c,Post_Implementation_Stage__c,Pre_Implementation_Stage__c,BackOut_Stage__c,Backout__c,Task_Late_Threshold_mins__c,QA_Review_Required__c,WalkThrough_Required__c,QA_Manager__c from SOE__c where id =: SOEId]);
            SOE__c newsoe = new SOE__c();
            newsoe = old_SOEMap.get(SOEID).clone();
            newsoe.SOE_Title__c = SOETitles[0];
            newsoe.Status__c = 'Build' ;           
            New_SOEMap.put(SOEId,newsoe);
            Integer i =1;                   
              for(SOE__c soe:  [select id, Name,SOE_Title__c,Summary__c,Baseline_Start__c,Department__c,Programme__c,Project__c,Change_Record__c,Conference_Call_No__c,Post_Implementation_Stage__c,Pre_Implementation_Stage__c,BackOut_Stage__c,Backout__c,Task_Late_Threshold_mins__c,QA_Review_Required__c,WalkThrough_Required__c,QA_Manager__c from SOE__c where id IN: SOEIds]){
                  newsoe = new SOE__c();
                  newsoe = soe.Clone();
                  newsoe.SOE_Title__c = SOETitles[i];
                  newsoe.Status__c = 'Build';
                  New_SOEMap.put(soe.id , newsoe);
                  i++;
                  old_SOEMap.put(soe.id,soe);
              }
            MAp<Id,SOE__c> NewSOEMap  = new MAp<Id,SOE__c>();
            SOE_TriggerHandler.TriggerStop = true;
            NewSOEMap = getSOEsAndTasks(SOEId,old_SOEMap,new_SOEmap,Extnl_depcy_selct,jump,Contingency,TimeBound,Plus_Minus_value  );
            //Keep All Imp Mgrs same
            if(Imp == true){
                list<SOE_Team_Member__c > NewSOE_TeamMemberList= new list<SOE_Team_Member__c>();
                if(Utils.isAccess_Create('i8__SOE_Team_Member__c') && Utils.isAccessible('i8__Role__c')){
                    for(SOE_Team_Member__c  team: [select SOE__c,Access_Level__c,Role__c,Team_Member__c from SOE_Team_Member__c where SOE__c =: NewSOEMap.keyset()  and Default_Imp_Manager__c = false and Role__c IN(select id from Role__c where NAme ='Imp Manager' )]){
                        SOE_Team_Member__c  tmember = new SOE_Team_Member__c ();
                        tmember = team.Clone();
                        tmember.SOE__c = NewSOEMap.get(tmember.SOE__c).Id;
                        NewSOE_TeamMemberList.add(tmember);
                    }
                    if(NewSOE_TeamMemberList.size()>0 && Utils.isCreateable('i8__SOE_Team_Member__c'))
                        insert NewSOE_TeamMemberList;
                 }
                else
                    LogFactory.debug('Clone_SOE_Cntrl', 'Create SOE', 'SOE Team Member Info', System.Label.AddTask001 ,'Line - 249');
                LogFactory.SAveLog();
            } 
        }             
    }
    public static Map<Id,SOE__c> getSOEsAndTasks(Id OrigSOEId,Map<id,SOE__c> old_SOEMap,Map<Id,SOE__c> new_SOEmap,string Extnl_depcy_selct,boolean jump,Integer Contingency,Boolean TimeBound,String Plus_Minus_value  ){
        Map<Id,Task__c> OrigTaskMap1 = new Map<Id,TAsk__c>();
        List<Attachment> Attlist1= new list<Attachment>();
        List<Attachment> OrigAttList = new list<Attachment>();
        List<Communication__c> Commlist1= new list<Communication__c>();
        List<Communication__c> OrigCommList = new list<Communication__c>();        
        Map<String,Task__c> NewSOE1TaskMap = new Map<String,Task__c>();
        set<id> DepIds = new set<Id>();
        Map<Id,SOE__c> OldNewSOEMap = new Map<Id,SOE__c>();
        //insert SOEs
        if(Utils.isAccess_Create('i8__SOE__c')&& Utils.isAccess_Create('i8__Task__c') && Utils.isAccess_Create('i8__Dependency__c')  ){
        for( Id  soeid: new_SOEmap.keyset())
            new_SOEmap.get(soeid).Cloned_SOE__c = old_SOEMap.get(soeid).Name +' : '+ old_SOEMap.get(soeid).SOE_Title__c;
        SavePOint sp = Database.SetSavePOint();
        try{
            if(Utils.isCreateable('i8__SOE__c'))
                insert new_SOEmap.values();
            // new inserted soes and ids in map
            for(Id soeid: new_SOEmap.keyset()){
                OldNewSOEMap.put(soeid,new_SOEmap.get(soeid));
            }
            LogFactory.info('Clone_SOE_Cntrl', 'Clone', 'New SOEs', JSON.Serialize(new_SOEmap.values()), 'Line - 275');
            //get Tasks from Original SOE 
            Map<Id,list<Task__c>> TasksInOldSOE = new Map<Id,list<Task__c>>();
            for(Task__c tas : [select id,SOE__c,Advanced_Notifications__c,Dependency_Type__c ,Comments__c,Description__c,End_Stack__c,Time_Bound__c,Baseline_Start__c,Baseline_End__c,ID_Text__c,Internal_Task__c,Is_Stack__c,
                               Owner__c,Stage__c,Jump__c,Jumped_Duration__c,Stage_Level__c,Task_Completed__c ,Task_Title__c,Team__c,Technical_Detail__c,Trigger_Comms__c,Link__c,Milestone__c,
                               When_Task_Ready__c,(select id,Dependent_Type__c,Dep_Type__c,Preceeding_SOE__c,Preceeding_Task__c,SOE__c,Task__c,Type__c from Dependencies__r) from Task__c where SOE__c =: old_SOEMap.keyset() order by Id_Before_Decimal__c,Id_After_Decimal__c]){
                 if(!TasksInOldSOE.containsKey(tas.SOE__c))
                      TasksInOldSOE.put(tas.SOE__c,new list<Task__c>());
                 TasksInOldSOE.get(tas.SOE__c).add(tas);
                 OrigTaskMap1.put(tas.Id,tas);
            }
            LogFactory.debug('Clone_SOE_Cntrl', 'Clone', 'Original Tasks', 'Successfully got Original Task Records', 'Line - 286');           
            //get Attachments from Original SOEs
            if(Schema.sObjectType.Attachment.isAccessible())
            for(Attachment att:[select Id,Name,BodyLength,body,parentid from attachment where parentid =: OrigTaskMap1.keyset()])
                OrigAttList.add(att);
            //get Communications from Original SOEs
            if(Utils.isAccessible('i8__Communication__c')){
                for(Communication__c att:[select id,Additinal_Emails_Milestone__c,Additinal_Emails_Task_Ready__c,Additional_Emails_Completed__c,
                       Additional_Phone_Milestone__c,Additional_Phone_Task_Ready__c,Additional_Phone_Completed__c,
                       Default_Owner_Completed__c,Default_Owner_Task_ready__c,Milestone_Members__c,Task_Ready_Members__c,Completed_Members__c,
                       Default_Team_Completed__c,Default_Team_Task_ready__c,MileStone_for_default_Imp_Mngrs__c,Task__c
                    from Communication__c where Task__c =: OrigTaskMap1.keyset()])
                        OrigCommList .add(att);
            }else
                LogFactory.debug('Clone_SOE_Cntrl', 'Clone', 'Communication Info', System.Label.AddTask001 ,'Line - 300');
            //Insert Tasks to New SOE
            List<Task__c> NewSOE1TaskList = new list<Task__c>();
            for( id SOEId : TasksInOldSOE.keyset()){
            for(Task__c tas: TasksInOldSOE.get(SOEId)){
                Task__c task1 = new Task__c();
                task1 = tas.clone();
                task1.Status__c = 'Build';
                task1.SOE__c = OldNewSOEMap.get(tas.SOE__c).Id;
                // keep all Jump tasks
                if(Jump == false){
                    task1.Jump__c =  false;
                    task1.Jumped_Duration__C = null;
                }
                //getting baseline duration and calculating days,hours and minutes
                task1.Baseline_Start__c = null;
                task1.Baseline_End__c = null;
                Integer mins,Contin,TotalMins,seconds ;
                Decimal duration  = tas.Baseline_End__c.getTime() - tas.Baseline_Start__c.getTime();
                seconds = Integer.valueof(duration  / 1000);
                mins = Integer.valueof(seconds/60) ;
                TotalMins = mins;
                Contin = Math.round((mins*Contingency)/100);
                if(Math.mod(mins*Contingency,100) > 50)
                    Contin += 1;
                if(Plus_Minus_value == '+')
                    TotalMins = mins + Contin ;
                else if(Plus_Minus_value == '-')
                    TotalMins = mins - Contin ;
                task1.Hours__c = Math.floor(TotalMins/60);
                task1.Minutes__c = Math.mod(TotalMins,60);
                task1.Days__c  = Math.floor( task1.Hours__c/ 24);
                task1.Hours__c = Math.mod(Integer.valueof(task1.Hours__c) , 24);
                //keep Timebound
                if(TimeBound == false)
                    task1.Time_Bound__c = null;
                else if(TimeBound == true && task1.Time_Bound__c != null)
                    task1.Time_Bound__c = System.Now(); 
                if(task1.Dependency_Type__c == 'External'){
                    if(task1.Internal_Task__c == true)
                        task1.Dependency_Type__c = 'Internal';
                    else if(task1.Link__c == true)
                        task1.Dependency_Type__c = 'Link';
                    else
                        task1.Dependency_Type__c = 'None';
                }
                NewSOE1TaskList.add(task1);
            }
            }
            if(NewSOE1TaskList.size()>0&& Utils.isCreateable('i8__Task__c')) {
                    insert NewSOE1TaskList;
                LogFactory.debug('Clone_SOE_Cntrl', 'Clone', 'New Tasks', 'Successfully insert Task Records', 'Line - 351');
            }
            //mapping task ID_Text To Task
            for(Task__c tas: NewSOE1TaskList){
                NewSOE1TaskMap.put(tas.Id_Text__c+'_'+tas.Stage_Level__c+'_'+tas.SOE__c,tas);
                if(tas.Internal_Task__c == true || tas.Link__c == true)
                    DepIds.add(tas.id);
            }
            //for adding Communication  to list
            for(Communication__c att : OrigCommList){
                Communication__c att1 = new Communication__c ();
                att1 = att.Clone();
                att1.Task__c = NewSOE1TaskMap.get(OrigTaskMap1.get(att.Task__c).Id_Text__c+'_'+OrigTaskMap1.get(att.Task__c).Stage_Level__c+'_'+OldNewSOEMap.get(OrigTaskMap1.get(att.Task__c).SOE__c).Id).Id;
                att1.SOE__c = OldNewSOEMap.get(OrigTaskMap1.get(att.Task__c).SOE__c).Id;
                CommList1.add(att1);
            } 
            if(Commlist1.size()>0 ){
                if(Utils.isCreateable('i8__Communication__c'))
                    insert Commlist1;
                LogFactory.debug('Clone_SOE_Cntrl', 'Clone', 'Communications ', 'Successfully insert Communiation Records', 'Line - 370'); 
            }  
            //for adding Attachments records to list     
            for(Attachment att : OrigAttList){
                Attachment att1 = new Attachment();
                att1.body = att.body;
                att1.Name = att.Name;
                att1.parentId = NewSOE1TaskMap.get(OrigTaskMap1.get(att.parentId).Id_Text__c+'_'+OrigTaskMap1.get(att.parentId).Stage_Level__c+'_'+OldNewSOEMap.get(OrigTaskMap1.get(att.parentId).SOE__c).Id).Id;
                Attlist1.add(att1);
            } 
            if(Attlist1.size()>0) {
                if(Schema.sObjectType.Attachment.isCreateable())
                    insert Attlist1;
                LogFactory.debug('Clone_SOE_Cntrl', 'Clone', 'Attachments', 'Successfully insert Attachment Records', 'Line - 383'); 
            }
            List<Dependency__c> NewSOE1DepList = new list<Dependency__c>();
            for(Task__c tas: OrigTaskMap1.values()){
                for(Dependency__c dep:tas.Dependencies__r){
                    Dependency__c depn1 = new Dependency__c();
                    if(dep.Dep_Type__c == 'Link' || dep.Dep_Type__c == 'Internal'){
                        depn1.Dep_Type__c = dep.Dep_type__c;
                        depn1.Dependent_Type__c = dep.Dependent_Type__c;
                        depn1.Type__c = dep.Type__c ;
                        depn1.Task__c = NewSOE1TaskMap.get(OrigTaskMap1.get(dep.Task__c).Id_Text__c+'_'+OrigTaskMap1.get(dep.Task__c).Stage_Level__c+'_'+OldNewSOEMap.get(OrigTaskMap1.get(dep.Task__c).SOE__c).Id).Id;
                        depn1.Preceeding_Task__c = NewSOE1TaskMap.get(OrigTaskMap1.get(dep.Preceeding_Task__c).Id_Text__c+'_'+OrigTaskMap1.get(dep.Preceeding_Task__c).Stage_Level__c+'_'+OldNewSOEMap.get(OrigTaskMap1.get(dep.Preceeding_Task__c).SOE__c).Id).Id;
                        depn1.SOE__c = OldNewSOEMap.get(OrigTaskMap1.get(dep.Preceeding_Task__c).SOE__c).Id;
                        depn1.Preceeding_SOE__c = OldNewSOEMap.get(OrigTaskMap1.get(dep.Preceeding_Task__c).SOE__c).Id;
                        NewSOE1DepList.add(depn1);
                    }
                    if(Extnl_depcy_selct == '0'){
                        set<Id> tasklist = new set<Id>();
                        if(dep.Dep_Type__c  == 'External')
                            tasklist.add(dep.Task__c);
                        if(tasklist.size()>0)
                            Task_TriggerHandler.CalculateDependencyType(tasklist);
                    }
                }
            }
            if(NewSOE1DepList.size()>0 && Utils.isCreateable('i8__Dependency__c') )
                insert NewSOE1DepList;
             if(Extnl_depcy_selct == '1' || Extnl_depcy_selct == '2'){
                    set<Task__c> UpdTaskList = new set<Task__c>();
                    list<Task__c> UpdTaskList1 = new list<Task__c>();
                    NewSOE1DepList = new list<Dependency__c>();
                    for(Task__c tas: OrigTaskMap1.values()){
                        for(Dependency__c dep:tas.Dependencies__r){
                            Dependency__c depn1 = new Dependency__c();
                            Dependency__c depn2 = new Dependency__c();
                            if(dep.Dep_Type__c == 'External' && dep.Dependent_Type__c == 'Predecessors' && dep.SOE__c == OrigSOEId){
                                depn1.Dep_Type__c = dep.Dep_type__c;
                                depn1.Dependent_Type__c = dep.Dependent_Type__c;
                                depn1.Type__c = dep.Type__c ;
                                depn1.Task__c = NewSOE1TaskMap.get(OrigTaskMap1.get(dep.Task__c).Id_Text__c+'_'+OrigTaskMap1.get(dep.Task__c).Stage_Level__c+'_'+OldNewSOEMap.get(OrigTaskMap1.get(dep.Task__c).SOE__c).Id).Id;
                                depn1.SOE__c = OldNewSOEMap.get(OrigTaskMap1.get(dep.Task__c).SOE__c).Id;
                                if(Extnl_depcy_selct == '1') {
                                    depn1.Preceeding_SOE__c = dep.Preceeding_SOE__c ;
                                    depn1.Preceeding_Task__c = dep.Preceeding_Task__c ;
                                }
                                else{
                                     depn1.Preceeding_SOE__c = OldNewSOEMap.get(dep.Preceeding_SOE__c).Id;
                                     depn1.Preceeding_Task__c = NewSOE1TaskMap.get(OrigTaskMap1.get(dep.Preceeding_Task__c).Id_Text__c+'_'+OrigTaskMap1.get(dep.Preceeding_Task__c).Stage_Level__c+'_'+OldNewSOEMap.get(OrigTaskMap1.get(dep.Preceeding_Task__c).SOE__c).Id).Id;
                                }
                                NewSOE1DepList.add(depn1);
                                
                                depn2.Dep_Type__c = dep.Dep_type__c;
                                depn2.Dependent_Type__c = 'Successors';
                                depn2.Type__c = dep.Type__c ;
                                depn2.Task__c = depn1.Preceeding_Task__c ;
                                depn2.Preceeding_Task__c = depn1.Task__c;
                                depn2.SOE__c = depn1.Preceeding_SOE__c ;
                                depn2.Preceeding_SOE__c = depn1.SOE__c;
                                NewSOE1DepList.add(depn2);
                                task__c tas1 = NewSOE1TaskMap.get(OrigTaskMap1.get(dep.Task__c).Id_Text__c+'_'+OrigTaskMap1.get(dep.Task__c).Stage_Level__c+'_'+OldNewSOEMap.get(OrigTaskMap1.get(dep.Task__c).SOE__c).Id);
                                tas1.Dependency_Type__c = 'External';
                                tas1.Broken_Task__c = true;
                                UpdTaskList.add(tas1);
                                if(Extnl_depcy_selct == '2') {
                                    task__c tas2 = NewSOE1TaskMap.get(OrigTaskMap1.get(dep.Preceeding_Task__c ).Id_Text__c+'_'+OrigTaskMap1.get(dep.Preceeding_Task__c ).Stage_Level__c+'_'+OldNewSOEMap.get(OrigTaskMap1.get(dep.Preceeding_Task__c ).SOE__c).Id);
                                    tas2.Dependency_Type__c = 'External';
                                    UpdTaskList.add(tas2);
                                }
                            }
                        }
                    }
                    if(NewSOE1DepList.size()>0  ){
                        UpdTaskList1.AddAll(UpdTaskList);
                        if(Utils.isUpdateable('i8__Task__c'))
                            update UpdTaskList1;
                        if(Utils.isCreateable('i8__Dependency__c'))    
                            insert NewSOE1DepList;
                        LogFactory.debug('Clone_SOE_Cntrl', 'Clone', 'Dependencies', 'Successfully insert Dpendency Records', 'Line - 460'); 
                    }             
                }
                if(DepIds.size()>0)
                     Task_TriggerHandler.CalculateDependencyType(DepIds);  
              LogFactory.SaveLog();
             return OldNewSOEMap; 
         }
         catch(Exception ex){
          if(Utils.isAccessible('User')){
            Database.Rollback(sp); 
            Messaging.Singleemailmessage theEmails = new Messaging.Singleemailmessage();  
            list<string> Addresses = new list<String>();
            Addresses.add([select id,name,Email from User where id=: UserInfo.getUserId()].Email);
            theEmails.setToAddresses(Addresses) ;
            string body = '<html>Clone SOE of  '+ old_SOEMap.get(OrigSOEId).Name +' : '+ old_SOEMap.get(OrigSOEId).SOE_Title__c +' failed due to following error.';
            body += '<br/><b> ERROR : '+ex.getMessage() + '' + ex.getStackTraceString() +'</html>';
            theEmails.setSubject('Clone SOE Failed'); 
            theEmails.setHtmlBody(body);
            try{
                Messaging.reserveSingleEmailCapacity(2);
                Messaging.SendEmailResult[] sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { theEmails});            
            }
            catch(Exception e){
                system.debug('---------'+e.getMessage());
            }                       
            LogFactory.error('Clone_SOE_Cntrl', 'Clone', '', ex.getMessage() + '' + ex.getStackTraceString());
         }else{LogFactory.error('Clone_SOE_Cntrl', 'Clone', 'System.Label.ADMIN001','Line - 487');}
          LogFactory.SaveLog();
         }
        }        
         return null;
    }
    public void PopUpCancel(){
        displaypopup = false;
    }     
}