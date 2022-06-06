/* select from OINV T0 WHERE T0.DocDate >= '[%0]' and T0.DocDate <= '[%1]' */
SELECT
    CP."DocNum",
    'Nota Entrada' as "Tipo de Documento",
    CP."BPLName" as "Filial",
    CP."CardCode" as "Código PN",
    CP."CardName" as "Nome PN",
    CP."DocDate" as "Lancamento",
    CP."DocDueDate" as "Vencimento",
    NEP."InstlmntID" as "N Parcela",
    NEP."InsTotal" as "Valor Parcela",
    (
        select "WTAmnt"
        from PCH5
        where "WTCode" = 'E001' AND "AbsEntry" = NE."DocEntry"
    ) AS "Valor PIS",
    (
        select "WTAmnt"
        from PCH5
        where "WTCode" = 'E002' AND "AbsEntry" = NE."DocEntry"
    ) AS "Valor COFINS",
    (
        select "WTAmnt"
        from PCH5
        where "WTCode" = 'E003' AND "AbsEntry" = NE."DocEntry"
    ) AS "Valor CSLL",
    (
        select "WTAmnt"
        from PCH5
        where "WTCode" in ('E004', 'E005') AND "AbsEntry" = NE."DocEntry"
    ) AS "Valor IR",
    (
        select "WTAmnt"
        from PCH5
        where "WTCode" in ('E007', 'E008') AND "AbsEntry" = NE."DocEntry"
    ) AS "Valor ISS",
    (
        select "WTAmnt"
        from PCH5
        where "WTCode" = 'E006' AND "AbsEntry" = NE."DocEntry"
    ) AS "Valor INSS",
    CPI."DcntSum" as "Desconto",
    CPI."U_ValorMulta" as "Multa",
    CPI."SumApplied" as "Valor Pago",
    NE."Comments" as "Observacao",
    (
        select
            CASE T0."DataSource" WHEN 'I' THEN T1."AcctName" WHEN 'O' THEN T1."AcctName" ELSE NULL END
        from
            OVPM T0
            INNER JOIN OACT T1 ON T0."CashAcct" = T1."AcctCode"
            OR T0."TrsfrAcct" = T1."AcctCode"
        WHERE
            T0."DocEntry" = CP."DocEntry"
    ) AS "Conta Corrente",
    CONCAT(NE."Serial", CONCAT('-', NE."SeriesStr")) as "N Documento"
FROM
    OVPM CP
    INNER JOIN VPM2 CPI ON CP."DocEntry" = CPI."DocNum"
    INNER JOIN OPCH NE ON CPI."baseAbs" = NE."DocEntry"
    INNER JOIN INV6 NEP ON NE."DocEntry" = NEP."DocEntry"
    AND CPI."InvoiceId" = NEP."InstlmntID"
    LEFT OUTER JOIN OPYM FP ON NE."PeyMethod" = FP."PayMethCod"
WHERE
    CP."DocDate" BETWEEN [%0]
    AND [%1]
    AND CP."Canceled" = 'N'
    AND CPI."InvType" = 18

UNION ALL

SELECT
    CP."DocNum",
    'Lançamento Contábil' as "Tipo de Documento",
    CP."BPLName" as "Filial",
    CP."CardCode" as "Código PN",
    CP."CardName" as "Nome PN",
    CP."DocDate" as "Lancamento",
    CP."DocDueDate" as "Vencimento",
    1 as "N Parcela",
    LC."LocTotal" as "Valor Parcela",
    null,
    null,
    null,
    null,
    null,
    null,
    CPI."DcntSum" as "Desconto",
    CPI."U_ValorMulta" as "Multa",
    CPI."SumApplied" as "Valor Recebido",
    LC."Memo" as "Observacao",
    (
        select
            CASE T0."DataSource" WHEN 'I' THEN T1."AcctName" WHEN 'O' THEN T1."AcctName" ELSE NULL END
        from
            OVPM T0
            INNER JOIN OACT T1 ON T0."CashAcct" = T1."AcctCode"
            OR T0."TrsfrAcct" = T1."AcctCode"
        WHERE
            T0."DocEntry" = CP."DocEntry"
    ) AS "Conta Corrente",
    CAST(LC."TransId" as char) as "N Documento"
FROM
    OVPM CP
    INNER JOIN VPM2 CPI ON CP."DocEntry" = CPI."DocNum"
    INNER JOIN OJDT LC ON CPI."baseAbs" = LC."TransId"
WHERE
    CP."DocDate" BETWEEN [%0] AND [%1]
    AND CP."Canceled" = 'N'
    AND CPI."InvType" = 30