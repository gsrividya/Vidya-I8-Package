@istest
Public class Test_GanttChart_Cntrl1 {
    Public static i8Constants i8 = new I8Constants();
    Static testmethod void GanttChart_Cntrl1(){
           SOEUtility.SystemSettings_Insert();
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);  
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
        list<Task__c> tas = [select id,Id_Text__c from Task__c where soe__c =: soe.Id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_Decimal__c,Id_After_Decimal__c];      
        Test.StartTest();
            ApexPages.CurrentPage().getparameters().put('Id', soe.Id);
            GanttChart_Cntrl1 Add = new GanttChart_Cntrl1 ();
            GanttChart_Cntrl1.getTasks(soe.Id);
            add.OpenCancel();
        Test.StopTest();
           
    }
}