#!/bin/ksh
typeset url_base="http://localhost/raptor/combined_pmrs"

typeset pmr
typeset prog=$(basename $0 )

# Set to y when -n is passed on command line to not actually call curl
# and force a few variables to the same value.  The main intent is to
# use -n for testing purposes.
typeset nflag=n

typeset -i start_time=$( date +%s )
typeset -i stop_time
typeset -i duration_index

# A temp file for the Component data
typeset COMP=/tmp/Comp.$$

# A temp file for the questions and answers data
typeset QA=/tmp/QA.$$

# A temp file used to store the current possible selection list.
typeset TEMP=/tmp/TEMP.$$

# Where to send interactive prompts and debug to.
typeset TTY=/dev/tty

# The call to OPC requires the question set.  This is currently
# preset.  It is suppose to change based upon the component.
typeset qset=Q006

# The call to OPC requires a component.  This is set via a call to
# pick_comp to the string to pass for the component
typeset comp

# I guess ksh does not have real two dimensional arrays nor can you
# dynamically define the components in a compond variable.  So, I'll
# fall back to a set of single index arrays.

# The "name" of the question (denoted by Name:)
typeset question_name

# The code for the question (denoted by Code:)
typeset question_code

# The restriction for the question (denoted by Restriction:)
typeset question_restriction

# The short text for the question (denoted by Text:)
typeset question_text

# The long description of the question (denoted by Description:)
typeset question_description

# A possible function to call instead of asking the question (denoted
# by Function)
typeset question_function

# The index into responses of the first valid response (index into
# response_code and response_text)
typeset question_response_start

# The index into responses of the last valid response (index into
# response_code and response_text)
typeset question_response_end

# The response codes
typeset response_code

# The response text
typeset response_text

# The answers to the questions
typeset question_answer

if [[ -t 0 ]] ; then
    interactive=yes
else
    interactive=no
fi

trap "rm -f ${COMP} ${QA} ${TEMP}" 0

# Do:
#   debug hello world
# to see hello world
function debug
{
    echo "$@" > "${TTY}"
}

# Use this to get prompts out to userland.  prompts are suppressed if
# not interactive (i.e. if stdin is redirected from a file).
function prompt
{
    if [[ $interactive = yes ]] ; then
	printf "$@" > "${TTY}"
    fi
}

# $1 is a line like:
#   blahblah | foo
# This returns the first field sans leading and trailing blanks
function cleanup_line
{
    echo "$1" | sed -e 's/ *|.*$//' -e 's/^ *//'
}

# $1 is the first level topic e.g. Networking
# Puts the possible selections for that topic into TEMP
function sub_comps
{
    sed -n -e "/^$1/,/^[^ ]/ {" -e '/^ /p' -e '}' "${COMP}" > "${TEMP}"
}

# no arg -- returns the outer level component selections
function outer_comps
{
    sed -n -e '/^[^ ]/p' "${COMP}" > "${TEMP}"
}

# $1 is the number entered by the user.  Returns the line that matches
# that choice from the temp file
function pick_line
{
    fgrep -n '|' "${TEMP}" | sed -n -e "s/^$1://p"
}

# Allows the user to select the outer level component name.  This
# returns the line if the user enters valid input or an empty line if
# they enter invalid input
function selector
{
    typeset -i lineno
    typeset cline
    let lineno=1
    prompt "Pick the component:\n"
    while read line ; do
	cline=$( cleanup_line "$line" )
	prompt "%2d) %s\n" "$lineno" "$cline"
	let lineno=lineno+1
    done < "${TEMP}"
    prompt "Component number: "
    read outer
    pick_line $outer
}

# Loops calling selector until user makes a sensible selection
function picker
{
    typeset line=""
    typeset rc			# Mac's ksh doesn't do job control right

    while [[ -z "$line" ]] ; do
	line="$( selector )"
	rc=$?
	if [[ $rc -ne 0 ]] ; then
	    exit $rc
	fi
    done
    echo "$line"
}

# Sets up TEMP to be the list of outer component choices and then
# calls the picker.
function pick_outer
{
    outer_comps
    picker
}

# $1 is the outer component that was chosen.  Sets up TEMP to be the
# list of inner components for this outer component.  If this list is
# empty, then returns the outer component, otherwise it calls picker
# so an inner component can be chosen.  Currently there is no way to
# back out and redo the outer choice.  ^C seems easy enough right
# now.
function pick_inner
{
    typeset outer="$1"
    typeset outer_desc="$( cleanup_line "$outer" ) "
    typeset lines
    sub_comps "$outer_desc"
    lines=$( wc -l < "${TEMP}" )
    if [[ $lines -gt 0 ]] ; then
	picker
    else
	echo "$outer"
    fi
}

function pick_comp
{
    typeset outer
    typeset inner=''
    typeset temp
    typeset rc			# Mac's ksh doesn't do job control right

    while [[ -z "$inner" ]] ; do
	outer="$( pick_outer )"
	rc=$?
	if [[ $rc -ne 0 ]] ; then
	    exit $rc
	fi
	inner="$( pick_inner "$outer" )"
	rc=$?
	if [[ $rc -ne 0 ]] ; then
	    exit $rc
	fi
    done
    temp=$( echo "$inner" | sed -e 's/.*| *//' -e 's/ //g' )
    comp="$( printf "xxxxxxxxxxxxxxxxxxxxx%-4sxxxxxxxxxxxxxxxxxxxxx" "$temp" )"
}




function make_tmp_files
{
    cat <<'EOF' > ${COMP}
Boot/Bring up				   | BOOT
CMDS/LIBS/Security			   | CLS 
    Accounting 				   | ACCT
    AIX based OS commands		   | ACMD
    AIX malloc subsystem		   | AMAL
    AIX Runtime Expert 			   | ARUN
    AIX Security Expert			   | ASEC
    Audit      				   | AUDT
    Authentication (LAM, PAM, LDAP, KRB5)  | AUTH
    Based system libraries (libc) 	   | SLIB
    DBX					   | CDBX
    Multi-level Security 		   | MLS 
    Role Based Access Control		   | RBAC
    Security commands 			   | SECC
    Shells				   | SHEL
    Time Zone (POSIX)			   | TMZN
    Trusted Execution			   | TRST
    Tzset/localtime for Olsen TZ 	   | TZSE
HACMP					   | HACM
    Cluster Aware AIX                      | HCAA
Install					   | INST
    alt_disk				   | ALTD
    emgr/epkg				   | EMGR
    geninstall				   | GENI
    install/mkinstallp			   | MKIN
    lppmgr				   | LPPM
    mksysb				   | MKSY
    multibos				   | MBOS
    nim					   | NIM 
    nimadm				   | NIMA
    restvg/savevg			   | REST
    rpm					   | RPM 
    wpar				   | IWPR
JAVA for AIX				   | JAVA
Kernel					   | KERN
    Filesystems				   | FSYS
    Loader/Linker/Assembler		   | LLAR
    LVM					   | LVM 
    RAS					   | RAS 
    Sysproc				   | SYSP
    VMM					   | VMM 
Networking				   | NETW
    Crypto				   | CRYP
    Network device drivers		   | NWDD
    NFS					   | NFS 
    Streams				   | STRE
    TCP application			   | TCPA
    TCP kernel				   | TCPK
    TTY					   | TTY 
Storage device drivers			   | STDD
    CDROM driver			   | CDRD
    Configuration methods		   | CFGM
    FC adapter driver			   | FCAD
    FC disk driver			   | FCDD
    FC tape driver			   | FCTD
    FCOE				   | FCOE
    MPIO				   | MPIO
    SCSI disk driver			   | SCDD
    SISRAID driver			   | SISR
    SISSAS adapter driver		   | SISA
    USB driver				   | USBD
    Other storage device drivers	   | OTHS
UI/DIAG                                    | UIDI
    DIAG				   | DIAG
    Globalization/NLS			   | NLS 
    Graphics device drivers		   | GRAP
    GraPHIGS				   | PHIG
    Inventory Scout			   | ISCT
    OpenGL				   | OPGL
    Pconsole				   | PCON
    Smitty				   | SMIT
    Websm				   | WEBS
    Xclients				   | XCLI
    Xserver				   | XSER
VIOS					   | VIOS
    AMS (Active Memory Sharing)		   | AMS 
    CAA (Cluster Aware AIX)		   | VCAA
    IVM					   | IVM 
    LPM					   | LPM 
    MKSYSPLAN				   | MKSP
    NPIV				   | NPIV
    padmin CLI commands  		   | PCLI
    SEA					   | SEA 
    SSP (Shared Storage Pool)		   | SSP 
    VFC device driver			   | VFCD
    VSCSI				   | VSCS
    VSCSI device driver			   | VSDD
    Other VIOS related			   | OVIO
WPAR					   | WPAR
Performance Issue			   | PERF
Non-AIX issue				   | OTH 
EOF

    # Note that we can't have single quotes in the text below
    cat <<'EOF' > ${QA}
Name: time
Code: @
Restriction: 0 == 1
Function: user_time

Name: user
Code: #
Restriction: 0 == 1
Function: user_name

Name: date
Code: $
Restriction: 0 == 1
Function: get_date

Name: Q1
Code: O
Restriction: 0 == 1
Text: Outage?
Description: Outage: a critical system partition is down/unusable, a critical application is hung/unusable, there is no access to data, performance is impacting the ability to do business, an install/RA is exceeding the maint window or a backup system/appl is down.
Response: 
No => N
Yes => Y

Name: Q2
Code: T
Restriction: $Q1 == N
Text: Outage type?
Description: Which piece/criteria of the outage definition did this PMR meet?
Response: 
Critical system partition down => S
Critical application hung => A
No access to data => D
Performance impacted business => P
Install/RA exceeded maintenance window => I
Backup system/application down => B

Name: Q3
Code: C
Restriction: $Q1 == N
Text: Crash or hang?
Description: Did this problem result in a crash or hang affecting a single or multiple partitions?
Response: 
No => N
Yes => Y

Name: Q4
Code: D
Restriction: $Q1 == N || $Q3 == N
Text: Outage duration?
Description: How long was the critical system partition down/unusable, the critical application hung/unusable, the lack of access to data, the performance impact, the install/RA time or the backup system/appl down?
Response: 
<= 30 minutes => 30
<= 1 hour => 1
<= 2 hours => 2
<= 4 hours => 4
Greater than 4 hours => G
Unknown => U

EOF
}

# Parses the QA file into the questions_* and response_* shell array variables
function grok_qa
{
    typeset -i index=0
    typeset line
    typeset mode=normal
    typeset field
    typeset value
    typeset text
    typeset code

    while read line ; do
	if [[ -z $line ]] ; then
	    (( index++ ))
	    mode=normal
	    continue
	fi
	case $mode in
	    normal)
		field="${line%%:*}"
		value="${line#*: }"
		case $field in
		    Name)
			question_name[index]=$value
			;;
		    Code)
			question_code[index]=$value
			;;
		    Restriction)
			question_restriction[index]=$value
			;;
		    Text)
			question_text[index]=$value
			;;
		    Description)
			question_description[index]=$value
			;;
		    Function)
			question_function[index]=$value
			;;
		    Response)
			question_response_start[index]="${#response_code[@]}"
			question_response_end[index]=-1
			mode=response
			;;
		    *)
			echo "Unknown field $field" 1>&2
			exit 1
		esac
		;;

	    response)
		text="${line% =>*}"
		code="${line##*=> }"
		response_code[${#response_code[@]}]=$code
		response_text[${#response_text[@]}]=$text
		question_response_end[index]="${#response_code[@]}"
		;;
	esac
    done < "${QA}"
}

function ask_questions
{
    typeset -i index=0
    typeset -i response_index
    typeset -i response_start
    typeset -i response_end
    typeset -i response_cnt
    typeset name
    typeset answer
    typeset restriction
    typeset result
    typeset last_question="${#question_name[@]}"
    typeset -i resp
    
    while [[ $index -lt $last_question ]] ; do
	# default answer is empty
	answer=''

	# See if the restriction wants this question asked.
	restriction="${question_restriction[index]}"
	if ! eval "[[ ${restriction} ]]" ; then
	    # First do the special case "Functions"
	    if [[ "${question_function[index]}x" != x ]] ; then
		case "${question_function[index]}" in
		    user_time)
			duration_index=$index
			;;
		    
		    user_name)
			answer=__user
			;;
		    
		    get_date)
			# if -n is set, always set date to my birthday.
			if [[ $nflag = n ]] ; then
			    answer=1958-12-11
			else
			    answer=$( date +%Y-%m-%d )
			fi
			;;
		    
		    *)
			echo "Unknown function ${question_function[index]}" 1>&2
			exit 1
			;;
		esac
	    else
		# Normal interactive questions...

		prompt "\n\n\n"

		# Figure out the range of possible responses
		response_start="${question_response_start[index]}"
		response_end="${question_response_end[index]}"
		(( response_cnt = response_end - response_start ))
		response_index=0

		# Put out long description
		prompt "%s\n" "$( echo "${question_description[index]}" | fold -s -b -w 72 )"

		# Loop through possible responses
		while [[ $response_index -lt $response_cnt ]] ; do
		    prompt "%2d) %s\n" $(( response_index + 1 )) \
			"${response_text[response_start + response_index]}"
		    (( response_index++ ))
		done

		# Ask the question
		prompt "%s " "${question_text[index]}"

		# Get the reply
		read resp

		# validate reply
		if [[ $resp < 1 || $resp -gt $response_index ]] ; then
		    prompt "Invalid response.\n"
		    continue
		fi
		
		# calculate which response user picked
		(( response_index = response_start + resp - 1 ))

		# Set answer equal to the code
		answer="${response_code[response_index]}"
	    fi
	fi

	question_answer[index]="$answer"

	# Set a variable with the same name as the question equal to the answer.
	# e.g. if the question has Name: Dog, then we'll set Dog equal
	# to the answer.  This allows the restrictions to refer to $Dog.
	name="${question_name[index]}"
	eval "${name}='${answer}'"

	(( index = index + 1 ))
    done
}

function stop_clock
{
    stop_time=$( date +%s )
    (( stop_time = stop_time - start_time ))

    # if -n is set, we always set the time to 42.
    if [[ $nflag = n ]] ; then
	question_answer[duration_index]=42
    else
	question_answer[duration_index]=$stop_time
    fi
}

function send_curl
{
    typeset args
    typeset -i arg_index=0
    typeset -i question_index=0
    typeset -i question_end="${#question_name[@]}"
    typeset answer

    args[arg_index++]='-n'
    args[arg_index++]='-d' ; args[arg_index++]="set=$qset"
    args[arg_index++]='-d' ; args[arg_index++]="comp=$comp"
    while [[ $question_index -lt $question_end ]] ; do
	answer="${question_answer[question_index]}"
	if [[ "x${answer}" != "x" ]] ; then
	    args[arg_index++]='-d'
	    args[arg_index++]="kv[][key]=${question_code[question_index]}"
	    args[arg_index++]='-d'
	    args[arg_index++]="kv[][value]=$answer"
	fi
	(( question_index = question_index + 1 ))
    done
    args[arg_index++]="${url_base}/${pmr}/opc"
    echo curl "${args[@]}"
    if [[ $nflag = n ]] ; then
	curl "${args[@]}"
    fi
}

function usage
{
    echo "Usage: $prog <pmr>" 1>&2
    exit 1
}

# Main

# Parse the args and find the pmr #
while getopts "n" option; do
    case $option in
	n)
	    nflag=y
	    ;;
	*)
	    echo "invalid option $OPTARG" 1>&1
	    exit 1
	    ;;
    esac
done
shift $(( OPTIND - 1 ))
if [[ $# -ne 1 ]] ; then
    usage
fi
pmr=$1

make_tmp_files
grok_qa
pick_comp
ask_questions
stop_clock
send_curl
