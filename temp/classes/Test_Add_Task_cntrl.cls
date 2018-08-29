@istest
Public class Test_Add_Task_cntrl{
    Public static i8Constants i8 = new I8Constants();
    Static testmethod void Add_Task_cntrl(){
            SOEUtility.SystemSettings_Insert();
            Department__c service = SOEUtility.Dep_Insert('Service2');
            Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
            SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);
            SOE.Status__c = I8.STATUS_FREEZE;
            Update SOE;
            System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
            list<task__c> Tas = [select id,name,Task_Title__c,SOE__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where stage__c =: I8.STAGE_IMP and SOE__c =: SOE.id];
        Test.StartTest();
             ApexPages.CurrentPage().getparameters().put('SOEId', SOE.Id);
            ApexPages.CurrentPage().getparameters().put('Id', TAS[0].Id);
            Add_Task_cntrl Add = new Add_Task_cntrl ();
            ApexPages.CurrentPage().getparameters().put('days', '2');
            ApexPages.CurrentPage().getparameters().put('hours', '2');
            ApexPages.CurrentPage().getparameters().put('minutes', '2');
            ApexPages.CurrentPage().getparameters().put('limitedtextarea1', 'qwerty');
            ApexPages.CurrentPage().getparameters().put('limitedtextarea2', 'qwertyqwerty');
            ApexPages.CurrentPage().getparameters().put('tasktitle', 'task1.1');
            Add.CreateTask();
    
            ApexPages.CurrentPage().getparameters().put('Id', TAS[1].Id);
            Add = new Add_Task_cntrl ();
            ApexPages.CurrentPage().getparameters().put('days', '2');
            ApexPages.CurrentPage().getparameters().put('hours', '2');
            ApexPages.CurrentPage().getparameters().put('minutes', '2');
            ApexPages.CurrentPage().getparameters().put('tasktitle', '');
            Add.CreateTask();
    
            ApexPages.CurrentPage().getparameters().put('Id', TAS[1].Id);
            Add = new Add_Task_cntrl ();
            ApexPages.CurrentPage().getparameters().put('days', '2');
            ApexPages.CurrentPage().getparameters().put('hours', '2');
            ApexPages.CurrentPage().getparameters().put('minutes', '2');
            ApexPages.CurrentPage().getparameters().put('tasktitle', 'T3');
            Add.NewTask.Link__c = true;
            Add.CreateTask();
            Add.CancelTask();
            tas[0].Jump__c = true;
            tas[0].Status__c = tas[0].Status__c + + i8.JUMP;
            update tas[0];
            User user1 = SOEUtility.USer_Insert('user--31--@gmail.com');
            Member__c member1 = [select id from Member__c where Email__c ='user--31--@gmail.com'];
            SOE_Team_Member__c stm1 = SOEUtility.teammember_insert(member1.id,'Read',soe.id,role.id);
            ApexPages.CurrentPage().getparameters().put('Id', TAS[0].Id);
            Add = new Add_Task_cntrl ();
        Test.StopTest();
    }
}