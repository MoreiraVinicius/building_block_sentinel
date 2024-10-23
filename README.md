# Sentinel - Monitoramento de maquina de estado
Sistema focado em criar uma maneira padronizada de monitorar a maquina de estado de uma ou mais jornadas. Seja fornecendo um Dataviz para consumo humano ou com a democratização das metricas para consumo de aplicações.
## Conhecimentos prévios
Esse projeto serve de referencia, então pode ter multiplas implementações e todas elas serão listadas aqui.
-  __./aws-table__ 
   -  Focado no armazenamento e exploração dos recursos do serviço Amazon DynamoDB
-  [Em fase de planejamento] __./aws-timeseries__
   -  Focado em armazenar e explorar os recursos do serviço Amazon Timestream 

### Scripts
A pasta __./scripts__ serve para armazenar codigo fonte e binarios utilitarios para testar e montar casos de usos especificos do sistema.
## Objetivo
O objetivo final de fornecer uma maneira simplificada e padronizada de consumir um Dashboard (e/ou metricas) de como a   

## Datadog
Iniciando:
```bash
terraform init
```

Planejar a infraestrutura:
```bash
terraform plan -target=module.sentinel_datadog
```

Aplicar a infraestrutura:
```bash
terraform apply -target=module.sentinel_datadog
```  

### Metricas
#### Nomeação
**Padrão**
- sentinel.type.**{nome_tipo}**.count
- sentinel.state.**{nome_status}**.count

**Exemplos** \
sentinel.state.incluido.count \
sentinel.state.pendentes_efetivacao.count \
sentinel.state.em_processamento.count \
sentinel.state.efetivado.count \
sentinel.state.cancelado.count \
sentinel.state.rejeitado.count

#### No contexto do Datadog:

_count_: Indica o número de ocorrências de um evento desde o último envio da métrica. É uma contagem incremental que o Datadog utiliza para calcular taxas e tendências ao longo do tempo. Por exemplo, ao reportar api.errors.500.count, você está informando quantos erros 500 ocorreram desde o último envio dessa métrica.