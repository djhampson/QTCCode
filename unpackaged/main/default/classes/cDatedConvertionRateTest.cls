@isTest(SeeAllData=true)

public class cDatedConvertionRateTest {
    static testMethod void testRate1() {
        Date tDate = date.today();
        Date rDate =  Date.newInstance(tDate.year(),tDate.month(),1);
        String cCurrency = 'AUD';
        
        DatedConversionRate Rate1 = new DatedConversionRate(IsoCode ='AUD',ConversionRate = 1);
        Rate1.StartDate = rDate;
        //insert Rate1;
        
        decimal nRate = 1;
        nRate = cDatedConversionRate.getDatedConversionRate(cCurrency,rDate);
        System.assertEquals(nRate, 1);
        
    }
}