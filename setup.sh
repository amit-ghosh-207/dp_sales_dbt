python -m venv ./.venv
source .venv/bin/activate
pip install -r requirements.txt
dbt --version
dbt init
sudo cp /usr/lib/python3.7/lib-dynload/_bz2.cpython-37m-x86_64-linux-gnu.so /home/amit/.pyenv/versions/3.11.9/lib/python3.11/lib-dynload
sudo mv _bz2.cpython-37m-x86_64-linux-gnu.so _bz2.cpython-38-x86_64-linux-gnu.so

sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev

$ sudo apt update
sudo apt install make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl git libncursesw5-dev \
xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev