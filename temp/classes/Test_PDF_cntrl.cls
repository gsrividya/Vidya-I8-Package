@istest
public class Test_PDF_cntrl{
    static testmethod void Test_PDF_cntrl(){ 
           SOEUtility.SystemSettings_Insert();
        Department__c  service1 = SOEUtility.Dep_Insert('Service1');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('newsoetemp343',service1.Id,true,true,false,false); 
        System.assertEquals(SOE.SOE_Title__c , 'newsoetemp343');
        Test.StartTest();
            list<task__c> Tas = [select id,name,Task_Title__c,SOE__c,Id_Before_Decimal__c,Id_After_Decimal__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where SOE__c =: soe.id and Stage__c = 'Pre' order by Id_Before_Decimal__c,Id_After_Decimal__c]; 
             ApexPages.CurrentPage().getparameters().put('SOEId',soe.Id);
            ApexPages.CurrentPage().getparameters().put('Id', TAS[1].Id);
            Add_Task_cntrl Add = new Add_Task_cntrl ();
            ApexPages.CurrentPage().getparameters().put('days', '2');
            ApexPages.CurrentPage().getparameters().put('hours', '2');
            ApexPages.CurrentPage().getparameters().put('minutes', '2');
            ApexPages.CurrentPage().getparameters().put('limitedtextarea1', 'qwerty');
            ApexPages.CurrentPage().getparameters().put('limitedtextarea2', 'qwertyqwerty');
            ApexPages.CurrentPage().getparameters().put('tasktitle', 'task1.1');
            Add.NewTask.Link__c = True;
            Add.CreateTask();
            ApexPages.CurrentPage().getparameters().put('id',SOE.Id); 
            ApexPages.CurrentPage().getparameters().put('fields','I8__Post_Implementation_Stage__c,I8__Pre_Implementation_Stage__c,I8__programme__r.name,I8__Project__r.name,I8__Department__r.name,I8__QA_Manager__r.name');        
            PDF_cntrl pdf=new PDF_cntrl ();
            pdf.getfields();              
        Test.StopTest();    
    }
 }