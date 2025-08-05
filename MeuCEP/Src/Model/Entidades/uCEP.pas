unit uCEP;

interface

type
  TCep = class
    private
    FCodigo: Integer;
    FCep: string;
    FLogradouro: string;
    FComplemento: string;
    FBairro: string;
    FLocalidade: string;
    FUf: string;
  public
    property Codigo: Integer read FCodigo write FCodigo;
    property Cep: string read FCep write FCep;
    property Logradouro: string read FLogradouro write FLogradouro;
    property Complemento: string read FComplemento write FComplemento;
    property Bairro: string read FBairro write FBairro;
    property Localidade: string read FLocalidade write FLocalidade;
    property Uf: string read FUf write FUf;

    function ToJson: string;
    class function FromJson(const AJson: string): TCep;
  end;

implementation

{ TCep }

uses
  System.JSON, REST.JSON;

function TCep.ToJson: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

class function TCep.FromJson(const AJson: string): TCep;
begin
  Result := TJson.JsonToObject<TCep>(AJson);
end;

end.
