@isTest
public class QuoteTriggerTest {
    
    @isTest
    static void testQuoteApprovalShiftsOpportunityStage() {
        List<OpportunityStage> activeStages = [
            SELECT MasterLabel 
            FROM OpportunityStage 
            WHERE IsActive = true 
            ORDER BY SortOrder ASC 
            LIMIT 2
        ];
        
        if(activeStages.size() < 2) {
            return; 
        }
        
        String firstStage = activeStages[0].MasterLabel;
        String secondStage = activeStages[1].MasterLabel;
        
        Account acc = new Account(Name = 'Stage Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Setup Shift Opp', 
            StageName = firstStage, 
            CloseDate = Date.today().addDays(30), 
            AccountId = acc.Id
        );
        insert opp;
        
        Quote testQuote = new Quote(
            Name = 'Shift Test Quote',
            OpportunityId = opp.Id,
            Status = 'Draft' 
        );
        insert testQuote;
        
        Opportunity initialOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(firstStage, initialOpp.StageName, 'Opportunity stage should initially match manual assignment');
        
        Test.startTest();
        testQuote.Status = 'Approved';
        update testQuote;
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(secondStage, updatedOpp.StageName, 'Opportunity stage should have automatically shifted sequentially');
    }
}
