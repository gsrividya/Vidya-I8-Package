/* 
Class Name        : View_All_Documents_Cntrl 
Test Class Name   : Test_View_All_Documents
Purpose/Overview  : To display the attachments for tasks with in that SOE. 
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 

*/
public with sharing class View_All_Documents_Cntrl {
    public list<task__C> tasklist{get;set;}
    public id Soeid{get;set;}    
    public list<SOE__c>  MISSOE_list{get;set;}
    public Set<Id> SOEIds{get;set;}
    public string SOEIdstring{get;set;}
    public list<wrapperclass> DocummentsList{get;set;}
    public boolean SOE{get;set;}
    
    public View_All_Documents_Cntrl(){
        DocummentsList = new list<wrapperclass>();
        Soeid = apexpages.currentpage().getparameters().get('id'); 
        SOEIds = new set<id>();      
        SOEIdstring = string.valueof(Soeid);        
        if(SOEIdstring.substring(0,3) == SOE__c.sobjecttype.getDescribe().getKeyPrefix()){
            SOE = true;
            SOEIds.add(SOEID);
        }
        else if(SOEIdstring.substring(0,3) == MIS__c.sobjecttype.getDescribe().getKeyPrefix()){
            SOE = False;
            if(Utils.isAccessible('i8__SOE__c')){
                MISSOE_list=[select id,MIS__c from SOE__c where MIS__c=:SOEID];            
                for(SOE__c MISESOE : MISSOE_list)
                    SOEIds.add(MISESOE.id);
            } 
        }
        if(Utils.isAccessible('i8__Task__c') && Schema.SobjectTYpe.Attachment.isAccessible()) {
            tasklist=[select id,Task_Title__c,Soe__r.Name,Soe__c,(select id,name,BodyLength,ownerid,createddate from attachments) from task__C where Soe__c IN: SOEIds order by Id_Before_Decimal__c,Id_After_Decimal__c];
        for(task__c tas:tasklist){
            for(attachment atth:tas.attachments)  
                DocummentsList.add(new wrapperclass(tas.Soe__r.Name,tas,atth));  
        } 
        }    
    }
    public class wrapperclass {
       public string soe{get;set;}
       public Task__c task{get;set;}
       public Attachment Att{get;set;}
       public wrapperclass(string soe1,Task__c  tas, Attachment att){
           this.soe = soe1;
           this.task = tas;
           this.Att = att;
       }
    } 
   public pagereference CancelTask(){          
        if(SOE == false)
            return new pagereference ('/apex/MIS_AllTasks?id='+SOEId);  
        else  
            return new pagereference ('/apex/AllTasks_ClientSide?id='+SOEId);
    }  
}