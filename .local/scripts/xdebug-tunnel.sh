#!/bin/zsh
ssh $DEV_ACCT@$DEV_VM 'sh /wayfair/data/codebase/php/.wf/helpers/enable_php_xdebug.sh'
ssh -Nv -R 9001:localhost:9001 $DEV_ACCT@$DEV_VM 
