package main

import (
	"log"
	"net/http"
)

func main() {
	initDB()

	r := setupRouter()

	log.Println("Server started at http://localhost:8081")
	err := http.ListenAndServe(":8081", r)
	if err != nil {
		log.Fatal("ListenAndServe error:", err)
	}
}
