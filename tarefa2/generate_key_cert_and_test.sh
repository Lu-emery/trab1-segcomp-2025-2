#!/bin/bash

echo "=========================================="
echo "         Executando Tarefa 2 (Linux)"
echo "=========================================="

# 0. Preparação: Criar pastas se não existirem
mkdir -p root intermediate server

# Verifica se o OpenSSL está acessível
if ! command -v openssl &> /dev/null; then
    echo "[E] OpenSSL nao encontrado."
    echo "Por favor, instale o openssl (apt install openssl ou yum install openssl)"
    exit 1
fi

echo ""
echo "[1/5] Gerando Root CA (Auto-assinada)..."
openssl req -x509 -new -nodes -newkey rsa:4096 -keyout root/root.key -out root/root.pem -days 3650 -config root/root.cnf
# req                faz uma requisição de gerar CA
# -x509              cria um certificado final, auto-assinado
# -newkey rsa:4096   gera uma chave RSA de tamanho 4096
# -nodes             criando sem criptografia para fins de teste
# -config            utiliza o arquivo de configurações

# Verifica erro
if [ $? -ne 0 ]; then
    echo "FALHA NA EXECUCAO: Erro ao gerar Root CA"
    exit 1
fi

echo ""
echo "[2/5] Gerando Intermediate CA..."
# Gera a chave e o pedido (CSR)
openssl req -new -nodes -newkey rsa:4096 -keyout intermediate/intermediate.key -out intermediate/intermediate.csr -config intermediate/intermediate.cnf
# req                faz uma requisição de gerar CA
# [-x509]            --não usamos pq queremos assinar
# -newkey rsa:4096   gera uma chave RSA de tamanho 4096
# -nodes             criando sem criptografia para fins de teste
# -config            utiliza o arquivo de configurações

# Assina o pedido com a Root CA
openssl x509 -req -in intermediate/intermediate.csr -CA root/root.pem -CAkey root/root.key -CAcreateserial -out intermediate/intermediate.pem -days 1825 -extfile intermediate/intermediate.cnf -extensions v3_intermediate_ca
# x509                    manipula certificado
# -req                    faz uma requisição
# -CA, -CAkey             arquivos para assinatura
# -extfile, -extensions   garante que as extensões ainda existem depois do pedido

if [ $? -ne 0 ]; then
    echo "FALHA NA EXECUCAO: Erro na Intermediate CA"
    exit 1
fi

echo ""
echo "[3/5] Gerando Certificado do Servidor (localhost)..."
# Gera a chave e o pedido (CSR)
openssl req -new -nodes -newkey rsa:4096 -keyout server/server.key -out server/server.csr -config server/server.cnf
# req                faz uma requisição de gerar CA
# [-x509]            --não usamos pq queremos assinar
# -newkey rsa:4096   gera uma chave RSA de tamanho 4096
# -nodes             criando sem criptografia para fins de teste
# -config            utiliza o arquivo de configurações

# Assina o pedido com a Intermediate CA
openssl x509 -req -in server/server.csr -CA intermediate/intermediate.pem -CAkey intermediate/intermediate.key -CAcreateserial -out server/server_base.crt -days 365 -extfile server/server.cnf -extensions v3_server
# x509                    manipula certificado
# -req                    faz uma requisição
# -CA, -CAkey             arquivos para assinatura
# -extfile, -extensions   garante que as extensões ainda existem depois do pedido

if [ $? -ne 0 ]; then
    echo "FALHA NA EXECUCAO: Erro no Certificado do Servidor"
    exit 1
fi

echo ""
echo "[4/5] Criando Certificado Final..."
cat server/server_base.crt intermediate/intermediate.pem > server/server.crt
echo "Bundle criado em server/server-bundle.crt"
# garante que o arquivo final contém os dados da cadeia completa

echo ""
echo "[5/5] Executando Validacao Final..."
openssl verify -CAfile root/root.pem -untrusted intermediate/intermediate.pem server/server.crt
# openssl verify   simula um navegador
# -CAfile          certificado a confiar
# -untrusted       garante que o verify vai realmente validar a intermediária

if [ $? -ne 0 ]; then
    echo "=========================================="
    echo "           FALHA NA VERIFICACAO"
    echo "=========================================="
    exit 1
fi

echo ""
echo "=========================================="
echo "                SUCESSO!"
echo "=========================================="