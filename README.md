# IMT-OpenStack-Courses

Dépot github de [Corentin CLaudel](mailto:corentin.claudel@etu.mines-ales.fr) dans le cadre du cours d'OpenStack dispensé au sein de l'IMT Mines Alès

Pour les scripts [Ansible](./ansible/), [CLI](./cli/) et [Terraform](./terraform/), le but est:
- Admin:
    - Créer un projet
    - Créer un utilisateur
    - Ajouter l'utilsiateur en tant que membre du projet
- Infra
    - Créer un réseau privé
    - Connecter le réseau privé au réseau public
    - Créer des règles de sécurités aui autorise: ``http``,``https`` et le ping
    - Ajouter une clé ssh dans le projet
    - Démarrer une VM
    - Attribuer une IP flottante a cette VM

Pour le Script [Heat](./heat/), le but est de déployer un wordpress avec une base de donnée SQL, un réseau privé, un load balancer (Octavia), mettre les bons groupes de sécurités
