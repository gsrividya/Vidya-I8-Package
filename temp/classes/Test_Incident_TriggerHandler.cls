@istest
public class Test_Incident_TriggerHandler{
    static testmethod void Incident_TriggerHandler(){
           SOEUtility.SystemSettings_Insert();
        Department__c  service1 = SOEUtility.Dep_Insert('Service1');
        SOE__c SOE1 = SOEUtility.SOE_Insert('newsoeinc',service1.Id,true,true,false,false);
        System.assertEquals(SOE1.SOE_Title__c , 'newsoeinc');
         user user1 = SOEUtility.user_insert('user--14@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--14@gmail.com'];
        List<Task__c> TaskList = [select id,status__c,Task_Title__c  from Task__C where SOE__c =: SOE1.Id order by Id_Before_Decimal__c,Id_After_decimal__c];      
        Incident__c  inc1=SOEUtility.Incident_insert(soe1.id,tasklist[1].id,soe1.id,'info','open',member1.id);       
        Test.StartTest();
        Inc1.Status__c = 'Closed';
        Update Inc1;
        Test.StopTest();   
    }
   
}