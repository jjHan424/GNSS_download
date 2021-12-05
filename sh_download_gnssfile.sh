#!/usr/bin/csh
###
 # @Author: your name
 # @Date: 2021-12-05 20:27:42
 # @LastEditTime: 2021-12-05 21:52:07
 # @LastEditors: Please set LastEditors
 # @Description: 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 # @FilePath: /xml-py-tool/download/sh_download_gnssfile.sh
### 

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

set ftpAC = CDDIS
set ftppath = https://cddis.nasa.gov/archive
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
#set rec list for observation
set rec_list = (AAAA CCCC BBBB DDDD)


while($count)
  # date transform
  set rec_index = 1
  set cdoy   = `echo $doy | awk '{printf("%3.3d\n",$1)}'`
  set date = `$bindir/jday $doy $yyyy`
  set mm = `echo $date | cut -b 1-2`
  set ymd_day = `echo $date | cut -b 3-4`
  set WEEKD  = `$bindir/mjday $doy $yyyy | awk '{nwk=int(($1-44244)/7);nwkd=$1-44244-nwk*7;print nwk*10+nwkd}'`
  set WEEK   = `echo $WEEKD | awk '{print substr($1,1,4)}'`
  # ptrint the date information
  echo $yyyy-$mm-$ymd_day
  # observation
  while($#rec_list >= $rec_index)
    echo observation:$rec_list[$rec_index]
    @ rec_index ++
  end
  @ doy ++
  @ count --

end