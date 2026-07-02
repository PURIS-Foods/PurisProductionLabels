codeunit 50201 "CompanyScopeCheck"
{
    procedure isAllowed(): Boolean
    begin
        exit(CompanyName = 'PURIS Grains')
    end;

    procedure isGrains(): Boolean
    begin
        if (CompanyName.Contains('Grains')) then
            exit(true)
        else
            exit(false);
    end;


    procedure isProteins(): Boolean
    begin
        if (CompanyName.ToLower().Contains('proteins')) then
            exit(true)
        else
            exit(false)
    end;
}