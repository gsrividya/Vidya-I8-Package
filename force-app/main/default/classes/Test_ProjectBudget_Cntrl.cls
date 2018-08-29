@IsTest
Public Class Test_ProjectBudget_Cntrl{
    Static Testmethod Void ProjectBudget_Cntrl(){
        SOEUtility.SystemSettings_Insert();
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
        
         user use = SOEUtility.user_insert('user--19@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--19@gmail.com'];
        Expense_Claim__c EXC=new Expense_Claim__c (From_Date__c =Date.today(),To_Date__c=Date.today(),Employee_Name__c='Test',Manager__c=use.id);
        Insert EXC;
        Expenses__c EX = New Expenses__c(Expense_Claim__c = EXC.ID, Amount__c = 50.00, SOE__c = SOE.ID);
        Insert EX;
        Timesheet__c TS = New Timesheet__c(PayPeriod_Start__c= System.Today(),PayPeriod_End__c= System.Today()+10);
        Insert TS;
        TS.Status__c = 'Approved';
        update TS;
        Timesheet_Entry__c TSE = New Timesheet_Entry__c(Net_Pay__c = 24,Timesheet__c = TS.ID, Start__c = System.Now().adddays(2), End__c = System.Now().adddays(4), SOE__c = SOE.ID);
        Insert TSE;
    Test.StartTest();
        ApexPages.CurrentPage().getparameters().put('Id', SOE.Id);
        ApexPages.CurrentPage().getparameters().put('SOE_Flag', 'True');
        ProjectBudget_Cntrl PBC1 = New ProjectBudget_Cntrl();
        PBC1.ProjectBudgUpdate();
        PBC1.Close();
        Project_Budget__c PB = New Project_Budget__c(Name = 'PB Test', SOE__c = SOE.ID);
        Insert PB;
        PBC1 = New ProjectBudget_Cntrl();
        PBC1.ProjectBudgUpdate();
        ApexPages.CurrentPage().getparameters().put('Id', PB.Id);
        ApexPages.CurrentPage().getparameters().put('SOE_Flag', 'soerec');
        ProjectBudget_Cntrl PBC = New ProjectBudget_Cntrl();
        PBC.ProjectBudgUpdate();
        PBC.Close();
        PBC.ProjBudg = null;
        pBC.ProjectBudgUpdate();
    Test.StopTest();
    }
}