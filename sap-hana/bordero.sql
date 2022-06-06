select
    "NomePN" as "Nome PN",
    "Vencimento",
    "ValorRecebido" as "Valor Recebido",
    "Observacao",
    "ContaCorrente" as "Conta Corrente",
    "Filial"
from
    (
        select
            CP."CardName" as "NomePN",
            CP."DocDueDate" as "Vencimento",
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
    )
where
    "Vencimento" = {?date}
    AND "ContaCorrente" = {?conta}
