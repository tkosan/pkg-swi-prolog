/*  Part of SWI-Prolog

    Author:        Jan Wielemaker
    E-mail:        J.Wielemaker@cs.vu.nl
    WWW:           http://www.swi-prolog.org
    Copyright (C): 2011, VU University Amsterdam

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.
*/

:- module(prolog_history,
	  [ prolog_history/1
	  ]).
:- use_module(library(base32)).

/** <module> Per-directory persistent commandline history

This module implements  persistency  of   the  commandline  history over
Prolog sessions on Prolog  installations  that   are  based  on  the GNU
readline library (default for the development version on Unix systems).

This is

*/

%%	history_directory(-Dir) is semidet.
%
%	Dir is the directory where   the per-directory history databases
%	are stored.

history_directory(Dir) :-
	absolute_file_name(user_profile('.swipl-dir-history'),
			   Dir,
			   [ access(write),
			     file_type(directory),
			     file_errors(fail)
			   ]), !.
history_directory(Dir) :-
	absolute_file_name(user_profile('.'),
			   Home,
			   [ access(write),
			     file_type(directory),
			     file_errors(fail)
			   ]),
	atom_concat(Home, '/.swipl-dir-history', Dir),
	(   exists_directory(Dir)
	->  fail
	;   make_directory(Dir)
	).

%%	dir_history_file(+Dir, -File) is det.
%%	dir_history_file(?Dir, ?File) is nondet.
%
%	File is the history file for a Prolog session running in Dir.

dir_history_file(Dir, File) :-
	nonvar(Dir), !,
	history_directory(Base),
	absolute_file_name(Dir, Path),
	base32(Path, Encoded),
	atomic_list_concat([Base, Encoded], /, File).
dir_history_file(Dir, File) :-
	history_directory(HDir),
	directory_files(HDir, Files),
	member(Base32, Files),
	base32(Dir, Base32),
	atomic_list_concat([Dir, Base32], /, File).


%%	prolog_history(+Action) is det.
%
%	Execute Action on the history. Currently only suppors the action
%	=enable= to enable save and restore   of  the Prolog commandline
%	history per-directory.

:- if(current_predicate(rl_read_history/1)).
prolog_history(enable) :- !,
	dir_history_file('.', File),
	(   exists_file(File)
	->  rl_read_history(File)
	;   true
	),
	at_halt(rl_write_history(File)).
:- endif.
prolog_history(_).
