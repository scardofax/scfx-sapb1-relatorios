/*- SEÇÃO DUPLICATAS RECEBIDAS*/ 

select [TAG],
[N° LCM],
[Cód.: PN],
[Nome do PN],
[N° NF],
[Data do Lançamento],
[Valor da Parcela],
[Data do Pagamento],
[Valor Pago],
[LCM Baixa],
[AcctName],
[Forma de Pagamento] from (
select k0.*, k2.AcctName, (select top 1 Forma from SBO_ELEVATE..AprovalWeb t20 where t20.Docentry = k0.DocEntry and t20.InstId = k0.InstId and t20.ObjType = k0.InvType) 'Forma de Pagamento'
from (
SELECT DISTINCT t0.InvType, t0.InstId, t0.docentry,
                      CASE T0.[InvType] WHEN '103' THEN 'A/R Down Payment' WHEN '13' THEN 'Nota Fiscal de Saida' WHEN '14' THEN 'A/R Credit Memo' WHEN '204' THEN 'Adiantamento'
                       WHEN '18' THEN 'Nota Fiscal de Entrada' WHEN '19' THEN 'A/P Credit Memo' WHEN '24' THEN 'Incoming Payment' WHEN '25' THEN 'Deposit' WHEN '46' THEN 'Payment Advice'
                       WHEN '57' THEN 'Checks for Payment' WHEN '76' THEN 'Postdated Deposit' WHEN '-2' THEN 'Opening Balance' WHEN '-3' THEN 'Closing Balance' WHEN '30' THEN
                       'Lançamento Manual *' WHEN '-1' THEN 'All Transactions' WHEN '163' THEN 'A/P Correction PCHoice' WHEN '165' THEN 'A/R Correction PCHoice' END 'TAG', M2.TransId 'N° LCM', 
                      T1.[CardCode] 'Cód.: PN', T1.[CardName] 'Nome do PN', m2.Serial 'N° NF', T0.[InstId] 'Parcela', M2.Obs 'Obs', m2.DocDate 'Data da Emissão', m2.DueDate 'Data do Vencimento da Parcela', m2.TaxDate 'Data do Lançamento', t0.sumapplied 'Valor da Parcela', t1.docdate 'Data do Pagamento', t0.sumapplied 'Valor Pago',
                      case when T1.CashSum > 0 then T1.CashAcct
     when T1.[CheckSum] > 0 then T1.CheckAcct
     when T1.TrsfrSum > 0 then T1.TrsfrAcct
     WHEN T1.BoeSum > 0 THEN T1.BoeAcc
end 'Conta Caixa', t1.transid 'LCM Baixa'
FROM         vpm2 T0 INNER JOIN
                      Ovpm T1 ON T0.DocNum = T1.DocEntry INNER JOIN
                          (SELECT     T0.ObjType, T0.DocEntry, T1.InstlmntID, T0.Comments 'OBS', T0.TransId, t0.DocDate, T1.DueDate, T0.Serial, T0.TaxDate
                            FROM          OPCH T0 INNER JOIN
                                                   PCH6 T1 ON T0.DocEntry = T1.DocEntry
                            UNION ALL
                            SELECT     T0.ObjType, T0.DocEntry, T1.InstlmntID, T0.Comments, T0.TransId, t0.DocDate, T1.DueDate, T0.Serial, T0.TaxDate
                            FROM         ODPO T0 INNER JOIN
                                                  DPO6 T1 ON T0.DocEntry = T1.DocEntry
                            UNION ALL
                            SELECT     T0.ObjType, T0.DocEntry, T1.InstlmntID, T0.Comments, T0.TransId, t0.DocDate, T1.DueDate, T0.Serial, T0.TaxDate
                            FROM         OCPI T0 INNER JOIN
                                                  CPI6 T1 ON T0.DocEntry = T1.DocEntry
                            UNION ALL
                            SELECT     T0.ObjType, T0.DocEntry, T1.InstlmntID, T0.Comments, T0.TransId, t0.DocDate, T1.DueDate, T0.Serial, T0.TaxDate
                            FROM         ORPC T0 INNER JOIN
                                                  RPC6 T1 ON T0.DocEntry = T1.DocEntry
                            UNION ALL
                            SELECT     t0.ObjType, t0.TransId, t1.Line_ID, t0.Memo, t0.TransId, t0.RefDate, t1.DueDate, T0.TransId, T0.TaxDate
                            FROM         OJDT t0 INNER JOIN
                                                  jdt1 t1 ON t0.TransId = t1.TransId) 
                                                  
                                                  m2 ON M2.ObjType = T0.InvType AND T0.DocEntry = M2.DocEntry AND m2.InstlmntID = T0.InstId
												  where t1.Canceled = 'N'
UNION ALL

select 30,0,0,
'Lançamento Manual', T0.TransId, A2.AcctCode, A2.AcctName, T0.TransId, T0.Line_ID, T1.Memo, T1.RefDate, null, T0.TaxDate, T0.Credit, T1.RefDate, T0.Credit, T0.Account, t1.transid
 from 
JDT1 T0  INNER JOIN OJDT T1 ON T0.TransId = T1.TransId INNER JOIN OACT T2 ON T0.Account = T2.AcctCode
INNER JOIN OACT A2 ON T0.ContraAct = A2.AcctCode
where 
T1.[TransType] = '30' and  T2.[Finanse] = 'y' and A2.LocManTran = 'N'
AND T0.CREDIT > 0
and T0.ShortName not in (select cardcode from ocrd)
) k0 left outer join OACT k2 on k0.[Conta Caixa] = k2.AcctCode
INNER join OJDT k3 on k3.TransId = k0.[LCM Baixa]
--and k0.[N° LCM] not in (select distinct TransId from OJDT where Indicator in( 'ES', 'TR'))
where (isnull(k3.Indicator,'') <> 'TR' and isnull(k3.Indicator,'') <> 'ES')
and TAG in ( 'Nota Fiscal de Entrada', 'Adiantamento')
--order by k0.[Cód.: PN]
) km1