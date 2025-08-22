unit FmrMeuCEP;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB, Vcl.StdCtrls,
  Vcl.Grids, Vcl.DBGrids, System.Generics.Collections, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, uCepController, uCepRepositoryImpl, uDmConexao, uCEP,
  System.StrUtils;

type
  TMeuCepFrm = class(TForm)
    Panel1: TPanel;
    DBGridCeps: TDBGrid;
    Panel2: TPanel;
    BtnBuscar: TButton;
    FDMemTable: TFDMemTable;
    DataSource: TDataSource;
    EdtBuscar: TEdit;
    FDMemTableLogradouro: TStringField;
    FDMemTableComplemento: TStringField;
    FDMemTableBairro: TStringField;
    FDMemTableLocalidade: TStringField;
    FDMemTableUF: TStringField;
    FDMemTableCEP: TStringField;
    RadioGroupTipo: TRadioGroup;
    RadioGroupFormato: TRadioGroup;
    LbBuscar: TLabel;
    Panel3: TPanel;
    QtdRegistros: TLabel;
    TaskDialog: TTaskDialog;
    procedure BtnBuscarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FCepController: TCepController;
    procedure PreencherGrid(const Lista: TList<TCep>);
    procedure ContaQuantidadeRegistros;
  public
  end;

var
  MeuCepFrm: TMeuCepFrm;

implementation

{$R *.dfm}

uses
  uCepRepository;

procedure TMeuCepFrm.FormCreate(Sender: TObject);
var
  Repo: ICepRepository;
begin
  Repo := TCepRepositoryImpl.Create(DmConexao.FDQuery);
  FCepController := TCepController.Create(Repo);

  FDMemTable.CreateDataSet;

  DataSource.DataSet := FDMemTable;
  DBGridCeps.DataSource := DataSource;
end;

procedure TMeuCepFrm.FormShow(Sender: TObject);
begin
  PreencherGrid(FCepController.ObterDados);
  EdtBuscar.SetFocus;
end;

procedure TMeuCepFrm.BtnBuscarClick(Sender: TObject);
var
  Lista: TList<TCep>;
  TipoBusca: Integer;
  Formato: string;
  Dialog: TTaskDialog;
  Erro: Boolean;

begin
  if Trim(EdtBuscar.Text) = '' then
    begin
      ShowMessage('Digite um CEP ou Endere�o.');
      Exit;
    end;

  Lista := nil;
  Erro := False;

  TipoBusca := RadioGroupTipo.ItemIndex;        // 0 = CEP, 1 = Endere�o
  Formato   := IfThen(RadioGroupFormato.ItemIndex = 0, 'json', 'xml'); // 0 = JSON, 1 = XML

  try
    if TipoBusca = 0 then
      begin
        Lista := FCepController.BuscarNoBancoPorCep(EdtBuscar.Text);

        if Lista.Count > 0 then
          begin
            Dialog := TTaskDialog.Create(nil);
            try
              Dialog.Title := 'Confirma��o';
              Dialog.Text := 'O CEP ' + EdtBuscar.Text + ' j� existe no banco de dados.' + sLineBreak +
                             'Deseja ver os resultados j� armazenados ou atualizar os dados com a API?';
              Dialog.MainIcon := tdiInformation;
              Dialog.CommonButtons := [];

              with Dialog.Buttons.Add do
                begin
                  Caption := 'Ver';
                  ModalResult := 0;
                end;

              with Dialog.Buttons.Add do
                begin
                  Caption := 'Atualizar';
                  ModalResult := 1;
                end;

              if Dialog.Execute then
                begin
                  case Dialog.ModalResult of
                    0: // Bot�o Ver (0)
                      begin
                        Lista.Free;
                        Lista := FCepController.BuscarNoBancoPorCep(EdtBuscar.Text);
                      end;
                    1: // Bot�o Atualizar (1)
                      begin
                        FCepController.AtualizarCep(EdtBuscar.Text, Formato);
                        Lista.Free;
                        Lista := FCepController.BuscarNoBancoPorCep(EdtBuscar.Text);
                        ShowMessage('Dados do CEP atualizados com sucesso!');
                      end;
                    2: //Cancelado ou fechado
                      begin
                        Exit;
                      end;
                  end;
                end;
            finally
              Dialog.Free;
            end;
          end
        else
          begin
            try
              Lista.Free;
              Lista := FCepController.InserirCepNoBanco(EdtBuscar.Text, Formato);
              Lista := FCepController.BuscarNoBancoPorCep(EdtBuscar.Text);
              ShowMessage('Dados do CEP inseridos com sucesso!');
            except
              on E: Exception do
                begin
                  ShowMessage('Erro ao inserir CEP: ' + E.Message);
                  Erro := True;
                end;
            end;
          end;

      end
    else if TipoBusca = 1 then
      begin
        Lista := FCepController.BuscarNoBancoPorEndereco(EdtBuscar.Text);

        if Lista.Count > 0 then
          begin
            Dialog := TTaskDialog.Create(nil);
            try
              Dialog.Title := 'Confirma��o';
              Dialog.Text := 'O Endere�o "' + EdtBuscar.Text + '" j� existe no banco de dados.' + sLineBreak +
                             'Deseja ver os dados armazenados ou atualiz�-los com a API?';
              Dialog.MainIcon := tdiInformation;
              Dialog.CommonButtons := [];

              // Bot�o Ver (0)
              with Dialog.Buttons.Add do
                begin
                  Caption := 'Ver';
                  ModalResult := 0;
                end;

              // Bot�o Atualizar (1)
              with Dialog.Buttons.Add do
                begin
                  Caption := 'Atualizar';
                  ModalResult := 1;
                  Default := True;
                end;

              if Dialog.Execute then
                begin
                  case Dialog.ModalResult of
                    0: // Ver
                      begin
                        Lista.Free;
                        Lista := FCepController.BuscarNoBancoPorEndereco(EdtBuscar.Text);
                      end;
                    1: // Atualizar
                      begin
                        FCepController.AtualizarEndereco(EdtBuscar.Text, Formato);
                        Lista.Free;
                        Lista := FCepController.BuscarNoBancoPorEndereco(EdtBuscar.Text);
                        ShowMessage('Dados do Endere�o atualizados com sucesso!');
                      end;
                    2: //Cancelado ou fechado
                      begin
                        Exit;
                      end;
                  end;
                end;
            finally
              Dialog.Free;
            end;
          end
        else
          begin
            try
              Lista.Free;
              Lista := FCepController.InserirEnderecoNoBanco(EdtBuscar.Text, Formato);

              ShowMessage('Dados do Endere�o inseridos com sucesso!');
            except
              on E: Exception do
                begin
                  ShowMessage('Erro ao inserir Endere�o: ' + E.Message);
                  Erro := True;
                end;
            end;
          end;
      end
    else
      begin
        ShowMessage('Selecione uma op��o de busca (CEP ou Endere�o).');
        Exit;
      end;

    if not Erro and Assigned(Lista) then
      PreencherGrid(Lista);
  finally
    if not Erro and Assigned(Lista) then
      Lista.Free;
  end;
end;

procedure TMeuCepFrm.PreencherGrid(const Lista: TList<TCep>);
var
  Cep: TCep;
begin
  FDMemTable.DisableControls;
  try
    FDMemTable.Close;
    FDMemTable.Open;
    FDMemTable.EmptyDataSet;

    for Cep in Lista do
      begin
        FDMemTable.Append;
        FDMemTable.FieldByName('cep').AsString         := Cep.Cep;
        FDMemTable.FieldByName('logradouro').AsString  := Cep.Logradouro;
        FDMemTable.FieldByName('complemento').AsString := Cep.Complemento;
        FDMemTable.FieldByName('bairro').AsString      := Cep.Bairro;
        FDMemTable.FieldByName('localidade').AsString  := Cep.Localidade;
        FDMemTable.FieldByName('uf').AsString          := Cep.Uf;
        FDMemTable.Post;
      end;
    FDMemTable.First;

    ContaQuantidadeRegistros;

  finally
    FDMemTable.EnableControls;
  end;
end;

procedure TMeuCepFrm.ContaQuantidadeRegistros;
begin
  QtdRegistros.Caption := FDMemTable.RecordCount.ToString + ' Registros';
end;

end.

