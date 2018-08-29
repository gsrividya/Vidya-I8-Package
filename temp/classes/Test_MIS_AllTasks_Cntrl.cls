// class :   SatckGantt_Chart_Cntrl

@istest
Public class Test_MIS_AllTasks_Cntrl {
    Public static i8Constants i8 = new I8Constants();
     @testSetup static void setup() {
           SOEUtility.SystemSettings_Insert();
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('MIS All TAsk 1',service.id,true,true,false,false);
        System.assertEquals(soe.SOE_Title__c, 'MIS All TAsk 1'); 
    }
    Static testmethod void Test_MIS_AllTasks_Cntrl1 (){
        test.StartTest();
         user user1 = SOEUtility.user_insert('user--15@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--15@gmail.com'];
        Team__c Team1=SOEUtility.Team_insert('sap');
        Team_Member__c Teammember1=SOEUtility.Teammember_insert(member1.id,Team1.id);
        MIS__c mis = SOEUtility.MIS_Insert('MIS insetrt1');
        System.assertEquals(mis.MIS_Title__c, 'MIS insetrt1');
        SOE__c soe = [select id,SOE_Title__c from SOE__c where SOE_Title__c ='MIS All TAsk 1'];     
        System.assertEquals(SOE.SOE_Title__c , 'MIS All TAsk 1');
        list<Task__c> tas = [select id,Id_Text__c from Task__c where soe__c =: soe.Id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_Decimal__c,Id_After_Decimal__c];
        SOE.MIS__c = mis.id;
        update soe;
        ApexPages.CurrentPage().getparameters().put('Id', mis.Id);
        MIS_AllTasks_Cntrl All = new MIS_AllTasks_Cntrl();
        tas[4].Team__c = Team1.Id;
        tas[4].Owner__c = Teammember1.Id;
        update tas[4];
        MIS_AllTasks_Cntrl.getTasks('select id,Owner__c,SOE__c from Task__c ','',mis.Id,10,0);
        ApexPages.CurrentPage().getparameters().put('input1', soe.id); 
        All.UpdateTasks();
        ApexPages.CurrentPage().getparameters().put('ActiveId', tas[4].Id);  
        ApexPages.CurrentPage().getparameters().put('input1', soe.id); 
        All.ActivateTask1();
        All.CompleteTask();      
        Test.StopTest();
        soe.Status__c = i8.STATUS_IMPINPROGRESS;
        update soe;
        ApexPages.CurrentPage().getparameters().put('Id', mis.Id);
        All = new MIS_AllTasks_Cntrl();        
        soe.Status__c = i8.STATUS_IMP_COMP;
        update soe;
        ApexPages.CurrentPage().getparameters().put('Id', mis.Id);
        All = new MIS_AllTasks_Cntrl();        
        soe.Status__c = i8.STATUS_SOE_COMP;
        update soe;
        ApexPages.CurrentPage().getparameters().put('Id', mis.Id);
        All = new MIS_AllTasks_Cntrl();
        All.Cancel(); 
    }
    Static testmethod void Test_MIS_AllTAsks_Cntrl2 (){
        test.StartTest();
        MIS__c mis = SOEUtility.MIS_Insert('MIS insetrt1');
        System.assertEquals(mis.MIS_Title__c, 'MIS insetrt1');
        SOE__c soe = [select id,SOE_Title__c from SOE__c where SOE_Title__c ='MIS All TAsk 1'];     
        System.assertEquals(SOE.SOE_Title__c , 'MIS All TAsk 1');
        list<Task__c> tas = [select id,Id_Text__c from Task__c where soe__c =: soe.Id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_Decimal__c,Id_After_Decimal__c];
        SOE.MIS__c = mis.id;
        update soe;
        BroadCast__c br = SOEUtility.Broadcast_Insert('this is one message');
        ApexPages.CurrentPage().getparameters().put('id', mis.Id);
        MIS_AllTasks_Cntrl All = new MIS_AllTasks_Cntrl();
        ApexPages.CurrentPage().getparameters().put('ActiveId', tas[4].Id);  
        All.ReRunTask();
        All.BroadCastOnOff();
        All.BroadCastOnOff();
        ApexPages.CurrentPage().getparameters().put('tas', tas[4].Id); 
        ApexPages.CurrentPage().getparameters().put('body1','this is sample message'); 
        All.AddPINtoTask();
        All.openListIncidents();
        All.openListOpenIncidents();
        All.openListClosedIncidents();
        All.openMISDashboards();
        All.openCreateIncident();
        All.openAddDocuments();
        All.openModifyTask(); 
        All.openAllDocuments();
        All.openResourceROTA();
        All.openHistoryPage();
        All.openMyView();  
        All.openTaskGanttChart();
        All.openResourceGanttChart();    
        Test.StopTest();      
    }
     Static testmethod void Test_MIS_AllTAsks_Cntrl3 (){
        test.StartTest();
        MIS__c mis = SOEUtility.MIS_Insert('MIS insetrt1');
        System.assertEquals(mis.MIS_Title__c, 'MIS insetrt1');
        SOE__c soe = [select id,SOE_Title__c from SOE__c where SOE_Title__c ='MIS All TAsk 1'];     
        System.assertEquals(SOE.SOE_Title__c , 'MIS All TAsk 1');
        list<Task__c> tas = [select id,Id_Text__c from Task__c where soe__c =: soe.Id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_Decimal__c,Id_After_Decimal__c];
        SOE.MIS__c = mis.id;
        update soe;
        ApexPages.CurrentPage().getparameters().put('id', mis.Id);
        MIS_AllTasks_Cntrl All = new MIS_AllTasks_Cntrl();
        All.RerunTask();
        All.ActivateTask1();
        All.CompleteTask();
        All.CreateCall();
        All.CreateSMS();
        All.UpdateTasks();
        Test.StopTest();
     }
     Static testmethod void Test_StackGanttChart_Cntrl (){
        test.StartTest();
        MIS__c mis = SOEUtility.MIS_Insert('MIS insetrt1');
        System.assertEquals(mis.MIS_Title__c, 'MIS insetrt1');
        SOE__c soe = [select id,SOE_Title__c from SOE__c where SOE_Title__c ='MIS All TAsk 1'];     
        System.assertEquals(SOE.SOE_Title__c , 'MIS All TAsk 1');
        list<Task__c> tas = [select id,Id_Text__c from Task__c where soe__c =: soe.Id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_Decimal__c,Id_After_Decimal__c];
        SOE.MIS__c = mis.id;
        update soe;
        ApexPages.CurrentPage().getparameters().put('id', mis.Id);
        StackGanttChart_Cntrl  All = new StackGanttChart_Cntrl ();
        StackGanttChart_Cntrl.getTasks(mis.Id);
        All.OpenCancel();
        Test.StopTest();      
    }
}