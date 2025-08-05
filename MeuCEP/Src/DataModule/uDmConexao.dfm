object DmConexao: TDmConexao
  Height = 518
  Width = 656
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=MeuCep'
      'User_Name=sa'
      'Password=123'
      'Server=localhost'
      'OSAuthent=Yes'
      'DriverID=MSSQL')
    Left = 248
    Top = 168
  end
  object FDQuery: TFDQuery
    ChangeAlertName = 'FDQuery'
    Connection = FDConnection
    Left = 392
    Top = 168
  end
end
