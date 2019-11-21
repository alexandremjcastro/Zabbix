#!/usr/bin/env bash
#
# Zabbix_Install_CentOS7.sh - Inicia Preparação e instalação do sistema zabbix
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
#      $ ./Zabbix_Install_CentOS7.sh
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
echo "#                 Instalação do zabbix 4.0.X Mysql 8.0.X no CentOS 7           #"
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
  yum update -y
  clear
echo "Instalando pacotes necessários"
  sleep 3
  yum install wget net-tools epel-release python-pip net-snmp* traceroute nmap vim -y
  clear

# Desabilitando o Selinux
if [[ $(sestatus | sed 's/\s\+//g' | cut -d: -f2) == "disabled" ]]; then
  echo "Selinux já está desabilitado!"
  sleep 3
else
  echo "Desabilitando Selinux..."
  sleep 3
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
  setenforce 0
  echo "Selinux desabilitado!"
  sleep 3
fi

# Desabilitando firewall do sistema
echo "Desabilitando Firewalld"
  systemctl stop firewalld
  systemctl disable firewalld
  sleep 3
echo "Firewalld desabilitado!"
  sleep 3

# Instalando o Mysql
echo "Realizando download da última versão do MySql"
  sleep 3
  wget https://repo.mysql.com/mysql57-community-release-el7-11.noarch.rpm
  sleep 1
  rpm -ivh mysql57-community-release-el7-11.noarch.rpm
echo "Instalando o MySql"
  sleep 3
  yum install mysql-server -y
echo "Iniciando serviço do Mysql"
  sleep 3
  systemctl enable mysqld > /dev/null
  systemctl start mysqld
db_mysql=$(systemctl status mysqld|grep running|wc -l)
if [[ $db_mysql == 1 ]]; then
  echo "Serviço mysqld iniciado com sucesso!"
  sleep 3
else
  echo "Serviço mysqld não iniciado!"
  sleep 3
exit
fi

# Criando Banco de Dados
echo "Verificando senha padrão do mysql"
sleep 3
SENHA_dbTMP=$(grep "temporary password" /var/log/mysqld.log | sed 's/\s\+//g' | cut -d: -f4)
sleep 1
echo "Alterando senha de root do Banco de Dados"
  sleep 3
  mysql -uroot -p$SENHA_dbTMP -e "set password for "root"@"localhost" = password('$SENHA_dbROOT')" --connect-expired-password
  sleep 1
  mysql -uroot -p$SENHA_dbROOT -e "flush privileges" --connect-expired-password 1> /dev/null
  sleep 1
echo "Criando banco de dados zabbix"
  sleep 3
  mysql -uroot -p$SENHA_dbROOT -e "create database zabbix character set utf8 collate utf8_bin;" --connect-expired-password
  sleep 1
echo "Criando usuário zabbix"
  sleep 3
  mysql -uroot -p$SENHA_dbROOT -e "create user "zabbix"@"localhost" identified by '$SENHA_dbZABBIX';" --connect-expired-password
  sleep 1
echo "Garantindo permissions de administrador para o usuário zabbix"
  sleep 3
  mysql -uroot -p$SENHA_dbROOT -e "grant all on zabbix.* to "zabbix"@"localhost" identified by '$SENHA_dbZABBIX';" --connect-expired-password
  sleep 1
  mysql -uroot -p$SENHA_dbROOT -e "alter user "zabbix"@"localhost" identified with mysql_native_password by '$SENHA_dbZABBIX';" --connect-expired-password
  sleep 1

# Instalando Zabbix Server
echo "Realizando download da última versão do Zabbix 4.0.X"
  sleep 3
  wget https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
  sleep 1
  rpm -ivh zabbix-release-4.0-1.el7.noarch.rpm
  sleep 1
echo "Instalando Zabbix server, sender, get e agent"
  sleep 3
  yum install zabbix-get.x86_64 zabbix-sender.x86_64 zabbix-web-mysql.noarch zabbix-agent.x86_64 zabbix-server-mysql.x86_64 -y
  clear

# Importando tabelas para o banco de dados
echo "Importando tabelas para o banco de dados"
sleep 3
versao_zabbix=$(rpm -qa | grep "zabbix-server-mysql" | cut -d"-" -f4)
  zcat /usr/share/doc/zabbix-server-mysql-$versao_zabbix/create.sql.gz | mysql -h 127.0.0.1 -uzabbix -p$SENHA_dbZABBIX zabbix

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
  sed -i 's/;date.timezone =/date.timezone = America\/Sao_Paulo/' /etc/php.ini
  sleep 1
echo "Retirando /zabbix da URL de acesso ao servidor"
  sleep 3
  sed -i 's/DocumentRoot "\/var\/www\/html"/DocumentRoot "\/usr\/share\/zabbix\/"/' /etc/httpd/conf/httpd.conf

# Startando serviços
echo "Iniciando serviços"
sleep 3

# Iniciando serviço apache
systemctl enable httpd > /dev/null
systemctl start httpd
httpd=$(systemctl status httpd|grep running|wc -l)
if [[ $httpd == 1 ]]; then
  echo "Serviço httpd iniciado com sucesso!"
  sleep 3
else
  echo "Serviço httpd não iniciado!"
  sleep 3
fi
sleep 1

# Iniciando serviço zabbix-server
systemctl enable zabbix-server > /dev/null
systemctl start zabbix-server
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
systemctl enable zabbix-agent > /dev/null
systemctl start zabbix-agent
zbx_agent=$(systemctl status zabbix-agent|grep running|wc -l)
if [[ $zbx_agent == 1 ]]; then
  echo "Serviço zabbix-agent iniciado com sucesso!"
  sleep 3
else
  echo "Serviço zabbix-agent não iniciado!"
  sleep 3
fi
sleep 1

# Iniciando serviço snmpd
systemctl enable snmpd > /dev/null
systemctl start snmpd
snmp=$(systemctl status snmpd|grep running|wc -l)
if [[ $snmp == 1 ]]; then
  echo "Serviço snmpd iniciado com sucesso!"
  sleep 3
else
  echo "Serviço snmpd não iniciado!"
  sleep 3
fi
sleep 1

# Informações para acessar o zabbix
echo "Digite http://$SERVER_IP/ no navegador para da continuidade na configuração"
sleep 4
exit 0
}

# Verificando sistema operacional
if [[ ($ID = "centos") && ($VERSION_ID -eq "7") ]]; then
  instalacao
else
  echo "Desculpe! O script foi desenvolvido para o sistema CentOS 7"
  sleep 3
exit 0
fi
