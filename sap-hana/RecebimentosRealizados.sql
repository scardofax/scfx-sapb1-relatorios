/* select from OINV T0 WHERE T0.DocDate >= '[%0]' and T0.DocDate <= '[%1]' */
SELECT
    CR."DocEntry",
    'Nota Saida' as "Tipo de Documento",
    CR."BPLName" as "Filial",
    CR."CardCode" as "Código PN",
    CR."CardName" as "Nome PN",
    CR."DocDate" as "Lancamento",
    CR."DocDueDate" as "Vencimento",
    NSP."InstlmntID" as "N Parcela",
    NSP."InsTotal" as "Valor Parcela",
    (
        select "WTAmnt"
        from INV5
        where "WTCode" = 'S001' AND "AbsEntry" = NS."DocEntry"
    ) AS "Valor PIS",
    (
        select "WTAmnt"
        from INV5
        where "WTCode" = 'S002' AND "AbsEntry" = NS."DocEntry"
    ) AS "Valor COFINS",
    (
        select "WTAmnt"
        from INV5
        where "WTCode" = 'S003' AND "AbsEntry" = NS."DocEntry"
    ) AS "Valor CSLL",
    (
        select "WTAmnt"
        from INV5
        where "WTCode" in ('S004', 'S005', 'S007') AND "AbsEntry" = NS."DocEntry"
    ) AS "Valor IR",
    (
        select "WTAmnt"
        from INV5
        where "WTCode" in ('S006') AND "AbsEntry" = NS."DocEntry"
    ) AS "Valor ISS",
    (
        select "WTAmnt"
        from INV5
        where "WTCode" = 'XXXX' AND "AbsEntry" = NS."DocEntry"
    ) AS "Valor INSS",
    CRI."DcntSum" as "Desconto",
    CRI."U_ValorMulta" as "Multa",
    CRI."SumApplied" as "Valor Recebido",
    NS."Comments" as "Observacao",
    (
        select
            CASE T0."DataSource" WHEN 'I' THEN T1."AcctName" WHEN 'O' THEN T1."AcctName" ELSE NULL END
        from
            ORCT T0
            INNER JOIN OACT T1 ON T0."CashAcct" = T1."AcctCode"
            OR T0."TrsfrAcct" = T1."AcctCode"
        WHERE
            T0."DocEntry" = CR."DocEntry"
    ) AS "Conta Corrente",
    CONCAT(NS."Serial", CONCAT('-', NS."SeriesStr")) as "Nota"
FROM
    ORCT CR
    INNER JOIN RCT2 CRI ON CR."DocEntry" = CRI."DocNum"
    INNER JOIN OINV NS ON CRI."baseAbs" = NS."DocEntry"
    INNER JOIN INV6 NSP ON NS."DocEntry" = NSP."DocEntry"    
    AND CRI."InvoiceId" = NSP."InstlmntID"
    LEFT OUTER JOIN OPYM FP ON NS."PeyMethod" = FP."PayMethCod"
WHERE
    CR."DocDate" BETWEEN [%0] AND [%1]
    AND CR."Canceled" = 'N'
    AND CRI."InvType" = 13
UNION ALL
SELECT
    CR."DocNum",
    'Lançamento Contábil' as "Tipo de Documento",
    CR."BPLName" as "Filial",
    CR."CardCode" as "Código PN",
    CR."CardName" as "Nome PN",
    CR."DocDate" as "Lancamento",
    CR."DocDueDate" as "Vencimento",
    1 as "N Parcela",
    LC."LocTotal" as "Valor Parcela",
    null,
    null,
    null,
    null,
    null,
    null,
    CRI."DcntSum" as "Desconto",
    CRI."U_ValorMulta" as "Multa",
    CRI."SumApplied" as "Valor Recebido",
    LC."Memo" as "Observacao",
    (
        select
            CASE T0."DataSource" WHEN 'I' THEN T1."AcctName" WHEN 'O' THEN T1."AcctName" ELSE NULL END
        from
            ORCT T0
            INNER JOIN OACT T1 ON T0."CashAcct" = T1."AcctCode"
            OR T0."TrsfrAcct" = T1."AcctCode"
        WHERE
            T0."DocEntry" = CR."DocEntry"
    ) AS "Conta Corrente",
    CAST(LC."TransId" as char) as "N Documento"
FROM
    ORCT CR
    INNER JOIN RCT2 CRI ON CR."DocEntry" = CRI."DocNum"
    INNER JOIN OJDT LC ON CRI."baseAbs" = LC."TransId"
WHERE
    CR."DocDate" BETWEEN [%0]
    AND [%1]
    AND CR."Canceled" = 'N'
    AND CRI."InvType" = 30