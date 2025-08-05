program MeuCEP;

uses
  Vcl.Forms,
  FmrMeuCEP in 'View\FmrMeuCEP.pas' {MeuCepFrm},
  uDmConexao in 'DataModule\uDmConexao.pas' {DmConexao: TDataModule},
  uCepRepository in 'Model\Repository\uCepRepository.pas',
  uCepRepositoryImpl in 'Model\Repository\uCepRepositoryImpl.pas',
  uCEP in 'Model\Entidades\uCEP.pas',
  uCepController in 'Controller\uCepController.pas',
  uViaCepComponent in 'Services\uViaCepComponent.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDmConexao, DmConexao);
  Application.CreateForm(TMeuCepFrm, MeuCepFrm);
  Application.Run;
end.
