import os,requests, subprocess

try:
  os.chdir("./tf")
  tfapply = subprocess.Popen(
    ["terraform", "apply", "-auto-approve"],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True
  )
  for line in tfapply.stdout:
    print(line, end='')
except subprocess.CalledProcessError as e:
  print(f"Error: {e}")

try:
  #os.chdir("./tf")
  tfoutput = subprocess.run(
    ["terraform", "output", "-raw", "ApiGwStageInvokeUrl"],
    capture_output=True,
    text=True,
    check=True
  )
  api_url = tfoutput.stdout.strip()
  if not api_url:
    raise ValueError("API_URL environment variable not set")
  for i in range(1055, 5000):
    try:
      response = requests.get(api_url + "/categories/MLA" + str(i))
      response.raise_for_status()  # Raise an exception for error HTTP status codes
      print(response.json())  # Assuming JSON response
    except requests.exceptions.RequestException as e:
      print(f"Error making API call: {e}")
except subprocess.CalledProcessError as e:
  print(f"Error getting Terraform output: {e}")
except OSError as e:
  print(f"Error changing directory: {e}")



