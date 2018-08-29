/* 
Class Name        : PDF_cntrl 
Test Class Name   : Test_PDF_cntrl
Purpose/Overview  : To export SOE and TAsks to PDF and CSV 
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 

*/
public with sharing class PDF_cntrl {    
    public list<task__c> task{get;set;}           
    public list<soe__c> soelist{get;set;}
    public Id SOEId{get;set;}
    public string displayfields {get;set;}
    public Map<string,string> labelMap{get;set;}
    public list<string> str{get;set;}
    public list<wrapperClass> WrapperList{get;set;}
    public PDF_cntrl (){
        str=new list<string>();
        labelMap = new map<string,string>();
        SOEId = ApexPages.currentPage().getParameters().get('id');  
        displayfields = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('fields')) ;
        WrapperList = new list<wrapperClass>();
        If(Utils.isAccessible('i8__Task__c') && Utils.isAccessible('i8__Dependency__c'))
        task = [select id,Is_Stack__c ,End_Stack__c ,SOE__r.Name,SOE__r.SOE_Title__c,Name,Description__c,Stage_Level__c,Stack_Owner_Name__c,Team__c,Task_Title__c,Stage__c,Start_Time__c,Duration__c,End_Time__c,
        (select id,Dep_Type__c ,Type__c,Dependent_Type__c,Preceeding_Task__r.ID_Text__c,Preceeding_Task__r.Task_Title__c,Preceeding_Task__r.State__c,Preceeding_SOE__r.SOE_Title__c,SOE__r.SOE_Title__c,Preceeding_Task__r.Status__c from Dependencies__r where Preceeding_Task__c != null order by Preceeding_Task__r.ID_Text__c)
        State__c,ID_Text__c,Id_After_Decimal__c,Id_Before_Decimal__c,Soe__c,Status__c from task__c where soe__c =: SOEId and Stage_Level__c = 'Implementation' order by Stage_Level__c ,Id_Before_decimal__c,Id_After_Decimal__c limit 1000];                                     
        for(Task__c tas: task){
            string str1='',str2='';
            for(Dependency__c dep: tas.Dependencies__r){
                if(dep.Dependent_Type__c == 'Predecessors')
                    str1 += dep.Type__c +'-'+dep.Preceeding_Task__r.ID_Text__c+',';
                else 
                    str2 += dep.Type__c +'-'+dep.Preceeding_Task__r.ID_Text__c+',';
            }
            if(str1.length() > 3)
                str1 = str1.substring(0,str1.length()-1);
            if(str2.length() > 3)
                str2 = str2.substring(0,str2.length()-1);
            if(str1 =='')
                str1 = 'None';
            if(str2 == '')
                str2 = 'None';
            WrapperList.add(new WrapperClass(tas,str1,str2));
        }
   }
   public class wrapperClass{
       public task__c tas{get;set;}
       public string Pred{get;set;}
       public string Succ{get;set;}
       public wrapperClass (Task__c tas1, string pre,string suc){
           Tas = tas1; Pred = pre; Succ = suc;
       }
   }     
    public PageReference getfields() {  
        soelist = new List<SOE__c>(); 
        List<String> SplitList = displayfields.split(','); 
        for(string field : SplitList ){         
            if(field == 'I8__programme__r.Name' )
                labelMap.put(field,'Programme');
             else if(field == 'I8__Project__r.Name' )
                labelMap.put(field,'Project');
             else if(field == 'I8__Department__r.name' )
                labelMap.put(field,'Department');
              else if(field == 'I8__QA_Manager__r.name' )
                labelMap.put(field,'QA Manager');   
             else
                 labelMap.put(field,Schema.getGlobalDescribe().get('I8__Soe__c').getDescribe().fields.getMap().get(field).getDescribe().getLabel());
        }
        str.addAll(labelMap.keyset());
        if(UTils.isAccessible('i8__SOE__c')){
            string  soequery1 = 'Select ' + displayfields+' from  I8__Soe__c where id =: SOEId';
            soelist = Database.query(String.escapeSingleQuotes(soequery1)); 
        }
        return null;
    }      
}