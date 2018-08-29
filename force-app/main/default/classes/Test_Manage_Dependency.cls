@istest
public class Test_Manage_Dependency{
    public static i8Constants i8 = new I8Constants(); 
    @testSetup static void setup() {
           SOEUtility.SystemSettings_Insert();
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('Manage Dependency 1',service.id,true,true,false,false);
        SOE__c SOE1 = SOEUtility.SOE_Insert('Manage Dependency 2',service.id,true,true,false,false);
        System.assertEquals(SOE.SOE_Title__c , 'Manage Dependency 1');           
    }
    static testmethod void Test_Manage_Dependency_cntrl1(){           
        SOE__c soe = [select id,SOE_Title__c from SOE__c where SOE_Title__c ='Manage Dependency 1'];     
        System.assertEquals(SOE.SOE_Title__c , 'Manage Dependency 1');
        list<Task__c> tas = [select id,Id_Text__c,Task_Title__c from Task__c where SOE__c=: soe.id order by Id_Before_Decimal__c,Id_After_Decimal__c];
        SOE__c soe1 = [select id,SOE_Title__c from SOE__c where SOE_Title__c ='Manage Dependency 2'];       
        list<Task__c> tas1 = [select id,Id_Text__c,Task_Title__c from Task__c where SOE__c=: soe1.id order by Id_Before_Decimal__c,Id_After_Decimal__c];  
        ApexPages.currentPage().getParameters().put('page','soe');
        ApexPages.CurrentPage().getparameters().put('SOEId',soe.id);
        ApexPages.CurrentPage().getparameters().put('ID',tas[0].Id);
        Add_Task_cntrl add_tas_1_1 = new Add_Task_cntrl ();
        ApexPages.CurrentPage().getparameters().put('days', '2');
        ApexPages.CurrentPage().getparameters().put('hours', '2');
        ApexPages.CurrentPage().getparameters().put('minutes', '2');
        ApexPages.CurrentPage().getparameters().put('tasktitle', 'task1.1');
        add_tas_1_1.CreateTask();
        ApexPages.CurrentPage().getparameters().put('ID',tas[0].Id);
        Add_Task_cntrl add_tas_1_2 = new Add_Task_cntrl ();
        ApexPages.CurrentPage().getparameters().put('days', '2');
        ApexPages.CurrentPage().getparameters().put('hours', '2');
        ApexPages.CurrentPage().getparameters().put('minutes', '2');
        ApexPages.CurrentPage().getparameters().put('tasktitle', 'task1.2');
        add_tas_1_2.CreateTask();
        ApexPages.CurrentPage().getparameters().put('ID',tas[0].Id);
        Add_Task_cntrl add_tas_1_1_Extrnl = new Add_Task_cntrl ();
        ApexPages.CurrentPage().getparameters().put('days', '2');
        ApexPages.CurrentPage().getparameters().put('hours', '2');
        ApexPages.CurrentPage().getparameters().put('minutes', '2');
        ApexPages.CurrentPage().getparameters().put('tasktitle', 'task1.3');
        add_tas_1_1_Extrnl .CreateTask();        
        tas = [select id,Id_Text__c,Task_Title__c from Task__c where SOE__c=: soe.id order by Id_Before_Decimal__c,Id_After_Decimal__c];
        ApexPages.currentPage().getParameters().put('Tid',tas[1].Id); 
        Test.StartTest();
        Manage_Dependencies_Cntrl  ManageDep = New Manage_Dependencies_Cntrl (); 
        ManageDep.getTasks();
        ManageDep.AfterTask();
        manageDep.LinkTask();
        ManageDep.UnLinkTask();
        manageDep.PrevTaskId = tas[1].Id;
        ManageDep.Add_Dependency();
        manageDep.LinkTask();
        manageDep.selectSOE = soe1.Id;
        manageDep.PrevTaskId = tas1[1].Id;
        ManageDep.Add_Dependency();
        manageDep.selectSOE = soe.Id;
        manageDep.PrevTaskId = tas[1].Id;
        ManageDep.Add_Dependency();
        manageDep.LinkTask();       
        ManageDep.AfterTask();
        Test.StopTest();       
    }
    static testmethod void Test_Manage_Dependency_cntrl2(){   
        
        SOE__c soe = [select id,SOE_Title__c from SOE__c where SOE_Title__c ='Manage Dependency 1'];     
        System.assertEquals(SOE.SOE_Title__c , 'Manage Dependency 1');
        list<Task__c> tas = [select id,Id_Text__c,Task_Title__c from Task__c where SOE__c=: soe.id order by Id_Before_Decimal__c,Id_After_Decimal__c];
        SOE__c soe1 = [select id,SOE_Title__c from SOE__c where SOE_Title__c ='Manage Dependency 2'];     
        list<Task__c> tas1 = [select id,Id_Text__c,Task_Title__c from Task__c where SOE__c=: soe1.id order by Id_Before_Decimal__c,Id_After_Decimal__c];  
        ApexPages.CurrentPage().getparameters().put('SOEId',soe.id);
        ApexPages.CurrentPage().getparameters().put('ID',tas[0].Id);
        Add_Task_cntrl add_tas_1_1 = new Add_Task_cntrl ();
        ApexPages.CurrentPage().getparameters().put('days', '2');
        ApexPages.CurrentPage().getparameters().put('hours', '2');
        ApexPages.CurrentPage().getparameters().put('minutes', '2');
        ApexPages.CurrentPage().getparameters().put('tasktitle', 'task1.1');
        add_tas_1_1.CreateTask();
        ApexPages.CurrentPage().getparameters().put('ID',tas[0].Id);
        Add_Task_cntrl add_tas_1_2 = new Add_Task_cntrl ();
        ApexPages.CurrentPage().getparameters().put('days', '2');
        ApexPages.CurrentPage().getparameters().put('hours', '2');
        ApexPages.CurrentPage().getparameters().put('minutes', '2');
        ApexPages.CurrentPage().getparameters().put('tasktitle', 'task1.2');
        add_tas_1_2.CreateTask();
        ApexPages.CurrentPage().getparameters().put('ID',tas[0].Id);
        Add_Task_cntrl add_tas_1_1_Extrnl = new Add_Task_cntrl ();
        ApexPages.CurrentPage().getparameters().put('days', '2');
        ApexPages.CurrentPage().getparameters().put('hours', '2');
        ApexPages.CurrentPage().getparameters().put('minutes', '2');
        ApexPages.CurrentPage().getparameters().put('tasktitle', 'task1.3');
        add_tas_1_1_Extrnl .CreateTask();
        Test.StartTest();    
        tas = [select id,Id_Text__c,Task_Title__c from Task__c where SOE__c=: soe.id order by Id_Before_Decimal__c,Id_After_Decimal__c];
        ApexPages.currentPage().getParameters().put('page','soe');
        ApexPages.currentPage().getParameters().put('Tid',tas[3].id);
        Manage_Dependencies_Cntrl  ManageDep=new Manage_Dependencies_Cntrl ();
        ManageDep.getTasks();
        manageDep.LinkTask();  
        manageDep.PrevTaskId = tas[1].Id;
        ManageDep.Add_Dependency();
        ManageDep.UnLinkTask();
        manageDep.LinkTask();   
        manageDep.selectSOE = soe1.Id;
        manageDep.PrevTaskId = tas1[1].Id;
        ManageDep.Add_Dependency();
        ManageDep.GetTasks();
        ManageDep.UnLinkTask();
        manageDep.DelDepId = [select id from dependency__c where Task__c = : tas[3].Id limit 1].Id;
        manageDep.Delete_Action();
        Test.StopTest();       
    }  
    static testmethod void Test_Manage_Dependency_cntrl3(){    
        SOE__c soe = [select id,SOE_Title__c from SOE__c where SOE_Title__c ='Manage Dependency 1'];     
        System.assertEquals(SOE.SOE_Title__c , 'Manage Dependency 1');
        ApexPages.currentPage().getParameters().put('page','soe');
        list<Task__c> tas = [select id,Id_Text__c,Task_Title__c,Id_Before_Decimal__c,Id_After_Decimal__c from Task__c where SOE__c=: soe.id order by Id_Before_Decimal__c,Id_After_Decimal__c];
        ApexPages.currentPage().getParameters().put('Tid',tas[4].Id); 
        Test.StartTest();        
        Manage_Dependencies_Cntrl  ManageDep=new Manage_Dependencies_Cntrl ();           
        ManageDep.context = 'implementation';
        ManageDep.AfterTask();
        ManageDep.BeforeTask();
        ManageDep.SOEID = soe.id;
        ManageDep.Cancel();
        manageDep.page = 'EditStack';
        manageDep.cancel();          
        ManageDep.page = 'Modify_Task';
        ManageDep.Cancel();
        ManageDep.Page = '';
        ManageDep.Cancel();
        
        ManageDep.getSOEOPtion(); 
        ManageDep.SOEName  = 'Manage Dependency 2';
        ManageDep.getSOEOPtion();  
        List<Task__c> TaskInsertList = New List<Task__c>();
        For(Integer i=0; i<1100; i++){
            Task__c Tas1 = New Task__c(Task_Title__c = 'Task'+i, Stage_Level__c = 'Implementation',Stage__c = 'Pre', SOE__c = SOE.Id, Status__c = 'Build', Id_Text__c = Tas[0].Id_Before_Decimal__c +'.'+ (Tas[0].Id_After_Decimal__c+i+1),days__c =0,Hours__c =0,Minutes__c = 5 );
            TaskInsertList.add(tas1);
        }
        Upsert TaskInsertList;
        ManageDep.TaskId = TaskInsertList[1050].Id;
        ManageDep.InitializeTask(ManageDep.TaskId);
        ManageDep.MoreTasks();
        ManageDep.DeleteDependency();   
        ManageDep.Save(); 
        MIS__c mis1 = SOEUtility.MIS_Insert('dds');
        soe.MIS__c = mis1.id;
        update soe;
        ApexPages.currentPage().getParameters().put('Tid',tas[1].Id); 
        ApexPages.currentPage().getParameters().put('MId',mis1.Id); 
        ManageDep = New Manage_Dependencies_Cntrl (); 
        ManageDep.page = 'Modify_Task';
        ManageDep.Cancel();  
        Test.StopTest();
    }
    static testmethod void Test_Manage_Dependency_cntrl4(){    
        SOE__c soe = [select id,SOE_Title__c from SOE__c where SOE_Title__c ='Manage Dependency 1'];     
        System.assertEquals(SOE.SOE_Title__c , 'Manage Dependency 1');
        ApexPages.currentPage().getParameters().put('page','soe');
        list<Task__c> tas = [select id,Id_Text__c,Task_Title__c,Id_Before_Decimal__c,Id_After_Decimal__c from Task__c where SOE__c=: soe.id order by Id_Before_Decimal__c,Id_After_Decimal__c];
        ApexPages.currentPage().getParameters().put('Tid',tas[4].Id); 
        Test.StartTest();        
        Manage_Dependencies_Cntrl  ManageDep=new Manage_Dependencies_Cntrl ();
        delete tas[4];
        ManageDep.LinkTask();
        manageDep.PrevTaskId = tas[3].Id;
        ManageDep.Add_Dependency();
        manageDep.Delete_Action();
        manageDep.UnlinkTask();
        ManageDep.DeleteDependency(); 
        Test.StopTest();
    }
}