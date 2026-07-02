namespace Puris.Tests;

codeunit 50211 "PurisCompanyScopeCheckTests"
{
    Subtype = Test;

    // -----------------------------------------------------------------------
    // Positive-path tests for isProteins(), isGrains(), and isAllowed() cannot
    // be written here because CompanyName() is a session-level built-in that
    // returns the company the test runner is deployed to. It cannot be overridden
    // mid-test. To cover positive paths, deploy the test extension to a company
    // whose name contains 'proteins', 'Grains', or equals 'PURIS Grains' and
    // run the test runner from there.
    // -----------------------------------------------------------------------

    var
        CompanyScopeCheck: Codeunit CompanyScopeCheck;
        IsInitialized: Boolean;

    [Test]
    procedure isProteins_WhenCompanyNotProteins_ReturnsFalse()
    begin
        // [GIVEN] CompanyName does not contain 'proteins' (case-insensitive)
        Initialize();
        // [WHEN] isProteins() is called
        // [THEN] Returns false
        if CompanyScopeCheck.isProteins() then
            Error('isProteins() returned true for company ''%1''; expected false', CompanyName());
    end;

    [Test]
    procedure isGrains_WhenCompanyNotGrains_ReturnsFalse()
    begin
        // [GIVEN] CompanyName does not contain 'Grains' (case-sensitive check in implementation)
        Initialize();
        // [WHEN] isGrains() is called
        // [THEN] Returns false
        if CompanyScopeCheck.isGrains() then
            Error('isGrains() returned true for company ''%1''; expected false', CompanyName());
    end;

    [Test]
    procedure isAllowed_WhenCompanyNotPurisGrains_ReturnsFalse()
    begin
        // [GIVEN] CompanyName is not exactly 'PURIS Grains'
        Initialize();
        // [WHEN] isAllowed() is called
        // [THEN] Returns false — only exact match 'PURIS Grains' returns true
        if CompanyScopeCheck.isAllowed() then
            Error('isAllowed() returned true for company ''%1''; only ''PURIS Grains'' should return true', CompanyName());
    end;

    [Test]
    procedure isProteins_CaseInsensitive_ReturnsFalse()
    begin
        // [GIVEN] isProteins() applies ToLower() before Contains('proteins') — verify no accidental match
        Initialize();
        // [WHEN] isProteins() is called in a company with no protein-related name
        // [THEN] CompanyName.ToLower() does not contain 'proteins' — returns false
        if CompanyScopeCheck.isProteins() then
            Error('isProteins() case-insensitive check returned true for company ''%1''', CompanyName());
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;
        IsInitialized := true;
    end;
}
