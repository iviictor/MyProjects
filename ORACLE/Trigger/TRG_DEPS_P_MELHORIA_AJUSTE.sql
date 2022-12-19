CREATE OR REPLACE TRIGGER DEPS_PEDIDOS
AFTER INSERT ON PCPEDC
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
v_numregiao_param NUMBER(3,0);
  v_condvenda PCPEDC.CONDVENDA%TYPE;
  v_codcli PCPEDC.CODCLI%TYPE;
  v_numregiao PCPEDC.NUMREGIAO%TYPE;
  v_codcob PCPEDC.CODCOB%TYPE;
  v_codfilial PCPEDC.CODFILIAL%TYPE;
  BEGIN
    v_numregiao := :NEW.numregiao;
    v_condvenda := :NEW.condvenda;
    v_codcli    := :NEW.codcli;
    v_codcob    := :NEW.codcob;
    v_codfilial := :NEW.codfilial;
/* CONSULTA REGIAO PARAM */
    SELECT VALOR
    INTO v_numregiao_param
    FROM pcparamfilial
    WHERE nome          = 'FIL_NUMREGIAOPADRAO'
    AND codfilial       = v_codfilial;

/* FIM CONSULTA REGIAO PARAM */

    IF (
			  ((v_condvenda = 1 AND v_codcli NOT IN (1, 2))
	       OR  (v_condvenda = 7 AND v_numregiao <> v_numregiao_param))
	       AND v_codcob IN ('BK', 'CH', 'CHV', 'CHP')
      --AND :NEW.codfilial NOT IN ('24', '27', '30', '33') entranda das filials no dia 19/07/2021
        )THEN
        INSERT INTO DEPS_PEDIDOS (
          codigo
        , tipocliente
        , documentocliente
        , nomeoriginal
        , codigooriginal
        , codigopedido
        , dataemissao
        , dataprimeirovencimento
        , valorbruto
        , valorentrada
        , valorliquido
        , valorsaldo
        , tiporepresentante
        , documentorepresentante
        , tipopagamento
        , prazo
        , qtparcelas
        , codigosistemagestao
        , desassociar
        , codigosistemagestao_div
        , valor
        , datacriacao
        , filial
        , empresa
        , origemped
        , condvenda
        , cobranca
        , rca
        )
        VALUES (
        :NEW.numped
        , (SELECT tipofj FROM  PCCLIENT WHERE CODCLI = :NEW.codcli)
        , (SELECT cgcent FROM  PCCLIENT WHERE CODCLI = :NEW.codcli)
        , (SELECT cliente FROM  PCCLIENT WHERE CODCLI = :NEW.codcli)
        , :NEW.codcli
        , :NEW.numped
        , :NEW.data
        , CASE  WHEN :NEW.posicao = 'F'
                THEN (SELECT MIN(dtvencorig) FROM pcprest pr WHERE pr.numped = :NEW.numped)
                ELSE :NEW.data + nvl(:NEW.prazo1,0)
          END
        , :NEW.vltabela
        , '0'
        , :NEW.vltotal
        , :NEW.vlatend
        , (SELECT CASE
                WHEN u.tipovend = 'I' AND u.areaatuacao = 'A' THEN 'F'
                WHEN u.tipovend = 'R' AND u.areaatuacao = 'A' THEN 'J'
                WHEN u.tipovend = 'I' AND u.areaatuacao = 'V' THEN 'F'
            ELSE 'F' END tiporepresentante
            FROM pcusuari u WHERE  u.codusur = :NEW.codusur)
        , (SELECT CASE
                WHEN u.tipovend = 'I' AND u.cpf IS NOT NULL THEN u.cpf
                WHEN u.tipovend = 'I' AND u.cpf IS NULL THEN (SELECT cpf FROM pcempr e WHERE e.codusur = :NEW.codusur and e.codusur = u.codusur and u.nome not like '%TUPAN%')
                --(SELECT cpf FROM pcempr e WHERE e.codusur = :NEW.codusur)
                WHEN u.tipovend = 'R' AND u.cgc IS NOT NULL THEN u.cgc
                END documentorepresentante
        FROM pcusuari u WHERE  u.codusur = :NEW.codusur)
        , (SELECT CASE
                WHEN codcobsefaz = '01' THEN 'DINHEIRO'
                WHEN codcobsefaz = '02' THEN 'CHEQUE'
                WHEN codcobsefaz = '03' THEN 'CARTAO CREDITO'
                WHEN codcobsefaz = '04' THEN 'CARTAO DEBITO'
                WHEN codcobsefaz = '05' THEN 'CREDITO LOJA'
                WHEN codcobsefaz = '12' THEN 'VALE PRESENTE'
                WHEN codcobsefaz = '15' THEN 'BOLETO BANCARIO'
                WHEN codcobsefaz = '99' THEN 'ADIANTAMENTO'
            END tipopagamento
            FROM pccob b WHERE b.codcob = :NEW.codcob)
        , CASE WHEN :NEW.posicao <> 'F'
                THEN :NEW.prazo1 ||' '|| :NEW.prazo2 ||' '|| :NEW.prazo3 ||' '|| :NEW.prazo4 ||' '|| :NEW.prazo5 ||' '|| :NEW.prazo6 ||' '|| :NEW.prazo7 ||' '|| :NEW.prazo8 ||' '|| :NEW.prazo9 ||' '|| :NEW.prazo10 ||' '|| :NEW.prazo11 ||' '|| :NEW.prazo12
                WHEN :NEW.posicao = 'F' AND (SELECT CASE WHEN MAX(qtparcelaspos) IS NULL THEN 0 END parczero FROM pcprest pr1 WHERE pr1.numped = :NEW.numped) = 0
                THEN :NEW.prazo1 ||' '|| :NEW.prazo2 ||' '|| :NEW.prazo3 ||' '|| :NEW.prazo4 ||' '|| :NEW.prazo5 ||' '|| :NEW.prazo6 ||' '|| :NEW.prazo7 ||' '|| :NEW.prazo8 ||' '|| :NEW.prazo9 ||' '|| :NEW.prazo10 ||' '|| :NEW.prazo11 ||' '|| :NEW.prazo12
        ELSE (SELECT CASE WHEN MAX(qtparcelaspos) = 1 THEN '30'
                    WHEN MAX(qtparcelaspos) = 2 THEN '30 60'
                    WHEN MAX(qtparcelaspos) = 3 THEN '30 60 90'
                    WHEN MAX(qtparcelaspos) = 4 THEN '30 60 90 120'
                    WHEN MAX(qtparcelaspos) = 5 THEN '30 60 90 120 150'
                    WHEN MAX(qtparcelaspos) = 6 THEN '30 60 90 120 150 180'
                    WHEN MAX(qtparcelaspos) = 7 THEN '30 60 90 120 150 180 210'
                    WHEN MAX(qtparcelaspos) = 8 THEN '30 60 90 120 150 180 210 240'
                    WHEN MAX(qtparcelaspos) = 9 THEN '30 60 90 120 150 180 210 240 270'
                    WHEN MAX(qtparcelaspos) = 10 THEN '30 60 90 120 150 180 210 240 270 300'
                    WHEN MAX(qtparcelaspos) = 11 THEN '30 60 90 120 150 180 210 240 270 300 330'
                    WHEN MAX(qtparcelaspos) = 12 THEN '30 60 90 120 150 180 210 240 270 300 330 350'
                    WHEN MAX(qtparcelaspos) = 48 THEN '1448'
                    WHEN MAX(qtparcelaspos) = 60 THEN '1800'
               END pcprest
            FROM pcprest pr WHERE pr.numped = :NEW.numped)
        END
        , CASE WHEN :NEW.posicao = 'F' AND nvl((SELECT max(qtparcelaspos) FROM pcprest pr WHERE pr.numped = :NEW.numped), 0) > 0
                THEN (SELECT max(qtparcelaspos) FROM pcprest pr WHERE pr.numped = :NEW.numped)
                ELSE  CASE WHEN :NEW.prazo1  IS NOT NULL AND :NEW.prazo2  IS NULL THEN 1
                           WHEN :NEW.prazo2  IS NOT NULL AND :NEW.prazo3  IS NULL THEN 2
                           WHEN :NEW.prazo3  IS NOT NULL AND :NEW.prazo4  IS NULL THEN 3
                           WHEN :NEW.prazo4  IS NOT NULL AND :NEW.prazo5 IS NULL THEN 4
                           WHEN :NEW.prazo5  IS NOT NULL AND :NEW.prazo6  IS NULL THEN 5
                           WHEN :NEW.prazo6  IS NOT NULL AND :NEW.prazo7  IS NULL THEN 6
                           WHEN :NEW.prazo7  IS NOT NULL AND :NEW.prazo8  IS NULL THEN 7
                           WHEN :NEW.prazo8  IS NOT NULL AND :NEW.prazo9  IS NULL THEN 8
                           WHEN :NEW.prazo9  IS NOT NULL AND :NEW.prazo10 IS NULL THEN 9
                           WHEN :NEW.prazo10 IS NOT NULL AND :NEW.prazo11 IS NULL THEN 10
                           WHEN :NEW.prazo11 IS NOT NULL AND :NEW.prazo12 IS NULL THEN 11
                           WHEN :NEW.prazo12 IS NOT NULL THEN 12
                    END
           END
        , :NEW.posicao
        , ''
        , ''
        , ''
        , systimestamp
        , :NEW.codfilial
        , CASE WHEN (SELECT RAZAOSOCIAL FROM PCFILIAL WHERE CODIGO = :NEW.codfilial AND CODIGO NOT IN (15, 21)) LIKE 'TUPAN%'
               THEN 'TUPAN'
               ELSE 'DISTAC'
          END
        , :NEW.origemped
        , :NEW.condvenda
        , :NEW.codcob
        , :NEW.codusur
     );

    END IF;
  	  EXCEPTION 
			WHEN OTHERS THEN  -- SE QUALQUER ERRO OCORRER 
			DBMS_OUTPUT.PUT_LINE('Erro na execução da TRIGGER.');
			DBMS_OUTPUT.PUT_LINE('Entre em contato com o administrador. ');
			DBMS_OUTPUT.PUT_LINE('Código Oracle: ' || SQLCODE);
			DBMS_OUTPUT.PUT_LINE('Mensagem Oracle: ' || SQLERRM);
END;
