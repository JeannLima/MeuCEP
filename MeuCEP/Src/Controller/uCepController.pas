unit uCepController;

interface

uses
  uCEP, uCepRepository, uCepRepositoryImpl,
  System.Generics.Collections, System.SysUtils;

type
  TCepController = class
    private
      FCepRepository: ICepRepository;
    public
      constructor Create(ACepRepository: ICepRepository);
      function ObterDados: TList<TCep>;

      function BuscarNoBancoPorCep(const ACep: string): TList<TCep>;
      function BuscarNoBancoPorEndereco(const AEndereco: string): TList<TCep>;

      procedure AtualizarCep(const ACep, AFormato: string);
      function AtualizarEndereco(const AEndereco, AFormato: string): TList<TCep>;

      function InserirCepNoBanco(const ACep, AFormato: string): TList<TCep>;
      function InserirEnderecoNoBanco(const AEndereco, AFormato: string): TList<TCep>;
  end;

implementation

{ TCepController }

constructor TCepController.Create(ACepRepository: ICepRepository);
begin
  FCepRepository := ACepRepository;
end;

function TCepController.InserirCepNoBanco(const ACep, AFormato: string): TList<TCep>;
var
  CepApi: TCep;
begin
  CepApi := FCepRepository.ConsultarCepViaApi(ACep, AFormato);

  if Assigned(CepApi) then
    begin
      FCepRepository.InserirCepNoBanco(CepApi);
      Result := FCepRepository.BuscarNoBancoPorCep(ACep);
    end
  else
    raise Exception.Create('CEP inválido ou não encontrado na API.');
end;

function TCepController.InserirEnderecoNoBanco(const AEndereco, AFormato: string): TList<TCep>;
var
  EnderecoApi: TList<TCep>;
begin
  EnderecoApi := FCepRepository.ConsultarEnderecoViaApi(AEndereco, AFormato);

  if Assigned(EnderecoApi) then
    begin
      if EnderecoApi.Count = 0 then
        begin
          EnderecoApi.Free;
          raise Exception.Create('Endereço não encontrado na API.');
        end;
      FCepRepository.InserirEnderecoNoBanco(EnderecoApi);
      Result := FCepRepository.BuscarNoBancoPorEndereco(AEndereco);
    end
  else
    raise Exception.Create('Endereço inválido ou não encontrado na API.');
end;

function TCepController.ObterDados: TList<TCep>;
begin
  Result := FCepRepository.ObterTodos;
end;

procedure TCepController.AtualizarCep(const ACep, AFormato: string);
var
  CepApi: TCep;
begin
  CepApi := FCepRepository.ConsultarCepViaApi(ACep, AFormato);
  FCepRepository.AtualizarCepNoBanco(CepApi);
end;

function TCepController.AtualizarEndereco(const AEndereco, AFormato: string): TList<TCep>;
var
  ListaCepApi: TList<TCep>;
  Cep: TCep;
begin
  ListaCepApi := FCepRepository.ConsultarEnderecoViaApi(AEndereco, AFormato);
  try
    for Cep in ListaCepApi do
      FCepRepository.AtualizarEnderecoNoBanco(Cep);

    // Retorna a lista atualizada
    Result := ListaCepApi;
  except
    ListaCepApi.Free;
    raise;
  end;
end;

function TCepController.BuscarNoBancoPorCep(const ACep: string): TList<TCep>;
begin
  Result := FCepRepository.BuscarNoBancoPorCep(ACep);
end;

function TCepController.BuscarNoBancoPorEndereco(const AEndereco: string): TList<TCep>;
begin
  Result := FCepRepository.BuscarNoBancoPorEndereco(AEndereco);
end;

end.
