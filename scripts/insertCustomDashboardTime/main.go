package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
)

// Função para carregar variáveis de ambiente de um arquivo .env
func loadEnvFile() error {
	file, err := os.Open("./../../.env")
	if err != nil {
		return err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.TrimSpace(line) == "" || strings.HasPrefix(line, "#") {
			continue
		}

		parts := strings.SplitN(line, "=", 2)
		if len(parts) != 2 {
			continue
		}

		key := strings.TrimSpace(parts[0])
		value := strings.TrimSpace(parts[1])
		os.Setenv(key, value)
	}

	return scanner.Err()
}

func main() {
	err := loadEnvFile()
	if err != nil {
		log.Fatalf("Erro ao carregar o arquivo .env: %v", err)
	}

	// Recupera as chaves do Datadog do ambiente
	apiKey := os.Getenv("DATADOG_API_KEY")
	appKey := os.Getenv("DATADOG_APP_KEY")

	if apiKey == "" || appKey == "" {
		log.Fatal("As chaves do Datadog não foram encontradas no ambiente")
	}

	fmt.Printf("Datadog API Key: %s\n", apiKey)
	fmt.Printf("Datadog Application Key: %s\n", appKey)

	dashboardID := "YOUR_DASHBOARD_ID"

	url := fmt.Sprintf("https://api.datadoghq.com/api/v1/dashboard/%s", dashboardID)

	// Define o payload para atualizar o intervalo de tempo
	data := map[string]interface{}{
		"time": map[string]interface{}{
			"live_span": "custom",
			"start":     "2023-09-19T03:32:00Z",
			"end":       "2023-09-19T05:43:00Z",
		},
	}

	payload, err := json.Marshal(data)
	if err != nil {
		fmt.Println("Error marshalling JSON:", err)
		os.Exit(1)
	}

	fmt.Println("Payload JSON criado com sucesso.")

	// Cria a requisição HTTP
	req, err := http.NewRequest("PATCH", url, bytes.NewBuffer(payload))
	if err != nil {
		fmt.Println("Error creating request:", err)
		os.Exit(1)
	}

	// Define os headers
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("DD-API-KEY", apiKey)
	req.Header.Set("DD-APPLICATION-KEY", appKey)

	fmt.Println("Requisição HTTP criada com sucesso.")

	// Executa a requisição
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Error making request:", err)
		os.Exit(1)
	}
	defer resp.Body.Close()

	fmt.Println("Requisição enviada, aguardando resposta...")

	// Lê a resposta
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Error reading response:", err)
		os.Exit(1)
	}

	// Verifica o status da resposta
	if resp.StatusCode == http.StatusOK {
		fmt.Println("Dashboard time updated successfully.")
	} else {
		fmt.Printf("Failed to update dashboard time: %s\n", body)
	}

	fmt.Println("Processo concluído.")
}
