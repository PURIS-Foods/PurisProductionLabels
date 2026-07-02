pageextension 50200 PurisProductionLabels extends "Released Production Order"
{

    actions
    {
        addlast("&Print")
        {
            action("Puris Production Labels")
            {
                ApplicationArea = All;
                Caption = 'Puris Production Labels';
                Image = Production;
                Visible = ShowProteinsFields;

                trigger OnAction()
                var
                    productionDataChecks: Codeunit PurisProductionDataChecks;
                    prodLineData: Record "Prod. Order Line";
                    routingData: record "Prod. Order Routing Line";
                    routingDataError: Integer;
                    prodLineError: Integer;

                begin

                    Rec.SetRange("No.", Rec."No.");
                    if Rec.FindSet() then begin

                        prodLineError := 0;
                        prodLineData.SetRange("Prod. Order No.", Rec."No.");
                        if prodLineData.FindSet() then begin
                            repeat
                                if (prodLineData."Routing No." = '') then
                                    prodLineError += 1;
                            until prodLineData.Next() = 0;

                            if prodLineError > 0 then
                                Message('Ensure all production order lines contain a routing number');
                        end;

                        routingDataError := 0;
                        routingData.SetRange("Prod. Order No.", Rec."No.");
                        if routingData.FindSet() then begin
                            repeat
                                if (routingData."Work Center No." = '') or (routingData."Operation No." = '') then
                                    routingDataError += 1;
                            until routingData.Next() = 0;

                            if routingData.Count() < prodLineData.count() then
                                routingDataError += 1;

                            if routingDataError > 0 then begin
                                Message('Operation No and Work Center No are missing from %1 line(s). Check Routing Information on Line -> Routing', (prodLineData.Count() - routingData.Count()));
                            end;
                        end;

                        if (prodLineError = 0) and (routingDataError = 0) then
                            Report.RunModal(Report::PurisProductionLabels, false, false, Rec);
                    end;
                end;
            }
        }
    }

    var
        ShowProteinsFields: Boolean;
        CompanyScopeCheck: Codeunit CompanyScopeCheck;

    trigger OnOpenPage()
    begin
        ShowProteinsFields := CompanyScopeCheck.isProteins();
        CurrPage.Update(false);
    end;
}