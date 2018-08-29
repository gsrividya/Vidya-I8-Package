@isTest
public class Test_Access_Request_Cntrl{
    static Testmethod void Add_AccessRequest_LineItems_Cntrl(){
    
        Test.StartTest();
        SOEUtility.SystemSettings_Insert();
        Department__c  service1 = SOEUtility.Dep_Insert('Service1');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        user user1 = SOEUtility.user_insert('user--11@gmail.com');
        Member__c member = [select id from Member__c where Email__c ='user--11@gmail.com'];
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1dadsd',service1.Id,true,true,false,false);  
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1dadsd');
        Access_Request__c AR = new Access_Request__c(SOE__c = SOE.ID, Start_Time__c = System.today().adddays(2), End_Time__c = System.today().adddays(4));
        Insert AR;
        ApexPages.CurrentPage().getparameters().put('Id', AR.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Access_Request__c());
        Add_AccessRequest_LineItems_Cntrl ARLI = new Add_AccessRequest_LineItems_Cntrl(sc);
        arli.WrapperList[0].ARLI.Access_Request_Type__c = 'Other';
        arli.WrapperList[0].ARLI.Environment__c = 'Other' ;
        arli.WrapperList[0].ARLI.Access_Type__c = 'Other' ;
        arli.SaveLineItems();
        arli.WrapperList[0].ARLI.Start_Time__c = System.Today();
        arli.WrapperList[0].ARLI.End_Time__c = System.Today().addDays(2);
        arli.SaveLineItems();
        arli.WrapperList[0].ARLI.Start_Time__c = System.Today();
        arli.WrapperList[0].ARLI.End_Time__c = System.Today().addDays(-2);
        arli.SaveLineItems();
        arli.EntryCount  =0;
        arli.DeleteRow();
        arli.AddRow();
        arli.WrapperList[0].ARLI.Start_Time__c = System.Today().adddays(2);
        arli.WrapperList[0].ARLI.End_Time__c = System.Today().addDays(3);
        arli.WrapperList[0].ARLI.Requested_User__c = UserInfo.getUSerId();
        arli.SaveLineItems();
        Access_Request_Line_Item__c ARLI1 = New Access_Request_Line_Item__c(Access_Request_ID__c = AR.ID, Start_Time__c = System.today().adddays(1), End_Time__c = System.today().adddays(3));
        Insert ARLI1;
        ARLI = new Add_AccessRequest_LineItems_Cntrl(sc);
        arli.EntryCount =0;
        arli.DeleteRow();
        arli.SaveLIneItems();     
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setComments('Approve.');
        app.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        app.setObjectId(AR.Id);
        Approval.ProcessResult result = Approval.process(App);
        arli = new Add_AccessRequest_LineItems_Cntrl(sc);
        arli.AddRow();
        arli.EntryCount  =0;
        arli.DeleteRow();
        arli.CancelPage();
        Test.StopTest();
 
    }
}