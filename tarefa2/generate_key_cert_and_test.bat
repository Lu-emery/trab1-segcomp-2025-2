@echo off
echo ==========================================
echo          Executando Tarefa 2
echo ==========================================

:: Verifica se o OpenSSL está acessível
where openssl >nul 2>nul
if %errorlevel% neq 0 (
    echo [E] OpenSSL nao encontrado no PATH.
    echo Por favor, rode este script pelo Git Bash ou instale o OpenSSL.
    pause
    exit /b
)

echo.
echo [1/5] Gerando Root CA (Auto-assinada)...
openssl req -x509 -new -nodes -newkey rsa:4096 -keyout root/root.key -out root/root.pem -days 3650 -config root/root.cnf
:: req                faz uma requisição de gerar CA
:: -x509              cria um certificado final, auto-assinado
:: -newkey rsa:4096   gera uma chave RSA de tamanho 4096
:: -nodes             criando sem criptografia para fins de teste
:: -config            utiliza o arquivo de configurações
if %errorlevel% neq 0 goto ERROR

echo.
echo [2/5] Gerando Intermediate CA...
:: Gera a chave e o pedido (CSR)
openssl req -new -nodes -newkey rsa:4096 -keyout intermediate/intermediate.key -out intermediate/intermediate.csr -config intermediate/intermediate.cnf
:: req                faz uma requisição de gerar CA
:: [-x509]          --não usamos pq queremos assinar
:: -newkey rsa:4096   gera uma chave RSA de tamanho 4096
:: -nodes             criando sem criptografia para fins de teste
:: -config            utiliza o arquivo de configurações

:: Assina o pedido com a Root CA
openssl x509 -req -in intermediate/intermediate.csr -CA root/root.pem -CAkey root/root.key -CAcreateserial -out intermediate/intermediate.pem -days 1825 -extfile intermediate/intermediate.cnf -extensions v3_intermediate_ca
:: x509                    manipula certificado
:: -req                    faz uma requisição
:: -CA, -CAkey             arquivos para assinatura
:: -extfile, -extensions   garante que as extensões ainda existem depois do pedido
if %errorlevel% neq 0 goto ERROR

echo.
echo [3/5] Gerando Certificado do Servidor (localhost)...
:: Gera a chave e o pedido (CSR)
openssl req -new -nodes -newkey rsa:4096 -keyout server/server.key -out server/server.csr -config server/server.cnf
:: req                faz uma requisição de gerar CA
:: [-x509]          --não usamos pq queremos assinar
:: -newkey rsa:4096   gera uma chave RSA de tamanho 4096
:: -nodes             criando sem criptografia para fins de teste
:: -config            utiliza o arquivo de configurações

:: Assina o pedido com a Intermediate CA
openssl x509 -req -in server/server.csr -CA intermediate/intermediate.pem -CAkey intermediate/intermediate.key -CAcreateserial -out server/server_base.crt -days 365 -extfile server/server.cnf -extensions v3_server
:: x509                    manipula certificado
:: -req                    faz uma requisição
:: -CA, -CAkey             arquivos para assinatura
:: -extfile, -extensions   garante que as extensões ainda existem depois do pedido
if %errorlevel% neq 0 goto ERROR

echo.
echo [4/5] Criando Certificado Final...
type server\server_base.crt intermediate\intermediate.pem > server\server.crt
echo Bundle criado em server\server.crt
:: garante que o arquivo final contém os dados da cadeia completa

echo.
echo [5/5] Executando Validacao Final...
openssl verify -CAfile root/root.pem -untrusted intermediate/intermediate.pem server/server.crt
:: openssl verify   simula um navegador
:: -CAfile          certificado a confiar
:: -untrusted       garante que o verify vai realmente validar a intermediária

echo.
echo ==========================================
echo                SUCESSO!
echo ==========================================
pause
exit /b 0

:ERROR
echo.
echo ==========================================
echo           FALHA NA EXECUCAO
echo ==========================================
pause
exit /b 1