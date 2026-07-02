codeunit 50202 PurisProductionDataChecks
{
    procedure orderHasRoutingAndWorkCenter(productionOrderNumber: Code[20]): Integer
    var
        routingData: record "Prod. Order Routing Line";
        errorCount: Integer;

    begin
        routingData.SetRange("Prod. Order No.", productionOrderNumber);
        errorCount := 0;
        if routingData.FindSet() then
            repeat
                if (routingData."Work Center No." = '') or (routingData."Operation No." = '') then
                    errorCount += 1;
            until routingData.Next() = 0;

        if errorCount > 0 then begin
            Error('Operation No and Work Center No are missing from %1 lines. Check Routing Information on Line -> Routing');
            exit(errorCount);
        end
        else
            exit(0);
    end;
}