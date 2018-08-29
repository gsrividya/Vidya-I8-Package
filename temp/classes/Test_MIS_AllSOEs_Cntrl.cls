@istest
Public class Test_MIS_AllSOEs_Cntrl {
    Public static i8Constants i8 = new I8Constants();
    Static testmethod void MIS_MIS_SOEs_cntrl1(){
        SOEUtility.SystemSettings_Insert();
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
        MIS__c mis1 = SOEUtility.MIS_Insert('dds');
        Test.StartTest();
            ApexPages.CurrentPage().getparameters().put('Id', mis1.Id);
           soe.MIS__c = mis1.id;
           update soe;              
            MIS_AllSOEs_Cntrl mis= new MIS_AllSOEs_Cntrl();
            soe.Status__c = i8.STATUS_FREEZE;
            update soe;
            mis.Execute();
            
            list<task__c> Tas = [select id,name,Task_Title__c,SOE__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where SOE__c =: SOE.id order by Id_Before_Decimal__c,Id_After_Decimal__c];
            Tas[0].Status__c = i8.STATUS_COMPLETED;
            update tas[0];
            mis= new MIS_AllSOEs_Cntrl();
            mis.Execute();
            
            soe.Schedule_Start__c = System.Now()+1;
            update soe;
            mis= new MIS_AllSOEs_Cntrl();
            mis.Execute();
            
            soe.Status__c = i8.STATUS_IMPINPROGRESS;
            update soe;
            mis= new MIS_AllSOEs_Cntrl();
            mis.Execute();
            mis.Cancel();
            mis.SOEList1 = null;
            mis.Execute();
        Test.StopTest();
   }
}