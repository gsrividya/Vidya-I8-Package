/* 
Class Name        : Import_ROTA_cntrl 
Test Class Name   : Test_Import_ROTA_Cntrl
Purpose/Overview  : To import ROTA from CSV File. 
Author            : Purview Ltd.
Code Coverage     : 98%
Change History    : 

*/
public with sharing class Import_ROTA_cntrl { 
    public string nameFile{get;set;}
    public Transient Blob contentFile{get;set;}
    public String[] filelines = new String[]{};
    public List<ROTA__c> taskupload{get;set;}
    public list<wrapperclass>Rotawraplist{get;set;}
    public set<string> Soestrings{get;set;}
    Public list<string> RotaName{get;set;}
    public string SoeName{get;set;}
    public Set<string> SoeStringslist1{get;set;}
    public map<string,id>Soemap{get;set;}
    
    public Import_ROTA_cntrl(){
        filelines = new String[]{};
            Rotawraplist = new list<wrapperclass>();
        Soestrings= new set<string>();
        RotaName = New List<string>();
        Soemap= new map<string,id>();
        SoeStringslist1= new Set<string>();
    }    
    public Pagereference ReadFile(){
        Savepoint sp = Database.setSavepoint();
        try{
            if(Utils.isCreateable('i8__ROTA__c')){
            String filetypeExtension = '.csv';
            if(nameFile !=null && filetypeExtension.contains(nameFile.substringAfterLast('.'))){   
                SoeStringslist1.clear();
                if(contentFile == null){
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.ROTAImport001);
                    ApexPages.addMessage(errormsg);
                    return null; 
                }
                nameFile=contentFile.toString();
                filelines = nameFile.split('\n');            
                taskupload = new list<ROTA__c>();
                for (Integer i=2;i<filelines.size();i++){
                    String[] inputvalues = new String[]{};
                        inputvalues = filelines[i].split(',');
                    ROTA__c rota= new ROTA__c();
                    if(inputvalues[0] != null && inputvalues[0] !='')
                        SoeName=inputvalues[0].toUpperCase();               
                    if(inputvalues[0]=='' || inputvalues[0]==' ')
                        SoeName=null;
                    rota.Name__c = inputvalues[1];  
                    rota.Email__c = inputvalues[2];  
                    rota.Mobile__c = inputvalues[3]; 
                    rota.Desk_Phone__c = inputvalues[4];
                    rota.Location__c = inputvalues[5];  
                    rota.Secondary_Name__c = inputvalues[6]; 
                    rota.Secondary_Mail__c = inputvalues[7];
                    rota.Secondary_Mobile__c = inputvalues[8];  
                    rota.Secondary_DeskPhone__c = inputvalues[9];
                    rota.Manager_Name__c = inputvalues[10];
                    rota.Manager_Email__c = inputvalues[11];  
                    rota.Manager_Mobile__c = inputvalues[12]; 
                    rota.Manager_DeskPhone__c = inputvalues[13];
                    rota.Shift_Type__c = inputvalues[14];
                    if(inputvalues[15] != null && inputvalues[15] !='' && inputvalues[15] !=' '){
                        rota.Start_Date__c = DateTime.valueof(inputvalues[15]);
                    }
                    if(inputvalues[16] != null && inputvalues[16] !=''&& inputvalues[16] !=' ') {
                        rota.End_Date__c = DateTime.valueof(inputvalues[16]);  
                    }
                    rota.Vendor__c = inputvalues[17]; 
                    rota.Comments__c = inputvalues[18];  
                    rota.Application__c = inputvalues[19]; 
                    Rotawraplist.add(new wrapperclass(SoeName,rota));
                    
                    Soestrings.add(SoeName);
                    
                    RotaName.add(rota.Name__c);
                }
                if(Utils.isAccessible('I8__SOE__c'))
                for(Soe__c soe:[select Name,id from Soe__c where Name Like : Soestrings]){
                    Soemap.put(soe.Name,soe.id);
                }
                for(wrapperclass wc : Rotawraplist){
                if(Soemap.size() > 0){   
                    for(String Str : Soestrings) {
                        if(Str != '' && Str != null && !Soemap.containskey(Str )){
                            SoeStringslist1.add(Str);   
                        }
                        else{
                            if(Str != null && Soemap.containskey(Str )){
                                wc.rotarec.Soe__c = Soemap.get(wc.Sname);
                            } 
                            else if( Str == null &&  wc.rotarec.Soe__c ==null){
                                wc.rotarec.Soe__c=null;
                            }
                        }
                      }
                   }
                    taskupload.add(wc.rotarec); 
                }
                For(Integer i=0; i<RotaName.size(); i++){
                    If(RotaName[i] == '' ||RotaName[i] == ' ' || RotaName[i] == null){
                        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.ROTAImport002);
                        ApexPages.addMessage(errormsg);
                        return null;     
                    }
                }
                if(SoeStringslist1.size()>0){
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,+SoeStringslist1+' '+System.Label.ROTAImport003);
                    ApexPages.addMessage(errormsg);   
                    Rotawraplist.clear();
                    Soestrings.clear();
                    return null;     
                }
                if(taskupload.size() > 0){
                    if(Utils.isCreateable('i8__ROTA__c'))
                        insert taskupload;
                    return new pagereference('/apex/ROTATab_page');
                }
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,System.label.SOEAttachment003+' '+filetypeExtension));  
            }
          }else{ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.Admin001); ApexPages.addMessage(errormsg);}
        }
        catch (Exception e){
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.SOEImport007);
            ApexPages.addMessage(errormsg);
            Database.rollback(sp);
            LogFactory.error('Import_ROTA_cntrl', 'ReadFile', '', e.getMessage() + '' + e.getStackTraceString());  
            LogFactory.SaveLog(); 
            ApexPages.Message exceptionMessage = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
            ApexPages.addMessage(exceptionMessage);
        }
        
        return null;
    }
    public class wrapperclass{
        public string Sname{get;set;}
        public Rota__c rotarec{get;set;}         
        public wrapperclass(string NAME, Rota__c RTA){
            this.Sname=NAME;
            this.rotarec=RTA;
        }    
    }
    public PageReference CancelROTA() {  
        return new pagereference('/'+ROTA__c.sobjecttype.getDescribe().getKeyPrefix()+'/o');
    }
}