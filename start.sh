# Executa o Terraform apply  
terraform apply -auto-approve  

# Verifica se o Terraform apply foi bem-sucedido  
if [ $? -eq 0 ]; then  
    # Recupera o ID do dashboard  
    DASHBOARD_ID=$(terraform output -raw dashboard_id)  
    echo "DASHBOARD_ID: $DASHBOARD_ID"  

    # Executa o binário Go com o ID do dashboard como argumento  
    ./scripts/insertCustomDashboardTime $DASHBOARD_ID  
else  
    echo "Terraform apply failed. Exiting."  
    exit 1  
fi