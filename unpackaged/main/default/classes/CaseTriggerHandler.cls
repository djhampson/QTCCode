/**
     Case Trigger Handler
 */
public class CaseTriggerHandler {

    public static BusinessHours defaultHours = [select Id, MondayStartTime, MondayEndTime from BusinessHours where IsDefault=true];
	public static Set<String> stopStatusSet = new Set<String>();
    public static Set<String> closedStatusSet = new Set<String>(); 
    public static List<Holiday> holidays=[Select StartTimeInMinutes, Name, ActivityDate From Holiday ]; 
	   
    static public void onAfterInsert(Case[] newCases) {
        SetCreatedDateMod(newCases);
        checkCasesForCreatingEntitlements( newCases ,null );
        
    }

    static public void onBeforeInsert(Case[] newCases) {
        loopKiller(newCases);
        initBusinessHoursAges(newCases);
    }

    static public void onBeforeUpdate(Case[] updatedCases, Map<ID, Case> oldMap) {
        // bypass all processing if Case Score update
        for(Case updatedCase : updatedCases) {
            Case beforeUpdate = oldMap.get(updatedCase.Id);
            if (updatedCase.Support_Case_Score__c != beforeUpdate.Support_Case_Score__c){
                return;
            }
        }
        resetMilestoneWarnings(updatedCases, oldMap);
        setDateToWorkDayOnCase(updatedCases, oldMap);
        calcTimeAwaitResAlloc(updatedCases, oldMap); // must be done prior to calcBusinessHoursAges as that function sets the Last Status Change date
        calcBusinessHoursAges(updatedCases, oldMap);
        // following moved from onAfterUpdate
        reopenCase(updatedCases, oldMap);
        calcCaseDurations(updatedCases, oldMap);
        
    }
    
    static public void onAfterUpdate(Case[] updatedCases, Map<ID, Case> oldMap) {
        checkCasesForCreatingEntitlements( updatedCases ,oldMap );
        // bypass all processing if Case Score update
        for(Case updatedCase : updatedCases) {
            Case beforeUpdate = oldMap.get(updatedCase.Id);
            if (updatedCase.Support_Case_Score__c != beforeUpdate.Support_Case_Score__c){
                return;
            }
        }
        completeMilestones(updatedCases, oldMap);
        updateJiraCases(updatedCases, oldMap);
        calcAssignment(updatedCases, oldMap);
    }

    public static void checkCasesForCreatingEntitlements( Case[] newCases, Map<Id, Case> oldMap ){
        /****************Processing Case Entitlements After Insert/Update *******************/
        Set<Id> caseIds = new Set<Id>();
        for(Case caseVar : newCases){
            if( !String.isempty(caseVar.Priority) && !String.isEmpty(caseVar.Customer_Product__c) ){
                if( oldMap != null ){
                    if( oldMap.get(caseVar.Id).Priority != caseVar.Priority ||  oldMap.get(caseVar.Id).Customer_Product__c != caseVar.Customer_Product__c || oldMap.get(caseVar.Id).RecordTypeId != caseVar.RecordTypeId ){
                        caseIds.add( caseVar.Id );
                    }
                }
                else{
                    caseIds.add( caseVar.Id );
                }
            }
        }
        try{
            if( caseIds.size() > 0 ){
                if( oldMap != null ){
                    List<Case_Entitlements__c> caseEntitlementsToDelete = T1_CaseEntitlementService.getCaseEntitlementsByCaseId( caseIds );
                    delete caseEntitlementsToDelete;
                }
                T1_CaseEntitlementService.processCasesforCreatingEntitlements( caseIds );
            }
        }catch(Exception e){
            system.debug( 'Exception details ' + e.getCause() + e.getMessage() + e.getStackTraceString());
            Error_Log__c errLog = T1_ErrorLogService.createErrorLog( e, caseIds, 'Apex Class',  'CaseTriggerHandler.checkCasesForCreatingEntitlements');
            insert errLog;
        }
        
    }

    static public void SetCreatedDateMod(Case[] newCases) {
    
         list <case> l_cases = new list<case>(); //list of cases to be updated
         set<Id> CaseIds = new set<Id>(); // list of Case Id's for Cases to be updated
            
         for(Case newCase : newCases){
            //if(newCase.CreatedDate_Mod__c == null){ // If our modifiable date is null we want to update this case
                CaseIds.add(newCase.ID); //add all cases - 11/6/18
            //}   
         } 
        
         if (!CaseIds.isEmpty()){
            for (case [] arrCase : [SELECT Id, 
                                           CreatedDate 
                                    FROM case 
                                    WHERE Id IN :caseIds]){      // an array of Cases based on the ID's to be updated 
                for (Case sCase : arrCase){ // Update the field for the Case to be updated and add it to the Update List
                    sCase.CreatedDate_Mod__c = sCase.CreatedDate;
                    l_cases.add(sCase);
                }
            }  
         }
        
        if (!l_cases.isEmpty()){
           	//update l_cases;
           	// following code from CaseAssignment trigger 11/6/18
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            if(!Test.isRunningTest())
                Database.update(l_cases, dmo);
        }   
    }
    
    // This trigger's purpose is to reset the milestone warnings when Case is closed or Interim Solution provided
    static public void resetMilestoneWarnings(Case[] updatedCases, Map<ID, Case> oldMap) {
        
        for(Case updatedCase : updatedCases) {
            Case beforeUpdate = oldMap.get(updatedCase.Id);
              if (updatedCase.Status != beforeUpdate.Status && (updatedCase.Status == 'Resolved' || updatedCase.Status == 'Closed')) { 
                // clear milestone warnings
                updatedCase.Response_MS_Warning__c = False;
                updatedCase.Update_MS_Warning__c = False;
                updatedCase.Interim_Resolution_MS_Warning__c = False;
                updatedCase.Final_Resolution_MS_Warning__c = False;
                // SCE-104 Clear the Jira Development Status when Case is Resolved or Closed
                if (updatedCase.Jira_Dev_Issue_Count__c > 0){
                    updatedCase.Development_Status__c = '';
                }
             } 
        }

        for(Case updatedCase : updatedCases) {
            Case beforeUpdate = oldMap.get(updatedCase.Id);
             if (updatedCase.Interim_Solution_Provided__c != beforeUpdate.Interim_Solution_Provided__c && updatedCase.Interim_Solution_Provided__c == True) { 
                // clear milestone warnings
                updatedCase.Response_MS_Warning__c = False;
                updatedCase.Update_MS_Warning__c = False;
                updatedCase.Interim_Resolution_MS_Warning__c = False;
             } 
        }        
    }

    static public void setDateToWorkDayOnCase(Case[] updatedCases, Map<ID, Case> oldMap) {
        //Query holidays from Org  
        //List<Holiday> holidays=[Select StartTimeInMinutes, Name, ActivityDate From Holiday ];
        
         for(Case updatedCase : updatedCases) {
             Case beforeUpdate = oldMap.get(updatedCase.Id);
             // Only update if the field has been modified
             if (updatedCase.AwaitInfoFinalFollowupDue__c != beforeUpdate.AwaitInfoFinalFollowupDue__c && updatedCase.AwaitInfoFinalFollowupDue__c != null) { 
                    // Field has been changed! 
                    Date DateOut = updatedCase.AwaitInfoFinalFollowupDue__c.Date();

                    if (WorkDayCalcs.checkifWorkDayFU(DateOut, holidays) == false){
                        DateOut = Date.today();
                        Integer numDays = 3; //the default for all but Urgent
                        if (updatedCase.Priority == 'Urgent')
                            numDays = 2;
                        DateOut = WorkDayCalcs.calculateNthWorkingDay(DateOut, numDays, holidays);
                        // now put date and time back together
                        String sDate = DateOut.day() + '/' + DateOut.month() + '/' + DateOut.year();
                        String sTime = updatedCase.AwaitInfoFinalFollowupDue__c.format('hh:mm a');
                        updatedCase.AwaitInfoFinalFollowupDue__c = DateTime.parse(sDate + ' ' + sTime);
                    }
             } 
                              
             if (updatedCase.AwaitInfoFirstFollowupDue__c != beforeUpdate.AwaitInfoFirstFollowupDue__c && updatedCase.AwaitInfoFirstFollowupDue__c != null) { 
                    // Field has been changed! 
                    Date DateOut = updatedCase.AwaitInfoFirstFollowupDue__c.Date();

                    if (WorkDayCalcs.checkifWorkDayFU(DateOut, holidays) == false){
                        DateOut = Date.today();
                        Integer numDays = 3; //the default for all but Urgent
                        if (updatedCase.Priority == 'Urgent')
                            numDays = 2;
                        DateOut = WorkDayCalcs.calculateNthWorkingDay(DateOut, numDays, holidays);
                        // now put date and time back together
                        String sDate = DateOut.day() + '/' + DateOut.month() + '/' + DateOut.year();
                        String sTime = updatedCase.AwaitInfoFirstFollowupDue__c.format('hh:mm a');
                        updatedCase.AwaitInfoFirstFollowupDue__c = DateTime.parse(sDate + ' ' + sTime);
                    }
             } 
                              
             if (updatedCase.AwaitInfoSecondFollowupDue__c != beforeUpdate.AwaitInfoSecondFollowupDue__c && updatedCase.AwaitInfoSecondFollowupDue__c != null) { 
                    // Field has been changed! 
                    Date DateOut = updatedCase.AwaitInfoSecondFollowupDue__c.Date();

                    if (WorkDayCalcs.checkifWorkDayFU(DateOut, holidays) == false){
                        DateOut = Date.today();
                        Integer numDays = 3; //the default for all but Urgent
                        if (updatedCase.Priority == 'Urgent')
                            numDays = 2;
                        DateOut = WorkDayCalcs.calculateNthWorkingDay(DateOut, numDays, holidays);
                        // now put date and time back together
                        String sDate = DateOut.day() + '/' + DateOut.month() + '/' + DateOut.year();
                        String sTime = updatedCase.AwaitInfoSecondFollowupDue__c.format('hh:mm a');
                        updatedCase.AwaitInfoSecondFollowupDue__c = DateTime.parse(sDate + ' ' + sTime);
                    }
             } 
             // CR 116848 Start
             if (updatedCase.Quote_Reminder__c != beforeUpdate.Quote_Reminder__c && updatedCase.Quote_Reminder__c != null) { 
                    // Field has been changed! 
                    Date DateOut = updatedCase.Quote_Reminder__c.Date();
                    DateOut = WorkDayCalcs.advanceIfNonworking(DateOut, holidays);
                    // now put date and time back together
                    String sDate = DateOut.day() + '/' + DateOut.month() + '/' + DateOut.year();
                    String sTime = updatedCase.Quote_Reminder__c.format('hh:mm a');
                    updatedCase.Quote_Reminder__c = DateTime.parse(sDate + ' ' + sTime);
             } 
             if (updatedCase.Quote_Expiry__c != beforeUpdate.Quote_Expiry__c && updatedCase.Quote_Expiry__c != null) { 
                    // Field has been changed! 
                    Date DateOut = updatedCase.Quote_Expiry__c.Date();
                    DateOut = WorkDayCalcs.advanceIfNonworking(DateOut, holidays);
                    // now put date and time back together
                    String sDate = DateOut.day() + '/' + DateOut.month() + '/' + DateOut.year();
                    String sTime = updatedCase.Quote_Expiry__c.format('hh:mm a');
                    updatedCase.Quote_Expiry__c = DateTime.parse(sDate + ' ' + sTime);
             } 
             // CR 116848 End
         }            
    }   
    
    static public void updateJiraCases(Case[] updatedCases, Map<ID, Case> oldMap) {
        // If Case contains a Jira Issue No then we will want to get the milestone target dates
        List<Id> updateJiraCases = new List<Id>();
        for(Case updatedCase : updatedCases) {
            Case beforeUpdate = oldMap.get(updatedCase.Id);
            
             if ((updatedCase.Jira_Issue_No__c != beforeUpdate.Jira_Issue_No__c 
                 || updatedCase.Priority != beforeUpdate.Priority
                 || updatedCase.Status != beforeUpdate.Status
                 || updatedCase.IsStopped != beforeUpdate.IsStopped
                 || updatedCase.Account != beforeUpdate.Account
                 || updatedCase.Entitlement != beforeUpdate.Entitlement
                 || updatedCase.BusinessHours != beforeUpdate.BusinessHours)
                 && (String.isBlank(updatedCase.Jira_Issue_No__c) == false
                    || updatedCase.Jira_Dev_Issue_Count__c > 0) // include case with any linked jira issues regardless of Issue_no field on Case
                 && updatedCase.Status != 'Resolved'
                 && updatedCase.Status != 'Closed') { 
                updateJiraCases.add(updatedCase.Id);
             } 
     
        }
        
        if (!updateJiraCases.isEmpty()) {
            CaseMilestoneUtils.copyTargetDate(updateJiraCases);
        }
    }

    static public void reopenCase(Case[] updatedCases, Map<ID, Case> oldMap) {    
         
        // If Case is being Reopened we need to set the Exit Entitlement flag
        for(Case updatedCase : updatedCases) {
            Case beforeUpdate = oldMap.get(updatedCase.Id);
        
            if (updatedCase.Status != beforeUpdate.Status && 
                (beforeUpdate.Status == 'Resolved' || beforeUpdate.Status == 'Closed') && 
                (updatedCase.Status != 'Resolved' && updatedCase.Status != 'Closed') &&
                updatedCase.Exit_Entitlement_Process__c <> false){ 
                   updatedCase.Exit_Entitlement_Process__c = false;
             } 
        }
     }
    
    
    static public void completeMilestones(Case[] updatedCases, Map<ID, Case> oldMap) {
        List<Id> updateJiraCases = new List<Id>();
        DateTime completionDate = System.now();
        //String milestoneType = '';    
        // If Case is being Resolved or Closed then we want to stop the Final resolution milestone, and any others that may be running, including Update and Interim Resolution
        List<Id> updateFinResCases = new List<Id>();
        for(Case updatedCase : updatedCases) {
             Case beforeUpdate = oldMap.get(updatedCase.Id);
             
             if (updatedCase.Status != beforeUpdate.Status && (updatedCase.Status == 'Resolved' || updatedCase.Status == 'Closed')) { 
                // Status has been changed to resolved or Closed
                updateFinResCases .add(updatedCase.Id);
              } 
        }
        
        if (updateFinResCases .isEmpty() == false ){
            milestoneUtils.completeMilestone(updateFinResCases , 'Response', completionDate);
            milestoneUtils.completeMilestone(updateFinResCases , 'Update', completionDate);
            milestoneUtils.completeMilestone(updateFinResCases , 'Interim Resolution', completionDate);
            milestoneUtils.completeMilestone(updateFinResCases , 'Final Resolution', completionDate);
            milestoneUtils.completeMilestone(updateFinResCases , 'Action Required', completionDate);
            CaseMilestoneUtils.setExitEntitlement(updateFinResCases, True);
        }
        // If Interim Solution is being supplied then we want to stop current Update and Interim Resolution milestones
        List<Id> updateIntResCases = new List<Id>();
        for(Case updatedCase : updatedCases) {
            Case beforeUpdate = oldMap.get(updatedCase.Id);
        
             if (updatedCase.Interim_Solution_Provided__c != beforeUpdate.Interim_Solution_Provided__c && updatedCase.Interim_Solution_Provided__c == True) { 
                // Field has been changed and set to True meaning our workflow was triggered which sends the Interim Solution email and updates our field
                updateIntResCases .add(updatedCase.Id);
             } 
        }
        
        if (updateIntResCases .isEmpty() == false ){
            milestoneUtils.completeMilestone(updateIntResCases , 'Response', completionDate);
            milestoneUtils.completeMilestone(updateIntResCases , 'Update', completionDate);
            milestoneUtils.completeMilestone(updateIntResCases , 'Interim Resolution', completionDate);
        }
        
        // If Jira Issue No is being supplied then we want to stop current Update
        for(Case updatedCase : updatedCases) {
            Case beforeUpdate = oldMap.get(updatedCase.Id);
            
             if ((updatedCase.Jira_Issue_No__c != beforeUpdate.Jira_Issue_No__c 
                &&  String.isBlank(updatedCase.Jira_Issue_No__c) == false)
                && (updatedCase.Status != 'Resolved' //only update if Case is still open
                && updatedCase.Status != 'Closed')) { 
                // Field has been changed
                updateJiraCases .add(updatedCase.Id);
             } 
        }
        
        if (updateJiraCases .isEmpty() == false ){
            milestoneUtils.completeMilestone(updateJiraCases , 'Update', completionDate);
        } 

        // If all comms flags are cleared then complete Acknowedge Comms
        List<Id> updateAckCases = new List<Id>();
        for(Case updatedCase : updatedCases) {
            Case beforeUpdate = oldMap.get(updatedCase.Id);
            
             if ((updatedCase.New_Customer_Email__c  != beforeUpdate.New_Customer_Email__c ||
                updatedCase.New_Customer_Attachment__c   != beforeUpdate.New_Customer_Attachment__c  ||
                updatedCase.New_Portal_Case_Comment__c   != beforeUpdate.New_Portal_Case_Comment__c  ||
                updatedCase.Priority_Has_Changed__c   != beforeUpdate.Priority_Has_Changed__c )
                &&  (updatedCase.New_Customer_Email__c == false &&
                updatedCase.New_Customer_Attachment__c == false &&
                updatedCase.New_Portal_Case_Comment__c == false &&
                updatedCase.Priority_Has_Changed__c == false)) { 
                // Field has been changed
                updateAckCases .add(updatedCase.Id);
             } 
        }
        
        if (updateAckCases .isEmpty() == false ){
            milestoneUtils.completeMilestone(updateAckCases , 'Action Required', completionDate);
        } 
    }

    static public void loopKiller(Case[] newCases){
        // Will not process a third email if there was already two preceeding identical emails (from
        // the same email address with the same subject) and the previous emails were less than 5 minutes old.
        // Second email to case required for situations where customer meant to include more information on
        // the first email and so recomposed and re-sent. It's unlikely a third deliberate email with identical
        // subject would be submitted within the same 5 minute window this trigger operates within.
    
        //Case newCase : newCases;
     
      // Granth 18/9/15 - The following code was found in UAT and Prod - added 19/3/15 in both. It was missing from Dev so I have reinstated it.
      // Add logic to exclude out of office replies
        if(newCases[0].Subject != null) {
            if (newCases[0].subject.startsWithIgnoreCase('Automatic Reply') || newCases[0].subject.startsWithIgnoreCase('Out of office')){
                if (!Test.isRunningTest()){
                    newCases[0].addError('Out of Office reply has been ignored');
                }
            }
        }
      // Granth 18/9/15 
      
        //case[] check = [select ID, CreatedDate, subject from Case where SuppliedEmail = :newCases[0].SuppliedEmail and subject = :newCases[0].subject order by CreatedDate desc];
        system.debug(newCases[0].SuppliedEmail);
        system.debug(newCases[0].subject);
        DateTime theDate = System.now().addMinutes(-5); // 18/5/18 GH - Variable for query
		
        //if(newCases[0].Subject != null ) {
        if(newCases[0].Subject != null && (String.isNotEmpty(newCases[0].SuppliedEmail) || Test.isRunningTest()) ) { 
            // 18/5/18 GH - Only query if we need to and use calculated date
            case[] check = [select ID, CreatedDate, subject from Case where SuppliedEmail = :newCases[0].SuppliedEmail and subject = :newCases[0].subject and CreatedDate > :theDate order by CreatedDate desc];

            if (Test.isRunningTest()){
                check = [select ID, CreatedDate, subject from Case where subject = :newCases[0].subject and CreatedDate > :theDate order by CreatedDate desc];
            }
            // we have a subject, proceed.
            if(newCases[0].subject.contains('[ ref:')){
                //No Errors.  Email should be attached to the case.
            }else{
                if(check.size() > 1){
                    if((check[0].createddate.addMinutes(5) > System.now()) && check[0].subject.contains(newCases[0].subject)){
                        if (!Test.isRunningTest()){
                            newCases[0].addError('Automatic email loop has been terminated');
                        }
                        //Loop Was Killed.
                    }else{
                        //New Case should be created now!       
                    }
                }
            }
        }
    } 
    
    static public void calcBusinessHoursAges (Case[] updatedCases, Map<ID, Case> oldMap) {   
 
 		//Set<String> stopStatusSet = new Set<String>();
 		if (stopStatusSet.IsEmpty()){
	        //Get the stop statuses
	        List<Stop_Status__c> StopStat = [select name from Stop_Status__c];
	        for (Stop_Status__c stopStatus:StopStat) {
	            stopStatusSet.add(stopStatus.Name);
	        }
 		}
 		
        //Get the default business hours (we might need it)
        //BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];

        //Get the closed statuses (because at the point of this trigger Case.IsClosed won't be set yet)
        //Set<String> closedStatusSet = new Set<String>();  
        if (closedStatusSet.IsEmpty()){
	        List<CaseStatus> cStat = [Select MasterLabel From CaseStatus where IsClosed=true];
	        for (CaseStatus status:cStat) {
	            closedStatusSet.add(status.MasterLabel);
	        }
        }
        //For any case where the status is changed, recalc the business hours in the buckets
        for (Case updatedCase:updatedCases) {
            Case oldCase = oldMap.get(updatedCase.Id);

            if (updatedCase.Last_Status_Change__c == null) {
                updatedCase.Last_Status_Change__c = System.now();
            }
            if (oldCase.Status!=updatedCase.Status && updatedCase.Last_Status_Change__c!=null) {
                //OK, the status has changed
                if (!oldCase.IsClosed) {
                    //We only update the buckets for open cases

                    //On the off-chance that the business hours on the case are null, use the default ones instead
                    Id hoursToUse = updatedCase.BusinessHoursId!=null?updatedCase.BusinessHoursId:defaultHours.Id;
                    
                    if (updatedCase.Time_With_Customer__c == null) {
                        updatedCase.Time_With_Customer__c = 0;
                    }
                    if (updatedCase.Time_With_Support__c == null) {
                        updatedCase.Time_With_Support__c = 0;
                    }
                    if (updatedCase.Case_Age_In_Business_Hours__c == null) {
                        updatedCase.Case_Age_In_Business_Hours__c = 0;
                    }
                        
                    //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
                    Double timeSinceLastStatus =  0.00;
                    
                    if (updatedCase.Last_Status_Change__c != System.now()){
                        timeSinceLastStatus = BusinessHours.diff(hoursToUse, updatedCase.Last_Status_Change__c, System.now())/3600000.0;
                        System.debug('Milliseconds ' + BusinessHours.diff(hoursToUse, updatedCase.Last_Status_Change__c, System.now()));
                    }
                    System.debug('Time since last status change ' + timeSinceLastStatus);

                    //We decide which bucket to add it to based on whether it was in a stop status before
                    if (stopStatusSet.contains(oldCase.Status)) {
                        updatedCase.Time_With_Customer__c += timeSinceLastStatus;
                    } else {
                        updatedCase.Time_With_Support__c += timeSinceLastStatus;
                    }

                    if (closedStatusSet.contains(updatedCase.Status)) {
                        updatedCase.Case_Age_In_Business_Hours__c = updatedCase.Time_With_Customer__c + updatedCase.Time_With_Support__c;
                    }
                }

                updatedCase.Last_Status_Change__c = System.now();
            }
        }
    }   

    static public void initBusinessHoursAges (Case[] newCases) {   
        for(Case newCase : newCases) {
            newCase.Last_Status_Change__c = System.now();
            newCase.Time_With_Customer__c = 0;
            newCase.Time_With_Support__c = 0;
            newCase.Case_Age_In_Business_Hours__c = 0;
            if (newCase.Status <> 'New') // cr 150222
                newCase.Status = 'New'; 
        }
    } 
    
    static public void calcCaseDurations (Case[] updatedCases, Map<ID, Case> oldMap) {   
 
        // As at 18/8/16 we shifted from Calendar days to Work Days
        list <case> c = new list<case>(); //list of cases to be updated
        Double Closed_Cal_Days = 0;
        Double Resolved_Cal_Days = 0;
        Boolean Close_Calc = false;
        Boolean Resolve_Calc = false;
        Id busHrsToUse;
        Integer hrsInDay = 12;
        
        //Get the default business hours 
        //Default Business Hours carry the work day hours. We take Monday Start and End Times to calculate the hours in the day.
        //
        //BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true limit 1]; 
        //
        //List<BusinessHours> BusHrs = [select Id, MondayStartTime, MondayEndTime from BusinessHours where IsDefault=true limit 1];
        //for (BusinessHours BusHr:BusHrs){
        //    busHrsToUse = BusHr.Id;
        //    hrsInDay = (BusHr.MondayEndTime.hour() - BusHr.MondayStartTime.hour());
        //}
        //
        hrsInDay = (defaultHours.MondayEndTime.hour() - defaultHours.MondayStartTime.hour());

        //For any case where the status is changed, recalc the business hours in the buckets
        for (Case updatedCase:updatedCases) {
            Case oldCase = oldMap.get(updatedCase.Id);
            
            Close_Calc = false;
            Resolve_Calc = false;
            Resolved_Cal_Days = 0;
            Closed_Cal_Days = 0;
            
            if (oldCase.ClosedDate != updatedCase.ClosedDate || oldCase.Resolved_Date__c != updatedCase.Resolved_Date__c) {
                if (oldCase.ClosedDate!=updatedCase.ClosedDate) {
                    if (updatedCase.ClosedDate!=null) {
                        //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
                        //Calculate Duration to Closed
                        Double duration;
                        duration = BusinessHours.diff(defaultHours.Id, updatedCase.CreatedDate, updatedCase.ClosedDate)/3600000.0;
                        Closed_Cal_Days = duration / hrsInDay;
                    }
                    
                    Close_Calc = true;
                }
                if (oldCase.Resolved_Date__c!=updatedCase.Resolved_Date__c) {
                    if (updatedCase.Resolved_Date__c!=null) {
                        //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
                        //Calculate Duration to Resolved
                        Double duration;
                        duration = BusinessHours.diff(defaultHours.Id, updatedCase.CreatedDate, updatedCase.Resolved_Date__c)/3600000.0;
                        Resolved_Cal_Days = duration / hrsInDay;
                    }
                    
                    Resolve_Calc = true;
                }
                
            }
            
            If (Close_Calc && Resolve_Calc){
                /*c.add(new Case(id = updatedCase.id, 
                               Duration_to_Closed_Cal_Days__c = Closed_Cal_Days,
                               Duration_to_Resolved_Cal_Days__c = Resolved_Cal_Days));*/
                               updatedCase.Duration_to_Closed_Cal_Days__c = Closed_Cal_Days;
                               updatedCase.Duration_to_Resolved_Cal_Days__c = Resolved_Cal_Days;
            }else if (Close_Calc) {
                        /*c.add(new Case(id = updatedCase.id, 
                               Duration_to_Closed_Cal_Days__c = Closed_Cal_Days));*/
                               updatedCase.Duration_to_Closed_Cal_Days__c = Closed_Cal_Days;
            }else if (Resolve_Calc) {
                        /*c.add(new Case(id = updatedCase.id, 
                               Duration_to_Resolved_Cal_Days__c = Resolved_Cal_Days));*/
                               updatedCase.Duration_to_Resolved_Cal_Days__c = Resolved_Cal_Days;
            }

        }
        
        /*if (!c.isEmpty()) {
            update c;
        }*/
    }   

    static public void calcTimeAwaitResAlloc (Case[] updatedCases, Map<ID, Case> oldMap) {   
 
        //if(!Test.isRunningTest()){
            //Get the default business hours 
            //BusinessHours defaultHours = [select Id, MondayStartTime, MondayEndTime from BusinessHours where IsDefault=true limit 1];
            Id hoursToUse = null;
            hoursToUse = defaultHours.Id;
            Integer hrsInDay = (defaultHours.MondayEndTime.hour() - defaultHours.MondayStartTime.hour());
                
            if (hoursToUse <> null){
                for (Case updatedCase:updatedCases) {
                    Case oldCase = oldMap.get(updatedCase.Id);
                    
                    if (oldCase.Status=='Awaiting Resource Allocation' && updatedCase.Status=='Scheduled') {
                        
                        //OK, the status has changed to match our conditions and the case was not closed
                        //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
                        Double timeSinceLastStatus =  0;
                        // Use the last status change date from the oldcase as this is when Awaiting Resource Allocation was set
                        if (updatedCase.Last_Status_Change__c != System.now()){
                            timeSinceLastStatus = BusinessHours.diff(hoursToUse, updatedCase.Last_Status_Change__c, System.now()) / 3600000.0 / hrsInDay;
                        }
                        updatedCase.Time_Await_Res_Alloc__c = timeSinceLastStatus; 
                        
                    }
                }
            }
        //}
    } 
    static public void calcAssignment(Case[] updatedCases, Map<ID, Case> oldMap) {
        List<Id> assignCases = new List<Id>();
        for(Case updatedCase : updatedCases) {
             Case beforeUpdate = oldMap.get(updatedCase.Id);
             
             if ((updatedCase.Customer_Product__c != beforeUpdate.Customer_Product__c || updatedCase.RecordType != beforeUpdate.RecordType ) && updatedCase.Status == 'New') { 
                // Status has been changed to resolved or Closed
                assignCases .add(updatedCase.Id);
              } 
        }
        
        if (assignCases .isEmpty() == false ){
             calcCaseAssignment.calcAssignment(assignCases);  
        } 
    }
    
}