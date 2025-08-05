unit uCepRepository;

interface

uses
  uCEP, System.Generics.Collections;

type
  ICepRepository = interface
    ['{A2E34A9D-33E9-47A4-88B2-5F20A0D77126}']
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

end.
