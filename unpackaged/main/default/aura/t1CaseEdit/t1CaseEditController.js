({
	 init : function(component, event, helper) {

        var action = component.get("c.getCase");
        action.setParams({"recordId": component.get("v.recordId")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var c = response.getReturnValue();
                component.set("v.case", c);
                window.setTimeout(
                    $A.getCallback(function () {
                        //if(c.Status != "Awaiting Quote Approval"){
                        //    button.set("v.class",".slds-hide");
                        //    button2.set("v.class",".slds-hide");
                        //}

                    })
                );

            } else {
                console.log('There was a problem : '+response.getError());
            }
        });
        $A.enqueueAction(action);

    },
    
                            
 	refresh : function(component, event, helper) {
        var action = component.get("c.returnnothing");
 
       	action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS"){
                var c = response.getReturnValue();
                window.setTimeout(
                    $A.getCallback(function () {
                    })
                );
                //window.location.reload();
               $A.get('e.force:refreshView').fire();

           } else {
                console.log('There was a problem : '+response.getError());
            }
        });
        $A.enqueueAction(action);

    },

   navHome : function (component, event, helper) {
        var navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvent.fire();
	},  
    
    isRefreshed: function(component, event, helper) {
    	location.reload();
	}
})