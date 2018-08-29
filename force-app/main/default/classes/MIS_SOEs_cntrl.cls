/* 
Class Name        : MIS_SOEs_cntrl 
Test Class Name   : Test_MIS_SOEs_cntrl
Purpose/Overview  : To Add SOE's to MIS 
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 

*/
public with sharing class MIS_SOEs_cntrl {
    public list<id> selectedrightSOE { get; set; }
    public list<id> selectedleftSOE { get; set; }
    public id misid{get;set;} 
    public MIS__c misobj{get;set;}
    public list<id> rightSOEs{get;set;}
    public list<id> leftSOEs{get;set;}
    public list<SOE__c> soelist{set;get;}
    public map<id,string> soe_map{set;get;}
    public map<id,SOE__c> Update_Soe_map{set;get;}
    public string search_SOE{get;set;}
    public set<Id> SOEIdsList = new set<Id>();
    public string errormessage{get;set;}
    public boolean errorbool{get;set;}
    
    public MIS_SOEs_cntrl(){
        errorbool = false;
        misid = apexpages.currentpage().getparameters().get('id');
        leftSOEs = new list<id>();
        rightSOEs = new list<id>();
        soelist = new list<SOE__c>();
        selectedrightSOE = new list<id>();
        selectedleftSOE = new list<id>();
        soe_map = new map<id,string>();
        Update_Soe_map = new map<id,Soe__c>();
        if(Utils.isAccessible('I8__MIS__c') && Utils.isAccessible('I8__SOE__c')){
        misobj =[select id,name from MIS__c where id=:misid];       
        search_SOE=''; 
        search_Action();
        }else{errorbool = true;errormessage = System.Label.Admin001;}
    }  
    public list<selectoption> getLeftSOE() {            
        list<selectoption> leftsoeoptions = new list<selectoption>(); 
        string queryString = '';       
        if(leftSOEs.size()>0){
            for(string s: leftSOEs)
                leftsoeoptions.add(new selectoption(s,soe_map.get(s)));
        }         
        return leftsoeoptions;
    }    
    public list<selectoption> getRightSOE() {          
        list<selectoption> rightsoeoptions = new list<selectoption>();
        if(soe_map.size()>0){
            for(string s: rightSOEs)
                rightsoeoptions.add(new selectoption(s,soe_map.get(s)));
        }    
        return rightsoeoptions;     
    }       
    public void AddAllSOEs() {   
        errorbool = false;  
        rightSOEs.addAll(leftSOEs);
        leftSOEs.clear();       
    }    
    public void refreshList() {
        errorbool = false;
        rightSOEs.clear();
        leftSOEs.clear();
        leftSOEs.addAll(soe_map.keyset());        
    }  
    public void addSOE() {
        errorbool = false;
        if(selectedleftSOE.size()>0){
            rightSOEs.addAll(selectedleftSOE);
            for( integer i=0; i<leftSOEs.Size(); i++){
                for(Id j: selectedleftSOE){
                    if(leftSOEs[i] == j)
                        leftSOEs.remove(i);
                }
            }
        }
        
    }  
    public void removeSOE() {
        errorbool = false;
        if(selectedrightSOE.size()>0){
            leftSOEs.addAll(selectedrightSOE);
            for( integer i=0; i<rightSOEs.Size(); i++){
                for(Id j:selectedrightSOE){
                    if(rightSOEs[i] == j)
                        rightSOEs.remove(i);
                }
            }
        }       
    }
    public void removeAllSOEs() {
        errorbool = false;
        if(rightSOEs.size()>0){
            leftSOEs.addAll(rightSOEs);
            rightSOEs.clear();            
        }        
    }      
    public PageReference search_Action() {
      if(Utils.isAccessible('I8__SOE__c')){
        errorbool = false;
        if(search_SOE==''){
            soelist = [select id,Name,SOE_Title__c,Summary__c,Schedule_End__c,MIS__c,Schedule_Start__c,Max_Planned_End__c,Min_Planned_Start__c  from SOE__c WHERE MIS__c = NULL and is_template__c =: false and QA_Review__c != 'In Progress' and Walkthrough__c != 'In Progress' order by name desc]; 
        }
        else{
            String SearchValue ='%'+search_SOE+'%';
            soelist = [select id,Name,SOE_Title__c,Summary__c,Schedule_End__c,MIS__c,Schedule_Start__c from SOE__c WHERE MIS__c = NULL and (SOE_Title__c Like: SearchValue or Name Like : SearchValue ) and is_template__c =: false and QA_Review__c != 'In Progress' and Walkthrough__c != 'In Progress'and Id NOT IN:rightSOEs order by name];
        } 
        if(soelist.size()>0){
            leftSOEs.clear();
            set<id> rightSet = new set<Id>();
            rightSet.AddAll(rightSOEs);
            for(SOE__c s: soelist){
                soe_map.put(s.id,s.name+':'+s.SOE_Title__c);
                Update_Soe_map.put(s.Id,s);
                if(!rightSet.contains(s.id))
                    leftSOEs.add(s.id);               
            }
        }
        Else{
            errorbool = true;
            errormessage = 'No SOE found with \''+search_SOE+'\'.';
        }
       }else{errorbool = true;errormessage = System.Label.Admin001;}
        return null;       
    }    
    public PageReference Apply_method() {
    if(Utils.isUpdateable('i8__MIS__c')  && Utils.isUpdateable('i8__SOE__c') && Utils.isAccessible('I8__MIS_Manager__c')){
        list<SOE__c> Update_Soelist = new list<SOE__c>();
         misobj.SOEs__c ='';
         Integer count =0;
        if(rightSOEs.size() > 0){            
            for(id i: rightSOEs){
                Update_Soe_map.get(i).MIS__c = MISOBJ.ID;
                misobj.SOEs__c += Update_Soe_map.get(i).Name;
                if(rightSOEs.Size()-1 != Count)
                    misobj.SOEs__c += ',';
                count++;
                Update_Soelist.add(Update_Soe_map.get(i));
            }
            Savepoint sp = Database.setSavepoint();
            try{ 
                if(Update_Soelist.size()>0){
                    LogFactory.debug('MIS_SOEs_cntrl', 'Apply_method', 'SOE LIst', 'SOE List selected ' ,'Line - 140'); 
                    if(Utils.isUpdateable('i8__MIS__c'))
                        update misobj;
                    rightSOEs.clear();                  
                    if(Utils.isUpdateable('i8__SOE__c'))  
                        update Update_Soelist;
                    errorbool = true;
                    errormessage = System.Label.EditStack010;
                }
            }
            catch(Exception e){
                   Database.rollback(sp);
                   LogFactory.error('MIS_SOEs_cntrl', 'Apply_method', '', e.getMessage() + '' + e.getStackTraceString());                  
                   errorbool = true;
                   errormessage = e.getMessage();                 
            }
             LogFactory.SaveLog(); 
        }  
        else{
            errorbool = true;
            errormessage = System.Label.CloneSOE007 ;
        }
       }else{errorbool = true;errormessage = System.Label.AddTask007;}   
        return null;
    } 
     public pagereference cancel_method(){
            if(UserInfo.getUiThemeDisplayed() == 'Theme3')
                return new PageReference('javascript:window.close()');
            else
                return new pagereference('/'+misId);
    }    
}