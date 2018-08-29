@istest
public class Test_Jump_Stack_Cntrl{
    Public static i8Constants i8 = new I8Constants();
    
    Static testmethod void Jump_Stack_Cntrl(){
           SOEUtility.SystemSettings_Insert();
        Department__c  service1 = SOEUtility.Dep_Insert('Service1');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service1.Id,false,false,false,false);
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
        SOE__c SOE1 = SOEUtility.SOE_Insert('SOE--11',service1.Id,true,true,false,false);
        list<task__c> Tas = [select id,name,Task_Title__c,SOE__c,Id_Before_Decimal__c,Id_Text__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where SOE__c =:soe.id and Is_Stack__c = True order by Id_Before_Decimal__c];
        test.starttest();
         User user1 = SOEUtility.USer_Insert('user--30--@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--30--@gmail.com'];
        SOE_Team_Member__c stm1 = SOEUtility.teammember_insert(member1.id,'Read',soe.id,role.id);
        ApexPages.CurrentPage().getparameters().put('Id', SOE.Id);
        Stack_CreateMove_Cntrl Stack_Create = new Stack_CreateMove_Cntrl();
        Stack_Create.TargetStage = I8.STAGE_IMP;
        Stack_Create.TargetStack = Tas[0].Id_Text__c; 
        ApexPages.CurrentPage().getparameters().put('days', '2');
        ApexPages.CurrentPage().getparameters().put('hours', '2');
        ApexPages.CurrentPage().getparameters().put('minutes', '2');
        ApexPages.CurrentPage().getparameters().put('tasktitle', 'T2');
        Stack_Create.CreateStack();
        Tas = [select id,name,Task_Title__c,SOE__c,Id_Before_Decimal__c,Id_Text__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where SOE__c =:soe.id  order by Id_Before_Decimal__c,Id_After_decimal__c];
        tas[0].Status__c = i8.STATUS_RUNNING;
        update tas[0];
        jump_stack_cntrl Jump = new jump_stack_cntrl ();
        Jump.SourceStage = I8.STAGE_IMP;
        Jump.selected_Stack = string.valueOf(Tas[0].Id_Before_Decimal__c);
        Jump.jump_stack();
        Jump.selected_Stack = string.valueOf(Tas[3].Id_Before_Decimal__c);
        Jump.jump_stack();        
        jump.openCancel();
        ApexPages.CurrentPage().getparameters().put('Id', SOE1.Id);
        jump_stack_cntrl Jump1 = new jump_stack_cntrl ();
        Jump1.SourceStage = I8.STAGE_IMP;
        Jump1.selected_Stack = string.valueOf(Tas[0].Id_Before_Decimal__c);
        Jump1.jump_stack();
        Jump1.SOEObj = null;
        Jump1.jump_Stack();
        test.stoptest();
    }
}