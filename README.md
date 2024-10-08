**1. Installer swaks**

Debian / Ubuntu
```
sudo apt-get install swaks
```

Centos
```
sudo yum install swaks
``` 

**2. Installer le script** à l'emplacement de votre choix 

```
git clone https://github.com/Eisteed/doctoresa
```


**3. Rendre les scripts executables :**

```
chmod +x ./doctoresa/doctoresa.sh
chmod +x ./doctoresa/curl_chrome110
chmod +x ./doctoresa/curl-impersonate-chrome
```

**4. Editer le script avec vos informations SMTP**

Lignes 13
```
# SMTP server details
SMTP_SERVER="mail.example.com"
USERNAME="mailquienvoie@example.com"
PASSWORD="motdepasse"
FROM="mailquienvoie@example.com"
```
**5. Executer le script avec ces arguments (doctoresa.sh url mail)**

1: L'url de la reservation (rendez vous sur doctolib, trouver votre medecin / spécialiste, aller sur sa page, cliquer sur prendre rendez vous, choisir un acte si besoin, lorsque la page affiche pas de reservation disponible copier l'url.)

2: Votre mail pour recevoir la notification


**Exemple (url doctolib non valide juste pour l'exemple)**

```
doctoresa.sh "https://www.doctolib.fr/medecin-generaliste/paris/**********" "exemple@mail.com"
```

**6. Cron job pour être executer toutes les 10 minutes par exemple**

crontab -e
```
*/10 * * * * /home/user/doctoresa.sh "remplacerparurldoctolib" "mailquirecois" >/dev/null 2>&1
```

**Si une reservation est disponible un mail est envoyé, par la suite la vérification continue mais un mail ne sera renvoyé à nouveau que au bout de 3h (modifiable dans le script variable DELAY)**
