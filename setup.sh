python -m venv ./.venv
source .venv/bin/activate
pip install -r requirements.txt
dbt --version
dbt init
