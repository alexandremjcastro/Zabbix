#!/usr/bin/env bash
#
# sefaznfe.discovery.sh - Realiza o download da página do serviço de NFE da receita federal
#
# GitHub:       https://github.com/alexandremjcastro/
# Autor:        Alexandre Castro
# Manutenção: -
#
# ------------------------------------------------------------------------ #
#  - Realiza o download da página e salva em /tmp com o nome statusNFE.txt.
#  Se ele tiver sucesso no download ele retorna o valor 1, caso tenha falha ou
#  a página estiver offline ele retorna 0.
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
