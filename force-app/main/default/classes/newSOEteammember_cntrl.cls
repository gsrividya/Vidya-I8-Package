/* 
Class Name        : newSOEteammember_cntrl
Test Class Name   : Test_newSOEteammember
Purpose/Overview  : To add/delete Team Members to SOE.
Author            : Purview Ltd.
Code Coverage     : 100%.
Change History    : 
*/
public with sharing class newSOEteammember_cntrl {
    public list<SOE_team_wrapper> wrapperlist{get;set;}
    public id SOEID{get;set;}
    public SOE_Team_Member__c newSOEteammember{get;set;}
    public soe__c soeobj{get;set;}
    public integer entrycount{get;set;}  
    public list<SOE_Team_Member__c> dellist{get;set;} 
    public list<SOE_Team_Member__c> listofteammembers{get;set;}
    public list<SOE_Team_Member__c> Original_SOETlist; 
    Public Map<Id,Id> ImpMgrMap{get;set;}
    public string ImpMgrMapKey{get;set;}
    public Integer MemberId{get;set;}
    public Map<id,Id> ExistedMemberMap ;
    public String errorMessage{get;set;}
    public Boolean error{get;set;}
    
    public newSOEteammember_cntrl() {
        SOEID =ApexPages.currentPage().getParameters().get('id'); 
        if(Utils.isAccessible('i8__SOE__c') && Utils.isAccessible('i8__SOE_Team_Member__c') ){
        Original_SOETlist = new   list<SOE_Team_Member__c>();
        soeobj = [select id,ownerid,QA_Review__c,Walkthrough__c from soe__c where id=:SOEID];   
        wrapperlist = new list<SOE_team_wrapper>();
        dellist=new list<SOE_Team_Member__c>();
        newSOEteammember = new SOE_Team_Member__c();
        newSOEteammember.SOE__c = SOEID;
        integer j=1;        
        ImpMgrMap = new Map<Id,Id>();
        list<string> RolesLIst = System.Label.Roles_To_Edit_SOE.split(',');
        set<string> RolesSet = new set<String>();
        RolesSet.addall(roleslist);             
        listofteammembers =[select id,SOE__c,Team_Member__c,Team_Member__r.Salesforce_User__c,Default_Imp_Manager__c,Access_Level__c,Role__c,Role__r.Reference_Role__c from SOE_Team_Member__c where soe__c=:SOEID order by name];
        for( SOE_Team_Member__c imp : listofteammembers ) {
             Original_SOETlist.add(imp.clone(true,true,false,true)); 
            if(imp.Access_Level__c != 'Read'  && RolesSet.contains(imp.Role__r.Reference_Role__c) )
                ImpMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
        }
        if(Schema.sObjectType.Profile.isAccessible()){
        if([Select Id,Name from Profile where Id=:userInfo.getProfileId()].Name == 'System Administrator')
             ImpMgrMap.put(userInfo.getUserId(),userInfo.getUserId());
        ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', '');
        }
        MaintainTMWraperlist(listofteammembers);
        }else{errormessage = System.Label.ADMIN001;}
    }
    public void MaintainTMWraperlist(list<SOE_Team_Member__c> teammemlist ){
        integer count=0;
        ExistedMemberMap  = new Map<Id,Id>();
        if(Utils.isAccessible('i8__SOE_Team_Member__c'))
        for(SOE_Team_Member__c member: teammemlist){
            ExistedMemberMap.put(member.Team_Member__r.Salesforce_User__C,member.Team_Member__r.Salesforce_User__c);                          
            wrapperlist.add(new SOE_team_wrapper(member,count,member.Team_Member__r.Salesforce_User__c));
            count++;
        }  
    } 
    public pagereference Additem(){
    error = false;
    if( Utils.isCreateable('i8__SOE_Team_Member__c')) { 
    for(SOE_team_wrapper tm:wrapperlist){
          Error  = SOET_Validations(tm.teammember);
          if(Error  == true )
          return null;
        } 
       if(error == false ){
         ExistedMemberMap.clear();        
        for(integer i=0;i<wrapperlist.size();i++){
             ExistedMemberMap.put(wrapperlist[i].SalesforceUser,wrapperlist[i].SalesforceUser);
        }
        SOE_team_wrapper stm= new SOE_team_wrapper(new SOE_Team_Member__c(),wrapperlist.size(),null);
        stm.Teammember.soe__c = SOEID;
        wrapperlist.add(stm);
        }
       }else{errorMessage = System.Label.AddTask006;}               
        return null;
    }
    public pagereference delitem(){
      dellist.clear(); 
        try{  
        for(integer i=0;i<wrapperlist.size();i++){
            if(wrapperlist[i].count==entrycount && wrapperlist[i].teammember.id == null){            
                wrapperlist.remove(i);
            }else if(wrapperlist[i].count==entrycount && wrapperlist[i].teammember.id != null){                      
                dellist.add(wrapperlist[i].teammember);
                wrapperlist.remove(i);                
            }
        }
        list<SOE_team_wrapper> wrapperlist1 = new list<SOE_team_wrapper>();
        ExistedMemberMap.clear();        
        for(integer i=0;i<wrapperlist.size();i++){
             wrapperlist1.add(new SOE_team_wrapper(wrapperlist[i].teammember,i,wrapperList[i].SalesforceUser));
             ExistedMemberMap.put(wrapperlist[i].SalesforceUser,wrapperlist[i].SalesforceUser);
        }
        wrapperlist.clear();
        wrapperlist.AddAll(wrapperlist1);       
        if(dellist.size()>0){
            if(Schema.sObjectType.SOE_Team_Member__c.isDeletable())
                delete dellist;
                else{
                    errormessage = System.Label.AddTask008;
              }        
        }
        }
         catch(Exception e){
               LogFactory.error('newSOEteammember_cntrl ', 'delitem', '', e.getMessage() + '' + e.getStackTraceString());  
               LogFactory.SaveLog(); 
               error = true; errorMessage = e.getMessage();                  
       }
        return null;
    }
    public PageReference Save() {  
        list<SOE_Team_Member__c> TeamMemberList =new list<SOE_Team_Member__c>();
        error=false;
        Boolean displayError = false;
        Savepoint sp = Database.setSavepoint();
        try{
         list<SOE_Team_Member__c> InsertList = new list<SOE_Team_Member__c>();
            list<SOE_Team_Member__c> UpdateList = new list<SOE_Team_Member__c>();            
            for(Integer i=0; i < wrapperlist.size(); i++){
              if(wrapperlist[i].Teammember.Default_Imp_Manager__c == False){
                if(wrapperlist[i].Teammember.Id == null)
                    insertList.add(wrapperlist[i].Teammember);
                else
                    UpdateList.add(wrapperlist[i].Teammember);
               }
            }
            if( Utils.isCreateable('i8__SOE_Team_Member__c')) {
                for(SOE_Team_Member__c tm : InsertLIst){
                    Error  = SOET_Validations(tm);
                    if(Error  == true )
                        return null;
                }  
                if(InsertList.Size() > 0 && Utils.isCreateable('i8__SOE_Team_Member__c'))    
                    insert InsertList;
            }  
            else if(InsertList.Size() > 0){
                displayError = true;
                errorMessage = System.Label.AddTask006;
            }
            list<SOE_Team_Member__c> SOETeamList = new list<SOE_Team_Member__c>();
            if(Utils.isUpdateable('i8__SOE_Team_Member__c')) {  
                for(SOE_Team_Member__c tm : UpdateList){
                   Error  = SOET_Validations(tm);
                    if(Error  == true )
                        return null;
                    else {
                        for(SOE_Team_Member__c SOETlist : Original_SOETlist){
                            if(tm.Id == SOETlist.Id && tm != SOETlist)
                                SOETeamList.add(tm);
                        }                        
                    }                    
                } 
                if(SOETeamList.Size() > 0 && Utils.isUpdateable('i8__SOE_Team_Member__c'))
                    update SOETeamList;
            }  
            else if(SOETeamList.Size() > 0){
                displayError = true;
                errorMessage =    System.Label.AddTask007 ;
            } 
        if(displayError == false ){
            return new pagereference('/'+SOEID);
        }
        }
        catch(Exception e){
                   Database.rollback(sp);
                   LogFactory.error('newSOEteammember_cntrl ', 'Save', '', e.getMessage() + '' + e.getStackTraceString());  
                   LogFactory.SaveLog(); 
                    error = true;
                   errorMessage = e.getMessage();                  
       }
        return null;
    }
     public boolean SOET_Validations(SOE_Team_Member__c tm){
        boolean bool = false;
         if(tm.Role__c == null ){ 
         tm.Role__c.adderror(System.Label.SOETeamMember001);
               bool = true;
            }
            if(tm.Access_Level__c  == null ){
            tm.Access_Level__c.adderror(System.Label.SOETeamMember002); 
               bool = true;
            }
            if(tm.Team_Member__C == null ){
            tm.Team_Member__C.adderror(System.Label.SOETeamMember003); 
               bool = true;
            }
           return bool;
    }
    public PageReference Cancel() {        
        return new pagereference('/'+SOEID);
    }
    public class SOE_team_wrapper{
        public SOE_Team_Member__c Teammember{get;set;}
        public Id SalesforceUser{get;set;}
        public integer count{get;set;}
        public SOE_team_wrapper(SOE_Team_Member__c tm,integer c,Id UserId){
            Teammember=tm; count=c; SalesforceUser = UserId;
        }
    }
    public pagereference HavingSalesforceUser(){
        if(Utils.isAccessible('i8__Member__c')){  
        Id Memberid1 ; 
        Memberid1  = wrapperlist[MemberId].Teammember.Team_Member__c;
        Member__c member = [select id,Salesforce_User__c  from Member__c where Id =: MemberId1 limit 1];
        if(member.Salesforce_User__c == null){
                WrapperList[MemberId].Teammember.Team_Member__c = null;
                errorMessage=System.Label.SOETeamMember005;
               error = true;
        }
        else if(ExistedMemberMap.containskey(member.Salesforce_User__c )){
                WrapperList[MemberId].Teammember.Team_Member__c = null;
                errorMessage=System.Label.SOETeamMember004;
               error = true;
        }
        else
            WrapperList[MemberId].SalesforceUser = member.Salesforce_User__c;
         }else{errormessage = System.Label.AddTask001;}   
        return null;
    }
}