#!/usr/bin/env bash

_sandy_short_option() {
	sandy ${@} -h | awk '/^ +-/ {print substr($1, 0, 2)}'
}

_sandy_long_option() {
	sandy ${@} -h | awk '/--/ {print $2}'
}

_sandy_database_option() {
	sandy ${@} | awk 'NR>3 && /^\|/ {print $2}'
}

_sandy_database() {
	local cmd scmd cur

	cmd=${1}; shift
	scmd=${COMP_WORDS[2]}
	cur=${COMP_WORDS[COMP_CWORD]}

	if [ ${COMP_CWORD} = 2 ]; then
		COMPREPLY=($(compgen -W "add dump remove restore" -- ${cur}))
	else
		case ${cur} in
			--*)
				COMPREPLY=($(compgen -W "$(_sandy_long_option ${cmd} ${scmd})" -- ${cur}))
				;;
			-*)
				COMPREPLY=($(compgen -W "$(_sandy_short_option ${cmd} ${scmd})" -- ${cur}))
				;;
			*)
				case ${scmd} in
					add)
						COMPREPLY=($(compgen -f ls -- ${cur}))
						;;
					remove|dump)
						COMPREPLY=($(compgen -W "$(_sandy_database_option ${cmd})" -- ${cur}))
						;;
					*)
						COMPREPLY=()
						;;
				esac
				;;
		esac
	fi
}

_sandy_simulation() {
	local cmd cur prev

	cmd=${1}; shift
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case ${prev} in
		--structural-variation|-a)
			if [ ${cmd} = genome ]; then
				COMPREPLY=($(compgen -W "$(_sandy_database_option variation)" -- ${cur}))
			fi
			;;
		--expression-matrix|-f)
			if [ ${cmd} = transcriptome ]; then
				COMPREPLY=($(compgen -W "$(_sandy_database_option expression)" -- ${cur}))
			fi
			;;
		--quality-profile|-q)
			COMPREPLY=($(compgen -W "poisson $(_sandy_database_option quality)" -- ${cur}))
			;;
		--sequencing-type|-t)
			COMPREPLY=($(compgen -W "single-end paired-end" -- ${cur}))
			;;
		*)
			case ${cur} in
				--*)
					COMPREPLY=($(compgen -W "$(_sandy_long_option ${cmd})" -- ${cur}))
					;;
				-*)
					COMPREPLY=($(compgen -W "$(_sandy_short_option ${cmd})" -- ${cur}))
					;;
				*)
					COMPREPLY=($(compgen -f ls -- ${cur}))
					;;
			esac
			;;
	esac
}

_sandy() {
	local cmd cur

	cmd=${COMP_WORDS[1]}
	cur=${COMP_WORDS[COMP_CWORD]}

	if [ ${COMP_CWORD} = 1 ]; then
		COMPREPLY=($(compgen -W "help man version citation quality expression variation genome transcriptome" -- ${cur}))
	else
		case ${cmd} in
			help|man)
				COMPREPLY=($(compgen -W "quality expression variation genome transcriptome" -- ${cur}))
				;;
			quality|expression|variation)
				_sandy_database ${cmd}
				;;
			genome|transcriptome)
				_sandy_simulation ${cmd}
				;;
			*)
				COMPREPLY=()
				;;
		esac
	fi
}

complete -F _sandy sandy
