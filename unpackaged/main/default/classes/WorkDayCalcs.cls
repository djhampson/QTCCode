public class WorkDayCalcs {

  //Calculate Nth business day 
  public static Date calculateNthWorkingDay(Date fromDate, Integer N, List<Holiday> holidays){

    //Query holidays from Org  
    //List<Holiday> holidays=[Select StartTimeInMinutes, Name, ActivityDate From Holiday ];

    Date NthDay = fromDate; 
    
    for(Integer k=0;k<N ;k++ ){
        if(checkifWorkDayFU(NthDay.addDays(1),holidays)){                        
            NthDay = NthDay.addDays(1);
        } 
        else
        {
          NthDay = NthDay.addDays(1);
          k--;
        }
    }

    return NthDay;//return Nth Business day

  }
  //Advance if Holiday, Saturday or Sunday
  public static Date advanceIfNonworking(Date DateIn, List<Holiday> holidays){

    //Get holidays  
    //List<Holiday> holidays=[Select StartTimeInMinutes, Name, ActivityDate From Holiday ];

    Date DayOut = DateIn; 
    
    while (checkifWorkDay(DayOut,holidays) == false){                        
        DayOut = DayOut.addDays(1);
    } 

    return DayOut ;//return the working day

  }

//Advance if Holiday, Saturday or Sunday
public static Date advanceIfNonworkingFU(Date DateIn, List<Holiday> holidays){

  //Get holidays  
  //List<Holiday> holidays=[Select StartTimeInMinutes, Name, ActivityDate From Holiday ];

  Date DayOut = DateIn; 
  
  while (checkifWorkDayFU(DayOut,holidays) == false){                        
      DayOut = DayOut.addDays(1);
  } 

  return DayOut ;//return the working day

}
//To check if sent date is a working day by comparing with org holidays
public static boolean checkifWorkDay(Date sentDate,List<Holiday> holidays){
    
    Date weekStart  = sentDate.toStartofWeek();
    
    for(Holiday hday:holidays){
            if(sentDate.daysBetween(hday.ActivityDate) == 0)                        
            return false;                        
    }
    
    // check if Sunday or Saturday
    if(weekStart.daysBetween(sentDate) ==0 || weekStart.daysBetween(sentDate) == 6)
    {
           return false;
    } else 
           return true;
  }

  //To check if sent date is a working day by comparing with org holidays
  public static boolean checkifWorkDayFU(Date sentDate,List<Holiday> holidays){
    
    Date weekStart  = sentDate.toStartofWeek();
    Date startDate = date.valueof('1901-01-01');
    Date endDate = date.valueof('1901-01-01');

    T1_Control_Settings__c custs = T1_Control_Settings__c.getOrgDefaults();
    if (custs.Case_Followup_Amnesty_Start__c <> NULL && custs.Case_Followup_Amnesty_End__c <> NULL){
        startDate = date.valueOf(custs.Case_Followup_Amnesty_Start__c);
        endDate = date.valueOf(custs.Case_Followup_Amnesty_End__c);
    }
    
    for(Holiday hday:holidays){
            if(sentDate.daysBetween(hday.ActivityDate) == 0 || (sentDate >= startDate && sentDate <= endDate))                        
            return false;                        
    }
    
    // check if Sunday or Saturday
    if(weekStart.daysBetween(sentDate) ==0 || weekStart.daysBetween(sentDate) == 6)
    {
           return false;
    } else 
           return true;
  }



}