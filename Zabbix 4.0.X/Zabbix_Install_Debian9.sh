#!/usr/bin/env bash
#
# Zabbix_Install_Debian9.sh - Inicia Preparação e instalação do sistema zabbix
#
# GitHub:       https://github.com/alexandremjcastro/
# Autor:        Alexandre Castro
# Manutenção: -
#
# ------------------------------------------------------------------------ #
#  - Este programa irá realizar a preparação do sistema operacional e a instalação
#    e configuração do Zabbix na ultima versão LTS 4.0.X
#
#   Exemplos:
#      $ ./Zabbix_Install_Debian9.sh
#      Neste exemplo o script realiza a realiza a instalação do sistema zabbix
# ------------------------------------------------------------------------ #
# Histórico:
#
#   v1.0 19/11/2019, Alexandre:
#     - Script criado.
#
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 4.2.46
# ------------------------------- VARIÁVEIS ----------------------------------------- #
SERVER_NAME=$(hostname | cut -d' ' -f1)
SERVER_IP=$(hostname -I | cut -d' ' -f1)
DEBIAN_FRONTEND="noninteractive"
# ------------------------------- FUNÇÕES ----------------------------------------- #
function db_root() {
  echo "Digite uma senha para o usuário root do banco de dados:"
    read -ers SENHA_dbROOT
  echo "Digite sua senha novamente para confirma:"
    read -ers SENHA_dbROOT1
      if [[ $SENHA_dbROOT != $SENHA_dbROOT1 ]]; then
        echo "Senhas não coincidem, tente novamente." && db_root
      fi
}
function db_zabbix() {
  echo "Digite uma senha para o usuário zabbix do banco de dados:"
    read -ers SENHA_dbZABBIX
  echo "Digite sua senha novamente para confirma:"
    read -ers SENHA_dbZABBIX1
      if [[ $SENHA_dbZABBIX != $SENHA_dbZABBIX1 ]]; then
        echo "Senhas não coincidem, tente novamente." && db_zabbix
      fi
}
# ------------------------------- EXECUÇÃO ----------------------------------------- #
# Leitura do arquivo de versão do sistema
source /etc/os-release

# Preparação do sistema e instalação do zabbix
function instalacao() {
echo "################################################################################"
echo "#                                                                              #"
echo "#                 Instalação do zabbix 4.0.X Mysql 8.0.X no Debian 9           #"
echo "#                 Autor: Alexandre Castro                                      #"
echo "#                 GitHub: https://github.com/alexandremjcastro/                #"
echo "#                 E-mail: alexandremichael.jesus@gmail.com                     #"
echo "#                 Versão: v1.0 - 19/11/2019                                    #"
echo "#                                                                              #"
echo "################################################################################"
sleep 6

# Armazenando senha do banco de dados
db_root # Chama a função para digitar a senha de root do banco de dados
sleep 1
db_zabbix # Chama a função para digitar a senha do usuário zabbix do banco de dados
sleep 1

# Atualizando sistema
echo "Atualizando sistema"
  sleep 3
  apt-get update -y && apt-get upgrade -y
  clear
echo "Instalando pacotes necessários"
  sleep 3
  apt-get install wget net-tools traceroute nmap vim snmp snmpd snmp-mibs-downloader -y
  clear

# Instalando o Mysql
echo "Realizando download da última versão do MySql"
  sleep 3
  apt-get install lsb-release -y
  sleep 1
  wget https://repo.mysql.com//mysql-apt-config_0.8.14-1_all.deb
  sleep 1
  dpkg -i mysql-apt-config_0.8.14-1_all.deb
  sleep 1
  debconf-set-selections <<< 'mysql-server mysql-server/root_password password '$SENHA_dbROOT''
  debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password '$SENHA_dbROOT''
echo "Instalando o MySql"
  sleep 3
  apt-get install mysql-server -y
echo "Iniciando serviço do Mysql"
  sleep 3
  systemctl enable mysql
db_mysql=$(systemctl status mysql|grep running|wc -l)
if [[ $db_mysql == 1 ]]; then
  echo "Serviço mysql iniciado com sucesso!"
  sleep 3
else
  echo "Serviço mysql não iniciado!"
  sleep 3
exit 1
fi

# Criando Banco de Dados
echo "Criando banco de dados zabbix"
  sleep 3
  mysql -uroot -p$SENHA_dbROOT -e "create database zabbix character set utf8 collate utf8_bin;"
  sleep 1
echo "Criando usuário zabbix"
  sleep 3
  mysql -uroot -p$SENHA_dbROOT -e "create user "zabbix"@"localhost" identified by '$SENHA_dbZABBIX';"
  sleep 1
echo "Garantindo permissões de administrador para o usuário zabbix"
  sleep 3
  mysql -uroot -p$SENHA_dbROOT -e "grant all on zabbix.* to "zabbix"@"localhost";"
  sleep 1
  mysql -uroot -p$SENHA_dbROOT -e "flush privileges"
  sleep 1
 echo "default-authentication-plugin = mysql_native_password" >> /etc/mysql/mysql.conf.d/mysqld.cnf

# Instalando Zabbix Server
echo "Realizando download da última versão do Zabbix 4.0.X"
  sleep 3
  wget https://repo.zabbix.com/zabbix/4.0/debian/pool/main/z/zabbix-release/zabbix-release_4.0-3+stretch_all.deb
  dpkg -i zabbix-release_4.0-3+stretch_all.deb
  apt-get update
echo "Instalando Zabbix server, sender, get e agent"
  sleep 3
  apt-get install zabbix-agent zabbix-frontend-php zabbix-get zabbix-sender zabbix-server-mysql -y
  clear

# Importando tabelas para o banco de dados
echo "Importando tabelas para o banco de dados"
  sleep 3
  zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -h 127.0.0.1 -uzabbix -p$SENHA_dbZABBIX zabbix

# Configuração dos arquivos zabbix_server e zabbix_agent
echo "Realizando configurações necessárias dentro arquivo zabbix_server"
  sleep 3
  sed -i 's/# DBPassword=/DBPassword='$SENHA_dbZABBIX'/' /etc/zabbix/zabbix_server.conf
  sleep 1
echo "Realizando configurações necessárias dentro arquivo zabbix_agent"
  sleep 3
  sed -i 's/Hostname=Zabbix server/Hostname='$SERVER_NAME'/' /etc/zabbix/zabbix_agentd.conf
  sleep 1
echo "Habilitando execução de comandos via Zabbix"
  sleep 3
	sed -i 's/# EnableRemoteCommands=0/EnableRemoteCommands=1/' /etc/zabbix/zabbix_agentd.conf
echo "Habilitando UserParameter"
  sleep 3
	sed -i 's/# UnsafeUserParameters=0/UnsafeUserParameters=1/' /etc/zabbix/zabbix_agentd.conf

# Configuração do apache
echo "Realizando configuração do timezone"
  sleep 3
  sed -i 's/;date.timezone =/date.timezone = America\/Sao_Paulo/' /etc/php/7.0/apache2/php.ini
  sleep 1
echo "Retirando /zabbix da URL de acesso ao servidor"
  sleep 3
  sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/usr\/share\/zabbix\//' /etc/apache2/sites-enabled/000-default.conf

# Startando serviços
echo "Iniciando serviços"
sleep 3

# Iniciando serviço apache
systemctl enable apache2
systemctl restart apache2
httpd=$(systemctl status apache2|grep running|wc -l)
if [[ $httpd == 1 ]]; then
  echo "Serviço apache2 iniciado com sucesso!"
  sleep 3
else
  echo "Serviço apache2 não iniciado!"
  sleep 3
fi
sleep 1

# Iniciando serviço zabbix-server
systemctl enable zabbix-server
systemctl restart zabbix-server
zbx_server=$(systemctl status zabbix-server|grep running|wc -l)
if [[ $zbx_server == 1 ]]; then
  echo "Serviço zabbix-server iniciado com sucesso!"
  sleep 3
else
  echo "Serviço zabbix-server não iniciado!"
  sleep 3
fi
sleep 1

# Iniciando serviço zabbix-agent
systemctl enable zabbix-agent
systemctl restart zabbix-agent
zbx_agent=$(systemctl status zabbix-agent|grep running|wc -l)
if [[ $zbx_agent == 1 ]]; then
  echo "Serviço zabbix-agent iniciado com sucesso!"
else
  echo "Serviço zabbix-agent não iniciado!"
fi
sleep 1

# Iniciando serviço snmpd
systemctl enable snmpd
systemctl restart snmpd
snmp=$(systemctl status snmpd|grep running|wc -l)
if [[ $snmp == 1 ]]; then
  echo "Serviço snmpd iniciado com sucesso!"
else
  echo "Serviço snmpd não iniciado!"
fi
sleep 1

# Informações para acessar o zabbix
echo "Digite http://$SERVER_IP/ no navegador para da continuidade na configuração"
sleep 4
exit
}

# Verificando sistema operacional
if [[ ($ID = "debian") && ($VERSION_ID -eq "9") ]]; then
  instalacao
else
  echo "Desculpe! O script foi desenvolvido para o sistema Debian 9"
fi
