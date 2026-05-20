python -m venv ./.venv
source .venv/bin/activate
pip install -r requirements.txt
dbt --version
dbt init
cd ./dp_sales_dbt
dbt build