@istest
Public class Test_SOEResource_Gantt_Cntrl {
    Public static i8Constants i8 = new I8Constants();
    @testSetup static void setup() {
           SOEUtility.SystemSettings_Insert();
           Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
           role = [select id,Reference_Role__c  from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
           System.assertEquals(role.Reference_Role__c , 'Imp Manager');
    }
    Static testmethod void Import_ROTA_cntrl1(){
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c role = [select id,Reference_Role__c  from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);        
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
        Test.StartTest();
            ApexPages.CurrentPage().getparameters().put('Id', soe.Id);
            SOEResource_Gantt_Cntrl Add = new SOEResource_Gantt_Cntrl ();
            SOEResource_Gantt_Cntrl.getTasks(soe.Id);
            Add.CancelPage();
        Test.StopTest();
    }
    Static testmethod void SOEResource_Gantt_Cntrl1 (){
        test.StartTest();
        MIS__c mis = SOEUtility.MIS_Insert('MIS insetrt1');
        System.assertEquals(mis.MIS_Title__c, 'MIS insetrt1');
        Department__c service = SOEUtility.Dep_Insert('Service2');
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1111',service.Id,true,true,false,false);  
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1111');
        list<Task__c> tas = [select id,Id_Text__c from Task__c where soe__c =: soe.Id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_Decimal__c,Id_After_Decimal__c];
        SOE.MIS__c = mis.id;
        update soe;
        ApexPages.CurrentPage().getparameters().put('MId', mis.Id);
        SOEResource_Gantt_Cntrl All = new SOEResource_Gantt_Cntrl ();
        SOEResource_Gantt_Cntrl.getTasks(mis.Id);
        All.CancelPage();
        Test.StopTest();
      
    }
}