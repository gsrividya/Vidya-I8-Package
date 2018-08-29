({
	doInit: function(component, event, helper) {
        var Contact = component.get('v.record');
        var FieldName = component.get('v.fieldName');
        var types = component.get('v.types');
        component.set("v.type" , types[component.get("v.index")] );
        if(FieldName == 'I8__Team__c'&& Contact[FieldName] != undefined ) 
       		component.set("v.value",Contact['I8__Team__r'].Name);
        else if(FieldName == 'I8__Owner__c'&& Contact[FieldName] != undefined ) 
       		component.set("v.value",Contact['I8__Stack_Owner_Name__c']);
        else
           component.set("v.value",Contact[FieldName]);
    }
})