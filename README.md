# MeuCEP

**MeuCEP** é uma aplicação Delphi 12 que consome o WebService [ViaCEP](https://viacep.com.br/) para realizar buscas de endereços por CEP e vice-versa.
Os dados podem ser salvos em um banco de dados SQL Server local e reaproveitados para consultas futuras.

---

## Funcionalidades

- Buscar endereço por CEP ou CEP por endereço
- Armazenar resultados em banco de dados SQL Server
- Atualizar dados manualmente através da API
- Interface simples com grid de resultados

---

## Arquitetura

- **Camadas**:
  - `Controller`: lógica de orquestração entre view e dados
  - `Repository`: acesso ao banco de dados
  - `Model`: objetos de domínio (`TCep`)
  - `Service/Component`: integração com API ViaCEP

- **Patterns aplicados**:
  - **Repository Pattern**
  - **MVC (Model-View-Controller)**

---

## Tecnologias utilizadas

- Delphi 12
- FireDAC
- SQL Server Express
- ViaCEP REST API
- Componentes nativos e `IdHTTP`

---

## Como executar

1. **Clonar o projeto**  
   ```bash
   git clone https://github.com/JeannLima/MeuCEP.git

2. **Abrir no Delphi (recomendado: Delphi 12 ou superior)**
 - Abra o arquivo MeuCEP.dproj.

3. **Configurar o banco de dados SQL Server**

 - Crie o banco MeuCEP (o script pode ser encontrado na pasta scripts)

 - Configure a conexão no DmConexaoBD.pas

4. **Executar**
Pressione F9 para compilar e executar.
