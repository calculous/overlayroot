# Add this to .bashrc
# This will prompt a ⚠️  sign if / is writeable

HAS_OVERLAY=$(df / | grep overlay)
if [ ! -z "${IMCHROOTED}" ]; then
        PS1="[⚠️ ] $PS1"
elif [ ! "$HAS_OVERLAY" ]; then
	PS1="[⚠️ ] $PS1"
fi
