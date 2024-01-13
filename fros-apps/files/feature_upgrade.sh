#!/bin/sh
flog()
{
	local date=`date`
	echo "$date $1" >>/tmp/log/feature_upgrade.log
}
upgrade()
{
	#num=` awk 'BEGIN{srand();print rand()*100}'`
	#num2=`echo $num |awk -F. '{print $1}'`
	#flog "random sleep time $num2"
	#sleep $num2

	rm /tmp/release.json
	wget http://ifros.cn/feature/release.json --no-check-certificate -O /tmp/release.json -t 10 -q
	if [ $? -ne 0 ];then
		flog  "download release info failed,  retry"
		wget http://175.178.71.82:88/feature/release.json --no-check-certificate -O /tmp/release.json -t 10 -q
		if [ $? -ne 0 ];then
			flog  "network error"
			return 1
		fi
	fi
	
 	local cur_md5=`md5sum  /etc/appfilter/feature.bin  | awk '{print $1}'`
	local remote_md5=`cat /tmp/release.json |grep md5 | awk -F: '{print $2}'| awk -F\" '{print $2}'`
	
	if [ x"" == x"$remote_md5" ];then
		wget http://175.178.71.82:88/feature/release.json --no-check-certificate -O /tmp/release.json -t 10 -q
	 	remote_md5=`cat /tmp/release.json |grep md5 | awk -F: '{print $2}'| awk -F\" '{print $2}'`
		echo "md5 = $remote_md5"
	fi
	
	if [ x"$cur_md5" == x"$remote_md5" ];then
		flog "md5 not change, return"	
		return 1
	fi
	flog "cur md5 $cur_md5 , remote_md5 = $remote_md5"
	
	wget http://ifros.cn/feature/feature.bin  --no-check-certificate -O /tmp/feature.bin -t 10 -q
	if [ $? -ne 0 ];then
		wget http://175.178.71.82:88/feature/feature.bin  --no-check-certificate -O /tmp/feature.bin -t 10 -q
		if [ $? -ne 0 ];then
			flog "download feature.bin failed"
			return 1;
		fi
	fi
	local md5=`md5sum /tmp/feature.bin | awk '{print $1}'`
	if [ x"$md5" != x"$remote_md5" ];then
		flog "md5 error, return"
		return 1
	fi
	flog "md5 check ok, begin upgrade"

	cp /tmp/feature.bin /etc/appfilter
	rm /tmp/appfilter -fr
	rm /tmp/feature.cfg
	/etc/init.d/appfilter restart >/dev/null
	flog "upgrade ok"
}

upgrade

