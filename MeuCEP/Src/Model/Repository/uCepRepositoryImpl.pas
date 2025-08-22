unit uCepRepositoryImpl;

interface

uses
  System.Generics.Collections, FireDAC.Comp.Client,
  uCep, uCepRepository, System.SysUtils,
  System.Classes, Data.DB, uViaCepComponent, FireDAC.Stan.Param;

type
  TCepRepositoryImpl = class(TInterfacedObject, ICepRepository)
  private
    FQuery: TFDQuery;
    FViaCepComp: TViaCepComponent;
  public
    constructor Create(AQuery: TFDQuery);
    destructor Destroy; override;
    function ObterTodos: TList<TCep>;

    function BuscarNoBancoPorCep(const ACep: string): TList<TCep>;
    function BuscarNoBancoPorEndereco(const AEndereco: string): TList<TCep>;

    procedure AtualizarCepNoBanco(const ACep: TCep);
    procedure InserirCepNoBanco(const ACep: TCep);

    procedure AtualizarEnderecoNoBanco(const ACep: TCep);
    procedure InserirEnderecoNoBanco(const ListaEnderecos: TList<TCep>);

    function ConsultarCepViaApi(const ACep, AFormato: string): TCep;
    function ConsultarEnderecoViaApi(const AEndereco, AFormato: string): TList<TCep>;
  end;

implementation

{ TCepRepository }

constructor TCepRepositoryImpl.Create(AQuery: TFDQuery);
begin
  FQuery      := AQuery;
  FViaCepComp := TViaCepComponent.Create(nil);
end;

destructor TCepRepositoryImpl.Destroy;
begin
  FViaCepComp.Free;
  inherited;
end;

procedure TCepRepositoryImpl.InserirCepNoBanco(const ACep: TCep);
begin
  FQuery.Close;
  FQuery.SQL.Text := 'INSERT INTO Ceps (cep, logradouro, complemento, bairro, localidade, uf) ' +
                     'VALUES (:cep, :logradouro, :complemento, :bairro, :localidade, :uf)';

  FQuery.Params.ParamByName('cep').AsString         := ACep.Cep;
  FQuery.Params.ParamByName('logradouro').AsString  := ACep.Logradouro;
  FQuery.Params.ParamByName('complemento').AsString := ACep.Complemento;
  FQuery.Params.ParamByName('bairro').AsString      := ACep.Bairro;
  FQuery.Params.ParamByName('localidade').AsString  := ACep.Localidade;
  FQuery.Params.ParamByName('uf').AsString          := ACep.Uf;
  FQuery.ExecSQL;
end;

procedure TCepRepositoryImpl.InserirEnderecoNoBanco(const ListaEnderecos: TList<TCep>);
var
  Cep: TCep;
begin
  for Cep in ListaEnderecos do
    begin
      InserirCepNoBanco(Cep);
    end;
end;

function TCepRepositoryImpl.ObterTodos: TList<TCep>;
var
  Lista: TList<TCep>;
  Cep: TCep;
begin
  Lista := TList<TCep>.Create;
  FQuery.Close;
  FQuery.SQL.Text := 'SELECT * FROM Ceps';
  FQuery.Open;

  while not FQuery.Eof do
    begin
      Cep            := TCep.Create;
      Cep.Codigo     := FQuery.FieldByName('codigo').AsInteger;
      Cep.Cep        := FQuery.FieldByName('cep').AsString;
      Cep.Logradouro := FQuery.FieldByName('logradouro').AsString;
      Cep.Complemento:= FQuery.FieldByName('complemento').AsString;
      Cep.Bairro     := FQuery.FieldByName('bairro').AsString;
      Cep.Localidade := FQuery.FieldByName('localidade').AsString;
      Cep.Uf         := FQuery.FieldByName('uf').AsString;
      Lista.Add(Cep);
      FQuery.Next;
    end;
  Result := Lista;
end;

procedure TCepRepositoryImpl.AtualizarCepNoBanco(const ACep: TCep);
begin
  FQuery.Close;
  FQuery.SQL.Text := 'UPDATE Ceps SET                                       '+
                     'logradouro = :logradouro, complemento = :complemento, ' +
                     'bairro = :bairro, localidade = :localidade, uf = :uf  '+
                     'WHERE cep = :cep';

  FQuery.ParamByName('logradouro').AsString  := ACep.Logradouro;
  FQuery.ParamByName('complemento').AsString := ACep.Complemento;
  FQuery.ParamByName('bairro').AsString      := ACep.Bairro;
  FQuery.ParamByName('localidade').AsString  := ACep.Localidade;
  FQuery.ParamByName('uf').AsString          := ACep.Uf;
  FQuery.ParamByName('cep').AsString         := ACep.Cep;
  FQuery.ExecSQL;
end;

procedure TCepRepositoryImpl.AtualizarEnderecoNoBanco(const ACep: TCep);
begin
  FQuery.Close;
  FQuery.SQL.Text := 'UPDATE Ceps SET                                       '+
                     'logradouro = :logradouro, complemento = :complemento, ' +
                     'bairro = :bairro, localidade = :localidade, uf = :uf  '+
                     'WHERE cep = :cep';

  FQuery.ParamByName('logradouro').AsString  := ACep.Logradouro;
  FQuery.ParamByName('complemento').AsString := ACep.Complemento;
  FQuery.ParamByName('bairro').AsString      := ACep.Bairro;
  FQuery.ParamByName('localidade').AsString  := ACep.Localidade;
  FQuery.ParamByName('uf').AsString          := ACep.Uf;
  FQuery.ParamByName('cep').AsString         := ACep.Cep;
  FQuery.ExecSQL;
end;

function TCepRepositoryImpl.BuscarNoBancoPorCep(const ACep: string): TList<TCep>;
var
  Lista: TList<TCep>;
  Cep: TCep;
  CepFormatado: string;

begin
  Lista := TList<TCep>.Create;

  CepFormatado := StringReplace(ACep, '-', '', [rfReplaceAll]);
  CepFormatado := Trim(CepFormatado);

  if not CepFormatado.IsEmpty and (Length(CepFormatado) = 8) then
    Insert('-', CepFormatado, 6)
  else
    begin
      Lista.Free;
      raise Exception.Create('Entrada inválida. Parece que você digitou um endereço ao invés de um CEP.');
    end;

  if Length(CepFormatado) = 8 then
    Insert('-', CepFormatado, 6);

  FQuery.Close;
  FQuery.SQL.Text := 'SELECT * FROM Ceps WHERE cep = :cep';
  FQuery.ParamByName('cep').AsString := CepFormatado;
  FQuery.Open;

  while not FQuery.Eof do
    begin
      Cep             := TCep.Create;
      Cep.Codigo      := FQuery.FieldByName('codigo').AsInteger;
      Cep.Cep         := FQuery.FieldByName('cep').AsString;
      Cep.Logradouro  := FQuery.FieldByName('logradouro').AsString;
      Cep.Complemento := FQuery.FieldByName('complemento').AsString;
      Cep.Bairro      := FQuery.FieldByName('bairro').AsString;
      Cep.Localidade  := FQuery.FieldByName('localidade').AsString;
      Cep.Uf          := FQuery.FieldByName('uf').AsString;
      Lista.Add(Cep);
      FQuery.Next;
    end;

  Result := Lista;
end;

function TCepRepositoryImpl.BuscarNoBancoPorEndereco(const AEndereco: string): TList<TCep>;
var
  Lista: TList<TCep>;
  Cep: TCep;
  UF, Cidade, Logradouro: string;
  Partes: TArray<string>;

begin
  Lista := TList<TCep>.Create;

  if AEndereco.Trim = '' then
    Exit(nil);

  Partes := AEndereco.Split(['/']);
  if Length(Partes) < 3 then
    raise Exception.Create('Formato de endereço inválido. Use: UF/Cidade/Logradouro e espaço para separar as palavras');

  UF         := Partes[0].Trim;
  Cidade     := Partes[1].Trim;
  Logradouro := Partes[2].Trim;

  FQuery.Close;
  FQuery.SQL.Text := 'SELECT * FROM Ceps                                          '+
                     'WHERE uf COLLATE Latin1_General_CI_AI = :uf                 '+
                     'AND localidade COLLATE Latin1_General_CI_AI LIKE :cidade    '+
                     'AND logradouro COLLATE Latin1_General_CI_AI LIKE :logradouro';

  FQuery.ParamByName('uf').AsString         := UpperCase(UF);
  FQuery.ParamByName('cidade').AsString     := '%' + UpperCase(Cidade) + '%';
  FQuery.ParamByName('logradouro').AsString := '%' + UpperCase(Logradouro) + '%';
  FQuery.Open;

  while not FQuery.Eof do
    begin
      Cep             := TCep.Create;
      Cep.Codigo      := FQuery.FieldByName('codigo').AsInteger;
      Cep.Cep         := FQuery.FieldByName('cep').AsString;
      Cep.Logradouro  := FQuery.FieldByName('logradouro').AsString;
      Cep.Complemento := FQuery.FieldByName('complemento').AsString;
      Cep.Bairro      := FQuery.FieldByName('bairro').AsString;
      Cep.Localidade  := FQuery.FieldByName('localidade').AsString;
      Cep.Uf          := FQuery.FieldByName('uf').AsString;
      Lista.Add(Cep);
      FQuery.Next;
    end;

  Result := Lista;
end;

function TCepRepositoryImpl.ConsultarCepViaApi(const ACep, AFormato: string): TCep;
begin
  Result := FViaCepComp.ConsultarCep(ACep, AFormato);
end;

function TCepRepositoryImpl.ConsultarEnderecoViaApi(const AEndereco, AFormato: string): TList<TCep>;
var
  Lista: TList<TCep>;
  UF, Cidade, Logradouro: string;
begin
  if AEndereco.Trim = '' then
    Exit(nil);

  var Partes := AEndereco.Split(['/']);
  if Length(Partes) < 3 then
    raise Exception.Create('Formato de endereço inválido. Use: UF/Cidade/Logradouro e espaço para separar as palavras');

  UF         := Partes[0].Trim;
  Cidade     := Partes[1].Trim;
  Logradouro := Partes[2].Trim;

  if UF.IsEmpty or (Length(UF) <> 2) then
    raise Exception.Create('UF inválida. Informe 2 letras, por exemplo: PR');

  if Cidade.IsEmpty or (Length(Cidade) < 3) then
    raise Exception.Create('Cidade inválida. Informe o nome da cidade completo');

  if Logradouro.IsEmpty or (Length(Logradouro) < 3) then
    raise Exception.Create('Logradouro inválido. Informe o nome da rua corretamente');

  Lista := FViaCepComp.ConsultarPorEndereco(UF, Cidade, Logradouro, AFormato);

  Result := Lista;
end;

end.

