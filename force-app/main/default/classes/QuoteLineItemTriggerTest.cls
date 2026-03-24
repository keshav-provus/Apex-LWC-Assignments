@isTest
public class QuoteLineItemTriggerTest {
    
    @isTest
    static void testQuoteLineItemCategoryAutomation() {
        // 1. Create the Category Record (Replace 'Category__c' with your Object API Name)
        // If your custom object is named 'Category__c', use that. 
        // If it's 'Product_Category__c', change it below.
        Category__c testCat = new Category__c(Name = 'Software');
        insert testCat;

        // 2. Setup Product - Link it to the Category ID, NOT the string "Software"
        Product2 testProduct = new Product2(
            Name = 'Cloud Service Gold', 
            Category__c = testCat.Id, 
            IsActive = true
        );
        insert testProduct;

        // 3. Setup Pricebook & Entry
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = testProduct.Id, 
            UnitPrice = 500, 
            IsActive = true
        );
        insert pbe;

        // 4. Setup Account, Opp, and Quote
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

        // 5. TEST INSERT
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = q.Id, 
            PricebookEntryId = pbe.Id, 
            Quantity = 1, 
            UnitPrice = 500
        );
        
        Test.startTest();
        insert qli;
        
        // 6. TEST UPDATE (Change Category)
        Category__c newCat = new Category__c(Name = 'Hardware');
        insert newCat;
        
        testProduct.Category__c = newCat.Id;
        update testProduct;
        
        update qli; 
        Test.stopTest();

        // Final Verification
        QuoteLineItem result = [SELECT Category__c FROM QuoteLineItem WHERE Id = :qli.Id];
        System.assertEquals(newCat.Id, result.Category__c, 'QLI Category ID should match the new Category record ID.');
    }
}