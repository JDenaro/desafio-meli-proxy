import os
import requests
import subprocess


def run_terraform_apply():
    try:
        print("Ejecutando terraform apply")
        os.chdir("./tf")
        tfapply = subprocess.Popen(
            ["terraform", "apply", "-auto-approve"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        for line in tfapply.stdout:
            print(line, end='')
        tfapply.wait()
        print("Terraform apply aplicado exitosamente")
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")


def get_terraform_output():
    try:
        print("Obteniendo API_URL")
        tfoutput = subprocess.run(
            ["terraform", "output", "-raw", "ApiGwStageInvokeUrl"],
            capture_output=True,
            text=True,
            check=True
        )
        api_url = tfoutput.stdout.strip()
        if not api_url:
            raise ValueError("Variable API_URL no seteada")
        print(f"api_url: {api_url} ")
        return api_url
    except subprocess.CalledProcessError as e:
        print(f"Error al obtener la salida de Terraform: {e}")
        return None


def make_api_calls(api_url):
    print(f"Iniciando llamadas a API {api_url}")
    for i in range(1055, 5000):
        try:
            response = requests.get(api_url + "/categories/MLA" + str(i))
            response.raise_for_status()  # Raise an exception for error HTTP status codes
            print(response.json())  # Assuming JSON response
        except requests.exceptions.RequestException as e:
            print(f"Error al hacer llamada a API: {e}")


def main():
    run_terraform_apply()
    api_url = get_terraform_output()
    if api_url:
        make_api_calls(api_url)


if __name__ == "__main__":
    main()
