#!/usr/bin/csh
###
 # @Author: your name
 # @Date: 2021-12-05 20:27:42
 # @LastEditTime: 2021-12-05 21:02:41
 # @LastEditors: Please set LastEditors
 # @Description: 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 # @FilePath: /xml-py-tool/download/sh_download_gnssfile.sh
### 
if ($#argv < 2) then
more << EOF

 Usage $0 yyyy doy ndays AC DataCenter workdir(where you save the download data)
  
 Example: $0 2015 1 5 igs 1 /home/kekezhang/data
 Note: AC: the script support includes: igs,igs_30s,cod,cod_05s,com,gbm,wum,grg,grm.
       The default AC is igs.
       DataCenter: 1 = CDDIS(cddis.gsfc.nasa.gov)
                   2 = WHU GNSS Center(igs.gnsswhu.cn)
EOF
   exit
endif

set yyyy = $1
set doy = $2

set count = 1
if ($#argv >= 3) then
  set count = $3
endif

set sample = 5
if ($#argv >= 4) then
  set sample = $4
endif

set beg = 0
set last = 6
if ($#argv >= 6) then
  set beg = $5
  set last = $6
endif

set AC = grm
if ($#argv >= 7) then
  set AC = $7
endif

set ftppath = ftp://igs.gnsswhu.cn/pub
set ftpAC = WHU
if ($8 == 1) then
  set ftppath = https://cddis.nasa.gov/archive
  set ftpAC = CDDIS
else if ($8 == 2) then
  set ftppath = ftp://igs.gnsswhu.cn/pub
  set ftpAC = WHU
endif

set workdir = /cache/hanjunjie/Data/$yyyy
if ($#argv >= 9) then
  set workdir = $9
endif

set yy = `echo $yyyy | awk '{printf("%2.2d",$1-int($1/100)*100)}'`
echo $yyyy $doy $count $AC $ftpAC $workdir

set bindir = /home/hanjunjie/tools/zbin/bin
set crx2rnx = /home/hanjunjie/tools/CRX2RNX
set gfzrnx = /home/hanjunjie/tools/gfzrnx
#set rec list for observation
#set rec_list = (areg arev areq wtza wtzz irkj irkm suth sutv dgar dgav)
#set rec_list = (yarr yar3)
#set rec_list = (wtza wtzz yarr yar3)
#set rec_list = (areg areq wtzz wtza yarr yar3 irkj irkm gold gol2 wtzr wtzs)
# set rec_list = (hkcl hkfn hkks hkkt hklm hklt hkmw hknp hkoh hkpc hksc hksl hkss hkst hktk hkws kyc1 t430)
# set rec_list = (hkkt hklm hklt hkmw hknp hkoh hkpc hksc hksl hkss hkst hktk hkws kyc1 t430)
# set rec_list = (ACOR ADAR AGRN AJAC ALAC ALBA ALME ANK2 AQUI ARA2 ARGI ARIS ARJ6 ASIR AUBG AUTN AXPV BACA BADH BAIA BAUT BBYS BCLN BELL BME1 BOGE BOGI BOGO BOLG BOR1 BORJ BORR BPDL BRMF BRMG BRST BRTS BRUX BSCN BUCU BUDD BUDP BUTE BYDG BZR2 CACE CAG1 CANT CARG CASC CASE CEBR CEU1 CFRM CHIO CHIZ CIMO CLIB CMEL COBA COMO COST CPAR CRAK CREU CTAB CUGA DARE DELF DENT DEVA DGOR DIEP DILL DLF1 DNMU DOUR DVCN DYNG EBRE EGLT EIJS ELBA ENAO ENTZ ENZA ESCO EUSK FFMJ FINS FLRS FRA2 FRNE FUNC GALH GANP GARI GELL GENO GOET GOML GOP6 GOPE GOR2 GRAC GRAS GRAZ GSR1 GUIP GWWL HAS6 HEL2 HELG HERS HETT HOBU HOFJ HOFN HUEL IBIZ IENG IGEO IGM2 IGMI IGNF IJMU ILDX INVR IRBE ISRN ISTA IZAN IZMI JOE2 JOEN JON6 JOZ2 JOZE KAD6 KARL KATO KDA2 KEV2 KILP KIR0 KIR8 KIRU KIV2 KLNK KLOP KNJA KOS1 KRA1 KRAW KRS1 KUNZ KURE KUU2 LAGO LAMA LAMP LCRA LDB2 LEIJ LEK6 LEON LERI LICC LIDA LIGN LIL2 LINZ LLIV LODZ LOV6 LPAL LROC M0SE MADR MAH1 MALA MALL MAN2 MAR6 MAR7 MARS MAS1 MAT1 MATE MATG MDEU MEDI MELI MERS MET3 METG METS MIK3 MIKL MLHD MLVL MMET MNKW MNSK MOGI MOP2 MOPI MOPS MUK2 NABG NICO NOR7 NOT1 NOVP NPAZ NYA1 NYA2 NYAL OBE4 OLK2 ONS1 ONSA ORID ORIV OROS OSK6 OSLS OST6 OUL2 OVE6 PADO PALB PASA PDEL PENC PFA3 PINS PLND PMTH POLV POPI POTS PPSH PRAT PRYL PSTO PSTV PTBB PULK PUYV PYHA PZA2 QAQ1 RAEG RAH1 RANT REDU REDZ REYK RIGA RIO1 RIVO ROM2 ROVE RVNE SABA SALA SART SAS2 SAVU SBG2 SCIL SCOA SCOR SFER SHOE SKE0 SKE8 SMLA SNEO SNIK SODA SOFI SONS SPRN SPT0 SPT7 SRJV STAS STNB SUL5 SULD SULP SUN6 SUR4 SVE6 SVLL SVTL SWAS SWKI TAR0 TEOS TER2 TERS TERU TIT2 TLL1 TLMF TLSE TLSG TOIL TOR1 TORI TORN TRDS TREU TRF2 TRMI TRO1 TUBI TUBO TUC2 TUO2 UBEN UCAG UME6 UNPG USAL USDL VAA2 VAAS VAE6 VAIN VALA VALE VARS VEN1 VFCH VIGO VIL0 VIL6 VILL VIR2 VIRG VIS0 VIS6 VITR VLIS VLN1 VLNS VTRB WARE WARN WRLG WROC WSRT WTZA WTZR WTZS WTZZ WUTH YEBE ZADA ZARA ZECK ZIM2 ZIMM ZYWI ZZON)
# set rec_list = (BOLG CMEL JOEN METS SODA TUBI VAAS WTZA ZIMM)
# set rec_list = (TRO1 VARS HETT OVE6 ROM2 OST6 OLK2 PYHA LEK6 METG LOV6 IRBE NOR7 SPT7 VAIN HAS6 RANT REDZ LAMA HELG GELL LDB2 GOML GOET BRTS LEIJ WARE INVR ARIS TLL1 SNEO WTZZ AUBG BUTE BACA MIKL POLV COMO EGLT SWAS MARS ZADA AJAC SCOA ACOR ALME MMET ORID IZMI NICO SAVU SUN6 MNSK TER2 SMLA IJMU DYNG DEVA MALL MAH1 LODZ ZYWI AUTN ENTZ VILL)
# set rec_list = (TERS IJMU DELF VLIS DENT WSRT KOS1 BRUX DOUR WARE REDU EIJS TIT2 EUSK DILL DIEP BADH KLOP FFMJ KARL HOBU PTBB GOET)
# set rec_list = (TERS IJMU DENT WSRT KOS1 BRUX DOUR WARE REDU EIJS TIT2 EUSK DILL DIEP BADH KLOP FFMJ KARL HOBU PTBB GOET)
# set rec_list = (KLOP)
#For HJX
# set rec_list = (ARA2 BAUT BBYS BME1 BUTE CFRM CLIB CPAR CPAK CTAB DVCN GANP GOP6 GOPE GRAZ HOFJ KATO KRA1 KRAW KUNZ LEIJ LINZ MOP2 MOPI PENC SBG2 SPRN TRF2 TUBO WROC WTZR WTZS WTZZ ZYWI ZZON)
# set rec_list = (MSEL MEDI IGMI IGM2 GENO PADO VEN1 MOPS CIMO BOLG GARI VIRG PRAT ELBA UNPG POPI)
# set rec_list = (ZIM2 ZIMM AUTN BRMF BSCN BRMG PFA3 LIGN COMO TORI IENG)
# set rec_list = (MOPI MOP2 KUNZ TRF2 SPRN BUTE PENC DVCN BBYS TUBO)
# set rec_list = (BOGO BOGE BOGI LAMA SWKI JOZE BPDL BRTS)
# set rec_list = (ONSA ONS1 SPT7 SPT0 VAE6 NOR7 JON6 OSK6 SULD HAS6)
# set rec_list = (METS MET3 OLK2 ORIV MIK3 TUO2 METG VIR2 FINS SUR4 TOIL)
set rec_list = (SPRN PENC LAMA BRTS SPT7)
set ftpUPD1 = http://igmas.users.sgg.whu.edu.cn/products/download/directory/products/upd
set ftpUPD2 = http://igmas.users.sgg.whu.edu.cn/products/download/directory/products/upd
while($count)
  # if ( $doy == 303 ) then
  #       @ count --
  #       @ doy ++
  #       continue
  # endif
  # if ( $doy == 304 ) then
  #       @ count --
  #       @ doy ++
  #       continue
  # endif
  # if ( $doy == 305 ) then
  #       @ count --
  #       @ doy ++
  #       continue
  # endif
  # if ( $doy == 310 ) then
  #       @ count --
  #       @ doy ++
  #       continue
  # endif
  # if ( $doy == 303 ) then
  #       @ count --
  #       @ doy ++
  #       continue
  # endif
  # date transform
  set rec_index = 1
  set cdoy   = `echo $doy | awk '{printf("%3.3d\n",$1)}'`
  set date = `$bindir/jday $doy $yyyy`
  set mm = `echo $date | cut -b 1-2`
  set ymd_day = `echo $date | cut -b 3-4`
  set WEEKD  = `$bindir/mjday $doy $yyyy | awk '{nwk=int(($1-44244)/7);nwkd=$1-44244-nwk*7;print nwk*10+nwkd}'`
  set WEEK   = `echo $WEEKD | awk '{print substr($1,1,4)}'`
  
  echo $yyyy-$mm-$ymd_day
  
  # set workdir
  set proddir = $workdir/prod
  set navdir = $workdir/NAV
  set dcbdir = $workdir/DCB
  set sp3dir = $workdir/SP3
  set clkdir = $workdir/CLK
  # set obsdir = $workdir/OBS_EPN/$cdoy/${sample}S
  set obsdir = $workdir/OBS_Temp/$cdoy
  echo "${obsdir}"
  set upddir = $workdir/UPD
  if (! -d $workdir) mkdir -p $workdir
  if (! -d $proddir) mkdir -p $proddir
  if (! -d $navdir) mkdir -p $navdir
  if (! -d $dcbdir) mkdir -p $dcbdir
  if (! -d $sp3dir) mkdir -p $sp3dir
  if (! -d $clkdir) mkdir -p $clkdir
  if (! -d $upddir) mkdir -p $upddir
  if (! -d $obsdir) mkdir -p $obsdir
  cd $workdir
  # observation rinex3
  while($#rec_list >= $rec_index)
    set crt_last = $last
    set crt_beg   = `echo $beg | awk '{printf("%2.2d\n",$1)}'`
    set Merge = ""
    set crt_rec = $rec_list[$rec_index]
    set CRT_REC = `cat /cache/hanjunjie/Software/Tools/site_list_EPN | grep $crt_rec | cut -b 6-17`
    echo "Downloading $rec_list[$rec_index] obs from $ftpAC"
    echo "samlpe:${sample}s  last:${crt_last}h"
    # curl -c .urs_cookies -b .urs_cookies -n -L "ftp://ftp.epncb.oma.be/pub/obs/${yyyy}/${cdoy}/${CRT_REC}${yyyy}${cdoy}0000_01D_30S_MO.crx.gz" -O
    curl -c .urs_cookies -b .urs_cookies -n -L "ftp://ftp.epncb.oma.be/pub/obs/${yyyy}/${cdoy}/${crt_rec}${cdoy}0.${yy}D.gz" -O
    # curl -c .urs_cookies -b .urs_cookies -n -L "ftp://ftp.epncb.oma.be/pub/obs/${yyyy}/${cdoy}/ACOR00ESP_R_20230010000_01D_30S_MO.crx.gz" -O
    # gunzip -f ACOR00ESP_R_20230010000_01D_30S_MO.crx.gz
    # gunzip -f ${CRT_REC}${yyyy}${cdoy}0000_01D_30S_MO.crx.gz
    gunzip -f ${crt_rec}${cdoy}0.${yy}D.gz
    # pwd
    # mv ${CRT_REC}${yyyy}${cdoy}0000_01D_30S_MO.crx $crt_rec${cdoy}0.${yy}d
    mv ${crt_rec}${cdoy}0.${yy}D $crt_rec${cdoy}0.${yy}d
    ${crx2rnx} ${crt_rec}${cdoy}0.${yy}d
    # ${gfzrnx} -finp ${crt_rec}${cdoy}0.${yy}o -fout ::RX3:: -split 3600
    # mv ${crt_rec}00XXX_R_${yyyy}${cdoy}0000_01H_30S_MO.rnx ${obsdir}/${crt_rec}${cdoy}0.${yy}o
    # mv ${CRT_REC}_R_${yyyy}${cdoy}0${crt_beg}0_01D_30S_MO.crx $crt_rec${cdoy}0.${yy}d
    
    mv ${crt_rec}${cdoy}0.${yy}o ${obsdir}/${crt_rec}${cdoy}0.${yy}o
    rm -rf *.${yy}o
    rm -rf *.${yy}d
    rm -rf *.rnx
    @ rec_index ++
  end
  

  
  @ doy ++
  @ count --

end