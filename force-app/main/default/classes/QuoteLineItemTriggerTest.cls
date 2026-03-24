@isTest
public class QuoteLineItemTriggerTest {
    
    @isTest
    static void testQuoteLineItemCategoryAutomation() {
        Category__c testCat = new Category__c(Name = 'Software', Default_Discount__c = 10.0);
        insert testCat;

        Quantitiy_Tier__c testTier = new Quantitiy_Tier__c(
            Name = 'Tier 1',
            Category__c = testCat.Id,
            Minimum_Quantity__c = 1,
            Maximum_Quantity__c = 10,
            Discount__c = 5.0
        );
        insert testTier;

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
            UnitPrice = 500,
            Offered_Discount__c = 2.0
        );
        
        Test.startTest();
        insert qli;
        
        QuoteLineItem insertedQli = [SELECT Category__c, Category_Based_Discount__c, Quantitiy_Tier_Discount__c, Discount FROM QuoteLineItem WHERE Id = :qli.Id];
        System.assertEquals(testCat.Id, insertedQli.Category__c, 'QLI Category ID should match the Category record ID.');
        System.assertEquals(10.0, insertedQli.Category_Based_Discount__c, 'Category discount should be 10.0');
        System.assertEquals(5.0, insertedQli.Quantitiy_Tier_Discount__c, 'Quantity tier discount should be 5.0');
        System.assertEquals(17.0, insertedQli.Discount, 'Total discount should be 17.0');

        Category__c newCat = new Category__c(Name = 'Hardware', Default_Discount__c = 15.0);
        insert newCat;
        
        testProduct.Category__c = newCat.Id;
        update testProduct;
        
        qli.Quantity = 15; 
        update qli; 
        Test.stopTest();

        QuoteLineItem updatedQli = [SELECT Category__c, Category_Based_Discount__c, Quantitiy_Tier_Discount__c, Discount FROM QuoteLineItem WHERE Id = :qli.Id];
        System.assertEquals(newCat.Id, updatedQli.Category__c, 'QLI Category ID should match the new Category record ID.');
        System.assertEquals(15.0, updatedQli.Category_Based_Discount__c, 'Category discount should be updated to 15.0');
        System.assertEquals(0.0, updatedQli.Quantitiy_Tier_Discount__c, 'Quantity tier discount should be 0.0 with no matching tier');
        System.assertEquals(17.0, updatedQli.Discount, 'Total discount should be 17.0');
    }
}