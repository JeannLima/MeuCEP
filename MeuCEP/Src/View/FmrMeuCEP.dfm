object MeuCepFrm: TMeuCepFrm
  Left = 0
  Top = 0
  Caption = 'Meu Cep'
  ClientHeight = 466
  ClientWidth = 818
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 818
    Height = 466
    Align = alClient
    BevelOuter = bvNone
    Caption = #39
    TabOrder = 0
    object DBGrid1: TDBGrid
      AlignWithMargins = True
      Left = 5
      Top = 54
      Width = 808
      Height = 386
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alBottom
      DataSource = DataSource1
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'CEP'
          Width = 65
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Logradouro'
          Width = 162
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Complemento'
          Width = 112
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Bairro'
          Width = 142
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Localidade'
          Width = 209
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'UF'
          Width = 45
          Visible = True
        end>
    end
    object Panel2: TPanel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 812
      Height = 47
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object LbBuscar: TLabel
        Left = 5
        Top = 1
        Width = 136
        Height = 15
        Caption = 'Digite o CEP ou Descri'#231#227'o'
      end
      object BtnBuscar: TButton
        Left = 736
        Top = 12
        Width = 75
        Height = 29
        Caption = 'Buscar'
        TabOrder = 3
        OnClick = BtnBuscarClick
      end
      object EdtBuscar: TEdit
        Left = 2
        Top = 18
        Width = 436
        Height = 23
        TabOrder = 0
      end
      object RadioGroupTipo: TRadioGroup
        Left = 447
        Top = 4
        Width = 150
        Height = 37
        Caption = 'Tipo de Consulta'
        Columns = 2
        Items.Strings = (
          'CEP'
          'Endere'#231'o')
        TabOrder = 1
      end
      object RadioGroupFormato: TRadioGroup
        Left = 599
        Top = 4
        Width = 131
        Height = 37
        Caption = 'Formato API'
        Columns = 2
        ItemIndex = 0
        Items.Strings = (
          'JSON'
          'XML')
        TabOrder = 2
      end
    end
    object Panel3: TPanel
      AlignWithMargins = True
      Left = 3
      Top = 448
      Width = 812
      Height = 15
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      object QtdRegistros: TLabel
        AlignWithMargins = True
        Left = 741
        Top = 0
        Width = 68
        Height = 15
        Margins.Left = 0
        Margins.Top = 0
        Margins.Bottom = 0
        Align = alRight
        Caption = 'QtdRegistros'
        ExplicitLeft = 687
      end
    end
  end
  object DataSource1: TDataSource
    Left = 736
    Top = 120
  end
  object FDMemTable1: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 736
    Top = 184
    object FDMemTable1CEP: TStringField
      FieldName = 'CEP'
    end
    object FDMemTable1Logradouro: TStringField
      FieldName = 'Logradouro'
      Size = 100
    end
    object FDMemTable1Complemento: TStringField
      FieldName = 'Complemento'
    end
    object FDMemTable1Bairro: TStringField
      FieldName = 'Bairro'
    end
    object FDMemTable1Localidade: TStringField
      FieldName = 'Localidade'
      Size = 100
    end
    object FDMemTable1UF: TStringField
      FieldName = 'UF'
    end
  end
  object TaskDialog: TTaskDialog
    Buttons = <>
    RadioButtons = <>
    Left = 736
    Top = 264
  end
end
