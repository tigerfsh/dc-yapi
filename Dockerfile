FROM ubuntu:20.04
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt update 
RUN apt install -y git curl python make

RUN curl -sL https://deb.nodesource.com/setup_10.x -o /tmp/nodesource_setup.sh

RUN /bin/bash  /tmp/nodesource_setup.sh

RUN apt install -y nodejs


RUN mkdir yapi && cd yapi && git clone https://github.com/YMFE/yapi.git vendors && cp vendors/config_example.json ./config.json && cd vendors

WORKDIR /yapi/vendors

RUN cd /yapi/vendors && rm -rf node_modules && npm cache clean --force && rm package-lock.json

RUN cd /yapi/vendors && npm install --production --registry https://registry.npm.taobao.org 

RUN npm install pm2 -g 

CMD cd /yapi/vendors && python -c "import os; import json; f = open('config_example.json'); content = f.read(); data = json.loads(content); adminAccount = os.environ.get('adminAccount', 'admin@admin.com'); db_servername = os.environ.get('db_servername', '127.0.0.1'); db_port = os.environ.get('db_port', 27017); db_port = int(db_port); db_user = os.environ.get('db_user'); db_pass = os.environ.get('db_pass'); db_authSource = os.environ.get('db_authSource', 'admin'); data['adminAccount'] = adminAccount; data['db']['servername'] = db_servername; data['db']['port'] = db_port; data['db']['user'] = db_user; data['db']['pass'] = db_pass; data['db']['authSource'] = db_authSource; f.close(); f = open('config.json', 'w'); f.write(json.dumps(data)); f.close();" && npm run install-server && pm2 start "server/app.js" --name yapi 

