select
    "NomePN" as "Nome PN",
    "DataVencimento",
    "ValorRecebido" as "Valor Recebido",
    "Observacao",
    "ContaCorrente" as "Conta Corrente",
    "Filial",
    "DataLancamento"
from
    (
        select
            CP."CardName" as "NomePN",
            NEP."DueDate" as "DataVencimento",
            CP."DocDate" as "DataLancamento",
            CPI."SumApplied" as "ValorRecebido",
            CP."Comments" as "Observacao",
            (
                select
                    CASE T0."DataSource" WHEN 'I' THEN T1."AcctName" WHEN 'O' THEN T1."AcctName" ELSE NULL END
                from
                    OVPM T0
                    INNER JOIN OACT T1 ON T0."CashAcct" = T1."AcctCode"
                    OR T0."TrsfrAcct" = T1."AcctCode"
                WHERE
                    T0."DocEntry" = CP."DocEntry"
            ) AS "ContaCorrente",
            CP."BPLName" as "Filial"
        FROM
            OVPM CP
            INNER JOIN VPM2 CPI ON CP."DocEntry" = CPI."DocNum"
            INNER JOIN OPCH NE ON CPI."baseAbs" = NE."DocEntry"
            INNER JOIN PCH6 NEP ON NE."DocEntry" = NEP."DocEntry"
    )
where
    "DataLancamento" = {?date}
    AND "ContaCorrente" = '{?conta}'    
    AND ("NomePN" = '{?pn}' OR '{?pn}' = 'TODOS')
