# Trabalho 1 de Segurança em Computação 2025/2: Infraestrutura de Chaves Públicas (PKI)
Alune: Lu Mendonça Emery Cade - 2017100210

Aqui teremos a implementação da infraestrutura completa (Raiz $\to$ Intermediária $\to$ Servidor) por duas abordagens distintas:

1.  **Tarefa 1:** Automação via Python + Servidor Web Nginx (Docker).
2.  **Tarefa 2:** Automação via OpenSSL.

---

## Pré-requisitos

* **Python** (com biblioteca `cryptography` instalada: `pip install cryptography`)
* **Docker** no meu caso, foi testado com Docker Desktop (para subir o servidor Nginx)
* **OpenSSL** (Instalado no Linux ou via Git Bash no Windows)
* **Navegador Web** (a importação de certificados foi feita pelo firefox nos testes)

---

## Estrutura de Diretórios

O projeto está organizado da seguinte forma:

```text
/projeto
├── tarefa1/
│   ├── arquivos/
│   │   └── # Aqui vão ser criados os arquivos server.crt, server.key e root.pem (entre outros)
│   │
│   ├── docker/
│   │   ├── certs/
│   │   │   └── # Aqui devem ser inseridos os arquivos server.crt e server.key 
│   │   ├── html/
│   │   │   └── index.html       # Página de teste
│   │   ├── docker-compose.yaml  # Configurações do docker
│   │   └── nginx.congf          # Configurações do Nginx
│   │
│   ├── key_and_cert_gen.py      # Script gerador de chaves e certificados
│   ├── main.py                  # Script que executa tudo em ordem
│   └── validate.py              # Script que valida os certificados por openssl verify
│
├── tarefa2/
│   ├── docker/
│   │   ├── certs/
│   │   │   └── # Aqui devem ser inseridos os arquivos server.crt e server.key 
│   │   ├── html/
│   │   │   └── index.html       # Página de teste
│   │   ├── docker-compose.yaml  # Configurações do docker
│   │   └── nginx.congf          # Configurações do Nginx
│   │
│   ├── intermediate/
│   │   └── intermediate.cnf     # Configuração da CA Intermediária
│   ├── root/
│   │   ├── root.cnf             # Configuração da CA Raiz
│   │   └── # Aqui será criado o root.pem
│   ├── server/
│   │   ├── server.cnf           # Configuração do Servidor
│   │   └── # Aqui serão criados server.key e server.crt
│   │
│   ├── generate_key_cert_and_test.bat  # Script de execução (Windows)
│   └── generate_key_cert_and_test.sh   # Script de execução (Linux)
│
└── readme.md
```

---

## Tarefa 1: Implementação via Python & Docker

O exemplo de execução e explicação do código pode ser encontrado [no youtube](https://youtu.be/odmN19uKGU0)

### 1. Geração das Chaves
Execute o código `main.py` a partir da pasta `tarefa1`.

```bash
cd tarefa1_python
python generate_pki.py
```

* **Arquivos esperados:** Será criada uma pasta `arquivos/` contendo `root.pem`, `server.key` e `server.crt`.

Então, copie os arquivos gerados `server.key` e `server.crt` para a pasta `docker/certs/`

### 2. Execução do Servidor
Quando o código solicitar a inicialização do Docker, navegue até `docker/` e inicie o container:

```bash
docker-compose up
```

Quando o container estiver iniciado, no código em execução digite `y` para prosseguir.

### 3. Validação no Terminal
O terminal, então, deve automaticamente seguir com a verificação.

### 4. Validação no Navegador
1.  Importe o arquivo `arquivos/root.pem` no seu navegador como uma **Autoridade Certificadora Confiável**.
2.  Acesse `https://localhost:443`. # Verifique o https
3.  Verifique se o cadeado de segurança aparece sem alertas de erro.

---

## Tarefa 2: Implementação via OpenSSL

O exemplo de execução e explicação do código pode ser encontrado [no youtube](https://youtu.be/Cy-NRh8P-AM)

Esta tarefa utiliza scripts de automação (`.bat` ou `.sh`) que leem os arquivos de configuração `.cnf` presentes nas pastas `root`, `intermediate` e `server`.

### 1a. Execução no Windows
Execute o script `.bat` (por exemplo, executado no git bash):

```cmd
cd tarefa2
.\generate_key_cert_and_test.bat
```

### 1b. Execução no Linux
Dê permissão de execução e rode o script `.sh`:

```bash
cd tarefa2
chmod +x generate_key_cert_and_test.sh
./generate_key_cert_and_test.sh
```

### 2. Validação por Terminal
O script finalizará executando automaticamente o comando de verificação do OpenSSL (`openssl verify`).

* **Resultado Esperado:** A saída final deverá ser `server/server.crt: OK`.

### 3. Validação por Navegador
Após a execução, copie os arquivos `server.key` e `server.crt` em `server/` para `docker/certs/`.

Caminhe até a pasta `docker/` e inicie o container.

```bash
docker-compose up
```

Pelo navegador, siga os seguintes passos:
1.  Importe o arquivo `arquivos/root.pem` no seu navegador como uma **Autoridade Certificadora Confiável**.
2.  Acesse `https://localhost:443`. # Verifique o https
3.  Verifique se o cadeado de segurança aparece sem alertas de erro.