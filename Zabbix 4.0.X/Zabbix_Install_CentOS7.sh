SERVER_NAME=$(hostname)
SERVER_IP=$(hostname -I)


# Criando Banco de Dados
echo "Verificando senha padrão do mysql"
SENHA_dbTMP=$(grep "temporary password" /var/log/mysqld.log | sed 's/\s\+//g' | cut -d: -f4)
sleep 1

function db_root() {
  echo "Digite uma senha para o usuário root do banco de dados:"
  read -ers SENHA_dbROOT
  echo "Digite sua senha novamente para confirma:"
  read -ers SENHA_dbROOT1
  if [[ $SENHA_dbROOT != $SENHA_dbROOT1 ]]; then
    echo "Senhas não coincidem, tente novamente."
    sleep 2
  fi
  while [[ $SENHA_dbROOT != $SENHA_dbROOT1 ]]; do
    db_root
  done
}
function db_zabbix() {
  echo "Digite uma senha para o usuário zabbix do banco de dados:"
  read -ers SENHA_dbZABBIX
  echo "Digite sua senha novamente para confirma:"
  read -ers SENHA_dbZABBIX1
  if [[ $SENHA_dbZABBIX != $SENHA_dbZABBIX1 ]]; then
    echo "Senhas não coincidem, tente novamente."
    sleep 2
  fi
  while [[ $SENHA_dbZABBIX != $SENHA_dbZABBIX1 ]]; do
    db_zabbix
  done
}
db_root # Chama a função para digitar a senha de root do banco de dados
db_zabbix # Chama a função para digitar a senha do usuário zabbix do banco de dados

echo "Alterando senha de root do Banco de Dados"
mysql -uroot -p$SENHA_dbTMP -e "set password for "root"@"localhost" = password('$SENHA_dbROOT')" --connect-expired-password 1> /dev/null
sleep 1
mysql -uroot -p$SENHA_dbROOT -e "flush privileges" --connect-expired-password 1> /dev/null
sleep 1
echo "Criando banco de dados zabbix"
mysql -uroot -p$SENHA_dbROOT -e "create database zabbix character set utf8 collate utf8_bin;" --connect-expired-password 1> /dev/null
sleep 1
echo "Criando usuário zabbix"
mysql -uroot -p$SENHA_dbROOT -e "create user "zabbix"@"localhost" identified by 'SdRedeszz#2019';" --connect-expired-password 1> /dev/null
sleep 1
echo "Garantindo permissions de administrador para o usuário zabbix"
mysql -uroot -p$SENHA_dbROOT -e "grant all on zabbix.* to "zabbix"@"localhost" identified by 'SdRedeszz#2019';" --connect-expired-password 1> /dev/null
sleep 1
mysql -uroot -p$SENHA_dbROOT -e "alter user "zabbix"@"localhost" identified with mysql_native_password by 'SdRedeszz#2019';" --connect-expired-password 1> /dev/null
sleep 1

# Instalando Zabbix Server
echo "Realizando download da última versão do Zabbix 4.0.X"
wget https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
sleep 1
rpm -ivh zabbix-release-4.0-1.el7.noarch.rpm
sleep 1
echo "Instalando Zabbix server, sender, get e agent"
yum install zabbix-get.x86_64 zabbix-sender.x86_64 zabbix-web-mysql.noarch zabbix-agent.x86_64 zabbix-server-mysql.x86_64 -y
sleep 1
clear

# Importando tabelas para o banco de dados
versao_zabbix=$(rpm -qa | grep "zabbix-server-mysql" | cut -d"-" -f4)
sleep 1
zcat /usr/share/doc/zabbix-server-mysql-$versao_zabbix/create.sql.gz | mysql -h 127.0.0.1 -uzabbix -p$SENHA_dbZABBIX zabbix

# Configuração dos arquivos zabbix_server e zabbix_agent
echo "Realizando configurações necessárias dentro arquivo zabbix_server"
sed -i 's/# DBPassword=/DBPassword='$SENHA_dbZABBIX'/' /etc/zabbix/zabbix_server.conf
sleep 1
echo "Realizando configurações necessárias dentro arquivo zabbix_agent"
sed -i 's/Hostname=Zabbix server/Hostname=zbxserver/' /etc/zabbix/zabbix_agentd.conf
sleep 1

# Configuração do apache
echo "Realizando configuração do timezone"
sed -i 's/;date.timezone =/date.timezone = America\/Sao_Paulo/' /etc/php.ini
sleep 1
echo "Retirando /zabbix da URL de acesso ao servidor"
sed -i 's/DocumentRoot "\/var\/www\/html"/DocumentRoot "\/usr\/share\/zabbix\/"/' /etc/httpd/conf/httpd.conf
clear

# Startando serviços
echo "Iniciando serviços"
systemctl enable httpd > /dev/null
systemctl start httpd
httpd=$(systemctl status httpd|grep running|wc -l)
if [[ $httpd == 1 ]]; then
  echo "Serviço httpd iniciado com sucesso!"
else
  echo "Serviço httpd não iniciado!"
fi
sleep 1
systemctl enable zabbix-server > /dev/null
systemctl start zabbix-server
zbx_server=$(systemctl status zabbix-server|grep running|wc -l)
if [[ $zbx_server == 1 ]]; then
  echo "Serviço zabbix-server iniciado com sucesso!"
else
  echo "Serviço zabbix-server não iniciado!"
fi
sleep 1
systemctl enable zabbix-agent > /dev/null
systemctl start zabbix-agent
zbx_agent=$(systemctl status zabbix-agent|grep running|wc -l)
if [[ $zbx_agent == 1 ]]; then
  echo "Serviço zabbix-agent iniciado com sucesso!"
else
  echo "Serviço zabbix-agent não iniciado!"
fi
