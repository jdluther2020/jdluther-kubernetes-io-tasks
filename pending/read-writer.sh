file=/tmp/file.txt
POD_NAME=podx
NODE_NAME=nodey
if [ -f $file ]; then cat $file; fi; echo "`date` : Written by pod $POD_NAME running on $NODE_NAME" >> $file
