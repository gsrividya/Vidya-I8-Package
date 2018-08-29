@istest
public class Test_Expenses_cntrl{
    static Testmethod void  Expenses_cntrl(){
        SOEUtility.SystemSettings_Insert();
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
         user user1 = SOEUtility.user_insert('user--13@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--13@gmail.com'];
        Expense_Claim__c EC = new Expense_Claim__c (From_Date__c =Date.today(),To_Date__c=Date.today()+1,Employee_Name__c='sot',Manager__c=user1.id);
        Insert EC;
        Test.StartTest();
            apexpages.currentpage().getparameters().put('id',EC.id);
            ApexPages.StandardController sc = new ApexPages.StandardController( new Expense_Claim__c ());
            Expenses_cntrl Expen = new Expenses_cntrl(sc);
            Expen.SaveExpenses();
            Expen.WrapperList[0].Exp.Date__c = Date.today()+ 2;
            Expen.WrapperList[0].Exp.Payment_Type__c = 'Card';
            Expen.WrapperList[0].Exp.Expense_Type__c = 'Airfare';
            Expen.WrapperList[0].Exp.Amount__c = 100.0;            
            Expen.SaveExpenses();
            Expen.UpdateLists();
            Expen.AddEntry();
            ApexPages.currentPage().getParameters().put('DeleteId','1'); 
            Expen.DeletEntry();
            ApexPages.currentPage().getParameters().put('DeleteId','0'); 
            Expen.DeletEntry();
            Expen.SaveExpenses();
            Expen.WrapperLIst = null;
            Expen.SaveExpenses();
            Expen.CancelExpenses();         
        Test.StopTest();
        }
}