
DECLARE
  contador NUMBER;
BEGIN
  contador := 0;
  FOR registro IN
  (SELECT rowid FROM PCCLIENT WHERE TIPOFJ = 'F' AND BLOQUEIOINATIVIDADE = 'S'
  )
  LOOP
    UPDATE PCCLIENT SET BLOQUEIOINATIVIDADE = 'N' WHERE ROWID = registro.rowid;
    contador   := contador + 1;
    IF contador > 500 THEN
      COMMIT;
      contador := 0;
    END IF;
  END LOOP;
  COMMIT;
END;