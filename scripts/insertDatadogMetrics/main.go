package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"os"
	"time"

	datadog "github.com/DataDog/datadog-api-client-go/api/v2/datadog"
)

type Metric struct {
	Name string
	Type string
}

func main() {
	// Configuração do cliente
	configuration := datadog.NewConfiguration()
	configuration.Host = "api.us5.datadoghq.com"
	// configuration.APIKey = map[string]datadog.APIKey{
	// 	"apiKeyAuth": {
	// 		Key: os.Getenv("DD_API_KEY"), // Defina a chave de API no ambiente
	// 	},
	// }
	// configuration.AppKey = map[string]datadog.APIKey{
	// 	"appKeyAuth": {
	// 		Key: os.Getenv("DD_APP_KEY"), // Defina a chave de aplicação no ambiente
	// 	},
	// }
	apiClient := datadog.NewAPIClient(configuration)
	ctx := datadog.NewDefaultContext(context.Background())

	ctx = context.WithValue(ctx, datadog.ContextAPIKeys, map[string]datadog.APIKey{
		"ApiKeyAuth": {
			Key: os.Getenv("DD_API_KEY"),
		},
		"AppKeyAuth": {
			Key: os.Getenv("DD_APP_KEY"),
		},
	})

	// Definindo o número de pontos e o intervalo entre eles
	numberOfPoints := 20              // Número máximo de pontos
	pointInterval := 30 * time.Minute // Intervalo entre pontos de coleta

	// Calculando o total necessário para identificar o intervalo seguro
	requiredInterval := time.Duration(numberOfPoints-1) * pointInterval

	// Calculando intervalo de tempo seguro
	now := time.Now()
	minInterval := requiredInterval + 30*time.Minute // Tempo desde o primeiro ponto + 30 minutos extra
	maxInterval := 48 * time.Hour                    // 48 horas atrás como limite máximo

	// Ajusta o início entre dois dias e (4 horas e 30 minutos + 30 minutos) atrás
	var startTime time.Time
	if now.Add(-minInterval).Before(now.Add(-maxInterval)) {
		startTime = now.Add(-maxInterval)
	} else {
		startTime = now.Add(-minInterval)
	}

	metrics := []Metric{
		{Name: "sentinel.state.incluidos.total", Type: "INICIAL"},
		{Name: "sentinel.state.pendente_efetivacao.total", Type: "OPCIONAL_INTERMEDIATE"},
		{Name: "sentinel.state.em_processamento.total", Type: "INTERMEDIATE"},
		{Name: "sentinel.state.efetivados.total", Type: "FINAL"},
		{Name: "sentinel.state.cancelados.total", Type: "FINAL"},
		{Name: "sentinel.state.rejeitados.total", Type: "FINAL"},
		{Name: "sentinel.state.aprovados.total", Type: "INTERMEDIATE"},
		{Name: "sentinel.state.aguardando.total", Type: "OPCIONAL_INTERMEDIATE"},
		{Name: "sentinel.state.revisao.total", Type: "INTERMEDIATE"},
		{Name: "sentinel.state.finalizado.total", Type: "FINAL"},
	}

	log.Println("Iniciando o envio de métricas...")

	var seriesList []datadog.MetricSeries

	// Loop para preparar dados para cada métrica
	for _, metric := range metrics {
		log.Printf("Preparando dados para a métrica: %s\n", metric.Name)
		var points []datadog.MetricPoint
		timestamps := []time.Time{}
		for i := 0; i < numberOfPoints; i++ {
			timestamp := startTime.Add(time.Duration(i) * pointInterval)
			if timestamp.After(now) {
				break
			}
			timestamps = append(timestamps, timestamp)
		}

		for _, timestamp := range timestamps {
			value := float64(rand.Intn(100)) // Valor simulado

			// Cria o ponto
			point := datadog.MetricPoint{
				Timestamp: datadog.PtrInt64(timestamp.Unix()),
				Value:     datadog.PtrFloat64(value),
			}
			points = append(points, point)
		}

		// Cria a série de métricas
		metricSeries := datadog.MetricSeries{
			Metric: metric.Name,
			Points: points,
			Tags:   []string{fmt.Sprintf("category:%s", metric.Type)},
			Type:   datadog.METRICINTAKETYPE_COUNT.Ptr(),
		}
		seriesList = append(seriesList, metricSeries)
	}

	// Cria a carga de métricas
	payload := datadog.MetricPayload{
		Series: seriesList,
	}

	// Opções adicionais (se necessário)
	options := *datadog.NewSubmitMetricsOptionalParameters()

	// Envia as métricas
	resp, r, err := apiClient.MetricsApi.SubmitMetrics(ctx, payload, options)
	if err != nil {
		log.Printf("Erro ao enviar métricas: %v\n", err)
		if r != nil {
			log.Printf("Resposta completa: %v\n", r)
		}
	} else {
		log.Printf("Métricas enviadas com sucesso. Resposta da API: %v\n", resp)
	}

	log.Println("Envio de métricas concluído.")
}
