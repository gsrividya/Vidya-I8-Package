@istest
Public class Test_Create_SOE_From_Template_Cntrl{
    Public static i8Constants i8 = new I8Constants();
    Static testmethod void Add_Task_cntrl(){
           SOEUtility.SystemSettings_Insert();
            Department__c  service = SOEUtility.Dep_Insert('Service2');
            Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
            SOE__c SOE = SOEUtility.SOE_Insert('SOE 18/12',service.Id,true,true,false,false);
            System.assertEquals(SOE.SOE_Title__c , 'SOE 18/12');
            list<task__c> Tas = [select id,name,Task_Title__c,SOE__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where SOE__c =: SOE.id];
        Test.StartTest();
            ApexPages.StandardController Stnd_Template= new ApexPages.StandardController(SOE);
            Create_SOE_From_Template_Cntrl Template = New Create_SOE_From_Template_Cntrl(Stnd_Template);
            Template.SOE_List();
            SOE.Is_Template__c = true;
            Update SOE;
            Template.CloneSOE = '';
            Template.SelectSOE();
            ApexPages.CurrentPage().getparameters().put('SOEId',SOE.Id);
            ApexPages.CurrentPage().getparameters().put('id',[select id,status__c,Task_Title__c from Task__C where SOE__c =: SOE.Id and ID_Text__c = '1.0'].id);
            Add_Task_cntrl add = new Add_Task_cntrl ();
            ApexPages.CurrentPage().getparameters().put('days', '2');
            ApexPages.CurrentPage().getparameters().put('hours', '2');
            ApexPages.CurrentPage().getparameters().put('minutes', '2');
            ApexPages.CurrentPage().getparameters().put('tasktitle', 'task1.1');
            Add.NewTask.Link__c = True;
            add.CreateTask();            
            ApexPages.CurrentPage().getparameters().put('id',[select id,status__c,Task_Title__c from Task__C where SOE__c =: SOE.Id and ID_Text__c = '1.1'].id);
            add = new Add_Task_cntrl ();
            ApexPages.CurrentPage().getparameters().put('days', '2');
            ApexPages.CurrentPage().getparameters().put('hours', '2');
            ApexPages.CurrentPage().getparameters().put('minutes', '2');
            ApexPages.CurrentPage().getparameters().put('tasktitle', 'task_Title.1');
            Add.NewTask.Link__c = True;
            add.CreateTask();  
            Attachment att = new Attachment();
            att.name = 'Test File';
            att.body = blob.valueof('test body');
            att.ParentId = [select id,status__c,Task_Title__c from Task__C where SOE__c =: SOE.Id and ID_Text__c = '1.0'].id;
            insert att;
            Template.Seact_ip = 'SOE 18/12';
            Template.ClrStr();
            Template.SOE_List();
            Template.CloneSOE = SOE.id;
            Template.SelectSOE();
            Template.Apply();
            Template.NewSOE.SOE_Title__c = 'SOE Template';
            Template.NewSOE.Baseline_Start__c = system.now();
            Template.Apply();
            Template.TaskrecId=[select id,status__c,Task_Title__c from Task__C where SOE__c =: SOE.Id and ID_Text__c = '1.0'].id;
            Template.openDocuments();
            Template.TaskrecId=[select id,status__c,Task_Title__c from Task__C where SOE__c =: SOE.Id and ID_Text__c = '1.0'].id;
            Template.OpenDependency();
        Test.StopTest();
    }
}