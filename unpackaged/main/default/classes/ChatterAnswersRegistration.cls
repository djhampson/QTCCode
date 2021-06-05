/**
 * This class has been generated to allow customization of Account creation for Chatter Answers Portal Users.
 * Chatter Answers requires that this class exist and implement ChatterAnswers.AccountCreator, renaming the class
 *   or removing the interface implementation is prohibited. */
public class ChatterAnswersRegistration implements ChatterAnswers.AccountCreator {
    public String createAccount(String firstname, String lastname, Id siteAdminId) {
         /*Account a = new Account(name = firstname + ' ' + lastname, ownerId = siteAdminId); */
          Account a = new Account(name = firstname + ' ' + lastname, ownerId = siteAdminId, CountryArea__c = 'Australia', Type = 'No business fit / Subsidiary - see note', T1_Industry__c = 'Other', Vertical_Market__c = 'Managed Services');
         insert a;
         return a.Id;
    }
}