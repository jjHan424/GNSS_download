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

set ftppath = sftp://172.16.2.103
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
set gfzrnx = /home/hanjunjie/tools/gfzrnx
#set rec list for observation
#set rec_list = (areg arev areq wtza wtzz irkj irkm suth sutv dgar dgav)
#set rec_list = (yarr yar3)
#set rec_list = (wtza wtzz yarr yar3)
#set rec_list = (areg areq wtzz wtza yarr yar3 irkj irkm gold gol2 wtzr wtzs)
#set rec_list = (WHXZ WHDS XGXN N004 N028 N047 N068 WUDA WHXK WHYJ WHSP K042 K057 K059 K070 K101 K110 2KJ1 A010 V092 S028 H035 H038 H053 H055 H068 H074 H139)
#set rec_list = (WUDA)
#set rec_list = (1012 1022 1140 3026 2KJ1 A010 C004 D002 D007 D017 D018 E033 F094 H035 H038 H053 H055 H068 H074 H139 I092 J003 K042 K057 K059 K070 K101 K110 M175 M192 N004 N062 N010 N032 N028 N047 N068 O038 P053 S028 T023 T044 U029 V092 W038 X046 Y065 CQKZ CZDZ FYFN NCAY NYNZ SXXA WHDS WHSP WHXK WHXZ WHYJ XGXN XXFH YYJK)
# observation rinex3 first
set workdir = /home/hanjunjie/data/IONO/$yyyy
set obsdir = $workdir/OBS
cd $workdir
set rec_index = 1
set cdoy   = `echo $doy | awk '{printf("%3.3d\n",$1)}'`
mkdir -p $obsdir/$cdoy/GRID
while($#rec_list >= $rec_index)
  set crt_rec = $rec_list[$rec_index]
  echo "Downloading $crt_rec obs from greatnpp"
  cp  /home/greatnpp/project/sixents202107-sixents/bnc_out_65_106_backup1/obs/${crt_rec}00CHN_S_${yyyy}${cdoy}0000_01D_01S_MO.rnx $obsdir/$cdoy/GRID/$crt_rec${cdoy}0.${yy}o
  @ rec_index ++
end