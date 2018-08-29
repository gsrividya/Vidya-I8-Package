@istest
public class Test_view_all_incidents{
    @testSetup static void setup() {
           SOEUtility.SystemSettings_Insert();
           Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
           role = [select id,Reference_Role__c  from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
           System.assertEquals(role.Reference_Role__c , 'Imp Manager');
    }
    static testmethod void View_all_incidents(){ 
        Department__c  service1 = SOEUtility.Dep_Insert('Service1');
        Role__c  Role = [select id,Reference_Role__c  from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
        SOE__c SOE1 = SOEUtility.SOE_Insert('newsoeinc',service1.Id,true,true,false,false);
        MIS__c MIS = SOEUtility.MIS_Insert('MIS');
        SOE1.MIS__c = MIS.id;
        update soe1;
        System.assertEquals(SOE1.SOE_Title__c , 'newsoeinc');
        user user1 = SOEUtility.user_insert('user--1@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--1@gmail.com'];
        Team__c Team1=SOEUtility.Team_insert('sap');
        Team_Member__c Teammember1=SOEUtility.Teammember_insert(member1.id,Team1.id);
        List<Task__c> TaskList = [select id,status__c,Task_Title__c  from Task__C where SOE__c =: SOE1.Id order by Id_Before_Decimal__c,Id_After_decimal__c];      
        Incident__c  inc1=SOEUtility.Incident_insert(soe1.id,tasklist[1].id,soe1.id,'info','open',member1.id);       
        Test.StartTest();
        Apexpages.currentPage().getParameters().put('id',SOE1.id); 
        List_incidents_Cntrl ListIncdents=new List_incidents_cntrl(); 
        ListIncdents.incid=inc1.id;
        ListIncdents.CancelIncidents(); 
        
        Apexpages.currentPage().getParameters().put('id',SOE1.id); 
        TaskList[0].status__c = 'Suspended';
        update TaskList;
        inc1.Task__c = TaskList[0].Id;
        inc1.Inc_Type__c = 'Suspended'; 
        inc1.INC_on_Object__c = 'Task';
        Update inc1;
        ListIncdents = new List_incidents_cntrl(); 
        ListIncdents.incid=inc1.id;
        ListIncdents.edit_inc();
        ListIncdents.edit_inc1();
        ListIncdents.edit_incedent.Status__c = 'Closed'; 
        ListIncdents.save_inc();
        ListIncdents.edit_incedent.Status__c = 'Closed';
        ListIncdents.edit_incedent.Resolution_Type__c = 'RT';
        ListIncdents.save_inc();
        ListIncdents.edit_incedent.Status__c = 'Closed';
        ListIncdents.edit_incedent.Resolution_Type__c = 'RT';
        ListIncdents.edit_incedent.Root_Cause__c = 'RC';
        ListIncdents.save_inc();
        ListIncdents.edit_incedent = null;
        ListIncdents.save_inc(); 
        ListIncdents.CANCEL();

        Apexpages.currentPage().getParameters().put('id',SOE1.id); 
        Apexpages.currentPage().getParameters().put('status','open'); 
        SOE_Team_Member__c stm1 = SOEUtility.teammember_insert(member1.id,'Read',soe1.id,role.id);
        ListIncdents=new List_incidents_cntrl();        
        ListIncdents.CANCEL();
        ListIncdents.edit_incedent.Resolution_Type__c = null; 
    Test.StopTest();
    }
    static testmethod void View_all_incidents1(){
        Test.StartTest(); 
        Department__c  service1 = SOEUtility.Dep_Insert('Service1');
        Role__c  Role = [select id,Reference_Role__c  from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
        SOE__c SOE1 = SOEUtility.SOE_Insert('newsoeinc12',service1.Id,true,true,false,false);
        MIS__c MIS = SOEUtility.MIS_Insert('MIS');
        SOE1.MIS__c = MIS.id;
        update soe1;
        System.assertEquals(SOE1.SOE_Title__c , 'newsoeinc12');    
        Apexpages.currentPage().getParameters().put('Mid',mis.id); 
        List_incidents_cntrl ListIncdents=new List_incidents_cntrl(); 
        ListIncdents.CancelIncidents();
        Test.StopTest();   
    } 
   
}