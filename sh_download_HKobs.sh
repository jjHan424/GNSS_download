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
# set ftppath = https://cddis.nasa.gov/archive
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
set rec_list = (hkcl hkfn hkks hkkt hklm hklt hkmw hknp hkoh hkpc hksc hksl hkss hkst hktk hkws kyc1 t430)
# set rec_list = (hkkt hklm hklt hkmw hknp hkoh hkpc hksc hksl hkss hkst hktk hkws kyc1 t430)
# set rec_list = (hksc)
#set rec_list = (hksc hktk hklm)
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
  set obsdir = $workdir/OBS/$cdoy/${sample}S
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
    set CRT_REC = `cat /home/hanjunjie/tools/download/site_list | grep $crt_rec | cut -b 6-14`
    echo "Downloading $rec_list[$rec_index] obs from $ftpAC"
    echo "samlpe:${sample}s  last:${crt_last}h"
    if ($sample == 5) then
        while(${crt_last} > 0)
            set crt_beg   = `echo $crt_beg | awk '{printf("%2.2d\n",$1)}'`
            echo "${crt_beg}h"
            if ($crt_beg >= 23) then
                set crt_last = 0
            endif
            echo "ftp://ftp.geodetic.gov.hk/rinex3/${yyyy}/${cdoy}/${crt_rec}/5s/${CRT_REC}_R_${yyyy}${cdoy}${crt_beg}00_01H_05S_MO.crx.gz"
            curl -c .urs_cookies -b .urs_cookies -n -L --silent "ftp://ftp.geodetic.gov.hk/rinex3/${yyyy}/${cdoy}/${crt_rec}/5s/${CRT_REC}_R_${yyyy}${cdoy}${crt_beg}00_01H_05S_MO.crx.gz" -O
            gunzip -f ${CRT_REC}_R_${yyyy}${cdoy}${crt_beg}00_01H_05S_MO.crx.gz
            mv ${CRT_REC}_R_${yyyy}${cdoy}${crt_beg}00_01H_05S_MO.crx $crt_rec${cdoy}${crt_beg}.${yy}d
            ${crx2rnx} ${crt_rec}${cdoy}${crt_beg}.${yy}d
            set Merge = "${Merge} ${crt_rec}${cdoy}${crt_beg}.${yy}o "
            echo $Merge
            @ crt_last --
            @ crt_beg ++
        end
        ${gfzrnx} -finp ${Merge} -kv > ${crt_rec}${cdoy}all.${yy}o
        mv ${crt_rec}${cdoy}all.${yy}o ${obsdir}/${crt_rec}${cdoy}0.${yy}o
    endif

    if ($sample == 1) then
        while(${crt_last} > 0)
            set crt_beg   = `echo $crt_beg | awk '{printf("%2.2d\n",$1)}'`
            echo "${crt_beg}h"
            if ($crt_beg >= 23) then
                set crt_last = 0
            endif
            curl -c .urs_cookies -b .urs_cookies -n -L --silent "ftp://ftp.geodetic.gov.hk/rinex3/${yyyy}/${cdoy}/${crt_rec}/1s/${CRT_REC}_R_${yyyy}${cdoy}${crt_beg}00_01H_01S_MO.crx.gz" -O
            gunzip -f ${CRT_REC}_R_${yyyy}${cdoy}${crt_beg}00_01H_01S_MO.crx.gz
            mv ${CRT_REC}_R_${yyyy}${cdoy}${crt_beg}00_01H_01S_MO.crx $crt_rec${cdoy}${crt_beg}.${yy}d
            ${crx2rnx} ${crt_rec}${cdoy}${crt_beg}.${yy}d
            set Merge = "${Merge} ${crt_rec}${cdoy}${crt_beg}.${yy}o "
            echo $Merge
            @ crt_last --
            @ crt_beg ++
        end
        ${gfzrnx} -finp ${Merge} -kv > ${crt_rec}${cdoy}all.${yy}o
        mv ${crt_rec}${cdoy}all.${yy}o ${obsdir}/${crt_rec}${cdoy}0.${yy}o
    endif
    
    if ($sample == 30) then
          curl -c .urs_cookies -b .urs_cookies -n -L "https://rinex.geodetic.gov.hk/rinex3/${yyyy}/${cdoy}/${crt_rec}/30s/${CRT_REC}_R_${yyyy}${cdoy}0000_01D_30S_MO.crx.gz" -O
          gunzip -f ${CRT_REC}_R_${yyyy}${cdoy}0000_01D_30S_MO.crx.gz
          pwd
          mv ${CRT_REC}_R_${yyyy}${cdoy}0${crt_beg}0_01D_30S_MO.crx $crt_rec${cdoy}0.${yy}d
          ${crx2rnx} ${crt_rec}${cdoy}0.${yy}d
          mv ${crt_rec}${cdoy}0.${yy}o ${obsdir}/${crt_rec}${cdoy}0.${yy}o
    endif
   
    rm -rf *.${yy}o
    rm -rf *.${yy}d
    @ rec_index ++
  end
  # download sp3 and clk
  echo "Downloading sp3 from $ftpAC"
  # if (! -e igs$WEEKD.sp3.Z) curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gps/products/mgex/$WEEK/grm$WEEKD.sp3.Z" -O
  # if (! -e grm$WEEKD.sp3.Z) curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gps/products/mgex/$WEEK/COD0MGXFIN_${yyyy}${cdoy}0000_01D_05M_ORB.SP3.gz" -O
  # if (! -e grm$WEEKD.sp3.Z) curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gps/products/mgex/$WEEK/GFZ0MGXRAP_${yyyy}${cdoy}0000_01D_05M_ORB.SP3.gz" -O
  # curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gps/products/$WEEK/GFZ0MGXRAP_${yyyy}${cdoy}0000_01D_05M_ORB.SP3.gz" -O
  # if (-e grm$WEEKD.sp3.Z) then
  #   gunzip -f grm$WEEKD.sp3.Z
  #   mv -f grm$WEEKD.sp3 $sp3dir
  # else
  #   gunzip -f GFZ0MGXRAP_${yyyy}${cdoy}0000_01D_05M_ORB.SP3.gz
  #   mv -f GFZ0MGXRAP_${yyyy}${cdoy}0000_01D_05M_ORB.SP3 $sp3dir/gfz$WEEKD.sp3
  

  echo "Downloading clk from $ftpAC"
  # if (! -e igs$WEEKD.clk.Z) curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gps/products/mgex/$WEEK/grm$WEEKD.clk.Z" -O
  # if (! -e grm$WEEKD.clk.Z) curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gps/products/mgex/$WEEK/GFZ0MGXRAP_${yyyy}${cdoy}0000_01D_30S_CLK.CLK.gz" -O
  # curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gps/products/$WEEK/GFZ0MGXRAP_${yyyy}${cdoy}0000_01D_30S_CLK.CLK.gz" -O
  # if (-e grm$WEEKD.clk.Z) then
  #   gunzip -f grm$WEEKD.clk.Z
  #   mv -f grm$WEEKD.clk $clkdir
  # else
  #   gunzip -f GFZ0MGXRAP_${yyyy}${cdoy}0000_01D_30S_CLK.CLK.gz
  #   mv -f GFZ0MGXRAP_${yyyy}${cdoy}0000_01D_30S_CLK.CLK $clkdir/gfz$WEEKD.clk
   
  echo "Downloading eph from $ftpAC"
  if (! -e brdc$cdoy"0."$yy"n".Z) then
	  curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gnss/mgex/daily/rinex3/$yyyy/$cdoy/${yy}p/brdm${cdoy}0.${yy}p.Z" -O
    if (${yyyy} >= 2021) then
      echo "eph >= 2021"
      curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gps/data/daily/$yyyy/$cdoy/${yy}p/BRDM00DLR_S_${yyyy}${cdoy}0000_01D_MN.rnx.gz" -O
      mv BRDM00DLR_S_${yyyy}${cdoy}0000_01D_MN.rnx.gz brdm${cdoy}0.${yy}p.Z
    endif
    gunzip -f brdm${cdoy}0.${yy}p.Z
    mv -f brdm${cdoy}0.${yy}p $navdir/brdm$cdoy"0."$yy"n"
  endif

  echo "Downloading DCB from $ftpAC"
  # curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gps/products/mgex/dcb/$yyyy/CAS0MGXRAP_${yyyy}${cdoy}0000_01D_01D_DCB.BSX.gz" -O
  # gunzip -f "CAS0MGXRAP_${yyyy}${cdoy}0000_01D_01D_DCB.BSX.gz"
  # mv -f CAS0MGXRAP_${yyyy}${cdoy}0000_01D_01D_DCB.BSX $dcbdir/CAS$WEEKD.BIA

  echo "Downloading UPD from GREAT"
  # cp /home/iGMAS/gnss_product/upd/${yyyy}/${cdoy}/upd_nl_${yyyy}${cdoy}_GREC $upddir/
  # cp /home/iGMAS/gnss_product/upd/${yyyy}/${cdoy}/upd_wl_${yyyy}${cdoy}_GREC $upddir/
  # cp /home/iGMAS/gnss_product/upd/${yyyy}/${cdoy}/upd_ewl_${yyyy}${cdoy}_GEC $upddir/
  

  
  @ doy ++
  @ count --

end