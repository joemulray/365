#!/bin/bash

cmd=${cmd:=libuseradd.sh}

LibNssMySQLCFG=/etc/libnss-mysql.cfg
LibNssMySQLRootCFG=/etc/libnss-mysql-root.cfg
AddUserConf=/etc/adduser.conf
LoginDefs=/etc/login.defs

MYHOME=$(grep '^DHOME=' "$AddUserConf" | cut -f 2 -d =)
SKEL=$(grep '^SKEL=' "$AddUserConf" | cut -f 2 -d =)
UID_MIN=$(grep '^UID_MIN' "$LoginDefs" | awk '{print $2}')
GID_MIN=$(grep '^GID_MIN' "$LoginDefs" | awk '{print $2}')
SYS_UID_MAX=$(getent passwd | grep -v nobody | awk -F : '$3 < '"$UID_MIN"' { print $3 }' | sort -n | tail -n 1)
SYS_GID_MAX=$(getent group | grep -v nogroup | awk -F : '$3 < '"$GID_MIN"' { print $3 }' | sort -n | tail -n 1)

function warning {
	echo "$@" 1>&2
}

if [ ! -e "$LibNssMySQLCFG" ]
then
	warning "$cmd : '$LibNssMySQLCFG' is missing.  Cannot find database."
	exit 1
fi

MySQLHost=$(grep '^host' "$LibNssMySQLCFG" | awk '{print $2}')
MySQLDB=$(grep '^database' "$LibNssMySQLCFG" | awk '{print $2}')
MySQLUser=$(grep '^username' "$LibNssMySQLRootCFG" | awk '{print $2}')
MySQLUserPW=$(grep '^password' "$LibNssMySQLRootCFG" | awk '{print $2}')

function sys {
	[ -n "${opt_n}${opt_v}" ] && warning "$@"
	[ -n "$opt_n" ] || "$@"
}

function cmdMySQL {
	if [ -n "$*" ]
	then
	    mysql -NB -h "$MySQLHost" -u "$MySQLUser" -p"$MySQLUserPW" -e "$*" "$MySQLDB"
	else
	    mysql -NB -h "$MySQLHost" -u "$MySQLUser" -p"$MySQLUserPW" "$MySQLDB"
	fi
}

function verbCmdMySQL {
        if [ -n "$opt_n" ]
	then
	    if [ -n "$*" ]
	    then
		warning mysql -h "$MySQLHost" -u "$MySQLUser" -p"$MySQLUserPW" -e "$*" "$MySQLDB"
	    else
		cat
		warning mysql -h "$MySQLHost" -u "$MySQLUser" -p"$MySQLUserPW" "$MySQLDB"
	    fi
	elif [ -n "$opt_v" ]
	then
		if [ -n "$*" ]
		then
			warning mysql -h "$MySQLHost" -u "$MySQLUser" -p"$MySQLUserPW" -e "$*" "$MySQLDB"
			cmdMySQL "$@"
		else
			tee >(cmdMySQL)
			warning mysql -h "$MySQLHost" -u "$MySQLUser" -p"$MySQLUserPW" "$MySQLDB"
			warning ""
		fi
	else
	 	cmdMySQL "$@"
	fi

}

#addUser_MySQL "$UName" "$EPW" "$Uid" "$Gid" "$GeCOS" "$HDir" "$SHELL"
function addUser_MySQL {
	local UName="$1"
	local EPW="$2"
	local Uid="$3"
	local Gid="$4"
	local GeCOS="$5"
	local HDir="$6"
	local Shell="$7"

	verbCmdMySQL "INSERT INTO users (username,password,uid,gid,gecos,homedir,shell)
			    VALUES ('$UName', '$EPW', $Uid, $Gid, '$GeCOS', '$HDir', '$Shell')"
}

# setUserGeCOSMySQL "$User" "$opt_c"
function setUserGeCOSMySQL {
	local User="$1"
	local GeCOS="$2"

	verbCmdMySQL "UPDATE users SET gecos = '$GeCOS' WHERE username = '$User'"
}

# setUserHDirMySQL "$User" "$opt_d"
function setUserHDirMySQL {
	local User="$1"
	local HDir="$2"

	verbCmdMySQL "UPDATE users SET homedir = '$HDir' WHERE username = '$User'"
}

# setUserGidMySQL "$User" "$opt_g"
function setUserGidMySQL {
	local User="$1"
	local Gid="$2"

	verbCmdMySQL "UPDATE users SET gid = '$Gid' WHERE username = '$User'"
}

# setUserUNameMySQL "$User" "$opt_l"
function setUserUNameMySQL {
	local OldUserName="$1"
	local NewUserName="$2"

	verbCmdMySQL "UPDATE users SET username = '$NewUserName' WHERE username = '$OldUserName'"
}

# setUserEPWMySQL "$User" "$opt_p"
function setUserEPWMySQL {
	local User="$1"
	local EPW="$2"

	verbCmdMySQL "UPDATE users SET password = '$EPW' WHERE username = '$User'"
}

# setUserShellMySQL "$User" "$opt_s"
function setUserShellMySQL {
	local User="$1"
	local Shell="$2"

	verbCmdMySQL "UPDATE users SET shell = '$Shell' WHERE username = '$User'"
}

# setUserUidMySQL "$User" "$opt_u"
function setUserUidMySQL {
	local User="$1"
	local Uid="$2"

	verbCmdMySQL "UPDATE users SET uid = '$Uid' WHERE username = '$User'"
}

# setUserLastDayMySQL "$User" "$opt_d"
function setUserLastDayMySQL {
	local User="$1"
	local LastDay="$2"

	verbCmdMySQL "UPDATE users SET lstchg = '$LastDay' WHERE username = '$User'"
}

# setUserExpireDateMySQL "$User" "$opt_E"
function setUserExpireDateMySQL {
	local User="$1"
	local ExpireDate="$2"

	verbCmdMySQL "UPDATE users SET expire = '$ExpireDate' WHERE username = '$User'"
}
		
# setUserInactiveMySQL "$User" "$opt_I"
function setUserInactiveMySQL {
	local User="$1"
	local InActive="$2"

	verbCmdMySQL "UPDATE users SET inactive = '$Inactive' WHERE username = '$User'"
}

# setUserMinDaysMySQL "$User" "$opt_m"
function setUserMinDaysMySQL {
	local User="$1"
	local Days="$2"

	verbCmdMySQL "UPDATE users SET min = '$Days' WHERE username = '$User'"
}

# setUserMaxDaysMySQL "$User" "$opt_M"
function setUserMaxDaysMySQL {
	local User="$1"
	local Days="$2"

	verbCmdMySQL "UPDATE users SET max = '$Days' WHERE username = '$User'"
}

# setUserWarnDaysMySQL "$User" "$opt_W"
function setUserWarnDaysMySQL {
	local User="$1"
	local Days="$2"

	verbCmdMySQL "UPDATE users SET warn = '$Days' WHERE username = '$User'"
}

# setGroupGid "$Group" "$opt_g"
function setGroupGid {
	local Group="$1"
	local Gid="$2"

	verbCmdMySQL "UPDATE groups SET gid = '$Gid' WHERE name = '$Group'"
}

# setGroupName "$Group" "$opt_n"
function setGroupName {
	local OldGroupName="$1"
	local NewGroupName="$2"

	verbCmdMySQL "UPDATE groups SET name = '$NewGroupName' WHERE name = '$OldGroupName'"
}

# setGroupEPW "$Group" "$opt_p"
function setGroupEPW {
	local Group="$1"
	local EPW="$2"

	verbCmdMySQL "UPDATE groups SET password = '$EPW' WHERE name = '$Group'"
}

# getUserAgingMySQL "$User" "$opt_l"
function getUserAgingMySQL {
	local User="$1"

	verbCmdMySQL "select lstchg,min,max,warn,inact,expire FROM users WHERE username = '$User'"
}

#addGroup_MySQL "$GName" "$Gid"
function addGroup_MySQL {
	local Group="$1"
	local Gid="$2"
	
	verbCmdMySQL "INSERT INTO groups (name,gid) VALUES ('$Group',$Gid)"
}

#rmUserMySQL "$User"
function rmUserMySQL {
	local User="$1"

	verbCmdMySQL "DELETE FROM users where username = '$User'"
}

function getGroupIDMySQL {
	local Group="$1"
	
	cmdMySQL "SELECT gid FROM groups WHERE name = '$Group'"
}

#rmUserFromGroupsMySQL "$User" 
function rmUserFromGroupsMySQL {
	local User="$1"

	verbCmdMySQL "DELETE FROM grouplist where username = '$User'"
}

#rmGroupMySQL "$User"
function rmGroupMySQL {
	local Group="$1"

	verbCmdMySQL "DELETE FROM groups WHERE name = '$Group'"
}

function getNextGid {
	local MaxGID=$(getent group | awk -F : '{ print $3 }' | sort -n | tail -n 1)

	if [ -z "$MaxGID" ]
	then
		warning "No gids in group table"
		return 1
	fi

	echo $(($MaxGID + 1))
}

function getNextUid {
	local MaxUID=$(getent passwd | awk -F : '{ print $3 }' | sort -n | tail -n 1)

	if [ -z "$MaxUID" ]
	then
		warning "No uids in users table"
		return 1
	fi

	echo $(($MaxUID + 1))
}

function getMaxSysUid {
	getent passwd | awk -F : '$3 < '"$UID_MIN"' { print $3 }' | sort -n | tail -n 1
}

function getMaxSysGid {
	getent group | awk -F : '$3 < '"$GID_MIN"' { print $3 }' | sort -n | tail -n 1
}

function getNextSysUid {
	local MaxUID=$(getMaxSysUid)

	if [ -z "$MaxUID" ]
	then
		warning "No uids in users table"
		return 1
	fi

	echo $(($MaxUID + 1))
}

function getNextSysGid {
	local MaxGID=$(getMaxSysGid)

	if [ -z "$MaxGID" ]
	then
		warning "No gids in group table"
		return 1
	fi

	echo $(($MaxGID + 1))
}

function addUserToGidMySQL {
	local Gid="$1"
	local User="$2"

	verbCmdMySQL "INSERT INTO grouplist (gid,username) VALUES ($Gid,'$User')"
}

function addUsersToGroup {
	local Group="$1"
	shift

	local Gid
	local i

	if echo "$Group" | grep -Pq '^\d+$'
	then
		Gid="$Group"
	else
		Gid=$(cmdMySQL "SELECT gid FROM groups WHERE name = '$Group'")
	fi

	for i in "$@"
	do
		addUserToGidMySQL "$Gid" "$i"
	done
}


