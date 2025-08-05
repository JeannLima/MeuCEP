unit uViaCepComponent;

interface

uses
  System.Classes, System.SysUtils, System.JSON, uCep, IdHTTP, IdSSLOpenSSL, IdGlobal,
  System.NetEncoding, System.Generics.Collections;

type
  TViaCepComponent = class(TComponent)
  private
    FHttpClient: TIdHTTP;
    function GetUrl(const ACep, AFormato: string): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ConsultarCep(const ACep, AFormato: string): TCep;
    function ConsultarPorEndereco(const UF, Cidade, Logradouro, AFormato: string): TList<TCep>;
    function EncodeURL(const AValue: string): string;
  end;

implementation

uses
  System.JSON.Serializers, IdURI, XMLDoc, XMLIntf;

{ TViaCepComponent }

constructor TViaCepComponent.Create(AOwner: TComponent);
begin
  inherited;
  FHttpClient := TIdHTTP.Create(nil);
end;

destructor TViaCepComponent.Destroy;
begin
  FHttpClient.Free;
  inherited;
end;

function TViaCepComponent.EncodeURL(const AValue: string): string;
begin
  Result := TIdURI.ParamsEncode(AValue);
end;

function TViaCepComponent.GetUrl(const ACep, AFormato: string): string;
begin
  if AFormato.ToUpper = 'JSON' then
    Result := Format('https://viacep.com.br/ws/%s/json/', [ACep])
  else
    Result := Format('https://viacep.com.br/ws/%s/xml/', [ACep]);
end;

function TViaCepComponent.ConsultarCep(const ACep, AFormato: string): TCep;
var
  Http: TIdHTTP;
  ResponseStream: TStringStream;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStr: string;
  JsonValue: TJSONObject;

begin
  Result := TCep.Create;
  Http   := TIdHTTP.Create(nil);
  SSL    := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  ResponseStream := TStringStream.Create('', TEncoding.UTF8);

  try
    SSL.SSLOptions.Method      := sslvTLSv1_2;
    SSL.SSLOptions.SSLVersions := [sslvTLSv1_2];
    Http.IOHandler             := SSL;
    Http.Request.ContentType   := 'application/json';
    Http.Request.UserAgent     := 'Mozilla/5.0';

    try
      Http.Get(GetUrl(ACep, AFormato), ResponseStream);
    except
      on E: Exception do
        begin
          raise Exception.Create('Erro ao consultar o CEP: ' + E.Message);
        end;
    end;

    ResponseStream.Position := 0;
    ResponseStr := ResponseStream.DataString;

    if AFormato.ToUpper = 'JSON' then
      begin
        JsonValue := TJSONObject.ParseJSONValue(ResponseStr) as TJSONObject;
        try
          if Assigned(JsonValue) and JsonValue.TryGetValue('erro', ResponseStr) then
            raise Exception.Create('CEP inválido ou não encontrado.');

          Result := TCep.Create;
          Result.Cep         := JsonValue.GetValue<string>('cep');
          Result.Logradouro  := JsonValue.GetValue<string>('logradouro');
          Result.Complemento := JsonValue.GetValue<string>('complemento');
          Result.Bairro      := JsonValue.GetValue<string>('bairro');
          Result.Localidade  := JsonValue.GetValue<string>('localidade');
          Result.Uf          := JsonValue.GetValue<string>('uf');
        finally
          JsonValue.Free;
        end;
      end
    else if AFormato.ToUpper = 'XML' then
      begin
        var XMLDoc: IXMLDocument;
        var RootNode, Node: IXMLNode;

        XMLDoc := TXMLDocument.Create(nil);
        XMLDoc.LoadFromXML(ResponseStr);
        XMLDoc.Active := True;

        RootNode := XMLDoc.DocumentElement;

        if Assigned(RootNode) then
          begin
            Result.Cep         := RootNode.ChildNodes['cep'].Text;
            Result.Logradouro  := RootNode.ChildNodes['logradouro'].Text;
            Result.Complemento := RootNode.ChildNodes['complemento'].Text;
            Result.Bairro      := RootNode.ChildNodes['bairro'].Text;
            Result.Localidade  := RootNode.ChildNodes['localidade'].Text;
            Result.Uf          := RootNode.ChildNodes['uf'].Text;
          end;
      end;
  finally
    ResponseStream.Free;
    SSL.Free;
    Http.Free;
  end;
end;

function TViaCepComponent.ConsultarPorEndereco(const UF, Cidade, Logradouro, AFormato: string): TList<TCep>;
var
  Http: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStream: TStringStream;
  ResponseStr: string;
  JsonArray: TJSONArray;
  JsonItem: TJSONObject;
  XmlDoc: IXMLDocument;
  XmlNode: IXMLNode;
  ItemCep: TCep;
  i: Integer;
  URL: string;
begin
  Result := TList<TCep>.Create;
  Http := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  ResponseStream := TStringStream.Create('', TEncoding.UTF8);
  try
    SSL.SSLOptions.Method := sslvTLSv1_2;
    SSL.SSLOptions.SSLVersions := [sslvTLSv1_2];
    Http.IOHandler := SSL;
    Http.Request.UserAgent := 'Mozilla/5.0';

    if SameText(AFormato, 'XML') then
      Http.Request.Accept := 'application/xml'
    else
      Http.Request.Accept := 'application/json';

    if SameText(AFormato, 'XML') then
      URL := Format('https://viacep.com.br/ws/%s/%s/%s/xml/',
                    [EncodeURL(UF), EncodeURL(Cidade), EncodeURL(Logradouro)])
    else
      URL := Format('https://viacep.com.br/ws/%s/%s/%s/json/',
                    [EncodeURL(UF), EncodeURL(Cidade), EncodeURL(Logradouro)]);

    Http.Get(URL, ResponseStream);
    ResponseStr := ResponseStream.DataString;

    if SameText(AFormato, 'JSON') then
      begin
        JsonArray := TJSONObject.ParseJSONValue(ResponseStr) as TJSONArray;
        try
          for i := 0 to JsonArray.Count - 1 do
            begin
              JsonItem := JsonArray.Items[i] as TJSONObject;
              ItemCep := TCep.Create;
              ItemCep.Cep         := JsonItem.GetValue<string>('cep');
              ItemCep.Logradouro  := JsonItem.GetValue<string>('logradouro');
              ItemCep.Complemento := JsonItem.GetValue<string>('complemento');
              ItemCep.Bairro      := JsonItem.GetValue<string>('bairro');
              ItemCep.Localidade  := JsonItem.GetValue<string>('localidade');
              ItemCep.Uf          := JsonItem.GetValue<string>('uf');
              Result.Add(ItemCep);
            end;
        finally
          JsonArray.Free;
        end;
      end
    else if SameText(AFormato, 'XML') then
      begin
        XmlDoc := LoadXMLData(ResponseStr);
        var EnderecosNode := XmlDoc.DocumentElement.ChildNodes['enderecos'];

        for i := 0 to EnderecosNode.ChildNodes.Count - 1 do
          begin
            XmlNode := EnderecosNode.ChildNodes[i];

            ItemCep := TCep.Create;
            ItemCep.Cep         := XmlNode.ChildNodes['cep'].Text;
            ItemCep.Logradouro  := XmlNode.ChildNodes['logradouro'].Text;
            ItemCep.Complemento := XmlNode.ChildNodes['complemento'].Text;
            ItemCep.Bairro      := XmlNode.ChildNodes['bairro'].Text;
            ItemCep.Localidade  := XmlNode.ChildNodes['localidade'].Text;
            ItemCep.Uf          := XmlNode.ChildNodes['uf'].Text;

            Result.Add(ItemCep);
          end;
      end;
  finally
    ResponseStream.Free;
    SSL.Free;
    Http.Free;
  end;
end;


end.

