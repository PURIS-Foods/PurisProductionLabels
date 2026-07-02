namespace Puris.Tests;

using Microsoft.Manufacturing.Routing;
using Microsoft.Manufacturing.Document;

codeunit 50212 "PurisProductionDataChecksTests"
{
    Subtype = Test;

    var
        ProductionDataChecks: Codeunit PurisProductionDataChecks;
        IsInitialized: Boolean;
        TestOrderNo: Code[20];

    [Test]
    procedure AllLinesValid_ReturnsZero()
    var
        Result: Integer;
    begin
        // [GIVEN] Two routing lines both with Work Center No. and Operation No. populated
        Initialize();
        InsertRoutingLine(TestOrderNo, 10000, '10', 'WC-001');
        InsertRoutingLine(TestOrderNo, 20000, '20', 'WC-001');

        // [WHEN] orderHasRoutingAndWorkCenter is called
        Result := ProductionDataChecks.orderHasRoutingAndWorkCenter(TestOrderNo);

        // [THEN] Returns 0 — no validation errors
        if Result <> 0 then
            Error('Expected 0 errors but got %1', Result);
    end;

    [Test]
    procedure MissingWorkCenter_ThrowsError()
    begin
        // [GIVEN] A routing line with blank Work Center No.
        Initialize();
        InsertRoutingLine(TestOrderNo, 10000, '10', '');

        // [WHEN] orderHasRoutingAndWorkCenter is called
        // [THEN] Error() is thrown
        AssertError ProductionDataChecks.orderHasRoutingAndWorkCenter(TestOrderNo);
    end;

    [Test]
    procedure MissingOperationNo_ThrowsError()
    begin
        // [GIVEN] A routing line with blank Operation No.
        Initialize();
        InsertRoutingLine(TestOrderNo, 10000, '', 'WC-001');

        // [WHEN] orderHasRoutingAndWorkCenter is called
        // [THEN] Error() is thrown
        AssertError ProductionDataChecks.orderHasRoutingAndWorkCenter(TestOrderNo);
    end;

    [Test]
    procedure NoRoutingLines_ReturnsZero()
    var
        Result: Integer;
    begin
        // [GIVEN] No routing lines exist for the order number
        Initialize();

        // [WHEN] orderHasRoutingAndWorkCenter is called with no matching records
        Result := ProductionDataChecks.orderHasRoutingAndWorkCenter(TestOrderNo);

        // [THEN] Returns 0 — no routing lines means nothing to validate
        if Result <> 0 then
            Error('Expected 0 errors for order with no routing lines but got %1', Result);
    end;

    local procedure Initialize()
    var
        RoutingLine: Record "Prod. Order Routing Line";
    begin
        // Always wipe test data so each test starts clean
        TestOrderNo := 'TEST-0001';
        RoutingLine.SetRange(RoutingLine."Prod. Order No.", TestOrderNo);
        RoutingLine.DeleteAll();

        if IsInitialized then
            exit;
        IsInitialized := true;
    end;

    local procedure InsertRoutingLine(OrderNo: Code[20]; RoutingRefNo: Integer; OperationNo: Code[10]; WorkCenterNo: Code[20])
    var
        RoutingLine: Record "Prod. Order Routing Line";
    begin
        RoutingLine.Init();
        RoutingLine.Status := RoutingLine.Status::Released;
        RoutingLine."Prod. Order No." := OrderNo;
        RoutingLine."Routing Reference No." := RoutingRefNo;
        RoutingLine."Operation No." := OperationNo;
        RoutingLine."Work Center No." := WorkCenterNo;
        RoutingLine.Insert();
    end;
}
