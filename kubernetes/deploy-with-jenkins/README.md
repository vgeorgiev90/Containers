## Prerequesites
## kubernetes persistent volume with name: web-pod-scripts , with content deploy-and-start.sh, start.sh scripts
## Jenkins installed , plugins: parameterized trigger, Kubernetes Continuous Deploy Plugin
## Separate user in kubernetes and generated kube-config file for jenkins to use (default namespace name: deploy)
## 1 - job: pvc-deploy
##   - params: deploy_web , deploy_mysql , domain, mysql_user, mysql_pass, mysql_db
##   - exec: deploy-pvc.sh ${deploy_web} ${deploy_mysql}
##   - post: trigger param build on other project (kube-deploy) with current build params
## 2 - job: kube-deploy
##   - params: deploy_web , deploy_mysql , domain, mysql_user, mysql_pass, mysql_db
##   - exec: deploy to kubernetes (template deploy-wordpress.yml)
##   - post: pre-warm.sh $deploy_web $deploy_mysql $mysql_db $mysql_user $mysql_pass $domain
