# MeuCEP

**MeuCEP** é uma aplicação desktop desenvolvida em **Delphi 12**, que consome o WebService [ViaCEP](https://viacep.com.br/) para realizar consultas de endereços a partir de CEPs e vice-versa. Os resultados são armazenados localmente em um banco de dados **SQL Server**, permitindo consultas futuras mesmo offline.
---

## Funcionalidades

- Consulta de CEP por endereço (UF/Cidade/Logradouro)
- Consulta de endereço por CEP
- Armazenamento dos resultados em banco de dados local
- Atualização manual dos dados com base na API
- Interface visual com grid para listagem

---

## Arquitetura

O projeto segue uma arquitetura em camadas:

- **Model**: representação da entidade `TCep`
- **Controller**: gerencia lógica entre View e Repository
- **Repository**: acesso a dados e persistência
- **Service**: consumo da API ViaCEP

### Patterns aplicados

- `Repository Pattern`
- Separação de responsabilidades (MVC-like)
- `Interface-based Programming`: uso de interfaces (`ICepRepository`) para reduzir acoplamento e permitir testes

---

## Tecnologias utilizadas

- Delphi 12
- FireDAC
- SQL Server Express
- REST API ViaCEP
- Componentes: `IdHTTP`, `TTaskDialog`, `TFDMemTable`

---

## Como executar

### Requisitos

- Delphi 12 ou superior
- SQL Server (Express ou completo)

### Passos

1. **Clone o repositório:**  
   ```bash
   git clone https://github.com/JeannLima/MeuCEP.git

2. **Restaure o banco de dados:**
 - Localize o arquivo Bd\MeuCEP.bak
 - No SQL Server Management Studio:
 - Clique com o botão direito em Databases > Restore Database
 - Escolha Device > selecione o .bak
 - Restaure com o nome MeuCEP
 - Importante: a conexão com o banco já está pré-configurada no código para acessar o banco MeuCEP no localhost. Basta restaurar o .bak com esse nome e garantir que o SQL Server esteja rodando localmente.

2. **Abrir no Delphi (recomendado: Delphi 12 ou superior)**
 - Abra o arquivo MeuCEP.dproj.

4. **Executar**
 - Pressione F9 para compilar e executar.
