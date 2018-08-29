@istest
public class Test_Task_TriggerHandler{
public static I8Constants i8 = new I8Constants();
    @testSetup static void setup() {
           SOEUtility.SystemSettings_Insert();
           Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
           role = [select id,Reference_Role__c  from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
           System.assertEquals(role.Reference_Role__c , 'Imp Manager');
    }
    static testmethod void Test_Task_Triggerhandeler(){
       
        Department__c  service1 = SOEUtility.Dep_Insert('1Service1');
        SOE__c SOE = SOEUtility.SOE_Insert('newsoetemp',service1.Id,true,true,true,false,false);           
        System.assertEquals(SOE.SOE_Title__c , 'newsoetemp');
        list<Task__c> tas = [select id,Id_TExt__c,Minutes__c from TASk__c where SOE__c =: Soe.id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_decimal__c,Id_After_decimal__c];
        tas[1].Minutes__c = 10;
        tas[1].Jump__c = true;
        update tas[1];
        SOE__c SOE1 = SOEUtility.SOE_Insert('newsoetemp11190',service1.Id,true,true,true,false,false);
        list<Task__c> tas1 = [select id,Id_TExt__c,Minutes__c from TASk__c where SOE__c =: Soe1.id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_decimal__c,Id_After_decimal__c];
        ApexPages.CurrentPage().getparameters().put('SOEId',soe.Id);
        ApexPages.CurrentPage().getparameters().put('Id', TAS[1].Id);
        Test.StartTest();
        Add_Task_cntrl Add = new Add_Task_cntrl ();
        ApexPages.CurrentPage().getparameters().put('days', '2');
        ApexPages.CurrentPage().getparameters().put('hours', '2');
        ApexPages.CurrentPage().getparameters().put('minutes', '2');
        ApexPages.CurrentPage().getparameters().put('tasktitle', 'T3');
        Add.NewTask.Link__c = true;
        Add.CreateTask();
       
        ApexPages.CurrentPage().getparameters().put('Id', TAS[1].Id);
        Add = new Add_Task_cntrl ();
        ApexPages.CurrentPage().getparameters().put('days', '2');
        ApexPages.CurrentPage().getparameters().put('hours', '2');
        ApexPages.CurrentPage().getparameters().put('minutes', '2');
        ApexPages.CurrentPage().getparameters().put('tasktitle', 'T4');
        Add.CreateTask();
         ApexPages.currentPage().getParameters().put('page','SOE');
         ApexPages.currentPage().getParameters().put('Tid',tas[2].Id); 
            Manage_Dependencies_Cntrl  ManageDep=new Manage_Dependencies_Cntrl ();           
            manageDep.PrevTaskId = tas[1].Id;
            ManageDep.Add_Dependency();
            manageDep.LinkTask();
            manageDep.selectSOE = soe1.Id;
            manageDep.PrevTaskId = tas1[1].Id;
            ManageDep.Add_Dependency();
        Task_triggerHandler.UpdateAllTAsks(new list<id>{soe.id},i8.CONTEXT_IMP);
        soe.Schedule_Start__c = System.Now()+1;
        soe.Schedule_End__c = soe.Schedule_Start__c.AddHours(2);
        soe.Warning_Zone__c = soe.Schedule_End__c.AddHours(2);
        soe.Schedule_End__c = soe.Warning_Zone__c.AddHours(2);
        soe.status__c = i8.STATUS_SCHEDULED;
        update soe;
          Test.StopTest();
        Task_triggerHandler.UpdateAllTAsks(new list<id>{soe.id},i8.CONTEXT_IMP);
        ApexPages.currentPage().getParameters().put('ID',SOE.Id);      
        AllTasks_ClientSide_cntrl AllTasks = New AllTasks_ClientSide_cntrl();        
        AllTasks.SOEFreeze();
    }
    static testmethod void Test_Task_Triggerhandeler1(){
        Test.startTest();
        Department__c  service1 = SOEUtility.Dep_Insert('1Service1');
        SOE__c SOE = SOEUtility.SOE_Insert('newsoetemp',service1.Id,true,true,true,false,false);           
        System.assertEquals(SOE.SOE_Title__c , 'newsoetemp');
        SOE.Status__c = 'Freeze';
        Update SOE;
        list<Task__c> tas2 = [select id,Id_TExt__c,Status__c,Minutes__c from TASk__c where SOE__c =: Soe.id and Stage__c =: I8.STAGE_IMP and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_decimal__c,Id_After_decimal__c];
        ApexPages.CurrentPage().getparameters().put('SOEId',soe.Id);
        ApexPages.CurrentPage().getparameters().put('Id', TAS2[1].Id);
        Add_Task_cntrl Add = new Add_Task_cntrl ();
        ApexPages.CurrentPage().getparameters().put('days', '2');
        ApexPages.CurrentPage().getparameters().put('hours', '2');
        ApexPages.CurrentPage().getparameters().put('minutes', '2');
        ApexPages.CurrentPage().getparameters().put('tasktitle', 'T4');
        Add.CreateTask();
         
        ApexPages.currentPage().getparameters().put('SId',SOE.Id);
        ApexPages.currentPage().getparameters().put('Id',Tas2[1].Id);
        Modify_Task_cntrl Modify = New Modify_Task_cntrl();
        Modify.CurTask.Task_Title__c = 'Freeze Task';
        Modify.CurTask.Days__c = 12;
        Modify.CurTask.Technical_Detail__c = 'Freeze Detail';
        Modify.CurTask.Description__c = 'Freeze Description';
        Modify.CurTask.Milestone__c = True;
        Modify.SaveTask();   
        Test.stopTest();
    }
     static testmethod void Test_Task_Triggerhandeler2(){       
        Department__c  service1 = SOEUtility.Dep_Insert('1Service1');
        Role__c rol = [select id,Reference_Role__c  from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
        SOE__c SOE = SOEUtility.SOE_Insert('newsoetemp',service1.Id,true,true,true,false,false);           
        list<Task__c> tas = [select id,Id_TExt__c,Minutes__c from TASk__c where SOE__c =: Soe.id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_decimal__c,Id_After_decimal__c];
        Communication__c com = SOEUtility.COMM_Insert(tas[2].id,soe.id,true,'dsdad@gmail.com','','','');
        tas[1].Status__c = i8.STATUS_RUNNING;
        tas[1].End_time__c = System.Now().adddays(-1);
        update tas[1];
          tas[2].Milestone__c = true;
          update tas[2];
         System.assertEquals(tas[1].Status__c,  i8.STATUS_RUNNING);
        Task_triggerHandler.UpdateAllTAsks(new list<id>{soe.id},i8.CONTEXT_IMP);        
        tas[1].Status__c = i8.STATUS_COMPLETED;
        tas[2].Status__c = i8.STATUS_COMPLETED;
        update tas;
        Test.StartTest();
        ApexPages.CurrentPage().getparameters().put('SOEId',soe.Id);
        ApexPages.CurrentPage().getparameters().put('Id', TAS[4].Id);
        Add_Task_cntrl Add = new Add_Task_cntrl ();
        ApexPages.CurrentPage().getparameters().put('days', '2');
        ApexPages.CurrentPage().getparameters().put('hours', '2');
        ApexPages.CurrentPage().getparameters().put('minutes', '2');
        ApexPages.CurrentPage().getparameters().put('tasktitle', 'T3');
        Add.NewTask.Link__c = true;
        Add.CreateTask();       
        ApexPages.CurrentPage().getparameters().put('Id', TAS[4].Id);
        Add = new Add_Task_cntrl ();
        ApexPages.CurrentPage().getparameters().put('days', '2');
        ApexPages.CurrentPage().getparameters().put('hours', '2');
        ApexPages.CurrentPage().getparameters().put('minutes', '2');
        ApexPages.CurrentPage().getparameters().put('tasktitle', 'T3');
        Add.NewTask.Link__c = true;
        Add.CreateTask();       
        tas = [select id,Id_TExt__c,Minutes__c from TASk__c where SOE__c =: Soe.id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_decimal__c,Id_After_decimal__c];
        tas[5].Jump__c = true;
        update tas[5];
        tas[4].Jump__c = true;
        update tas[4];
        tas[4].Jump__c = False;
        update tas[4];
        soe.Status__c = i8.STATUS_FREEZE;
        update soe;
        Task_triggerHandler.UpdateAllTAsks(new list<id>{soe.id},i8.CONTEXT_IMP);
        delete tas[6];
        Test.StopTest();
        Task_triggerHandler.UpdateAllTAsks(new list<id>{soe.id},i8.CONTEXT_IMP);       
        soe.Schedule_Start__c = System.Now().addMinutes(-2);
        soe.Schedule_End__c = soe.Schedule_Start__c.AddHours(2);
        soe.Warning_Zone__c = soe.Schedule_End__c.AddHours(2);
        soe.Schedule_End__c = soe.Warning_Zone__c.AddHours(2);
        soe.status__c = i8.STATUS_IMPINPROGRESS;
        update soe;
        tas = [select id,Id_TExt__c,Minutes__c from TASk__c where SOE__c =: Soe.id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_decimal__c,Id_After_decimal__c];
        tas[4].Status__c = i8.STATUS_COMPLETED;
        update tas[4];
        Task_triggerHandler.UpdateAllTAsks(new list<id>{soe.id},i8.CONTEXT_IMP);
        tas[6].Status__c = i8.STATUS_COMPLETED;
        update tas[6];
        Task_triggerHandler.UpdateAllTAsks(new list<id>{soe.id},i8.CONTEXT_IMP);  
     }
      static testmethod void Test_Task_Triggerhandeler3(){
        Test.startTest();
        Department__c  service1 = SOEUtility.Dep_Insert('1Service1');
        SOE__c SOE = SOEUtility.SOE_Insert('newsoetemp',service1.Id,true,true,true,false,false);           
        System.assertEquals(SOE.SOE_Title__c , 'newsoetemp');
        SOE.Status__c = 'Freeze';
        Update SOE;
        list<Task__c> tas2 = [select id,Id_TExt__c,Status__c,Minutes__c from TASk__c where SOE__c =: Soe.id and Stage__c =: I8.STAGE_IMP and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_decimal__c,Id_After_decimal__c];
      
        Task_triggerHandler.UpdateAllTAsks(new list<id>{soe.id},i8.CONTEXT_IMP);
        soe.Status__c = i8.STATUS_IMPINPROGRESS;
        update soe;
        Create_Incident.SOE_ReExe = true;
        Task_triggerHandler.UpdateAllTAsks(new list<id>{soe.id},i8.CONTEXT_IMP);        
         soe.Status__c = i8.STATUS_ABANDONED;
        update soe;
        Task_triggerHandler.UpdateAllTAsks(new list<id>{soe.id},i8.CONTEXT_IMP);
        Test.StopTest();
    }
    static testmethod void Test_Task_Triggerhandeler4(){
        Test.startTest();
        Department__c  service1 = SOEUtility.Dep_Insert('1Service1');
        SOE__c SOE = SOEUtility.SOE_Insert('newsoetempa',service1.Id,true,true,true,false,false);           
        System.assertEquals(SOE.SOE_Title__c , 'newsoetempa');
        list<Task__c> tas = [select id,Id_TExt__c,Status__c,Minutes__c,SOE__c,Id_Before_Decimal__c from TASk__c where SOE__c =: Soe.id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_decimal__c,Id_After_decimal__c];
        user user1 = SOEUtility.user_insert('user--161@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--161@gmail.com'];
        Team__c Team1=SOEUtility.Team_insert('sap');
        Team_Member__c Teammember1=SOEUtility.Teammember_insert(member1.id,Team1.id);
        tas[1].Team__c = team1.id;
        tas[1].Owner__c = teammember1.id;
        tas[1].PIN__c = '2017-01-09 08:44:11-xaxaxa1321:sample message';
        update tas[1];
        Test.StopTest();
     }
}