select
    F."BPLName",
    'CNPJ: ' || F."TaxIdNum" || ' | Inscrição Estadual: ' || F."TaxIdNum2" || ' | Inscrição Municipal: ' || F."AddtnlId" AS "insc",
    F."AddrType" || ' ' || F."Street" || ', ' || cast(F."StreetNo" AS VARCHAR) || ' - ' || F."Building" || ' - ' || F."Block" as "End1",
    F."City" || ' - ' || F."State" || ' CEP: ' || F."ZipCode" AS "end2",
    F."City" || ' (' || F."State" || '), ' || TO_VARCHAR(N."DocDate", 'DD/MM/YYYY') as "emissao",
    N."DocEntry",
    'Recibo de Locação Nº ' || LPAD(n."Serial", 9, '0') num_nota,
    N."DocNum",
    N."DocDate",
    CONCAT('Dia ', TO_VARCHAR(N."DocDueDate", 'DD/MM/YYYY')) || ' no valor de R$ ' || cast(N."DocTotal" AS numeric(15, 2)) as "vencimento",
    N."DiscSumSy",
    N."DocTotal",
    N."Comments",
    PN."CardCode",
    PN."CardName",
    CONCAT(PNE."AddrType", ' ') || CONCAT(PNE."Street", ', ') || CONCAT(ifnull(PNE."StreetNo", ''), ' - ') || CONCAT(
        CONCAT(ifnull(PNE."Building", ''), ' - '),
        PNE."Block"
    ) as "End1_pn",
    CONCAT(PNE."City", ' - ') || CONCAT(CONCAT(PNE."State", ' CEP: '), PNE."ZipCode") AS "end2_pn",
    CONCAT('CNPJ: ', PNC."TaxId0") as "cnpj_pn",
    'Telefone: (' || PN."Phone2" || ') ' || PN."Phone1" as "telefone",
    PN."E_Mail",
    I."ItemCode",
    I."ItemName",
    NI."Quantity",
    NI."Price",
    NI."LineTotal"
from
    OINV N
    INNER JOIN INV1 NI ON N."DocEntry" = NI."DocEntry"
    INNER JOIN OITM I ON NI."ItemCode" = I."ItemCode"
    INNER JOIN OBPL F ON N."BPLId" = F."BPLId"
    INNER JOIN OCRD PN ON N."CardCode" = PN."CardCode"
    INNER JOIN CRD1 PNE ON PN."CardCode" = PNE."CardCode"
    INNER JOIN CRD7 PNC ON PNE."CardCode" = PNC."CardCode"
    and PNE."Address" = PNC."Address"
WHERE
    PNE."AdresType" = 'S'
    AND N."DocEntry" = 115