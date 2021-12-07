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

set AC = grm
if ($#argv >= 4) then
  set AC = $4
endif

set ftppath = ftp://igs.gnsswhu.cn/pub
set ftpAC = WHU
if ($5 == 1) then
  set ftppath = https://cddis.nasa.gov/archive
  set ftpAC = CDDIS
else if ($5 == 2) then
  set ftppath = ftp://igs.gnsswhu.cn/pub
  set ftpAC = WHU
endif

set workdir = /home/hanjunjie/data/IONO/$yyyy
if ($#argv >= 6) then
  set workdir = $6
endif

set yy = `echo $yyyy | awk '{printf("%2.2d",$1-int($1/100)*100)}'`
echo $yyyy $doy $count $AC $ftpAC $workdir

set bindir = /home/hanjunjie/tools/zbin/bin
set crx2rnx = /home/hanjunjie/tools/CRX2RNX
#set rec list for observation
set rec_list = (areg arev areq wtza wtzz irkj irkm suth sutv)
#set country_list = (GLP MDG GHA ARG JPN CAN AUS TUR MYS PER ATA ARM SHN RUS IDN KGZ USA POL COL BRA FRA BEL ISR ROU ESP COK TWN THA CPV VIR ATF KOR GBR NLD PRT PYF FLK DEU WLF SVK ITA CZE GUM HKG ISL ZAF IND MEX CHN SWE KIR UZB GUF FJI MTQ MHL KEN MYT UGA FIN UKR CYP NIU GAB NCL SGP NOR MKD NZL PHL PNG GRL MAR DOM REU CHL BOL CUB SYC LKA SLB SPM TON MNG MUS CHE ZMB)


while($count)
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
  set obsdir = $workdir/OBS
  if (! -d $workdir) mkdir -p $workdir
  if (! -d $proddir) mkdir -p $proddir
  if (! -d $navdir) mkdir -p $navdir
  if (! -d $dcbdir) mkdir -p $dcbdir
  if (! -d $sp3dir) mkdir -p $sp3dir
  if (! -d $clkdir) mkdir -p $clkdir
  if (! -d $obsdir) mkdir -p $obsdir
  cd $workdir
  # download sp3 and clk
  echo "Downloading sp3 from $ftpAC"
  if (! -e igs$WEEKD.sp3.Z) curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gps/products/$WEEK/igs$WEEKD.sp3.Z" -O
  gunzip -f igs$WEEKD.sp3.Z
  mv -f igs$WEEKD.sp3 $sp3dir

  echo "Downloading clk from $ftpAC"
  if (! -e igs$WEEKD.clk.Z) curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gps/products/$WEEK/igs$WEEKD.clk.Z" -O
  gunzip -f igs$WEEKD.clk.Z
  mv -f igs$WEEKD.clk $clkdir
   
  echo "Downloading eph from $ftpAC"
  if (! -e brdc$cdoy"0."$yy"n".Z) then
	  curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gps/data/daily/$yyyy/$cdoy/{$yy}n/brdc{$cdoy}0.{$yy}n.Z" -O
    gunzip -f brdc$cdoy"0."$yy"n.Z"
    mv -f brdc$cdoy"0."$yy"n" $navdir
	  rm -rf brdc$cdoy"0."$yy"n.Z"
  endif

  #echo " Downloading DCB from $ftpAC"
  curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gps/products/mgex/dcb/$yyyy/CAS0MGXRAP_${yyyy}${cdoy}0000_01D_01D_DCB.BSX.gz" -O
  gunzip -f "CAS0MGXRAP_${yyyy}${cdoy}0000_01D_01D_DCB.BSX.gz"
  mv -f CAS0MGXRAP_${yyyy}${cdoy}0000_01D_01D_DCB.BSX $dcbdir/CAS$WEEKD.BIA
  # observation rinex3 first
  while($#rec_list >= $rec_index)
    set crt_rec = $rec_list[$rec_index]
    set CRT_REC = `cat /home/hanjunjie/tools/site_list | grep $crt_rec | cut -b 6-14`
    echo "Downloading $rec_list[$rec_index] obs from $ftpAC"
    curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gps/data/daily/$yyyy/$cdoy/${yy}d/${CRT_REC}_R_${yyyy}${cdoy}0000_01D_30S_MO.crx.gz" -O    
    if (-f ${CRT_REC}_R_${yyyy}${cdoy}0000_01D_30S_MO.crx.gz) then
      gunzip -f ${CRT_REC}_R_${yyyy}${cdoy}0000_01D_30S_MO.crx.gz
      mv ${CRT_REC}_R_${yyyy}${cdoy}0000_01D_30S_MO.crx $crt_rec${cdoy}0.${yy}d
    endif
    if (! -f $crt_rec${cdoy}0.${yy}d) then
      echo "Waring:No rinex3 observation $crt_rec"
      curl -c .urs_cookies -b .urs_cookies -n -L --silent "$ftppath/gps/data/daily/$yyyy/$cdoy/${yy}d/$crt_rec${cdoy}0.${yy}d.Z" -O
      if (! -e $crt_rec${cdoy}0.${yy}d.Z) then
        echo "ERROR:No observation $crt_rec"
      else
        gunzip -f $crt_rec${cdoy}0.${yy}d.Z
      endif     
    endif
    if (-f $crt_rec${cdoy}0.${yy}d) then
      ${crx2rnx} $crt_rec${cdoy}0.${yy}d
      mv $crt_rec${cdoy}0.${yy}o $obsdir/$crt_rec${cdoy}0.${yy}o
      rm -rf $crt_rec${cdoy}0.${yy}d
    endif
    @ rec_index ++
  end
  @ doy ++
  @ count --

end