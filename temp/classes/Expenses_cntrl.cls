/* 
Class Name        : Expenses_cntrl
Test Class Name   : Test_Expenses_cntrl
Purpose/Overview  : To add Expenses to an SOE.
Author            : Purview Ltd.
Code Coverage     : 100%.
Change History    : 
*/
public with sharing class Expenses_cntrl {
    public ID ExpClaimID{get;set;}
    public boolean error{get;set;}
    public string errorMessage{get;set;}
    public Expense_Claim__c ExpClaim{get;set;} 
    public List<Expenses__c> entryList{get;set;}
    public list<Expenses__c> Original_expenseslist; 
    public List<WrapperClass> WrapperList{get;set;}
    public List<Expenses__c> deletEntryList;
    public String deleteID;
    
    public Expenses_cntrl(ApexPages.StandardController controller) {
    WrapperList = new list< WrapperClass>();
        ExpClaimID = ApexPages.currentPage().getParameters().get('id');
        
        if(ExpClaimID != null){
      
        deletEntryList = new list<Expenses__c>();
        if(Utils.isAccessible('I8__Expense_Claim__c') && Utils.isAccessible('I8__Expenses__c')){
        Original_expenseslist = new list<Expenses__c>();
        ExpClaim = [Select id, Name, From_Date__c, To_Date__c, Employee_Name__c, Manager__c,Total_Claim_Amount__c, No_Of_Claims__c  From Expense_Claim__c where id =: ApexPages.currentPage().getParameters().get('id')];
        UpdateLists();
        If(WrapperList.size() < 1)
            AddEntry();
         }else{error=true;errorMessage = System.Label.AddTask001;}
         }
    }
    public class WrapperClass{
        public Expenses__c Exp{get;set;}
        public Integer Count{get;set;}
        public WrapperClass(Expenses__c exp1, integer cnt){
            Exp = exp1;
            Count = cnt;
        }
    } 
    public void UpdateLists(){      
        
        Integer cnt =0;  
        if(Utils.isAccessible('I8__Expenses__c'))
        for (Expenses__c exp: [Select Id, Expense_Claim__c,CreatedDate,Date__c, SOE__c, Task__c, Expense_Type__c,Payment_Type__c, Amount__c,Description__c From Expenses__c Where Expense_Claim__c =: ExpClaimID order by createddate ]){
            Original_expenseslist.add(exp.clone(true,true,false,true)); 
            WrapperList.add(new WrapperClass(exp,cnt));
            cnt++;
        }
    }
    public PageReference AddEntry()
    {        
        if(WrapperList.SIze() == 0)
            WrapperList.add(new WrapperClass(new Expenses__c(Expense_Claim__c = ExpClaimID),0)); 
        else
            WrapperList.add(new WrapperClass(new Expenses__c(Expense_Claim__c = ExpClaimID,Payment_Type__c='Cash'),WrapperList.Size()));          
        return null;
    }
    public void DeletEntry()
    {  
        deleteID = ApexPages.currentPage().getParameters().get('DeleteId');
        for(Integer i=0;i<  WrapperList.Size();i++){
            if(WrapperList[i].Count == Integer.valueof(deleteID )){
                WrapperLIst[i].exp.Date__c = System.Today();
                 WrapperLIst[i].exp.Expense_Type__c= 'Airfare';
                 WrapperLIst[i].exp.Amount__c = 10;
                if(WrapperList[i].exp.id != null)
                    deletEntryList.add(WrapperList[i].Exp);
                WrapperList.Remove(i);
            }
        }
        list< WrapperClass> WrapperList1 = new list< WrapperClass>();
        for(integer i=0;i< WrapperList.Size(); I++){
            WrapperList1.add(new WrapperClass(WrapperList[i].exp,i));
        }
        WrapperList.Clear();
        WrapperList.AddAll(WrapperList1);
    }
    public pagereference SaveExpenses(){
    Boolean displayError = False;
        entryList = new List<Expenses__c>(); 
        Savepoint sp = Database.setSavepoint();
        boolean bool = false;
        try{
            list<Expenses__c> InsertList = new list<Expenses__c>();
            list<Expenses__c> UpdateList = new list<Expenses__c>();
            
            for(Integer i=0;i<  WrapperList.Size();i++){
            WrapperList[i].exp.Expense_Claim__c = ExpClaimID;
                if(WrapperList[i].exp.Id == null)
                    insertList.add(WrapperLIst[i].exp);
                else 
                    UpdateList.add(WrapperLIst[i].exp);
            }
            if( Utils.isCreateable('I8__Expenses__c')) {
                for(Expenses__c exp : InsertLIst){
                    Error  = Expenses_Validations(exp);
                    if(Error  == true )
                        return null;
                }  
                if(InsertList.Size() > 0 && Utils.isCreateable('I8__Expenses__c'))    
                    insert InsertList;
            }  
            else if(InsertList.Size() > 0){
                displayError = true;
                errorMessage = System.Label.AddTask006;
            }
            list<Expenses__c> expenseList = new list<Expenses__c>();
            if( Utils.isUpdateable('I8__Expenses__c')) {              
                for(Expenses__c exp : UpdateList){
                    Error  = Expenses_Validations(exp);
                    if(Error  == true )
                        return null;
                    else {
                        for(Expenses__c expensesList : Original_expenseslist){
                            if(exp.Id == expensesList.Id && exp != expensesList)
                                expenseList.add(exp);
                        }                        
                    }                    
                } 
                if(expenseList.Size() > 0 && Utils.isUpdateable('I8__Expenses__c'))
                    update expenseList;
            }  
            else if(expenseList.Size() > 0){
                displayError = true;
                errorMessage =    System.Label.AddTask007 ;
            } 
            if(deletEntryList.size() > 0 ){
                if(Schema.sObjectType.Expenses__c.isDeletable())
                    delete deletEntryList;
                else{
                    displayError = true;
                    errormessage = System.Label.AddTask008;
                }
            } 
            if(displayError == false){
                return new pagereference('/'+ExpClaimID);
            } 
            else
                return null; 
        }
        catch (Exception e) {
           Database.rollback(sp);
           LogFactory.error('Expenses_cntrl', 'SaveExpenses', '', e.getMessage() + '' + e.getStackTraceString());  
           LogFactory.SaveLog(); 
           error = true;
           errorMessage = e.getMessage();  
            return null;
        }      
    } 
        public boolean Expenses_Validations(Expenses__c exp){
        boolean bool = false;
        if(exp.Date__c == null) {
                    exp.Date__c.AddError('You must enter value');
                    bool = true;
                }
                if(exp.Expense_Type__c== null) {
                   exp.Expense_Type__c.AddError('You must enter value');
                    bool = true;
                }
                if(exp.Amount__c== null) {
                    exp.Amount__c.AddError('You must enter value');
                    bool = true;
                }
                if(exp.Payment_Type__c== null) {
                    exp.Payment_Type__c.AddError('You must enter value');
                    bool = true;
                }
        return bool;
    }
    public pagereference CancelExpenses(){
       if(ExpClaimID != null)
        return new pagereference('/'+ExpClaimID);
        return null;
    }
}