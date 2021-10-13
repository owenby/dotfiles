(setq org-agenda-file "FILENAME HERE")
(setq org-capture-bookmark nil)
(setq org-default-notes-file (concat org-directory "agenda.org"))
(setq org-capture-templates
	  '(
		("l" "List of")
		("ll" "Library"
		 entry
		 (file "list/library.org")
		 "* %^{Status|HOME|BORROWED|LENT|GONE} %^{Title}\n\n** Info\n\n:AUTHOR: %^{Authors}\n:SORT: %^{Author Sort}\n:SERIES: %^{Series}\n:NUMBER: %^{Number in series}\n:PUBL: %^{Publisher}\n:LANG: %^{Language|Português|English|Español}\n:CONDITION: %^{Condition|New|Good|Medium|Worn|Fucked}\n:SHELF: %^{Shelf|Fiction|Non-fiction|Manga|Other}\n:SOURCE: %^{Source|Gift:|Purchase:} %?\n\n** Log\n\n")

		("la" "Anime"
		 entry
		 (file "list/anime.org")
		 "* %^{Status|PLAN|WATCHING|SEEN|DROPPED} %^{Title}\n:TIME: %t\n:STUDIO: %^{Studio}\n:DIRECTOR:\n:YEAR: %^{Year}\n:SEASON: %^{Season}\n")
		
		("h" "Home maintenance"
		 entry
		 (file "agenda/home.org")
		 "* TODO %^{ITEM}\n%?\nDEADLINE: %^T")))
