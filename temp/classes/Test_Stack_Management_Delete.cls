@istest
Public class Test_Stack_Management_Delete {
    Public static i8Constants i8 = New I8Constants();
    @testSetup static void setup() {
           SOEUtility.SystemSettings_Insert();
           Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
           role = [select id,Reference_Role__c  from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
           System.assertEquals(role.Reference_Role__c , 'Imp Manager');
    }
    Static testmethod void Stack_Mgmt_del1(){
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = [select id,Reference_Role__c  from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
        Role__c  Role1 = SOEUtility.Role_Insert('QA Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);  
        SOE__c SOE1 = SOEUtility.SOE_Insert('SOE---1',service.Id,false,false,false,false);  
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1');       
        list<Task__c> tas = [select id,Id_Text__c from Task__c where soe__c =: soe.Id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_Decimal__c,Id_After_Decimal__c];
       
        Test.StartTest();
            ApexPages.CurrentPage().getparameters().put('page', 'clone');
            ApexPages.CurrentPage().getparameters().put('Id', soe1.Id);
            Stack_Management_Delete SMD = New Stack_Management_Delete();
            ApexPages.CurrentPage().getparameters().put('Id', soe.Id);
            User user1 = SOEUtility.USer_Insert('user--34--@gmail.com');
            Member__c member1 = [select id from Member__c where Email__c ='user--34--@gmail.com'];
            SOE_Team_Member__c stm1 = SOEUtility.teammember_insert(member1.id,'Read',soe.id,role.id);
            SMD = New Stack_Management_Delete();
            //for copy stack
            SMD.getGetSOES();
            SMD.copyStack();
            SMD.taskobj.Task_Title__c = 'New stack 1';
            SMD.selectStack = '1';
            SMD.selectDesStack = '1';
            SMD.copyStack();
            SMD = New Stack_Management_Delete();
            SMD.selectStack = '1';
            SMD.selectDesStack = '1';
            SMD.BAValue = '-';
            SMD.SkipCheck = true;
            SMD.taskobj.Task_Title__c = 'New stack 2';
            SMD.copyStack();
            
            // for drop stack
            SMD.getdeleteitems();
            SMD.selectdeletecon = 'None';
            SMD.deleteStack();
            SMD.selectdeletecon = '4';
            SMD.deletestack();
            SMD.selectdeletecon = '1';
            SMD.deletestack();
        Test.StopTest();
   }
   Static testmethod void Stack_Mgmt_del2(){
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = [select id,Reference_Role__c  from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,true,false,false);   
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1');       
        list<Task__c> tas = [select id,Id_Text__c from Task__c where soe__c =: soe.Id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_Decimal__c,Id_After_Decimal__c];
       
        Test.StartTest();
            ApexPages.CurrentPage().getparameters().put('page', 'clone');
            ApexPages.CurrentPage().getparameters().put('Id', soe.Id);
            Stack_Management_Delete SMD = New Stack_Management_Delete();
            smd.taskobj1.Stage_Level__c = i8.CONTEXT_BO;
            smd.getTargetStages();
            smd.selectdeletecon =null;
            smd.deleteStack();
            smd.openCancel();
        Test.StopTest();
    }
}