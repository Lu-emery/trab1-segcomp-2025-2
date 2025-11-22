import json
import os
import sys
import subprocess

# Lê e executa as células de código de um arquivo .ipynb
def run_notebook(notebook_path):
    print(f"--- [1/3] Executando gerador de chaves ({notebook_path}) ---")
    
    if not os.path.exists(notebook_path):
        print(f"[E] O arquivo '{notebook_path}' não foi encontrado.")
        return False

    try:
        with open(notebook_path, 'r', encoding='utf-8') as f:
            nb = json.load(f)
        
        # Dicionário para manter o estado das variáveis entre as células
        # (simula a memória do kernel do Jupyter)
        nb_globals = {}
        
        code_cells = [c for c in nb['cells'] if c['cell_type'] == 'code']
        total_cells = len(code_cells)

        for i, cell in enumerate(code_cells, 1):
            source = "".join(cell['source'])
            if source.strip(): # Ignora células vazias
                # Executa o código da célula
                exec(source, nb_globals)
        
        print(f"\n[C] Gerador de chaves executado com sucesso.")
        return True

    except ImportError as e:
        print(f"\n[E] Falta uma biblioteca necessária: {e}")
        print("Certifique-se de instalar: pip install cryptography")
        return False
    except Exception as e:
        print(f"\n[E] Falha ao executar o notebook: {e}")
        return False

# Não faz nada, só printa coisas e espera um Y
def wait_for_docker_confirmation():
    print("\n==================================================================")
    print("--- [2/3] Ação Manual Necessária: Docker ---")
    print(" Os arquivos de certificado foram gerados na pasta 'arquivos/'.")
    print(" Por favor, inicie seu ambiente Docker, utilizando os arquivos 'server.crt' e 'server.key' em 'arquivos/'.")
    print(" O arquivo 'root.pem' pode ser mantido na pasta.")
    print(" Ou utilize os arquivos de teste já existentes.")
    print("==================================================================")
    
    while True:
        response = input("\n>> O Docker já está rodando? Digite 'Y' para continuar: ").strip()
        
        if response.lower() == "y":
            print("[C] Prosseguindo para validação...")
            break
        else:
            print("Aguardando confirmação ('y')...")

# Executa o validate.py
def run_validation_script(script_path):
    print(f"\n--- [3/3] Executando script de validação ({script_path}) ---")
    
    if not os.path.exists(script_path):
        print(f"[E] O arquivo '{script_path}' não foi encontrado.")
        return

    try:
        subprocess.run([sys.executable, script_path], check=True)
    except subprocess.CalledProcessError:
        print("[E] O script de validação encontrou um erro durante a execução.")
    except KeyboardInterrupt:
        print("\nValidação interrompida pelo usuário.")


# Executa as partes do código
def main():
    # Configurações de nomes de arquivo
    NOTEBOOK_FILE = "key_and_cert_gen.ipynb"
    VALIDATE_FILE = "validate.py"

    # 1. Executar Notebook
    success = run_notebook(NOTEBOOK_FILE)
    if not success:
        input("\nPressione Enter para sair (Erro na etapa 1)...")
        sys.exit(1)

    # 2. Pausa para Docker
    wait_for_docker_confirmation()

    # 3. Executar Validação
    run_validation_script(VALIDATE_FILE)

    # 4. Finalização
    input("Pressione qualquer tecla (Enter) para fechar a janela...")

if __name__ == "__main__":
    main()