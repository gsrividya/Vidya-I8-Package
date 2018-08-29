/* 
Class Name        : SOE_TriggerHandler 
Trigger Name      : SOE_Trigger 
Test Class Name   : Test_SOE_Trigger_Handler
Purpose/Overview  : Trigger Handler for SOE Trigger.
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 98%
                    Trigger - 100%
Change History    : 
*/

/***     Trigger Handler for SOE object         ***/
public class SOE_TriggerHandler {    
    public static boolean TriggerStop = false;
    public static I8Constants I8= new I8Constants();     
    
    // Create default tasks after SOE Created
    public static void AfterInsert(set<id> SOEIds){
        if(TriggerStop == false){
            CreateTasksFromSOE(SOEIds);   
            list<id> SOEIdslist = new list<id>();
            SOEIdslist.addAll(SOEIds);     
            Task_TriggerHandler.UpdateAllTasks(SOEIdslist,i8.CONTEXT_IMP);
        }        
    }
    public static void AfterUpdate(Map<Id,SOE__c> NewSOEMap, Map<Id,SOE__C> OldSOEMap){
        list<SOE__c>  soelist = new list<SOE__C>();
         list<SOE__c>  soelist1 = new list<SOE__C>();
         Map<Id,string>  soelist2 = new Map<Id,string>();
         Map<Id,string>  soelist3 = new Map<Id,string>();
         Map<id,set<id>> SoETeamMemberMap = new Map<Id,set<id>>();
         set<id> MISIds = new set<Id>();   
         if(Utils.isAccessible('i8__SOE_Team_Member__c'))      
         for(SOE_Team_Member__c team_mem : [select id,SOE__c,SOE__r.Status__c,Team_member__r.Salesforce_User__c from SOE_team_Member__c where SOE__c IN:NewSOEMap.keyset()]){ 
             if(team_mem.SOE__r.Status__c == 'Build' || team_mem.SOE__r.Status__c == 'Review'){
                 if(!SoETeamMemberMap.ContainsKey(team_mem.SOE__c) )
                     SoETeamMemberMap.put(team_mem.SOE__c,new set<Id>());                 
                 SoETeamMemberMap.get(team_mem.SOE__c).add(team_mem.Team_member__r.Salesforce_User__c);                 
             }
         }
         for(SOE__c soe:NewSOEMap.values()){
             if(soe.MIS__c != null && (soe.MIS__c != OldSOEMap.get(Soe.id).MIS__c || soe.Min_Planned_Start__c != OldSOEMap.get(soe.id).Min_Planned_Start__c  || soe.Max_Planned_End__c != OldSOEMap.get(soe.id).Max_Planned_End__c))
                 MISIds.add(soe.MIS__c);
             if(soe.Status__c == 'Imp In Progress' && OldSOEMap.get(soe.Id).Status__c != soe.Status__c)
                 soelist.add(soe);
             if(soe.Status__c == 'Build' || soe.Status__c == 'Review'){
                set<id> TeamMAp = new set<Id>();
                if(SoETeamMemberMap.containskey(soe.id))
                    TeamMap.Addall(SoETeamMemberMap.get(soe.id));
                 if(soe.QA_Review_Required__c == true && soe.QA_Manager__c != null  && !TeamMAp.Contains(soe.QA_Manager__c) &&  OldSoeMap.get(soe.Id).QA_Manager__c != soe.QA_Manager__c )
                     SOELIst1.add(soe);
                 if(soe.QA_Review_Required__c == true && soe.QA_Manager__c != null && OldsoeMap.get(soe.Id).QA_Manager__c != soe.QA_Manager__c && OldsoeMap.get(soe.Id).QA_Manager__c != null && TeamMAp.Contains(OldsoeMap.get(soe.Id).QA_Manager__c))
                     SOELIst2.put(soe.id,String.valueOf(OldsoeMap.get(soe.Id).QA_Manager__c).substring(0, 15));
                 if(soe.QA_Review_Required__c == true && soe.QA_Manager__c != null && OldsoeMap.get(soe.Id).QA_Manager__c != soe.QA_Manager__c && TeamMAp.Contains(soe.QA_Manager__c))
                     SOELIst3.put(soe.id,String.valueOf(soe.QA_Manager__c).substring(0, 15));
                 if(soe.QA_Review_Required__c == true && soe.QA_Manager__c == null && OldsoeMap.get(soe.Id).QA_Manager__c != soe.QA_Manager__c )
                     SOELIst2.put(soe.id,String.valueOf(OldsoeMap.get(soe.Id).QA_Manager__c).substring(0, 15));
             }
         }
         if(soelist.size()>0)
             mail(soelist);
         if(SOELIst1.size()>0)
              TeamMemberInsert(SOELIst1,'Update');
         if(SOELIst2.size()>0)
              TeamMemberDelete(SOELIst2);
         if(SOELIst3.size()>0)
              TeamMemberUpdateRole(SOELIst3);
         if(MisIds.Size() > 0)
             UpdateMIS(MISIDs);
    }
    public static void CreateTasksFromSOE(set<id> SOEIds){        
        list<Task__c> TaskList =new list<Task__c>();
        list<SOE__c> SOElist ;
        if(Utils.isAccessible('i8__SOE__c'))
            SOEList = [select id,Status__c,Pre_Implementation_Stage__c,Backout__c,Post_Implementation_Stage__c,BackOut_Stage__c from SOE__c where id IN: SOEIds];
        for(SOE__c s: SOElist){
            decimal count =0;
            if(s.Pre_Implementation_Stage__c == true){
                if(count ==0)
                    count =1.0;
                TaskList.add(CreateTask(I8.STAGE_PRE ,I8.PRE_STACK_START+I8.START_CKP,true,string.valueof(count),s.Id,'',I8.CONTEXT_IMP,0,0,0,false));
                TaskList.add(CreateTask(I8.STAGE_PRE ,I8.PRE_STACK_START,false,string.valueof(count+0.1),s.Id,I8.STATUS_BUILD,I8.CONTEXT_IMP,0,0,5,false));
                TaskList.add(CreateTask(I8.STAGE_PRE ,I8.PRE_STACK_START+I8.END_CKP,false,string.valueof(count+0.2),s.Id,I8.STATUS_BUILD,I8.CONTEXT_IMP,0,0,0,true));
            }
            if(count ==0)
                count = 1.0;
            else
                count = count+1;
            TaskList.add(CreateTask(I8.STAGE_IMP,I8.IMP_STACK_START+I8.START_CKP ,true,string.valueof(count),s.Id,'',I8.CONTEXT_IMP,0,0,0,false));
            TaskList.add(CreateTask(I8.STAGE_IMP ,I8.IMP_STACK_START,false,string.valueof(count+0.1),s.Id,I8.STATUS_BUILD,I8.CONTEXT_IMP,0,0,5,false));
            TaskList.add(CreateTask(I8.STAGE_IMP,I8.IMP_STACK_START+I8.END_CKP ,false,string.valueof(count+0.2),s.Id,I8.STATUS_BUILD ,I8.CONTEXT_IMP,0,0,0,true));
            if(s.Post_Implementation_Stage__c == true){
                count = count+1;
                TaskList.add(CreateTask(I8.STAGE_POST ,I8.POST_STACK_START+I8.START_CKP,true,string.valueof(count),s.Id,'',I8.CONTEXT_IMP,0,0,0,false));
                TaskList.add(CreateTask(I8.STAGE_POST ,I8.POST_STACK_START,false,string.valueof(count+0.1),s.Id,I8.STATUS_BUILD,I8.CONTEXT_IMP,0,0,5,false));
                TaskList.add(CreateTask(I8.STAGE_POST ,I8.POST_STACK_START+I8.END_CKP,false,string.valueof(count+0.2),s.Id,I8.STATUS_BUILD,I8.CONTEXT_IMP,0,0,0,true));
            }
            if(s.BackOut_Stage__c == true){
                count =0.0;
                if(s.Backout__c == i8.BO_MANUAL){
                    count += 1.0;
                    TaskList.add(CreateTask(I8.STAGE_IMP,I8.BOIMP_STACK_START+I8.START_CKP ,true,string.valueof(count),s.Id,'',I8.CONTEXT_BO ,0,0,0,false));
                    TaskList.add(CreateTask(I8.STAGE_IMP,I8.BOIMP_STACK_START,false,string.valueof(count+0.1),s.Id,I8.STATUS_BUILD,I8.CONTEXT_BO,0,0,5,false));
                    TaskList.add(CreateTask(I8.STAGE_IMP,I8.BOIMP_STACK_START+I8.END_CKP ,false,string.valueof(count+0.2),s.Id,I8.STATUS_BUILD,I8.CONTEXT_BO,0,0,0,true));
                }
                if(s.Post_Implementation_Stage__c == true){
                    count = count+1;
                    TaskList.add(CreateTask(I8.STAGE_POST,I8.BOPOST_STACK_START+I8.START_CKP,true,string.valueof(count),s.Id,'',I8.CONTEXT_BO,0,0,0,false));
                    TaskList.add(CreateTask(I8.STAGE_POST ,I8.BOPOST_STACK_START,false,string.valueof(count+0.1),s.Id,I8.STATUS_BUILD,I8.CONTEXT_BO,0,0,5,false));
                    TaskList.add(CreateTask(I8.STAGE_POST,I8.BOPOST_STACK_START+I8.END_CKP,false,string.valueof(count+0.2),s.Id,I8.STATUS_BUILD,I8.CONTEXT_BO,0,0,0,true));
                }
            }
        }
        if(Utils.isCreateable('i8__Task__c') )
            insert TaskList;        
    }    
    // Create Task 
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
    public static void TeamMemberInsert(list<SOE__C> SOEList,string str){   
        Map<id,id> SoeMap = new Map<id,id>();
        Map<id,id> SoeMap1 = new Map<id,id>();
        map<id,id> soe_membermap = new map<id,id>();  
        list<SOE_Team_Member__c> team_memberlist = new list<SOE_Team_Member__c>();
        Map<Id,String> RoleUserMap = new Map<Id,String>(); 
        Map<String,Id> RoleMap = new Map<String,Id>();
        if(Utils.isAccessible('i8__Role__c'))
        for(Role__c role: [select id,Reference_Role__c from  Role__c where (Reference_Role__c = 'Imp Manager' and Default_SOE_Manager__c = true)  or Reference_Role__c = 'QA Manager'] )       
            RoleMap.put(role.Reference_Role__c,role.Id); 
        for(SOE__c soe: SOElist){
            if(str == 'Insert' ){
                SoeMap.put(soe.id,soe.ownerid);
                RoleUserMap.put(soe.ownerid,'Imp Manager');
                if(soe.QA_Review_Required__c == true && soe.QA_Manager__c != null){
                    SoeMap1.put(soe.id,soe.QA_Manager__c);  
                    RoleUserMap.put(soe.QA_Manager__c,'QA Manager');
                }
           }
           else{
               SoeMap1.put(soe.id,soe.QA_Manager__c);  
               RoleUserMap.put(soe.QA_Manager__c,'QA Manager'); 
           }
        }               
        list<Member__c> MemList ;
        if(Utils.isAccessible('i8__Member__c'))
        Memlist = [select id,Salesforce_User__c,Name,Salesforce_User__r.name from Member__c where Salesforce_User__c =: RoleUserMap.keyset()];
        for(Member__c mem :MemList ){  
            soe_membermap.put(mem.Salesforce_User__c,mem.id);         
        }                
        for(Id SOEId : SoeMap.keyset()){
            SOE_Team_Member__c team_member = new SOE_Team_Member__c();            
            team_member.Role__c = RoleMap.get('Imp Manager');
            team_member.SOE__c = soeid;
            team_member.Team_Member__c = soe_membermap.get(SoeMap.get(SOEId));
            team_member.Default_Imp_Manager__c = true;
            team_member.Access_Level__c = 'All';                
            team_memberlist.add(team_member);
        }
         for(Id SOEId : SoeMap1.keyset()){
            SOE_Team_Member__c team_member = new SOE_Team_Member__c();            
            team_member.Role__c = RoleMap.get('QA Manager');
            team_member.SOE__c = soeid;
            team_member.Team_Member__c = soe_membermap.get(SoeMap1.get(SOEId));
            team_member.Access_Level__c = 'Edit';
            team_memberlist.add(team_member);
        }
        if(team_memberlist.size()>0 && Utils.isCreateable('i8__SOE_Team_Member__c'))
                insert team_memberlist;
    }
    /*** When SOE is in 'Imp In Progress' status, All Imp Managers will recieive mail.***/     
    public static void mail(list<SOE__c> SOElist){          
        Map<Id,list<string>> Soemails = new Map<Id,list<String>>();
        Integer count =0;
        set<Id> soeIds = new set<Id>();
        for(SOE__c s : SOELIst){
            soeIds.add(s.id);
        }
        if(Utils.isAccessible('i8__SOE_Team_Member__c'))
        for(SOE_Team_Member__c soetm: [select id,SOE__c,Team_Member__r.Email__c from SOE_TEam_Member__C where SOE__C IN: soeIds and Role__r.Reference_Role__c = 'Imp Manager']){
             if(!Soemails.containsKey(soetm.SOE__c))
                 Soemails.put(soetm.SOE__C,new list<string>());
             Soemails.get(soetm.SOE__c).add(soetm.Team_Member__r.Email__c);
        } 
        List<Messaging.SingleEmailMessage>  soeEmails = new List<Messaging.SingleEmailMessage>();
        for(SOE__c soe: SOEList){
            if(Soemails.containsKey(soe.id) && Soemails.get(soe.id).size()>0 ){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setsubject(soe.name +'-'+ soe.SOE_Title__c +' Status');
                email.setToAddresses(Soemails.get(soe.id));
                email.setPlainTextBody('SOE is in IMP IN PROGRESS');
                soeEmails.add(email);
                count+= Soemails.get(soe.id).Size();
            }
        }
        try{
            Messaging.reserveSingleEmailCapacity(Count);
            Messaging.sendEmail(soeEmails);
        }
        catch(Exception e){
            system.debug('---------'+e.getMessage());
        }       
    }
     public static void TeamMemberDelete(Map<Id,string> SOEMap){  
         list<SOE_Team_member__c> DeleteTeamMembers = new list<SOE_Team_Member__c>();
         if(Utils.isAccessible('i8__SOE_Team_Member__c'))
         DeleteTeamMembers = [select id,SOE__c,User_Id__c  from SOE_Team_Member__c where SOE__c IN:SOEMap.keyset() and User_Id__c IN : SOEMap.values()]; 
         if(DeleteTeamMembers.Size () > 0 && Schema.SOBjectTYpe.SOE_Team_Member__c.isDeletable())
             Delete DeleteTeamMembers ;   
     }
     public static void TeamMemberUpdateRole(Map<Id,string> SOEMap){  
         list<SOE_Team_member__c> DeleteTeamMembers = new list<SOE_Team_Member__c>();
         Role__c role ;
         if(Utils.isAccessible('i8__Role__c'))
         role = [select id,Reference_Role__c from  Role__c where Reference_Role__c = 'QA Manager' limit 1];
         if(Utils.isAccessible('i8__SOE_Team_Member__c'))
         for(SOE_Team_Member__c team : [select id,SOE__c,User_Id__c,Role__c  from SOE_Team_Member__c where SOE__c IN:SOEMap.keyset() and User_Id__c IN : SOEMap.values()]){
             team.Role__c = role.id;
             DeleteTeamMembers.add(team);
         }
         if(DeleteTeamMembers.Size () > 0 && Utils.isUpdateable('i8__SOE_Team_Member__c'))
             Update DeleteTeamMembers ;   
     }
     public static void BeforeUpdate(Map<Id,SOE__c> SOEMap){
         // getting SOE Team Members
         Map<id,set<id>> SoETeamMemberMap = new Map<Id,set<id>>();
         if(Utils.isAccessible('i8__SOE_Team_Member__c'))
         for(SOE_Team_Member__c team_mem : [select id,SOE__c,Team_Member__r.Salesforce_User__c from SOE_Team_Member__c where SOE__c IN: SOEMap.keyset()]){
            if(!SoETeamMemberMap.ContainsKey(team_mem.SOE__c) )
                SoETeamMemberMap.put(team_mem.SOE__c,new set<Id>());                 
            SoETeamMemberMap.get(team_mem.SOE__c).add(team_mem.Team_member__r.Salesforce_User__c); 
        }
        // getting MISs
        Map<Id,Id> SOEMISMap = new Map<id,Id>();
        for(SOE__c soe: SOEMap.values())
            SOEMISMap.put(soe.id,Soe.MIS__c);
       //getting MIS Managers
        Map<Id,Set<Id>> MIS_MgrMap = new Map<Id,Set<Id>>();
        set<Id> UserIds = new Set<Id>(); 
        if(Utils.isAccessible('i8__MIS_Manager__c'))
        for(MIS_Manager__c mismgr: [select id,MIS_Manager__c,MIS__c from MIS_Manager__c where MIS__c IN: SOEMISMap.values()]){
            if(!MIS_MgrMap.containskey(mismgr.MIS__c))   
                 MIS_MgrMap.put(mismgr.MIS__c, new set<ID>());
            MIS_MgrMap.get(mismgr.MIS__c).add(mismgr.MIS_Manager__c);
            userIds.add(mismgr.MIS_Manager__c);
        }
        // getting member list for salesforce users
        Map<id,Member__c> MemberMap = new Map<Id,Member__c>();
        if(Utils.isAccessible('i8__Member__c'))
        for(Member__c member : [select id,Salesforce_User__c from Member__c where Salesforce_User__c In : USerIds])
            MemberMap.put(member.Salesforce_User__c,member);
        Set<ID> memberIds= new set<ID>();
        list<SOE_Team_Member__c> insertlist = new list<SOE_Team_Member__c>();
        list<Role__c> role;
        if(Utils.isAccessible('i8__Role__c'))
        role  =  [select id,Reference_Role__c from  Role__c where Reference_Role__c = 'Imp Manager' and Default_SOE_Manager__c = true limit 1];
        SOE_Team_Member__c stm;
        for(SOE__c soe: SOEMap.values()){
            memberIds.clear();            
            memberIds.addAll(SoETeamMemberMap.get(soe.Id));
            for(Id MisMgrId : MIS_MgrMap.get(soe.MIS__c)){
                if(!memberIds.contains(MisMgrId)){
                    stm = new SOE_Team_Member__c(SOE__c = soe.id,Access_Level__c = 'Edit',Team_Member__c = MemberMap.get(MisMgrId).id,Role__c = role[0].id);
                    insertlist.add(stm);
                }
            }            
        }
        if(insertlist.size() > 0 && Utils.isCreateable('i8__SOE_Team_Member__c'))
            insert insertlist ;
     }     
     public static void UpdateMIS(set<Id> MISIds){
         Map<id,MIS__c> MISMap;
         if(Utils.isAccess_Update('i8__MIS__c') && Utils.isAccessible('i8__SOE__c')){
             MISMap  = new Map<id,MIS__c>([select id,MIS_PlannedStart__c,MIS_PlannedEnd__c from MIS__c where id =: MISIds]);
             list<aggregateResult> Result = [select MIS__c,MIN(Min_Planned_Start__c) MINStart, MAX(Max_Planned_End__c) MaxEnd from SOE__c where MIS__c IN : MISIds group by MIS__c];
             for(AggregateResult res : Result){
                 string MIsid = String.valueof(res.get('I8__MIS__c'));
                 MISMap.get(MIsid).MIS_PlannedStart__c = DateTime.valueof(res.get('MINStart'));
                 MISMap.get(MIsid).MIS_PlannedEnd__c  = DateTime.valueof(res.get('MaxEnd'));
             }
             if(Utils.isUpdateable('i8__MIS__c'))
                 update MISMap.values();
         }
     }
}