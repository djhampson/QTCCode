trigger IdeaNumberIncrement on Idea (before insert) {
if (trigger.isBefore && trigger.isInsert)
  {
  
    // bypass trigger processing START
    T1_Control_Settings__c s = T1_Control_Settings__c.getInstance( UserInfo.GetUserID() ); //or Profile
     
    if( s.Bypass_Triggers__c) return; // skip trigger...
    // bypass trigger processing END
  
    // ---- GENERATE IDEA NUMBER, AUTO RUNNING NUMBER, RESET EVERY MONTH BASED ON Created Date --- //
    // ---- IDEA NUMBER FORMAT : {YYYY}{MM}-{000} --//
    Integer iCharLen = 3; // character length for number
    Integer iLastNo = 0; // information last running number this year
    String strZero = '0';
    
    // search type of idea month, because possible to have trigger for different month
    String strMonthCode = '';
    String strTemp;
    Map<String, Integer> mapMonthLast = new Map<String, Integer>(); // map of last number for a month
    strMonthCode = String.ValueOf(System.Today().year()) + String.ValueOf(System.Today().month());
    System.debug('Loading array - YearMonth ' +  String.ValueOf(System.Today().year()) + String.ValueOf(System.Today().month()));
    mapMonthLast.put(strMonthCode, 0); // add default last number
    // cater for internal zone idea number prefixed with E
    strMonthCode = 'E' + String.ValueOf(System.Today().year()) + String.ValueOf(System.Today().month());
    System.debug('Loading array - YearMonth E' +  String.ValueOf(System.Today().year()) + String.ValueOf(System.Today().month()));
    mapMonthLast.put(strMonthCode, 0); // add default last number
    
    // CreatedDate is not accessible at this point
    /* for (Idea i: trigger.new)
    {
      strMonthCode = String.ValueOf(i.CreatedDate.year()) + String.ValueOf(i.CreatedDate.month());
      System.debug('Loading array - YearMonth ' +  String.ValueOf(i.CreatedDate.year()) + String.ValueOf(i.CreatedDate.month()));
      mapMonthLast.put(strMonthCode, 0); // add default last number
    } */
    
    // search latest idea number
    List<String> arrStr = new List<String>();
    Set<String> setMonthCode = mapMonthLast.keyset();
    for (AggregateResult ar : [Select CALENDAR_YEAR(convertTimezone(CreatedDate)) idea_year, CALENDAR_MONTH(convertTimezone(CreatedDate)) idea_month, MAX(idea_number__c) idea_number From Idea 
                               WHERE IsDeleted = false and (not idea_number__c like 'E%')
                               GROUP BY CALENDAR_YEAR(convertTimezone(CreatedDate)), CALENDAR_MONTH(convertTimezone(CreatedDate))
                              ])
    {
        strTemp = String.valueOf(ar.get('idea_number'));
        System.debug('Updating array - Idea number ' + strtemp);
        arrStr = strTemp.split('-');
        System.debug('Last Number after split ' + arrStr);
        System.debug('arrStr.size() ' + arrStr.size());

        strMonthCode = String.valueOf(ar.get('idea_year')) + String.valueOf(ar.get('idea_month'));
        System.debug('Updating array - strMonthCode ' + strMonthCode);
        if (arrStr.size() > 1 && arrStr[1].isNumeric()) mapMonthLast.put(strMonthCode, Integer.valueOf(arrStr[1]));
        System.debug('LastNo for strMonthCode ' + arrStr[1] + ' Full string ' + arrStr);
    }
    //Process E prefixes
    for (AggregateResult ar : [Select CALENDAR_YEAR(convertTimezone(CreatedDate)) idea_year, CALENDAR_MONTH(convertTimezone(CreatedDate)) idea_month, MAX(idea_number__c) idea_number From Idea 
                               WHERE IsDeleted = false and idea_number__c like 'E%'
                               GROUP BY CALENDAR_YEAR(convertTimezone(CreatedDate)), CALENDAR_MONTH(convertTimezone(CreatedDate))
                              ])
    {
        strTemp = String.valueOf(ar.get('idea_number'));
        System.debug('Updating array - Idea number ' + strtemp);
        arrStr = strTemp.split('-');
        System.debug('Last Number after split ' + arrStr);
        System.debug('arrStr.size() ' + arrStr.size());

        strMonthCode = 'E' + String.valueOf(ar.get('idea_year')) + String.valueOf(ar.get('idea_month'));
        System.debug('Updating array - strMonthCode ' + strMonthCode);
        if (arrStr.size() > 1 && arrStr[1].isNumeric()) mapMonthLast.put(strMonthCode, Integer.valueOf(arrStr[1]));
        System.debug('LastNo for strMonthCode ' + arrStr[1] + ' Full string ' + arrStr);
    }
    
    // start generate number
    String strNo = '';
    for(Idea i2: trigger.new)
    {
      iLastNo = 0; // init
      String strZone;
      strZone = [SELECT name 
            FROM Community
            WHERE Id = :i2.CommunityId ].name;
       
      if (strZone.startswith('Internal')) {
          strMonthCode = 'E' + String.ValueOf(System.Today().year()) + String.ValueOf(System.Today().month());
        }
      else {
          strMonthCode = String.ValueOf(System.Today().year()) + String.ValueOf(System.Today().month());
      } 
      
      if (mapMonthLast.containsKey(strMonthCode)) iLastNo = mapMonthLast.get(strMonthCode);
      iLastNo++; // update to next number
      strTemp = String.valueOf(iLastNo);
      if (strTemp.length() < iCharLen) strTemp = strZero.repeat(iCharLen - strTemp.length()) + strTemp; // add 0 prefix
      
      strNo  = String.ValueOf(System.Today().year());
      strNo += (System.Today().month() < 10) ? '0' + String.ValueOf(System.Today().month()) : String.ValueOf(System.Today().month());
      strNo += '-' + strTemp;
      if (i2.Idea_Number__c == null) {
          if (strZone.startswith('Internal')) {
              i2.Idea_Number__c = 'E' + strNo; // update field
              }
          else {
              i2.Idea_Number__c = strNo;
              // CR 221832 - Idea Number now available as separate field via App Pkg
              //String strBody;
              //strBody = 'Idea Number - ' + strNo + '<br><br>' + i2.Body;
              //i2.Body = strBody;
            }          
      }
      System.debug('Idea number generated ' + strNo);
      
      mapMonthLast.put(strMonthCode, iLastNo); // update map info      
    } 
  
  }
}