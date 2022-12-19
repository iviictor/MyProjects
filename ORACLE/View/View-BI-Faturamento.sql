SELECT vendas.codfilial,vendas.dtsaida, vendas.codcli, vendas.codprodmov, vendas.codeptomov,
       vendas.qtcont, vendas.numtransvenda, vendas.vlvenda, vendas.codfornecmov,  vendas.vltabela,
       vendas.codusurmov, vendas.ufmov, cab.CODMUNICIPIO, cab.codsupervisor, vendas.vlcustofin, 
       cab.codemitentepedido, vendas.codplpag, vendas.codcob, vendas.vlipi, vendas.ICMSRETIDO
    FROM view_vendas_resumo_faturamento vendas, pcnfsaid cab
    WHERE vendas.numtransvenda = cab.numtransvenda
    AND vendas.codfilial = cab.codfilial
 
    AND vendas.codfilial IN (2,6,15,24,25,27,30,31,32,33,41,43,44,45,47,48,49,53,54)
    AND Extract(YEar from vendas.dtsaida) = 2022
    AND NVL (vendas.condvenda, 0) IN (1, 7);