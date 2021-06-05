public class cDatedConversionRate {
    public static decimal getDatedConversionRate(String cCode, Date sDate) {
        //setup default rate
        decimal Conversion_Rate = 1;
        
        //search dated conversion rate for exact Start Date
        List <DatedConversionRate> dcRates=[SELECT Id, IsoCode, ConversionRate, StartDate
        									FROM DatedConversionRate
        									WHERE (StartDate =:sDate and IsoCode =: cCode ) limit 1  ];
        if (dcRates.size()>0)
            Conversion_Rate = dcRates.get(0).ConversionRate;
        else {

            Date nDate =  Date.newInstance(9999,12,31); 
            
            //search dated conversion rate for next Start Date            
            dcRates=[SELECT Id, IsoCode, ConversionRate, StartDate
                     FROM DatedConversionRate
                     WHERE (NextStartDate =:nDate and IsoCode =: cCode ) limit 1  ];
            if (dcRates.size()>0)
            Conversion_Rate = dcRates.get(0).ConversionRate;
        }
            
        return Conversion_Rate;
    }
}