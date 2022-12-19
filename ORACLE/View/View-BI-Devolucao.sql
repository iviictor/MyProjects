SELECT devol.codfilial, devol.dtent, devol.codcli, devol.codprod, devol.qtcont, devol.motivo, devol.motivo2,
       devol.numtransent, devol.vldevolucao, devol.vlcmvdevol, devol.codfornec, devol.codusur, devol.codepto,
       devol.ufmov, cab.CODMUNICIPIO, devol.codplpag, devol.codcob
    FROM view_devol_resumo_faturamento devol, pcnfent cab   
    WHERE devol.numtransent = cab.numtransent
    AND devol.codfilial IN (2,6,15,24,25,27,30,31,32,33,41,43,44,45,47,48,49,53,54)
    AND devol.dtent = $(V_DATA_FORMAT)
    AND devol.condvenda NOT IN (4, 5, 10, 13, 20, 98, 99);

/***************************************************************************************************************************
*/
SELECT avulsa.codfilial, avulsa.dtent, avulsa.codcli, avulsa.codprod,  avulsa.motivo, avulsa.motivo2,
       avulsa.qt, avulsa.numtransent, avulsa.vltotal, avulsa.vldevolucao, avulsa.vldevcmvavulsai, avulsa.codfornec, 
       avulsa.codusur, avulsa.uf, cab.CODMUNICIPIO, avulsa.codplpag, avulsa.codepto
    FROM tupan.view_devol_resumo_faturavulsa avulsa, pcnfent cab   
    WHERE avulsa.numtransent = cab.numtransent
    AND avulsa.codfilial IN (2,6,15,24,25,27,30,31,32,33,41,43,44,45,47,48,49,53,54)
    AND avulsa.dtent  = $(V_DATA_FORMAT);