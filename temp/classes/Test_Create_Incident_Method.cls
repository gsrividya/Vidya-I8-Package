@istest
public class Test_Create_Incident_Method{
    public static i8Constants i8 = new I8Constants();
    public static boolean ReExecute;   
    static testmethod void Create_Incident(){ 
        SOEUtility.SystemSettings_Insert();
        MIS__c mis = SOEUtility.MIS_Insert('MIS_Testing');
        Department__c service1 = SOEUtility.Dep_Insert('Service1');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE1 = SOEUtility.SOE_Insert('newsoeinc',service1.Id,true,true,false,false);  
        System.assertEquals(SOE1.SOE_Title__c , 'newsoeinc');
        user user1 = SOEUtility.user_insert('user--10@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--10@gmail.com'];        
        SOE_Team_Member__c stm1 = SOEUtility.teammember_insert(member1.id,'Read',soe1.id,role.id);
        List<Task__c> TaskList = [select id,status__c,Task_Title__c  from Task__C where SOE__c =: SOE1.Id order by Id_Before_Decimal__c,Id_After_decimal__c];
        Test.StartTest();
        
       ApexPages.CurrentPage().getparameters().put('SOEId',soe1.Id); 
        Create_Incident inc = new Create_Incident();  
        inc.cancel_INC();        
        ApexPages.CurrentPage().getparameters().put('MId',mis.Id);
        inc = new Create_Incident();  
        inc.cancel_INC();
        
        inc = new Create_Incident(); 
        inc.INCOBJ.Inc_Type__c =null;
        inc.save_INC();
        
        inc.INCOBJ.Inc_Type__c ='Bug';
        inc.INCOBJ.Summary__c='hii';
        inc.INCOBJ.Priority__c = 'Low';
        inc.save_INC();  
        inc.Add_Note ='incident';
        inc.Add_Note_Action();
        
        //SOE Suspend,ReExecute,Abandoned. 
        ApexPages.CurrentPage().getparameters().put('SOEId',soe1.Id);  
        ApexPages.CurrentPage().getparameters().put('type', 'Abandoned');
        inc = new Create_Incident();
        inc.INCOBJ.Summary__c = 'Summary';
        inc.INCOBJ.Inc_Type__c = 'Abandoned';
        inc.INCOBJ.Priority__c = 'Low';
        inc.save_INC();
        ApexPages.CurrentPage().getparameters().put('type', 'Suspend');
        inc = new Create_Incident();
        inc.save_INC();
        ApexPages.CurrentPage().getparameters().put('type', 'Suspend');
        inc = new Create_Incident(); 
        inc.INCOBJ.Summary__c='hii';
        inc.INCOBJ.Priority__c = 'Low'; 
        inc.INCOBJ.Assignee__c=member1.id; 
        inc.save_INC();
        ApexPages.CurrentPage().getparameters().put('type', 'ReExecute');
        inc = new Create_Incident(); 
        inc.INCOBJ.Summary__c='hii';
        inc.INCOBJ.Priority__c = 'Low'; 
        inc.INCOBJ.Assignee__c=member1.id; 
        inc.save_INC();
        
        ApexPages.CurrentPage().getparameters().put('TAskId',TaskList[1].Id);
        ApexPages.CurrentPage().getparameters().put('type', 'Suspend');
        inc = new Create_Incident(); 
        inc.INCOBJ.Summary__c='hii';
        inc.INCOBJ.Priority__c = 'Low'; 
        inc.INCOBJ.Assignee__c=member1.id;
        inc.save_INC();
        ApexPages.CurrentPage().getparameters().put('type', 'ReExecute');
        inc = new Create_Incident(); 
        inc.INCOBJ.Summary__c='hii';
        inc.INCOBJ.Priority__c = 'Low';
        inc.INCOBJ.Inc_Type__c ='Suspended'; 
        inc.INCOBJ.Assignee__c=member1.id; 
        inc.save_INC();
        Test.stoptest();
        ApexPages.CurrentPage().getparameters().put('type', 'Force');
        inc = new Create_Incident();         
        inc.INCOBJ.Priority__c = 'Low';
        inc.INCOBJ.Summary__c='hii';
        inc.INCOBJ.Inc_Type__c ='Suspended'; 
        inc.INCOBJ.Assignee__c=member1.id; 
        inc.save_INC();
        ApexPages.CurrentPage().getparameters().put('TAskId',null);
        ApexPages.CurrentPage().getparameters().put('type', 'backout');
        inc = new Create_Incident();         
        inc.INCOBJ.Priority__c = 'Low';
        inc.INCOBJ.Summary__c='hii';
        inc.INCOBJ.Inc_Type__c ='Suspended'; 
        inc.INCOBJ.Assignee__c=member1.id; 
        inc.save_INC();
        ApexPages.CurrentPage().getparameters().put('TAskId',TaskList[1].Id);
        ApexPages.CurrentPage().getparameters().put('type', 'ReExecute');
        inc = new Create_Incident();         
        inc.INCOBJ.Priority__c = 'Low';
        inc.INCOBJ.Summary__c='hii';
        inc.INCOBJ.Inc_Type__c ='Suspended'; 
        inc.INCOBJ.Assignee__c=member1.id; 
        inc.save_INC();
        ApexPages.CurrentPage().getparameters().put('TAskId',null);
        ApexPages.CurrentPage().getparameters().put('MId',mis.Id);
        inc.save_INC();
        
        ApexPages.CurrentPage().getparameters().put('MId',null);
        ApexPages.CurrentPage().getparameters().put('TAskId',TaskList[1].Id);
        Create_Incident incident = new Create_Incident(); 
        incident.cancel_INC();
        ApexPages.CurrentPage().getparameters().put('SOEId',null);
        ApexPages.CurrentPage().getparameters().put('MId',mis.Id);
        ApexPages.CurrentPage().getparameters().put('TAskId',TaskList[1].Id);
        incident = new Create_Incident(); 
        incident.cancel_INC();
        
        
    } 
}