#!/usr/bin/csh
###
 # @Author: your name
 # @Date: 2021-12-05 20:27:42
 # @LastEditTime: 2021-12-05 21:02:41
 # @LastEditors: Please set LastEditors
 # @Description: 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 # @FilePath: /xml-py-tool/download/sh_download_gnssfile.sh
###

set year=2021
set doy = 311
set count = 2
set workdir = /cache/hanjunjie/Data/$year
set homedir = /home/hanjunjie/Data/$year

set CLK = $workdir/CLK
set DCB = $workdir/DCB
set NAV = $workdir/NAV
set OBS = $workdir/OBS
set SP3 = $workdir/SP3
set UPD = $workdir/UPD
if (! -d $CLK) mkdir -p $CLK
if (! -d $DCB) mkdir -p $DCB
if (! -d $NAV) mkdir -p $NAV
if (! -d $OBS) mkdir -p $OBS
if (! -d $SP3) mkdir -p $SP3
if (! -d $UPD) mkdir -p $UPD
set bindir = /home/hanjunjie/tools/zbin/bin
while($count)
  # date transform
  set rec_index = 1
  set cdoy   = `echo $doy | awk '{printf("%3.3d\n",$1)}'`
  set date = `$bindir/jday $doy $year`
  set mm = `echo $date | cut -b 1-2`
  set ymd_day = `echo $date | cut -b 3-4`
  set WEEKD  = `$bindir/mjday $doy $year | awk '{nwk=int(($1-44244)/7);nwkd=$1-44244-nwk*7;print nwk*10+nwkd}'`
  set WEEK   = `echo $WEEKD | awk '{print substr($1,1,4)}'`
  echo $year-$mm-$ymd_day

#   #=========CLK==========#
#   cp -r $homedir/CLK/*$WEEKD*.clk $CLK
#   #=========DCB==========#
#   cp -r $homedir/DCB/*$WEEKD*.BIA $DCB
#   #=========NAV==========#
#   cp -r $homedir/NAV/*$cdoy*n $NAV
#   #=========SP3==========#
#   cp -r $homedir/SP3/*$WEEKD*.sp3 $SP3
  #=========OBS==========#
  if (! -d $OBS/$cdoy) mkdir -p $OBS/$cdoy
  cp -r $homedir/OBS/$cdoy/*$cdoy* $OBS/$cdoy
  @ doy ++
  @ count --
end
echo "End ALL"

