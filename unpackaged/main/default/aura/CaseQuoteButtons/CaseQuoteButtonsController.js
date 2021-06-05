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
                        var button = component.find("acceptbtn");
                        var button2 = component.find("declinebtn");
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
	onclick : function(component, event, helper) {
        var action = component.get("c.saveCase");
        action.setParams({"caseRec": component.get("v.case"), "vstatus": 'Accepted'});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS"){
                var c = response.getReturnValue();
                component.set("v.case", c);
                window.setTimeout(
                    $A.getCallback(function () {
                       
                    })
                );
                window.location.reload();
                $A.get('e.force:refreshView').fire();

           } 
            /* Start CR 206104 - Include rrorr message handling to pick up DMS exceptions */
            /*else {
                console.log('There was a problem : '+response.getError());
           }*/
            else if(state == "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set('v.hasError', true);
                        component.set('v.errorMessage', errors[0].message);
                    }
                }
            	}else if (status == "INCOMPLETE") {
                    		component.set('v.hasError', true);
                        	component.set('v.errorMessage', 'Unknown Server error has occurred.');
                    /* End CR 206104 - Include rrorr message handling to pick up DMS exceptions */
            }
        });
        $A.enqueueAction(action);

},
    onclick2 : function(component, event, helper) {

        var action = component.get("c.saveCase");
        action.setParams({"caseRec": component.get("v.case"), "vstatus": 'Declined'});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS"){
                var c = response.getReturnValue();
                component.set("v.case", c);
                window.setTimeout(
                    $A.getCallback(function () {
                   })
                );
                window.location.reload();
                $A.get('e.force:refreshView').fire();
            } 
            /* Start CR 206104 - Include rrorr message handling to pick up DMS exceptions */
            else if(state == "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set('v.hasError', true);
                        component.set('v.errorMessage', errors[0].message);
                    }
                }
            }
                else if (status == "INCOMPLETE") {
                        component.set('v.hasError', true);
                        component.set('v.errorMessage', 'Unknown Server error has occurred.');
                    /* End CR 206104 - Include rrorr message handling to pick up DMS exceptions */
            }
        });
        $A.enqueueAction(action);

},
    
    isRefreshed: function(component, event, helper) {
    	location.reload();
},
    
    dismissError : function (component, event, helper) {
        helper.dismissErrorMessages(component)
    }
})