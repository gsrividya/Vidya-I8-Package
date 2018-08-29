@istest
public class Test_SOEPageHeader{
     Static testmethod void SOEPageHeader(){
           SOEUtility.SystemSettings_Insert();
         Department__c service = SOEUtility.Dep_Insert('Service2');
         Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
         SOE__c SOE = SOEUtility.SOE_Insert('SOE1',service.Id,true,true,false,false);
         MIS__c MIS = SOEUtility.MIS_Insert('MIS');
         System.assertEquals(SOE.SOE_Title__c , 'SOE1');
         
         Test.starttest();
           SOEPageHeader SOEPageheader= new SOEPageHeader ();  
           SOEPageheader.SOEId='SOE.id';
           SOEPageheader.getSOE();
         
           SOEPageheader= new SOEPageHeader ();
           SOEPageheader.SOEId='MIS.id';
           SOEPageheader.getMIS();
         Test.stoptest();
         
    }
}