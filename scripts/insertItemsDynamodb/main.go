package main

import (
	"crypto/rand"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"math/big"
	"os"
	"os/exec"
	"time"

	"github.com/google/uuid"
)

type Status struct {
	Name string
	Type string
}

// a CRIAÇÃO DOS ESTADOS SEGUE A ORDEM DO ARRAY
var statuses = []Status{
	{"REQUESTED", "INITIAL"},
	{"ANALYZING", "INTERMEDIATE"},
	{"PENDING_APPROVAL", "OPCIONAL_INTERMEDIATE"},
	{"COMPLETED", "FINAL"},
	{"FAILED", "FINAL"},
	{"CANCELLED", "FINAL"},
}

type PutRequest struct {
	PutRequest struct {
		Item map[string]map[string]string `json:"Item"`
	} `json:"PutRequest"`
}

func main() {
	numItems := flag.Int("numItems", 1, "Number of scenarios to generate")
	flag.Parse()

	var requests []PutRequest

	for i := 0; i < *numItems; i++ {
		generateRequests(&requests)
	}

	tableName := "sentinel-tb"
	batchRequest := map[string][]PutRequest{
		tableName: requests,
	}

	jsonData, err := json.Marshal(batchRequest)
	if err != nil {
		log.Fatalf("Error marshalling to JSON: %v", err)
	}

	fmt.Println(string(jsonData))

	file, err := os.CreateTemp("", "dynamodb-*.json")
	if err != nil {
		log.Fatalf("Failed to create temp file: %v", err)
	}
	defer os.Remove(file.Name())

	if _, err = file.Write(jsonData); err != nil {
		log.Fatalf("Failed to write JSON to temp file: %v", err)
	}
	file.Close()

	cmd := exec.Command("aws", "dynamodb", "batch-write-item", "--request-items", "file://"+file.Name())
	output, err := cmd.CombinedOutput()
	if err != nil {
		log.Fatalf("Error executing AWS CLI command: %v\nOutput: %s", err, output)
	}
	fmt.Printf("AWS CLI output: %s\n", output)
}

func generateRequests(requests *[]PutRequest) {
	var currentJourneyID string
	var lastTimestamp time.Time

	for _, status := range statuses {
		if status.Type == "INITIAL" {
			// Gerar um novo IdJornada para a nova jornada
			currentJourneyID = generateUUID()
			// Inicializar o timestamp a partir do tempo atual para o primeiro status
			lastTimestamp = time.Now()
		}

		if status.Type == "OPCIONAL_INTERMEDIATE" && shouldSkipOptional() {
			continue
		}

		// Gerar um novo timestamp incremental para manter a ordem temporal correta
		if !lastTimestamp.IsZero() {
			// Incrementar o timestamp em 1 hora para cada status subsequente
			lastTimestamp = lastTimestamp.Add(1 * time.Hour)
		}

		// Concatenar o UUID base mais o nome do status para garantir singularidade no Pk
		uniquePk := fmt.Sprintf("%s:%s", currentJourneyID, status.Name)

		putRequest := PutRequest{}
		putRequest.PutRequest.Item = map[string]map[string]string{
			"Pk":          {"S": uniquePk},
			"IdJornada":   {"S": currentJourneyID},
			"IdTransacao": {"S": generateUniqueTransactionID()},
			"StatusNome":  {"S": status.Name},
			"DataHora":    {"S": lastTimestamp.Format(time.RFC3339)}, // Usar o timestamp incremental
			"Descricao":   {"S": generateLoremIpsum()},
		}

		*requests = append(*requests, putRequest)

		if status.Type == "FINAL" {
			break
		}
	}
}
func shouldSkipOptional() bool {
	nBig, err := rand.Int(rand.Reader, big.NewInt(2))
	if err != nil {
		log.Fatalf("Erro gerando número aleatório: %v", err)
	}

	return nBig.Int64() == 0
}

func generateUUID() string {
	uuidObj, err := uuid.NewUUID()
	if err != nil {
		log.Fatalf("Error generating UUID: %v", err)
	}
	return uuidObj.String()
}

func generateUniqueTransactionID() string {
	return uuid.New().String()
}

func generateRandomDatetime() string {
	now := time.Now()

	maxHours := big.NewInt(24)
	randomHours, err := rand.Int(rand.Reader, maxHours)
	if err != nil {
		log.Fatalf("Erro gerando número aleatório: %v", err)
	}

	randomTime := now.Add(time.Duration(-randomHours.Int64()) * time.Hour)

	return randomTime.Format(time.RFC3339)
}

func generateLoremIpsum() string {
	max := big.NewInt(1000000)

	randomSuffix, err := rand.Int(rand.Reader, max)
	if err != nil {
		log.Fatalf("Erro gerando número aleatório: %v", err)
	}

	return fmt.Sprintf("Description random: %d", randomSuffix)
}
