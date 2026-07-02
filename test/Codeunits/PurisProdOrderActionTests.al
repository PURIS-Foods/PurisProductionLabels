namespace Puris.Tests;

using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Routing;

codeunit 50213 "PurisProdOrderActionTests"
{
    Subtype = Test;

    // -----------------------------------------------------------------------
    // These tests must be run from a BC company whose name contains 'proteins'
    // (e.g. 'PURIS Proteins'). The Print Production Labels action is hidden via
    // ShowProteinsFields when CompanyName() does not contain 'proteins', making
    // the action uninvokable from any other company.
    // -----------------------------------------------------------------------

    var
        IsInitialized: Boolean;
        TestOrderNo: Code[20];

    [Test]
    [HandlerFunctions('HandleMessage')]
    procedure PrintAction_MissingRoutingNo_ShowsMessage()
    var
        ReleasedProdOrderPage: TestPage "Released Production Order";
    begin
        // [GIVEN] A released production order with a prod line that has no Routing No.
        Initialize();
        InsertProductionOrder(TestOrderNo);
        InsertProdOrderLine(TestOrderNo, 10000, '');

        // [WHEN] The Print Production Labels action is invoked
        ReleasedProdOrderPage.OpenEdit();
        ReleasedProdOrderPage.GoToKey("Production Order Status"::Released, TestOrderNo);
        ReleasedProdOrderPage."Puris Production Labels".Invoke();
        ReleasedProdOrderPage.Close();

        // [THEN] A warning message is shown (caught by HandleMessage) and the report is not run
    end;

    [Test]
    [HandlerFunctions('HandleMessage')]
    procedure PrintAction_MissingWorkCenter_ShowsMessage()
    var
        ReleasedProdOrderPage: TestPage "Released Production Order";
    begin
        // [GIVEN] A prod line with a Routing No. but the routing line has no Work Center No.
        Initialize();
        InsertProductionOrder(TestOrderNo);
        InsertProdOrderLine(TestOrderNo, 10000, 'ROUTE-001');
        InsertRoutingLine(TestOrderNo, 10000, '10', '');

        // [WHEN] The Print Production Labels action is invoked
        ReleasedProdOrderPage.OpenEdit();
        ReleasedProdOrderPage.GoToKey("Production Order Status"::Released, TestOrderNo);
        ReleasedProdOrderPage."Puris Production Labels".Invoke();
        ReleasedProdOrderPage.Close();

        // [THEN] A warning message is shown and the report is not run
    end;

    [Test]
    [HandlerFunctions('HandleMessage')]
    procedure PrintAction_RoutingCountLessThanLineCount_ShowsMessage()
    var
        ReleasedProdOrderPage: TestPage "Released Production Order";
    begin
        // [GIVEN] Two prod order lines but only one routing line
        Initialize();
        InsertProductionOrder(TestOrderNo);
        InsertProdOrderLine(TestOrderNo, 10000, 'ROUTE-001');
        InsertProdOrderLine(TestOrderNo, 20000, 'ROUTE-001');
        InsertRoutingLine(TestOrderNo, 10000, '10', 'WC-001');

        // [WHEN] The Print Production Labels action is invoked
        ReleasedProdOrderPage.OpenEdit();
        ReleasedProdOrderPage.GoToKey("Production Order Status"::Released, TestOrderNo);
        ReleasedProdOrderPage."Puris Production Labels".Invoke();
        ReleasedProdOrderPage.Close();

        // [THEN] A warning message is shown and the report is not run
    end;

    [Test]
    [HandlerFunctions('HandleReport')]
    procedure PrintAction_AllDataValid_RunsReport()
    var
        ReleasedProdOrderPage: TestPage "Released Production Order";
    begin
        // [GIVEN] A prod line with a Routing No. and a matching routing line with all fields set
        Initialize();
        InsertProductionOrder(TestOrderNo);
        InsertProdOrderLine(TestOrderNo, 10000, 'ROUTE-001');
        InsertRoutingLine(TestOrderNo, 10000, '10', 'WC-001');

        // [WHEN] The Print Production Labels action is invoked
        ReleasedProdOrderPage.OpenEdit();
        ReleasedProdOrderPage.GoToKey("Production Order Status"::Released, TestOrderNo);
        ReleasedProdOrderPage."Puris Production Labels".Invoke();
        ReleasedProdOrderPage.Close();

        // [THEN] The report runs (caught by HandleReport) — no warning messages shown
    end;

    [MessageHandler]
    procedure HandleMessage(Message: Text[1024])
    begin
        // Absorbs warning messages shown when validation fails.
        // Reaching this handler confirms a message was shown.
    end;

    [ReportHandler]
    procedure HandleReport(var PurisProductionLabels: Report "PurisProductionLabels")
    begin
        // Suppresses actual report rendering.
        // Reaching this handler confirms the report was invoked.
    end;

    local procedure Initialize()
    var
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        RoutingLine: Record "Prod. Order Routing Line";
    begin
        TestOrderNo := 'TEST-PA-001';

        ProdOrder.SetRange(ProdOrder."No.", TestOrderNo);
        ProdOrder.DeleteAll();

        ProdOrderLine.SetRange(ProdOrderLine."Prod. Order No.", TestOrderNo);
        ProdOrderLine.DeleteAll();

        RoutingLine.SetRange(RoutingLine."Prod. Order No.", TestOrderNo);
        RoutingLine.DeleteAll();

        if IsInitialized then
            exit;
        IsInitialized := true;
    end;

    local procedure InsertProductionOrder(OrderNo: Code[20])
    var
        ProdOrder: Record "Production Order";
    begin
        ProdOrder.Init();
        ProdOrder.Status := "Production Order Status"::Released;
        ProdOrder."No." := OrderNo;
        ProdOrder.Insert();
    end;

    local procedure InsertProdOrderLine(OrderNo: Code[20]; LineNo: Integer; RoutingNo: Code[20])
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProdOrderLine.Init();
        ProdOrderLine.Status := "Production Order Status"::Released;
        ProdOrderLine."Prod. Order No." := OrderNo;
        ProdOrderLine."Line No." := LineNo;
        ProdOrderLine."Routing No." := RoutingNo;
        ProdOrderLine.Insert();
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
