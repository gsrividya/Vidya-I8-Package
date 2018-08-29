@istest
public class Test_ExportSOE{
    static testmethod void ExportSOE(){
           SOEUtility.SystemSettings_Insert();
        Department__c service1 = SOEUtility.Dep_Insert('Service1');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE1 = SOEUtility.SOE_Insert('newsoeinc',service1.Id,true,true,false,false);
        System.assertEquals(SOE1.SOE_Title__c , 'newsoeinc');
        
        Test.starttest();
            ApexPages.CurrentPage().getparameters().put('Id',soe1.Id); 
            Export_Soe_cntrl ExportSOE = new Export_Soe_cntrl();
            ExportSOE.Select_soe();
            ExportSOE.getleftfields();
            ExportSOE.leftselected=new list<string>();
            ExportSOE.leftselected.add('Pre-Imp Stage');
            ExportSOE.leftselected.add('Post-Imp Stage');
            ExportSOE.leftselected.add('SOE Title');
            ExportSOE.AddFields();                  
            Exportsoe.getRightfileds();
            Exportsoe.Rightselected =new list<string>();
            Exportsoe.Rightselected.add('Pre-Imp Stage');
            Exportsoe.Rightselected.add('Post-Imp Stage');            
            Exportsoe.DeleteFields(); 
            ExportSOE.Export_method();
            ExportSOE.rightlist=new list<string>();
            ExportSOE.rightlist.add('Pre-Imp Stage');
            ExportSOE.rightlist.add('Post-Imp Stage');
            ExportSOE.fieldsdisplay='Pre_Implementation_Stage__c,Post_Implementation_Stage__c'; 
            ExportSOE.selectradio='PDF'; 
            ExportSOE.DownloadSoe_method();
            ExportSOE.selectradio='CSV'; 
            ExportSOE.DownloadSoe_method();
            ExportSOE.close_method();
         //   ExportSOE.Cancel_download();
            ExportSOE.CancelSOE();
            ExportSOE.DownloadSoe='';
            ExportSOE.Select_soe();
            
            ApexPages.CurrentPage().getparameters().put('Page','tab');              
            ExportSOE = new Export_Soe_cntrl();            
            ExportSOE.getSOEOptions();
            ExportSOE.SearchValue ='newsoeinc';
            ExportSOE.SOE_List();
            ExportSOE.DownloadSoe=SOE1.id;
            ExportSOE.SelectedSOEdownload();                      
            ExportSOE.CancelSOE(); 
            ExportSOE.DownloadSoe_method();
            ExportSOE.Clear_search();
        //    ExportSOE.Cancel_download();
            
        Test.stoptest();
    }
}