#!/usr/bin/env bash
#
# sefaznfe.consulta.sh - Consulta o status do serviço de NFE da receita federal
#
# GitHub:       https://github.com/alexandremjcastro/
# Autor:        Alexandre Castro
# Manutenção: -
#
# ------------------------------------------------------------------------ #
#  - Este programa irá consultar o status do serviço de NFE da receita federal
#  Responsável por realizar a consulta dentro do arquivo statusNFE.txt,
#  nas consultas será pesquisada as linhas do Autorizador e cada linha de serviço
#  deste autorizador, nesse script ele verificará as alterações das “Bolinhas”
#  em cada serviço, se for verde (Disponível) ele apresentará o resultado 1, 2
#  para amarelo (Indisponível) e 0 para Vermelho(Offine).
#
#  - Script criado com base no script do @bernardolankheet.
#
#   Exemplos:
#      $ ./sefaznfe.consulta.sh AM AUTORIZACAO
#      Neste exemplo o script realiza a consulta do campo de "Autorização" do
#      estado de AM. Retornando o valor 1, 2 ou 0.
# ------------------------------------------------------------------------ #
# Histórico:
#
#   v1.0 07/11/2019, Alexandre:
#     - Script criado.
#
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 4.2.46
# ------------------------------- VARIÁVEIS ----------------------------------------- #
SERVER_NAME=$(hostname)
SERVER_IP=$(hostname -I)
WGET=$(which wget)
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
# Instalando o Mysql
echo "Realizando download da última versão do MySql"
wget https://repo.mysql.com/mysql57-community-release-el7-11.noarch.rpm
sleep 1
rpm -ivh mysql57-community-release-el7-11.noarch.rpm
echo "Instalando o MySql"
yum install mysql-server -y
echo "Iniciando serviço do Mysql"
systemctl enable mysqld > /dev/null
systemctl start mysqld
db_mysql=$(systemctl status mysqld|grep running|wc -l)
if [[ $db_mysql == 1 ]]; then
  echo "Serviço mysqld iniciado com sucesso!"
else
  echo "Serviço mysqld não iniciado!"
exit
fi


# Criando Banco de Dados
db_root # Chama a função para digitar a senha de root do banco de dados
sleep 1
db_zabbix # Chama a função para digitar a senha do usuário zabbix do banco de dados
sleep 1
echo "Verificando senha padrão do mysql"
SENHA_dbTMP=$(grep "temporary password" /var/log/mysqld.log | sed 's/\s\+//g' | cut -d: -f4)
sleep 1
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
