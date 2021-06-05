({
    /* doInitHelper function to fetch all records, and set attributes value on component load */
    doInitHelper : function(component,event){ 
        var action = component.get("c.getServiceContracts");
        action.setParams({ OppId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state ', state);
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                console.log('Response ', oRes);
                console.log('Response length ', oRes.length);
                if(oRes.length > 0){
                    component.set("v.listOfAllServiceContracts", oRes);
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    console.log('LIST OF SERVICE CONTRACTS ', component.get("v.listOfAllServiceContracts"));
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfAllServiceContracts").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));    
                }else{
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound" , true);
                } 
            }
            else{
               component.set("v.Spinner",'false');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "An error occured please contact your administrator."
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);  
    },
    
    // GET RECORDS BASED ON GIVEN DATE
    getRecordsBydates : function(component,event){ 
        var action = component.get("c.getRecordsBydates");
        var SelectedDate = component.get("v.SDate");
        if(SelectedDate == null){
            SelectedDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");; 
        }
        component.set("v.Spinner",'true');
        action.setParams({ OppId : component.get("v.recordId"),EffectiveDate : SelectedDate});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state ', state);
            if (state === "SUCCESS"){
                component.set("v.Spinner",'false');
                var oRes = response.getReturnValue();
                console.log('Response ', oRes);
                console.log('Response length ', oRes.length);
                if(oRes.length > 0){
                    component.set("v.listOfAllServiceContracts", oRes);
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    console.log('LIST OF SERVICE CONTRACTS ', component.get("v.listOfAllServiceContracts"));
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfAllServiceContracts").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));    
                }else{
                    component.set("v.Spinner",'false');
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound" , true);
                } 
            }
            else{
               component.set("v.Spinner",'false');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "An error occured please contact your administrator."
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);  
    },
    
    // CREATE NEW LINES FOR NEW QUOTE
    createLinesHelper : function(component,event){ 
        var allRecords = component.get("v.listOfAllServiceContracts");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i].objServiceContract);
            }
        }
        component.set("v.Spinner",'true');
        component.set("v.ProcessButtonControl", true);
        component.set("v.Processing", true);
        var action = component.get("c.createLines");
        action.setParams({ ServContList : selectedRecords,
                          OppId : component.get("v.recordId") 
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state ', state);
            if (state === "SUCCESS"){
                component.set("v.Spinner",'false');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "The records has been created successfully! Please refresh the page."
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
            else{
                component.set("v.Spinner",'false');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "An error occured please contact your administrator."
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);  
    },
    
    //  NAVIGATE TO NEXT PAGINATION RECORD SET
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]);  
                }
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    
    // NAVIGATE TO PREVIOUS PAGINATION RECORD SET
    previous : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]); 
                }
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
})