import yaml
import json
import os
import pathlib
import requests

def generate_config_json(config_path, target_path, workspace):

    try:

        with open(f'{config_path}/{workspace}/config.yml') as input, open(f"{target_path}/config.json", "w") as output:
            yaml_object = yaml.safe_load(input)

            json_data = {}
            json_data['workspace_configuration'] = yaml_object

            json.dump(json_data, output)
    
    except Exception as e:
        print(f"Error Occured while generating JSON from Workspace Config => {e}")


def get_tfplan_json (run_id, token, target_path):

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/vnd.api+json"
    }

    try:
        res = requests.get(
            f'https://app.terraform.io/api/v2/runs/{run_id}/plan/json-output',
            headers=headers
        )

        with open(f"{target_path}/tfplan.json", "w") as tfplan:
            json.dump(res.json(), tfplan)

    except Exception as e:
        print(f"Error Occured while generating JSON from Workspace Config => {e}")

if __name__ == "__main__":
    POLICY_PATH = pathlib.Path(__file__).parent.resolve()
    REPO_PATH  = POLICY_PATH.parent.parent
    CONFIG_PATH = f"{REPO_PATH}/Infrastructure/resources/"
    WORKSPACE = os.environ['WORKSPACE']

    generate_config_json(CONFIG_PATH, POLICY_PATH, WORKSPACE)

    get_tfplan_json(os.environ['RUN_ID'], os.environ['TOKEN'],POLICY_PATH)





    

