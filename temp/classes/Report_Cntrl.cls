/* 
Class Name        : Report_Cntrl 
Test Class Name   : Test_SOE_DashBoards_Cntrl
Purpose/Overview  : To open a Report when click on dashboard in SOE Dashboards page 
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 

*/

public with sharing class Report_Cntrl {
    public string reportURL{get;set;}    
    public Report_Cntrl (){
        string reportid =  ApexPAges.CurrentPAge().getPArameters().get('reportid');
        string params1 =  ApexPAges.CurrentPAge().getPArameters().get('pc0');
        string params2 =  ApexPAges.CurrentPAge().getPArameters().get('pn0');
        string params3 =  ApexPAges.CurrentPAge().getPArameters().get('pv0');
        string params4 =  ApexPAges.CurrentPAge().getPArameters().get('pv1');
        reportURL = reportid;
        if(params1 != null)
            reportURL += '?pc0='+params1 ;
        if(params2 != null)
            reportURL += '&pn0='+params2;
        if(params3 != null)
            reportURL += '&pv0='+params3;
        if(params3 != null && params1 == null && params2== null) 
            reportURL = reportid+'?pv0='+params3; 
        if(params4 != null)
           reportURL = reportid+'?pv0='+params3+'&pv1='+params4;       
    }
}