/**
 * Created by armievergara on 21/8/18.
 */
({
    cancelButton: function(component,event,helper){
    	$A.get("e.force:closeQuickAction").fire();
	},
    doInit: function(component,event,helper){
       component.set("v.submitFailedMessage",'Unable to generate job id for the requested report type.<br/>Please re-submit. If error persists, Please contact Sales Operations.');
        var action = component.get("c.setRequestTypes");
	    action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
          	component.set("v.requestTypes", response.getReturnValue());
          }
          else if (state === "INCOMPLETE") {
		  }
          else if (state === "ERROR") {
          }
	    });
	   $A.enqueueAction(action);
    },
    submitToCIButton: function(component,event,helper){
        component.set("v.selectedRequestLabel",'');
        component.set("v.jobID",'');
        component.set("v.submitFailed",false);


        var isValid = true;
        if(component.get("v.selectedRequest")==''){
            isValid = false;
        }
        var action = component.get("c.submitToCI");
        action.setParams({
            "opportunityID": component.get("v.recordId"),
            "reportType": component.get("v.selectedRequest")
        });
	    action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {

          	component.set("v.jobID",response.getReturnValue());
          	if(component.get("v.jobID") == ''){
                component.set("v.submitFailed",true);
            }

            if(component.get("v.jobID") != ''){
                var requestTypes = component.get("v.requestTypes");

                 // set default record type value to attribute
                for(var i = 0; i < requestTypes.length; i++){
                    if(requestTypes[i].value==component.get("v.selectedRequest")){
                        component.set("v.selectedRequestLabel",requestTypes[i].description);
                    }
                }

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : component.get("v.selectedRequestLabel"),
                    message: 'Job ID: '+component.get("v.jobID"),
                    type: 'success',
                    mode: 'sticky'
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
             }

          }
          else if (state === "INCOMPLETE") {
            component.set("v.submitFailed",true);
		  }
          else if (state === "ERROR") {
            component.set("v.submitFailed",true);
          }
            
           helper.hideSpinner(component);
           component.set("v.disableSubmit",false);
	    });
        if(isValid){
            helper.showSpinner(component);
            component.set("v.disableSubmit",true);
            $A.enqueueAction(action);
        }
    }
})