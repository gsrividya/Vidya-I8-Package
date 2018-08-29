@istest
public class Test_Dependency_TriggerHandler{
  Public static i8Constants i8 = new I8Constants();
        Static testmethod void Dependency_TriggerHandler(){
            SOEUtility.SystemSettings_Insert();
            Department__c  service1 = SOEUtility.Dep_Insert('Service1');
            Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
            SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service1.Id,true,true,false,false);
            System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
            Test.StartTest();
            list<task__c> Tas = [select id,name,Task_Title__c,SOE__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where SOE__c =:soe.id and Stage__c='Imp' order by Id_Before_Decimal__c,Id_After_Decimal__c];
          
             ApexPages.CurrentPage().getparameters().put('SOEId',SOE.Id);
            ApexPages.CurrentPage().getparameters().put('Id', TAS[1].Id);
            Add_Task_cntrl   Add = new Add_Task_cntrl ();
            ApexPages.CurrentPage().getparameters().put('days', '12');
            ApexPages.CurrentPage().getparameters().put('hours', '12');
            ApexPages.CurrentPage().getparameters().put('minutes', '12');
            ApexPages.CurrentPage().getparameters().put('tasktitle', 'T3');
            Add.NewTask.Link__c = true;
            Add.CreateTask();
            Tas = [select id,name,Task_Title__c,SOE__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where SOE__c =:soe.id and Stage__c='Imp' order by Id_Before_Decimal__c,Id_After_Decimal__c];
            ApexPages.CurrentPage().getparameters().put('Id', TAS[1].Id);
            Add = new Add_Task_cntrl ();
            ApexPages.CurrentPage().getparameters().put('days', '12');
            ApexPages.CurrentPage().getparameters().put('hours', '12');
            ApexPages.CurrentPage().getparameters().put('minutes', '16');
            ApexPages.CurrentPage().getparameters().put('tasktitle', 'T4');
            Add.NewTask.Link__c = true;
            Add.CreateTask();
            Tas = [select id,name,Task_Title__c,SOE__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where SOE__c =:soe.id and Stage__c='Imp' order by Id_Before_Decimal__c,Id_After_Decimal__c];
            Dependency__c dep1 = SOEUtility.Dependency_Insert('Link',Tas[2].Id,soe.id,Tas[1].Id,Soe.Id,'Predecessors');
            Dependency__c dep2 = SOEUtility.Dependency_Insert('Link',Tas[1].Id,soe.id,Tas[2].Id,Soe.Id,'Successors');
            list<Dependency__c> deplist = new list<Dependency__c>();
            deplist.add(dep1);
            deplist.add(dep2);
            insert deplist;
            Test.StopTest();            
}
}