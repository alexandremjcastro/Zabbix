#!/bin/bash
# SCRIPT CONSULTA O STATUS DO SERVICO DE NFE DIRETAMENTE DA RECEITA FEDERAL
# SCRIPT FEITO BASEADO NO AUTORIZADOR CONSULTA_AUTORIZADOR

# VARIAVEIS

CURL=$(which curl)
AWK=$(which awk)
CAT=$(which cat)
ESTADO=$1
STATUS=$2

ARQUIVO_TEMPORARIO="/tmp/statusNFE.txt"

function consultar_servico() {
        [[ $STATUS_AUTORIZACAO == "imagens/bola_verde_P.png" ]] && echo "1" #DISPONIVEL
        [[ $STATUS_AUTORIZACAO == "imagens/bola_amarela_P.png" ]] && echo "2" #INDISPONIVEL
        [[ $STATUS_AUTORIZACAO == "imagens/bola_vermelho_P.png" ]] && echo "0" #OFFLINE
        [[ $STATUS_RETORNO_AUTORIZACAO == "imagens/bola_verde_P.png" ]] && echo "1" #DISPONIVEL
        [[ $STATUS_RETORNO_AUTORIZACAO == "imagens/bola_amarela_P.png" ]] && echo "2" #INDISPONIVEL
        [[ $STATUS_RETORNO_AUTORIZACAO == "imagens/bola_vermelho_P.png" ]] && echo "0" #OFFLINE
        [[ $STATUS_INUTILIZACAO == "imagens/bola_verde_P.png" ]] && echo "1" #DISPONIVEL
        [[ $STATUS_INUTILIZACAO == "imagens/bola_amarela_P.png" ]] && echo "2" #INDISPONIVEL
        [[ $STATUS_INUTILIZACAO == "imagens/bola_vermelho_P.png" ]] && echo "0" #OFFLINE
        [[ $STATUS_CONSULTA_PROTOCOLO == "imagens/bola_verde_P.png" ]] && echo "1" #DISPONIVEL
        [[ $STATUS_CONSULTA_PROTOCOLO == "imagens/bola_amarela_P.png" ]] && echo "2" #INDISPONIVEL
        [[ $STATUS_CONSULTA_PROTOCOLO == "imagens/bola_vermelho_P.png" ]] && echo "0" #OFFLINE
        [[ $STATUS_CONSULTA_PROTOCOLO2 == "imagens/bola_verde_P.png" ]] && echo "1" #DISPONIVEL
        [[ $STATUS_CONSULTA_PROTOCOLO2 == "imagens/bola_amarela_P.png" ]] && echo "2" #INDISPONIVEL
        [[ $STATUS_CONSULTA_PROTOCOLO2 == "imagens/bola_vermelho_P.png" ]] && echo "0" #OFFLINE
        [[ $STATUS_SERVICO == "imagens/bola_verde_P.png" ]] && echo "1" #DISPONIVEL
        [[ $STATUS_SERVICO == "imagens/bola_amarela_P.png" ]] && echo "2" #INDISPONIVEL
        [[ $STATUS_SERVICO == "imagens/bola_vermelho_P.png" ]] && echo "0" #OFFLINE
        [[ $STATUS_SERVICO2 == "imagens/bola_verde_P.png" ]] && echo "1" #DISPONIVEL
        [[ $STATUS_SERVICO2 == "imagens/bola_amarela_P.png" ]] && echo "2" #INDISPONIVEL
        [[ $STATUS_SERVICO2 == "imagens/bola_vermelho_P.png" ]] && echo "0" #OFFLINE
        [[ $STATUS_CONSULTA_CADASTRO == "imagens/bola_verde_P.png" ]] && echo "1" #DISPONIVEL
        [[ $STATUS_CONSULTA_CADASTRO == "imagens/bola_amarela_P.png" ]] && echo "2" #INDISPONIVEL
        [[ $STATUS_CONSULTA_CADASTRO == "imagens/bola_vermelho_P.png" ]] && echo "0" #OFFLINE
        [[ $STATUS_RECEPCAO_EVENTO == "imagens/bola_verde_P.png" ]] && echo "1" #DISPONIVEL
        [[ $STATUS_RECEPCAO_EVENTO == "imagens/bola_amarela_P.png" ]] && echo "2" #INDISPONIVEL
        [[ $STATUS_RECEPCAO_EVENTO == "imagens/bola_vermelho_P.png" ]] && echo "0" #OFFLINE
        [[ $STATUS_RECEPCAO_EVENTO2 == "imagens/bola_verde_P.png" ]] && echo "1" #DISPONIVEL
        [[ $STATUS_RECEPCAO_EVENTO2 == "imagens/bola_amarela_P.png" ]] && echo "2" #INDISPONIVEL
        [[ $STATUS_RECEPCAO_EVENTO2 == "imagens/bola_vermelho_P.png" ]] && echo "0" #OFFLINE
        [[ $STATUS_RECEPCAO_EVENTO3 == "imagens/bola_verde_P.png" ]] && echo "1" #DISPONIVEL
        [[ $STATUS_RECEPCAO_EVENTO3 == "imagens/bola_amarela_P.png" ]] && echo "2" #INDISPONIVEL
        [[ $STATUS_RECEPCAO_EVENTO3 == "imagens/bola_vermelho_P.png" ]] && echo "0" #OFFLINE
}

if [[ $ESTADO,$STATUS == @(AM|BA|CE|GO|MG|MS|MT|PE|PR|RS|SP|SVAN|SVRS|SVC-AN|SVC-RS),AUTORIZACAO ]]; then
  STATUS_AUTORIZACAO=$($CAT $ARQUIVO_TEMPORARIO | egrep "<td>$ESTADO</td>" | $AWK '{print $2}' | $AWK -F 'src="' '{print $2}'| $AWK -F '"' '{print $1}') && consultar_servico
    elif [[ $ESTADO,$STATUS == @(AM|BA|CE|GO|MG|MS|MT|PE|PR|RS|SP|SVAN|SVRS|SVC-AN|SVC-RS),RETORNO.AUT ]]; then
      STATUS_RETORNO_AUTORIZACAO=$($CAT $ARQUIVO_TEMPORARIO | egrep "<td>$ESTADO</td>" | $AWK '{print $4}' | $AWK -F 'src="' '{print $2}'| $AWK -F '"' '{print $1}') && consultar_servico
        elif [[ $ESTADO,$STATUS == @(AM|BA|CE|GO|MG|MS|MT|PE|PR|RS|SP|SVAN|SVRS),INUTILIZACAO ]]; then
          STATUS_INUTILIZACAO=$($CAT $ARQUIVO_TEMPORARIO | egrep "<td>$ESTADO</td>" | $AWK '{print $6}' | $AWK -F 'src="' '{print $2}'| $AWK -F '"' '{print $1}') && consultar_servico
            elif [[ $ESTADO,$STATUS == @(AM|BA|CE|GO|MG|MS|MT|PE|PR|RS|SP|SVAN|SVRS),CONSULTA.PROTOCOLO ]]; then
              STATUS_CONSULTA_PROTOCOLO=$($CAT $ARQUIVO_TEMPORARIO | egrep "<td>$ESTADO</td>" | $AWK '{print $8}' | $AWK -F 'src="' '{print $2}'| $AWK -F '"' '{print $1}') && consultar_servico
            elif [[ $ESTADO,$STATUS == @(SVC-AN|SVC-RS),CONSULTA.PROTOCOLO ]]; then
              STATUS_CONSULTA_PROTOCOLO2=$($CAT $ARQUIVO_TEMPORARIO | egrep "<td>$ESTADO</td>" | $AWK '{print $6}' | $AWK -F 'src="' '{print $2}'| $AWK -F '"' '{print $1}') && consultar_servico
                elif [[ $ESTADO,$STATUS == @(AM|BA|CE|GO|MG|MS|MT|PE|PR|RS|SP|SVAN|SVRS),SERVICO ]]; then
                  STATUS_SERVICO=$($CAT $ARQUIVO_TEMPORARIO | egrep "<td>$ESTADO</td>" | $AWK '{print $10}' | $AWK -F 'src="' '{print $2}'| $AWK -F '"' '{print $1}') && consultar_servico
                elif [[ $ESTADO,$STATUS == @(SVC-AN|SVC-RS),SERVICO ]]; then
                  STATUS_SERVICO2=$($CAT $ARQUIVO_TEMPORARIO | egrep "<td>$ESTADO</td>" | $AWK '{print $8}' | $AWK -F 'src="' '{print $2}'| $AWK -F '"' '{print $1}') && consultar_servico
                    elif [[ $ESTADO,$STATUS == @(BA|CE|GO|MG|MS|MT|PE|PR|RS|SP|SVRS),CONSULTA.CADASTRO ]]; then
                      STATUS_CONSULTA_CADASTRO=$($CAT $ARQUIVO_TEMPORARIO | egrep "<td>$ESTADO</td>" | $AWK '{print $12}' | $AWK -F 'src="' '{print $2}'| $AWK -F '"' '{print $1}') && consultar_servico
                        elif [[ $ESTADO,$STATUS == @(BA|CE|GO|MG|MS|MT|PE|PR|RS|SP|SVRS),RECEPCAO.EVENTO ]]; then
                          STATUS_RECEPCAO_EVENTO=$($CAT $ARQUIVO_TEMPORARIO | egrep "<td>$ESTADO</td>" | $AWK '{print $14}' | $AWK -F 'src="' '{print $2}'| $AWK -F '"' '{print $1}') && consultar_servico
                        elif [[ $ESTADO,$STATUS == @(AM|SVAN),RECEPCAO.EVENTO ]]; then
                          STATUS_RECEPCAO_EVENTO2=$($CAT $ARQUIVO_TEMPORARIO | egrep "<td>$ESTADO</td>" | $AWK '{print $12}' | $AWK -F 'src="' '{print $2}'| $AWK -F '"' '{print $1}') && consultar_servico
                        elif [[ $ESTADO,$STATUS == @(SVC-AN|SVC-RS),RECEPCAO.EVENTO ]]; then
                          STATUS_RECEPCAO_EVENTO3=$($CAT $ARQUIVO_TEMPORARIO | egrep "<td>$ESTADO</td>" | $AWK '{print $10}' | $AWK -F 'src="' '{print $2}'| $AWK -F '"' '{print $1}') && consultar_servico
else
  echo "10" #SEM DADOS
fi
