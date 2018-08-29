@istest
public class Test_SOE_MyView_cntrl{
  Public static i8Constants i8 = new I8Constants();
        Static testmethod void SOE_MyView_cntrl(){
             SOEUtility.SystemSettings_Insert();
        Test.StartTest(); 
            Department__c  service1 = SOEUtility.Dep_Insert('Service1');
            Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
            SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service1.Id,true,true,false,false);
            MIS__c MIS = SOEUtility.MIS_Insert('MIS');
            System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
            list<task__c> Tas = [select id,name,Task_Title__c,SOE__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where SOE__c =:soe.id];

            ApexPages.CurrentPage().getparameters().put('id',MIS.id); 
            SOE_MyView_cntrl MyView= new  SOE_MyView_cntrl();
            MyView.getObjectFields();
            MyView.leftselected.add('Actual Start');
            MyView.leftselected.add('Actual Duration');
            MyView.leftselected.add('Actual_End');
            MyView.Rightselected.add('Actual Start'); 
            MyView.Rightselected.add('Actual Duration');
            MyView.Rightselected.add('Actual_End');
            MyView.rightlist.add('Actual Start');
            MyView.rightlist.add('Actual Duration');
            MyView.rightlist.add('Actual_End');
            MyView.getrightFields();                  
            MyView.save();
            MyView.Cancel();

            ApexPages.CurrentPage().getparameters().put('id',soe.id); 
            MyView = new  SOE_MyView_cntrl();
            MyView.getObjectFields();
      
            MyView.leftselected.add('Actual Start');
            MyView.leftselected.add('Actual Duration');
            MyView.leftselected.add('Actual_End');
            MyView.Rightselected.add('Actual Start'); 
            MyView.Rightselected.add('Actual Duration');
            MyView.Rightselected.add('Actual_End');
            MyView.rightlist.add('Actual Start');
            MyView.rightlist.add('Actual Duration');
            MyView.rightlist.add('Actual_End');
            MyView.getrightFields();                  
                      
            MyView.AddFields();
            MyView.removefields();
            MyView.save();
            MyView.Cancel();
            MyvIew.SOEId = null;
            MyView.save();
           
          Test.StopTest(); 
            }
          
                 }