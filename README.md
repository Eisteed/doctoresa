**Télécharger ou copier le script** à l'emplacement de votre choix (exemple : /home/user/doctoresa.sh)

wget doctoresa.sh https://raw.githubusercontent.com/Eisteed/doctoresa/refs/heads/main/doctoresa.sh


**Rendre le script executable :**

chmod +x doctoresa.sh


**Script bash à lancer avec deux arguments**

1: L'url de la reservation (rendez vous sur doctolib, trouver votre medecin / spécialiste, aller sur sa page, cliquer sur prendre rendez vous, choisir un acte si besoin, lorsque la page affiche pas de reservation disponible copier l'url.)

2: Votre mail pour recevoir la notification


**Exemple (url doctolib non valide juste pour l'exemple)**

doctoresa.sh "https://www.doctolib.fr/medecin-generaliste/paris/**********" "exemple@mail.com"

Vous pouvez ensuite rentrer cette command en cron job pour être executer toutes les minutes / 10 minutes par exemple

crontab -e
*/5 * * * * /home/user/doctoresa.sh "" "" >/dev/null 2>&1

Pour executer la vérification toutes les 5 minutes.


**Si une reservation est disponible un mail est envoyé, par la suite la vérification continue mais un mail ne sera renvoyé à nouveau que au bout de 3h (modifiable dans le script variable DELAY)**
