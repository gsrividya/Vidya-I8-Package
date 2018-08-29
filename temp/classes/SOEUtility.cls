/* 
Class Name        : SOEUtility
Purpose/Overview  : This class is mainly used to generate the test data for test classes.
                    No user interface for this call. 
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 
*/

public class SOEUtility{
    public static I8Constants i8 = new I8Constants();
    public static Department__c Dep_Insert(string Name){
        Department__c ms = new Department__c();
        ms.Name = Name;
        if(Schema.sObjectType.Department__c.isCreateable())
        insert ms;
        return ms;
    }
    public static SOE__c SOE_Insert(string title,Id service,Boolean pre,Boolean Post,Boolean QA,Boolean WT){
        SOE__c soe = new SOE__c();
        soe.SOE_Title__c = title;
        soe.Department__c = service;
        soe.Pre_Implementation_Stage__c = pre;
        soe.Post_Implementation_Stage__c = post;
        soe.QA_Review_Required__c = QA;
        soe.WalkThrough_Required__c = WT;
        SOE.Baseline_Start__c = system.now();
        soe.Summary__c = 'fdsfdsfs';
        if(Schema.sObjectType.SOE__c.isCreateable())
        insert soe;
        return soe;
    }
    public static SOE__c SOE_Insert(string title,Id service,Boolean pre,Boolean Post,Boolean BO,Boolean QA,Boolean WT){
        SOE__c soe = new SOE__c();
        soe.SOE_Title__c = title;
        soe.Department__c = service;
        soe.Pre_Implementation_Stage__c = pre;
        soe.Post_Implementation_Stage__c = post;
        soe.BackOut_Stage__c = BO;
        soe.QA_Review_Required__c = QA;
        soe.WalkThrough_Required__c = WT;
        SOE.Baseline_Start__c = system.now();
        if(soe.BackOut_Stage__c  == true)
            soe.Backout__c = 'Manual';
        soe.Summary__c = 'fdsfdsfs';
        if(Schema.sObjectType.SOE__c.isCreateable())
        insert soe;
        return soe;
    }
   public static task__c Task_Insert(String Stage, string title,boolean IsStack, string IdText,Id SOEId,string context ,Integer days,integer hours,integer mins,boolean EndStack){
         Task__c t= new Task__c();
         t.Stage__c = Stage;
         t.Task_Title__c = title;
         t.Is_Stack__c = IsStack;
         t.ID_Text__c = IdText;
         t.SOE__c = SOEId;
         t.Status__c = i8.STATUS_BUILD;
         t.Stage_Level__c = context;
         t.Days__c = days;
         t.Hours__c = hours;
         t.Minutes__c = mins;
         t.End_Stack__c = EndStack;
         if(Schema.sObjectType.Task__c.isCreateable())
         insert t;
         return t;       
   }
    public static Dependency__c Dependency_Insert(String Deptype, ID TASKID,ID SOEID,Id PrevTask, Id PrevSoe,string predecessor){
         Dependency__c D= new Dependency__c ();
         d.Dep_Type__c= Deptype;
         d.Task__c = TASKID;
         d.SOE__c= SOEID;
         d.Preceeding_Task__c = PrevTask;
         d.Preceeding_SOE__c = PrevSOE;
         d.Dependent_Type__c = predecessor;
         return d;       
   }
   public static Incident__c Incident_insert(Id soe,Id task,string IncType,string status,string incOnObj,id Assignee){
       Incident__c inc=new Incident__c ();
       inc.SOE1__c= soe;
       inc.Task__c=task;
       inc.INC_on_Object__c = incOnObj;
       inc.Inc_Type__c = IncType;
       inc.Status__c = status;
       inc.Assignee__c = Assignee;
       if(Schema.sObjectType.Incident__c.isCreateable())
       insert inc;
       return inc;
   }
   public static user user_insert(string mail){
       user new_user=new user();
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       new_user.lastName = 'test user';
       new_user.Alias = 'test';
       new_user.Email = mail;
       new_user.Username = 'I8@Purv.com';
       new_user.CommunityNickname = 'test.user';
       new_user.LanguageLocaleKey='en_US';
       new_user.EmailEncodingKey='UTF-8';
       new_user.LocaleSidKey='en_US';
       new_user.ProfileId = p.Id;
        new_user.Phone = '919878458956';
       new_user.TimeZoneSidKey='America/Los_Angeles';
       if(Schema.sObjectType.user.isCreateable())
       insert new_user;
       return new_user;
   }
   public static user user_insert1(string mail){
       user new_user=new user();
       Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
       new_user.lastName = 'Unit Test';
       new_user.Alias = 'test';
       new_user.Email = mail;
       new_user.Username = 'Unit_Test@Purv.com';
       new_user.CommunityNickname = 'Unit.Test';
       new_user.LanguageLocaleKey='en_US';
       new_user.EmailEncodingKey='UTF-8';
       new_user.LocaleSidKey='en_US';
       new_user.ProfileId = p.Id;
       new_user.Phone = '919878458956';
       new_user.TimeZoneSidKey='America/Los_Angeles';
       if(Schema.sObjectType.user.isCreateable())
       insert new_user;
       return new_user;
   }   
   public static Team__c Team_insert(string Name){
       Team__c  team1=new Team__c();
       team1.Name='Team name';
       if(Schema.sObjectType.Team__c.isCreateable())
       insert team1;
       return team1;
   
   }   
    public static Team_Member__c Teammember_insert(id memberid,id Teamid){
       Team_Member__c Teammember = new Team_Member__c();
       Teammember.Member__c=memberid;
       Teammember.Team__c = teamid;
       if(Schema.sObjectType.Team_Member__c.isCreateable())
       insert Teammember;
       return Teammember;
   }
    public static Role__c Role_Insert(string rolename){
        Role__c Role = new Role__c();
        Role.Reference_Role__c = rolename;
        Role.Default_SOE_Manager__c = true;
        if(Schema.sObjectType.Role__c.isCreateable())
        insert Role;
        return Role;
    }
    public static Member__c Member_Insert(string name,Id UserId,string phone,string mail){
        Member__c member = new Member__c();
        member.Name = name;
        member.Salesforce_User__c = UserId;
        member.Email__c = mail ;
        member.Phone__c = phone;
        if(Schema.sObjectType.Member__c.isCreateable())
        insert member;
        return member;
        
    }
    public static SOE_Team_Member__c teammember_insert(id memberid,string acclvl,id soeid,id roleId){
      SOE_Team_Member__c team_member = new SOE_Team_Member__c();
      team_member.Access_Level__c =acclvl;
      team_member.SOE__c =soeid;
      team_member.Team_Member__c=memberid;
      team_member.Role__c = roleid;
      if(Schema.sObjectType.SOE_Team_Member__c.isCreateable())
      insert team_member;
      return team_member;        
    }
    public static MIS__c MIS_Insert(string title){
        MIS__c mis = new MIS__c();
        mis.MIS_Title__c = title;
        if(Schema.sObjectType.MIS__c.isCreateable())
        insert mis;
        return mis;
    }
    public static Communication__c COMM_Insert(id Task,id soe, boolean ms_d,string ms_add,string TR_add,string AN_Add,string COM_ADD){
       Communication__c com = new Communication__c();
        com.Additinal_Emails_Milestone__c = ms_add;
        com.Additinal_Emails_Task_Ready__c = TR_add;
        com.Additional_Emails_Completed__c = COM_Add;
        com.MileStone_for_default_Imp_Mngrs__c = ms_d;
        com.Task__c = Task;
        com.SOE__c = soe;
        if(Schema.sObjectType.Communication__c.isCreateable())
        insert com;
        return com;
    }
     public static BroadCast__c Broadcast_Insert(string msg){
        Broadcast__c br = new BroadCast__c();
        br.Message__c = msg;
        br.Status__c = 'Active';
        br.All_Users__c = true;
        br.Message_Start_Date__c = System.now();
        br.Message_End_Date__c = System.now().addMinutes(5);
        if(Schema.sObjectType.Broadcast__c.isCreateable())
        insert br;
        return br;
    }
    public static void TwilioSettings_Insert(string twilioname,string installed){
        list<System_Setting__c > SettingList= new LIst<System_Setting__c >();
        SettingList.add(new System_Setting__c ( Name= 'Twilio Class' ,Key__c = 'Twilio_Class_Name', value__c = twilioname,Categories__c = 'Twilio'));        
        SettingList.add(new System_Setting__c(Name='Twilio Installed',Key__c = 'Twilio_Installed',Value__c = 'no',Categories__c ='Twilio Settings'));
        SettingList.add(new System_Setting__c(Name='Twilio Account SId',Key__c = 'Twilio_Account_SId',Categories__c ='Twilio Settings'));
        SettingList.add( new System_Setting__c(Name='Twilio Auth Token',Key__c = 'Twilio_Auth_Token',Categories__c ='Twilio Settings'));
        SettingList.add(new System_Setting__c(Name='Twilio From Number',Key__c = 'Twilio_From_Number',Categories__c ='Twilio Settings'));
                
        if(Schema.sObjectType.System_Setting__c.isCreateable())
            insert SettingList;
    }
    public static void SystemSettings_Insert(){
        list<System_Setting__c > SettingList = new LIst<System_Setting__c >();
                SettingList.add( new System_Setting__c(Name='LOG ENABLE',Key__c = 'LOG_ENABLE',Value__c='false',Categories__c ='General Settings'));
                SettingList.add(new System_Setting__c(Name='LOG LEVEL',Key__c = 'LOG_LEVEL',Value__c ='ERROR; INFO; DEBUG;',Categories__c ='General Settings'));
                SettingList.add( new System_Setting__c(Name='Acceped Document Types',Key__c = 'Accepted_Document_Types',Value__c ='.doc,.docx,.csv,.xls,.xlsx,.pdf',Categories__c ='Task Document'));
                SettingList.add(new System_Setting__c ( Name='SOE FIelds',Key__c = 'i8__SOE__c',Value__c ='i8__SOE_Title__c,I8__Summary__c,i8__Baseline_Start__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Task Fields',Key__c = 'i8__Task__c',Value__c ='i8__Task_Title__c,i8__Status__c,i8__ID_Text__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='TeamMember Fields',Key__c = 'i8__Team_Member__c',Value__c ='I8__Member__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='MIS Fields',Key__c = 'i8__MIS__c',Value__c ='I8__MIS_Title__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Dependency Fields',Key__c = 'i8__Dependency__c',Value__c ='I8__Task__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Broadcast Fields',Key__c = 'i8__Broadcast__c',Value__c ='i8__Status__c,I8__All_Users__c,I8__Message__c,I8__Message_End_Date__c,I8__Message_Start_Date__c,I8__This_SOE_Users__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Access Request Line Item Fields',Key__c = 'I8__Access_Request_Line_Item__c',Value__c ='Start_Time__c,End_Time__c,Requested_User__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='TimeSheet Entry Fields',Key__c = 'I8__Timesheet_Entry__c',Value__c ='I8__Start__c,I8__End__c,I8__SOE__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Expenses Fields',Key__c = 'I8__Expenses__c',Value__c ='I8__Date__c,I8__Amount__c,I8__Expense_Type__c,I8__Payment_Type__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='SOE Team Member Fields',Key__c = 'I8__SOE_Team_Member__c',Value__c ='I8__SOE__c,I8__Team_Member__c,I8__Access_Level__c,I8__Role__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Incident Fields',Key__c = 'I8__Incident__c',Value__c ='I8__Summary__c,I8__Inc_Type__c,I8__Priority__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='User Fields',Key__c = 'User',Value__c ='I8__MIS_MyView__c,I8__SOE_MyView__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Member Fields',Key__c = 'I8__Member__c',Value__c ='I8__Salesforce_User__c,I8__Role__c,I8__Phone__c,I8__Email__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Communication Fields',Key__c = 'I8__Communication__c',Value__c ='I8__Completed_Members__c,I8__Milestone_Members__c,I8__Task_Ready_Members__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='MIS Manager Fields',Key__c = 'I8__MIS_Manager__c',Value__c ='I8__MIS__c,I8__MIS_Manager__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Role Fields',Key__c = 'I8__Role__c',Value__c ='I8__Default_SOE_Manager__c,I8__Reference_Role__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Log Fields',Key__c = 'I8__Log__c',Value__c ='Level__c,Source_Class__c,Source_Method__c,Title__c,Description__c,Location__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Access Request Fields',Key__c = 'I8__Access_Request__c',Value__c ='SOE__c,Task__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='TimeSheet Fields',Key__c = 'I8__Timesheet__c',Value__c ='PayPeriod_Start__c,PayPeriod_End__c,Rate_Card_Per_Hour__c,Total_Hours__c,Status__c,Manager__c,Pay_Total__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Expense Claim Fields',Key__c = 'I8__Expense_Claim__c',Value__c ='From_Date__c, To_Date__c, Employee_Name__c,Manager__c,Total_Claim_Amount__c, No_Of_Claims__c',Categories__c ='Required Fields'));
                if(Schema.sObjectType.System_Setting__c.isCreateable())
                    insert SettingList;
    }
}