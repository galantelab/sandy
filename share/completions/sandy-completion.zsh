#compdef sandy

#
# Rudimentary Zsh completion definition for sandy
#

_sandy_database_option() {
	sandy ${@} | awk 'NR>3 && /^\|/ {print $2}'
}

_sandy_help() {
	local ret=1
	local cmd=$words[3]
	local -a args

	if ((CURRENT == 3)); then
		args+=(
			'2:command:((
				quality:manage\ quality\ profile\ database
				expression:manage\ expression-matrix\ database
				variation:manage\ genomic\ variation\ database
				genome:simulate\ genome\ sequencing
				transcriptome:simulate\ transcriptome\ sequencing
			))'
		)
	else
		case $cmd in
			quality|expression|variation)
				args+=(
					"3:command:((
						add:add\ a\ new\ $cmd\ to\ database
						dump:dump\ $cmd\ from\ database
						remove:remove\ user\ $cmd\ from\ database
						restore:restore\ the\ database
					))"
				)
		esac
	fi

	_arguments -w -s -S $args[@] && ret=0
	return ret
}

_sandy_database() {
	local ret=1
	local cmd=$words[2]
	local subcmd=$words[3]
	local -a args

	if ((CURRENT == 3)); then
		args+=(
			"2:command:((
				add:add\ a\ new\ $cmd\ to\ database
				dump:dump\ $cmd\ from\ database
				remove:remove\ user\ $cmd\ from\ database
				restore:restore\ the\ database
			))"
			{'(--help)-h','(-h)--help'}'[brief help message]'
			{'(--man)-u','(-u)--man'}'[full documentation]'
		)
	else
		args+=(
			{'(--help)-h','(-h)--help'}'[brief help message]'
			{'(--man)-u','(-u)--man'}'[full documentation]'
			{'(--verbose)-v','(-v)--verbose'}'[print log messages]'
			{'(--source)-s','(-s)--source'}"[$cmd source detail for database]:str:"
		)
		case $subcmd in
			add)
				args+=(
					'*:files:_files'
				)
				case $cmd in
					quality)
						args+=(
							{'(--quality-profile)-q','(-q)--quality-profile'}'[a quality-profile name]:str:'
							{'(--sequencing-error)-e','(-e)--sequencing-error'}'[sequencing error rate]:float:'
							{'(--single-molecule)-1','(-1)--single-molecule'}'[constraint to single-molecule sequencing]'
						)
						;;
					expression)
						args+=(
							{'(--expression-matrix)-f','(-f)--expression-matrix'}'[an expression-matrix name]:str:'
						)
						;;
					variation)
						args+=(
							{'(--genomic-variation)-a','(-a)--genomic-variation'}'[a genomic variation name]:str:'
						)
						;;
				esac
				;;
			remove|dump)
				args+=(
					"3:command:((
						$(_sandy_database_option $cmd)
					))"
				)
				;;
		esac
	fi

	_arguments -w -s -S $args[@] && ret=0
	return ret
}

_sandy_simulation() {
	local ret=1
	local cmd=$words[2]
	local -a args

	args+=(
		{'(--help)-h','(-h)--help'}'[brief help message]'
		{'(--man)-u','(-u)--man'}'[full documentation]'
		{'(--verbose)-v','(-v)--verbose'}'[print log messages]'
		{'(--prefix)-p','(-p)--prefix'}'[prefix output]:str:'
		{'(--output-dir)-o','(-o)--output-dir'}'[output directory]:str:'
		{'(--output-format)-O','(-O)--output-format'}'[bam, sam, fastq.gz, fastq]:str:->format'
		{'(--join-paired-ends)-1','(-1)--join-paired-ends'}'[merge R1 and R2 outputs in one file]'
		{'(--compression-level)-x','(-x)--compression-level'}'[speed compression: "1" - compress faster, "9" - compress better]:int:->level'
		{'(--append-id)-i','(-i)--append-id'}'[append to the defined template id]:str:'
		{'(--id)-I','(-I)--id'}'[overlap the default template id]:str:'
		{'(--jobs)-j','(-j)--jobs'}'[number of jobs]:int:'
		{'(--seed)-s','(-s)--seed'}'[set the seed of the base generator]:int:'
		{'(--sequencing-type)-t','(-t)--sequencing-type'}'[single-end or paired-end reads]:str:(single-end paired-end)'
		{'(--quality-profile)-q','(-q)--quality-profile'}'[quality-profile from database]:str:->quality'
		{'(--sequencing-error)-e','(-e)--sequencing-error'}'[sequencing error rate for poisson]:float'
		{'(--read-mean)-m','(-m)--read-mean'}'[read mean size for poisson]:int:'
		{'(--read-stdd)-d','(-d)--read-stdd'}'[read standard deviation size for poisson]:int:'
		{'(--fragment-mean)-M','(-M)--fragment-mean'}'[the fragment mean size for paired-end reads]:int:'
		{'(--fragment-stdd)-D','(-D)--fragment-stdd'}'[the fragment standard deviation size for paired-end reads]:int:'
		'*:files:_files'
	)

	case $cmd in
		genome)
			args+=(
				{'(*--genomic-variation)*-a','(*-a)*--genomic-variation'}'[a list of genomic variation from database]:str:->variation'
				{'(*--genomic-variation-regex)*-A','(*-A)*--genomic-variation-regex'}'[a list of perl-like regex to match variations from database]:str:'
				{'(--coverage)-c','(-c)--coverage'}'[fastq-file coverage]:float:'
			)
			;;
		transcriptome)
			args+=(
				{'(--expression-matrix)-f','(-f)--expression-matrix'}'[an expression-matrix entry from database]:str:->expression'
				{'(--number-of-reads)-n','(-n)--number-of-reads'}'[set the number of reads]:int:'
			)
			;;
	esac

	case $state in
		variation)
			_values -s ',' 'variation' $(_sandy_database_option 'variation')
			;;
		expression)
			_values  'expression' $(_sandy_database_option 'expression')
			;;
		quality)
			_values 'quality' $(_sandy_database_option 'quality')
			;;
		level)
			_values 'compression' $(seq 9)
			;;
		format)
			_values 'format' 'bam' 'sam' 'fastq.gz' 'fastq'
	esac

	_arguments -w -s -S $args[@] && ret=0
	return ret
}

_sandy() {
	local ret=1
	local -a args

	if ((CURRENT == 2)); then
		args+=(
			'1:command:((
				help:show\ application\ or\ command-specific\ help
				man:show\ application\ or\ command-specific\ documentation
				version:print\ the\ current\ version
				citation:export\ citation\ in\ BibTeX\ format
				quality:manage\ quality\ profile\ database
				expression:manage\ expression-matrix\ database
				variation:manage\ genomic\ variation\ database
				genome:simulate\ genome\ sequencing
				transcriptome:simulate\ transcriptome\ sequencing
			))'
			{'(--help)-h','(-h)--help'}'[brief help message]'
			{'(--man)-u','(-u)--man'}'[full documentation]'
		)
		_arguments $args[@] && ret=0
		return ret
	else
		local subcmd
		case $words[2] in
			help|man)
				subcmd="_sandy_help"
				;;
			quality|expression|variation)
				subcmd="_sandy_database"
				;;
			genome|transcriptome)
				subcmd="_sandy_simulation"
				;;
		esac
		_call_function ret $subcmd
		return ret
	fi
}

_sandy
