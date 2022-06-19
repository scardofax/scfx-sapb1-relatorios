/* select from INV6 T0 WHERE T0.DueDate >= '[%0]' and T0.DueDate <= '[%1]' */
SELECT
    NS."DocEntry",
    NS."DocNum",
    'Nota Saida' as "Tipo de Documento",
    NS."BPLName" as "Filial",
    NS."CardCode" as "Código PN",
    NS."CardName" as "Nome PN",
    NS."DocDate" as "Lancamento",
    NSP."DueDate" as "Vencimento",
    NSP."InsTotal" as "Valor Prestacao",
    NS."Comments" as "Observacao",
    FP."Descript" as "Conta Corrente",
    CONCAT(NS."Serial", CONCAT('-', NS."SeriesStr")) as "Nota"
FROM
    OINV NS
    INNER JOIN INV6 NSP ON NS."DocEntry" = NSP."DocEntry"
    LEFT OUTER JOIN OPYM FP ON NS."PeyMethod" = FP."PayMethCod"
WHERE
    NSP."DueDate" BETWEEN [%0] AND [%1]
    AND NS."CANCELED" = 'N'
    AND NSP."Status" = 'O'

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
    LCI."Debit" as "Valor Prestacao",
    LC."Memo" as "Observacao",
    NULL as "Conta Corrente",
    CAST(LC."Number" as char) as "N Documento"
FROM
    OJDT LC
    INNER JOIN JDT1 LCI ON LC."TransId" = LCI."TransId"
    INNER JOIN OCRD PN ON PN."CardCode" = LCI."ShortName"
WHERE
    LC."DueDate" BETWEEN [%0] AND [%1]
    AND LCI."Debit" > 0
    AND LC."Ref1" IS NULL
    AND LC."StornoToTr" IS NULL
    