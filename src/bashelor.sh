[ -z "$BASHELOR_VENDOR_DIRECTORY" ] && BASHELOR_VENDOR_DIRECTORY='vendor'
[ -z "$BASHELOR_PATH" ] && BASHELOR_PATH="$(dirname $0)"
BASHELOR_PATH="$BASHELOR_PATH/$BASHELOR_VENDOR_DIRECTORY"
BASHELOR_PID=$$

if [ "$1" = "-q" ]
then
	function log() {
		return
	}

	shift
fi

if [ "$1" = "-h" ]
then
	log "Usage: $(success $0) $(warning [-h] [-q]) $(success [install] [inline])"
	log
	log "  $(success install): Install dependencies"
	log "  $(success inline): Inline install dependencies"
	log
	log "  $(warning -q): Quiet mode (no output)"
	log "  $(warning -h): Display this help message"

	exit
fi

function require() {
	local DRIVER="$1BashelorDriver"
	local URL="$2"
	local DEST="$3"

	[ ! -d "$BASHELOR_VENDOR_DIRECTORY" ] && mkdir "$BASHELOR_VENDOR_DIRECTORY"

	cd ${BASHELOR_VENDOR_DIRECTORY}
	${DRIVER} "$URL" "$DEST"
	echo
	cd "$DEST"
	( [ -f deps ] && . deps )
}

function mainuse() {
	local LIB

	for LIB in $*
	do
		if [ -f "$BASHELOR_PATH/$LIB" ]
		then
			function use() {
				BASHELOR_PATH="$(dirname "$BASHELOR_VENDOR_DIRECTORY/$LIB")/$BASHELOR_VENDOR_DIRECTORY" mainuse $*
			}

			BASHELOR_CURRENT_DIR=$(dirname "$BASHELOR_PATH/$LIB")
			. "$BASHELOR_PATH/$LIB"

			function use() {
				mainuse $*
			}
		else
			error "$LIB does not exist"

			exit 2
		fi
	done
}

if [ "$(type -t use 2> /dev/null)" != "function" ]
then
	function use() {
		mainuse $*
	}
fi

function reluse() {
	local LIB

	for LIB in $*
	do
		if [ -f "$BASHELOR_CURRENT_DIR/$LIB" ]
		then
			. "$BASHELOR_CURRENT_DIR/$LIB"
		else
			error "$LIB does not exist"

			exit 2
		fi
	done
}

if [ "$1" = "install" ]
then
	if [ -f deps ]
	then
		. deps
	else
		error "Nos deps file found in $(pwd)"

		exit 2
	fi

	[ "$2" != "inline" ] && exit 0
fi
