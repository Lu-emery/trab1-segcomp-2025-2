import socket
import ssl
import os

def validate_tls_connection(hostname, port, root_ca_path):
    print(f"--- [Validando {hostname}:{port}] ---")
    
    # 1. Criar um contexto SSL que exige validação
    context = ssl.create_default_context(ssl.Purpose.SERVER_AUTH)
    
    # 2. Tenta confiar na Root CA
    try:
        context.load_verify_locations(cafile=root_ca_path)
        print(f"Root CA '{root_ca_path}' carregada no contexto.")
    except FileNotFoundError:
        print(f"[E] Root CA não encontrado em: {root_ca_path}")
        return
    print()

    # 3. Conectar via Socket
    try:
        # Cria um socket TCP
        with socket.create_connection((hostname, port)) as sock:
            # Envolve o socket com a camada TLS
            with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                
                # Se chegou aqui deu certo
                cert = ssock.getpeercert()
                
                print(f"[C] Conexão validada!")
                print(f"Protocolo: {ssock.version()}")
                print(f"Cipher:    {ssock.cipher()[0]}")
                
                # Extraindo detalhes para prova visual
                subject = dict(x[0] for x in cert['subject'])
                issuer = dict(x[0] for x in cert['issuer'])
                print()
                
                print(f"Detalhes do Certificado Recebido:")
                print(f" - Subject: {subject.get('commonName')}")
                print(f" - Issuer:  {issuer.get('commonName')}")
                
    except ssl.SSLCertVerificationError as e:
        print(f"[E] Erro de validação de certificado: {e}")
    except ConnectionRefusedError:
        print(f"[E] Não foi possível conectar em {hostname}:{port}.")
    except Exception as e:
        print(f"[E] Treta inesperada: {e}")



if not os.path.exists('arquivos/'):
    root_path = 'arquivos/root.pem'
    print("Executando validação com arquivo em 'arquivos/'.")
else:
    root_path = 'root.pem'
    print("Arquivo recém-gerado não encontrado.")
    print("Executando validação com arquivo de exemplo.")

validate_tls_connection('localhost', 443, root_path)