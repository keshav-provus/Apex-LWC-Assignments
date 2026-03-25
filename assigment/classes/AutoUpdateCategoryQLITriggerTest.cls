@isTest
public class AutoUpdateCategoryQLITriggerTest {
    @isTest
    static void testCategoryAssignment() {
        Category__c testCat = new Category__c(Name = 'Software', Default_Discount__c = 10.0);
        insert testCat;

        Product2 testProduct = new Product2(
            Name = 'Cloud Service Gold', 
            Category__c = testCat.Id, 
            IsActive = true
        );
        insert testProduct;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = testProduct.Id, 
            UnitPrice = 500, 
            IsActive = true
        );
        insert pbe;

        Account acc = new Account(Name = 'Global Tech');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp', StageName = 'Prospecting', 
            CloseDate = Date.today(), AccountId = acc.Id
        );
        insert opp;

        Quote q = new Quote(
            Name = 'Test Quote', OpportunityId = opp.Id, 
            Pricebook2Id = pricebookId
        );
        insert q;

        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = q.Id, 
            PricebookEntryId = pbe.Id, 
            Quantity = 5, 
            UnitPrice = 500
        );
        
        Test.startTest();
        insert qli;
        Test.stopTest();
        
        QuoteLineItem insertedQli = [SELECT Category__c FROM QuoteLineItem WHERE Id = :qli.Id];
        System.assertEquals(testCat.Id, insertedQli.Category__c, 'QLI Category ID should match the Category assigned to Product2.');
    }
}
