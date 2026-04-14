Dans IntelliJ IDEA, le plus simple est d’utiliser Find in Files avec une regex.

Ouvre la recherche globale avec Ctrl + Shift + F sur Windows/Linux, ou Cmd + Shift + F sur Mac.
Coche Regex.
Mets une expression comme celle-ci pour chercher des IPv4 :
\b(?:\d{1,3}\.){3}\d{1,3}\b

Ça trouve des formes du type 192.168.1.10, 10.0.0.1, etc.
