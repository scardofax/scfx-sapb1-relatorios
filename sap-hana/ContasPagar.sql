/* select from OPCH T0 WHERE T0.DocDate >= '[%0]' and T0.DocDate <= '[%1]' */
SELECT
    NE."DocEntry",
    NE."DocNum",
    'Nota Entrada' as "Tipo de Documento",
    NE."BPLName" as "Filial",
    NE."CardCode" as "Código PN",
    NE."CardName" as "Nome PN",
    NE."DocDate" as "Lancamento",
    NEP."DueDate" as "Vencimento",
    NEP."InsTotal" as "Valor Prestacao",
    NE."Comments" as "Observacao",
    FP."Descript" as "Conta Corrente",
    CONCAT(NE."Serial", CONCAT('-', NE."SeriesStr")) as "N Documento"
FROM
    OPCH NE
    INNER JOIN PCH6 NEP ON NE."DocEntry" = NEP."DocEntry"
    LEFT OUTER JOIN OPYM FP ON NE."PeyMethod" = FP."PayMethCod"
WHERE
    NEP."DueDate" BETWEEN [%0] AND [%1]
    AND NE."CANCELED" = 'N'
    AND NEP."Status" = 'O'

UNION ALL

SELECT
    LC."TransId",
    LC."Number" as "DocNum",
    'Lançamento Contábil' as "Tipo de Documento",
    LCI."BPLName" as "Filial",
    PN."CardCode" as "Código PN",
    PN."CardName" as "Nome PN",
    LC."RefDate" as "Lancamento",
    LC."DueDate" as "Vencimento",
    LCI."Credit" as "Valor Prestacao",
    LC."Memo" as "Observacao",
    NULL as "Conta Corrente",
    CAST(LC."Number" as char) as "N Documento"    
FROM
    OJDT LC
    INNER JOIN JDT1 LCI ON LC."TransId" = LCI."TransId"
    INNER JOIN OCRD PN ON PN."CardCode" = LCI."ShortName"
WHERE
    LC."DueDate" BETWEEN [%0] AND [%1]
    AND LCI."Credit" > 0
    AND LC."Ref1" IS NULL
    AND LC."StornoToTr" IS NULL
